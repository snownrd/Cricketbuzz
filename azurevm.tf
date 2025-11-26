#################################################################################################
#Create a VM in azure                                                                           #
#This Terraform script creates an Azure VM along with necessary resources such as:-             #
# a resource group, virtual network, subnet, network security group, and network interface.     #
#################################################################################################

provider "azurerm" {
    features {}
    subscription_id = "your_sub_id"
    tenant_id = "your_tenant_id"
}

########################
# Create Resource group
########################

resource "azurerm_resource_group" "rg" {
    name = "TitanResourceGroup"
    location = "centralindia"
}

########################
# Create Virtual Network
########################
resource "azurerm_virtual_network" "vnet" {
    name = "TitanVNet"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}
########################
# Create Subnet
########################
resource "azurerm_subnet" "Subnet" {
    name = "TitanSubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.1.0/24"]
}
########################
# Create Network Security Group (NSG)
########################
resource "azurerm_network_security_group" "nsg" {
    name = "TitanNSG"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name = "AllowSSH"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

########################
# Create Network Interface
########################
resource "azurerm_network_interface" "nic" {
    name = "TitanNIC"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.Subnet.id
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id = azurerm_public_ip.pip.id
    }
}

########################
#attached NIC to NSG
########################
resource "azurerm_network_interface_security_group_association" "nsg_association" {
    network_interface_id = azurerm_network_interface.nic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

########################
#create Virtual Machine
########################
resource "azurerm_linux_virtual_machine" "vm" {
    name = "TitanVM"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_B1s"
    admin_username = "username"
    admin_password = "password"
    disable_password_authentication = "false"
    network_interface_ids = [azurerm_network_interface.nic.id]

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-minimal-jammy"
        sku       = "minimal-22_04-lts-gen2"
        version   = "latest"
    }
}
