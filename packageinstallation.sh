#!/bin/bash
###############################################################################
#This script will install packages:- git, curl, wget, unzip, nginx, jenkins   #
#also This will configure all the packages as well                            #
###############################################################################

# Exit immediately if a command fails
set -e

echo "Updating and upgrading system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing essential tools..."
sudo apt install git curl wget unzip -y

echo "Cloning the project repository..."
cd /var/www || { echo "Directory /var/www not found"; exit 1; }
sudo git clone https://github.com/snownrd/Cricketbuzz.git
cd Cricketbuzz || { echo "Failed to enter Cricketbuzz directory"; exit 1; }

echo "Installing Nginx web server..."
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

echo "Configuring Nginx for Cricketbuzz..."
NGINX_CONF="/etc/nginx/sites-available/cricketbuzz"
sudo bash -c "cat > $NGINX_CONF" <<EOL
server {
    listen 80;
    server_name 4.240.125.11;

    root /var/www/Cricketbuzz;
    index index.html index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

echo "Enabling Cricketbuzz site..."
sudo ln -s /etc/nginx/sites-available/cricketbuzz /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

echo "Installing Jenkins..."
# Add Jenkins repository and key
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update and install Jenkins
sudo apt update
sudo apt install openjdk-17-jdk -y
sudo apt install jenkins -y

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Setup completed successfully!"
echo "Jenkins is running on port 8080. Access it via: http://<your-server-ip>:8080"
