
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
                set -e

                echo "Backing up current code to tarball..."
                TIMESTAMP=$(date +%Y_%m_%d_%H_%M_%S)

                # Ensure backup directory exists
                sudo mkdir -p "${BACKUP_PATH}"

                # Create tar.gz of current deployed files
                # -C switches directory to DEPLOY_PATH so the archive has clean relative paths
                sudo tar -czf "${BACKUP_PATH}/${TIMESTAMP}.tar.gz" -C "${DEPLOY_PATH}" .

                echo "Backup created: ${BACKUP_PATH}/${TIMESTAMP}.tar.gz"
                '''
            }
        }
    }
        stage('Fetch Latest Code') {
            steps {
                git branch: 'master', url: 'https://github.com/snownrd/Cricketbuzz.git'
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
