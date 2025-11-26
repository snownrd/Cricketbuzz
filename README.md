# Cricketbuzz
Created VM by using terraform
on vm:-
1.Prepare Your Ubuntu VM:-
sudo apt update && sudo apt upgrade -y
2.Install essential tools:-
sudo apt install git curl wget unzip -y
3. Clone Your Project
cd /var/www

git clone https://github.com/snownrd/Cricketbuzz.git
cd Cricketbuzz

4. Install Web Server (Nginx or Apache)
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

5. Configure Nginx to serve your project
sudo vi /etc/nginx/sites-available/cricketbuzz

==>##add server ip and working dir##
server {
    listen 8000;
    TitanVM 4.240.125.11;

    root /var/www/Cricketbuzz;
    index index.html index.php;
}


Enable site:-
sudo ln -s /etc/nginx/sites-available/cricketbuzz /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

