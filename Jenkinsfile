pipeline {
    agent { label 'docker' }

    environment {
        IMAGE_NAME = "simple-web-app"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install & Test') {
            steps {
                sh '''
                python3 -m venv venv
                . venv/bin/activate
                pip install --upgrade pip
                pip install -r app/requirements.txt
                pytest
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME .
                '''
            }
        }

        stage('Run Container Locally') {
            steps {
                sh '''
                # stop and remove previous container if it exists
                docker stop $IMAGE_NAME || true
                docker rm $IMAGE_NAME || true

                # run the newly built image
                docker run -d -p 5000:5000 --name $IMAGE_NAME $IMAGE_NAME:latest
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                // credentials are only available inside this block
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-hub',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

                    # push image with correct tag format
                    docker tag $IMAGE_NAME ${DOCKER_USER}/$IMAGE_NAME:latest
                    docker push ${DOCKER_USER}/$IMAGE_NAME:latest
                    '''
                }
            }
        }
    }
}
