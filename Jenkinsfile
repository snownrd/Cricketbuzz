
pipeline {
    agent any

    environment {
        DEPLOY_PATH = "/var/www/Cricketbuzz"
        BACKUP_PATH = "/var/www/Cricketbuzz_backup"
    }

    stages {
        stage('Backup Current Code') {
            steps {
                script {
                    sh '''
                    echo "Backing up current code..."
                    TIMESTAMP=$(date +%F-%H-%M-%S)
                    sudo mkdir -p ${BACKUP_PATH}/$TIMESTAMP
                    sudo cp -r ${DEPLOY_PATH}/* ${BACKUP_PATH}/$TIMESTAMP/
                    '''
                }
            }
        }

        stage('Fetch Latest Code') {
            steps {
                git branch: 'main', url: 'https://github.com/snownrd/Cricketbuzz.git'
            }
        }

        stage('Deploy to /var/www/Cricketbuzz') {
            steps {
                script {
                    sh '''
                    echo "Deploying latest code..."
                    sudo rm -rf ${DEPLOY_PATH}/*
                    sudo cp -r * ${DEPLOY_PATH}/
                    '''
                }
            }
        }

        stage('Restart Nginx') {
            steps {
                script {
                    sh '''
                    echo "Restarting Nginx..."
                    sudo systemctl restart nginx
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}
