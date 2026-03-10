pipeline {
    agent any

    environment {
        IMAGE_NAME = "simple-web-app"
        DOCKER_REGISTRY = "docker.io"
        DOCKERHUB_CREDENTIALS = "docker-hub"
    }

    options {
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Python') {
            steps {
                sh '''
                python3 -m venv venv
                . venv/bin/activate
                pip install --upgrade pip
                pip install -r app/requirements.txt
                pip install pytest
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                . venv/bin/activate
                PYTHONPATH=$PWD pytest -v
                '''
            }
        }

        stage('Debug env') {
            steps {
                sh '''
                echo IMAGE_NAME=$IMAGE_NAME
                echo DOCKER_USER=$DOCKER_USER
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                sudo docker build -t $IMAGE_NAME .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKERHUB_CREDENTIALS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    
                    docker tag simple-web-app ${DOCKER_USER}/simple-web-app:latest

                    docker push ${DOCKER_USER}/simple-web-app:latest
                    ''''

                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([usernamePassword(
                  credentialsId: DOCKERHUB_CREDENTIALS,
                  usernameVariable: 'DOCKER_USER'
                )]) {
                sh '''
                docker stop simple-web-app || true
                docker rm simple-web-app || true

                docker run -d -p 5000:5000 \
                  --name simple-web-app \
                  ${DOCKER_USER}/simple-web-app:latest
                '''
                }
            }
        }
    }

    post {

        success {
            echo "Pipeline completed successfully"
        }

        failure {
            echo "Pipeline failed"
        }

        always {
            cleanWs()
        }
    }
}
