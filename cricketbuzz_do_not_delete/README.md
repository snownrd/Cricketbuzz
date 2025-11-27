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
    TitanVM server_ip;

    root /var/www/Cricketbuzz;
    index index.html index.php;
}


Enable site:-
sudo ln -s /etc/nginx/sites-available/cricketbuzz /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx


====================================================
=====================================================
✅ Overall Architecture

GitHub → Jenkins → Docker → Kubernetes → Nginx
Two Jenkins pipelines:

Pipeline 1 (Test on VM): Pull latest code → Backup old repo → Deploy to /var/www → Test on port 8000.
Pipeline 2 (Production): Build Docker image → Push to registry → Deploy to Kubernetes → Expose on port 80.
✅ Step-by-Step Implementation

=====================================================
1.Jenkins Setup
=====================================================

Install required plugins:

GitHub Integration
Pipeline
Docker
Kubernetes


Configure GitHub Webhook:

Go to your GitHub repo → Settings → Webhooks → Add Jenkins URL (http://<jenkins-server>:8080/github-webhook/).
Select push events.

=================================
2. Pipeline 1: Test Deployment
=================================
Purpose: Pull latest code, backup old repo, deploy to /var/www, test on port 8000.
Jenkinsfile Example:
pipeline {
    agent any
    stages {
        stage('Pull Latest Code') {
            steps {
                git branch: 'main', url: 'https://github.com/snownrd/Cricketbuzz.git'
            }
        }
        stage('Backup Old Repo') {
            steps {
                sh 'cp -r /var/www/Cricketbuzz /var/www/Cricketbuzz_backup_$(date +%F-%T)'
            }
        }
        stage('Deploy to Test') {
            steps {
                sh 'cp -r * /var/www/Cricketbuzz'
                sh 'systemctl restart nginx'
            }
        }
    }
}

Configure Nginx to serve /var/www/Cricketbuzz on port 8000 (add a new server block in /etc/nginx/sites-available).

===========================
3. Pipeline 2: Docker + Kubernetes
===============================

Purpose: Build Docker image, push to registry, deploy on Kubernetes.
Jenkinsfile Example:
pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "yourdockerhubusername/cricketbuzz:${BUILD_NUMBER}"
    }
    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }
        stage('Push to Registry') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKER_TOKEN')]) {
                    sh 'echo $DOCKER_TOKEN | docker login -u yourdockerhubusername --password-stdin'
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/cricketbuzz cricketbuzz=$DOCKER_IMAGE
                kubectl rollout status deployment/cricketbuzz
                '''
            }
        }
    }
}

=======================
4. Kubernetes Setup
=======================
Create Deployment and Service YAML:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cricketbuzz
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cricketbuzz
  template:
    metadata:
      labels:
        app: cricketbuzz
    spec:
      containers:
      - name: cricketbuzz
        image: yourdockerhubusername/cricketbuzz:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: cricketbuzz-service
spec:
  type: LoadBalancer
  selector:
    app: cricketbuzz
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

===
Apply:
kubectl apply -f cricketbuzz.yaml
=======
===============================================
✅ Flow
Developer pushes code → GitHub webhook triggers Jenkins.
Pipeline 1 runs → Updates /var/www → Tests on port 8000.
If successful → Pipeline 2 runs → Builds Docker image → Pushes → Deploys on Kubernetes → Accessible on port 80.
===============================================

