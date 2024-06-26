pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = "keziban"
        DOCKERHUB_PASSWORD = "08062012EEM.,t"
        // DOCKERHUB_USERNAME = credentials('dockerhub_username')
        // DOCKERHUB_PASSWORD = credentials('dockerhub_password')
        DOCKERHUB_REGISTRY = "keziban"
        POSTGRE_REPO_NAME = "todopostgre"
        NODEJS_REPO_NAME = "todobac"
        REACT_REPO_NAME = "todoreact"
    }

    stages {

        stage('Build App Docker Image') {
            steps {
                echo 'Building App Image'
                sh 'docker build --force-rm -t "$DOCKERHUB_REGISTRY/$POSTGRE_REPO_NAME:latest" -f ./postgresql/Dockerfile .'
                sh 'docker build --force-rm -t "$DOCKERHUB_REGISTRY/$NODEJS_REPO_NAME:latest" -f ./nodejs/Dockerfile .'
                sh 'docker build --force-rm -t "$DOCKERHUB_REGISTRY/$REACT_REPO_NAME:latest" -f ./react/Dockerfile .'
                sh 'docker image ls'
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                echo 'Pushing App Image to Docker Hub'
                sh 'docker login --username $DOCKERHUB_USERNAME --password $DOCKERHUB_PASSWORD'
                sh 'docker push $DOCKERHUB_REGISTRY/$POSTGRE_REPO_NAME:latest'
                sh 'docker push $DOCKERHUB_REGISTRY/$NODEJS_REPO_NAME:latest'
                sh 'docker push $DOCKERHUB_REGISTRY/$REACT_REPO_NAME:latest'
            }
        }

        stage('Deploy the App') {
            steps {
                echo 'Deploy the App'
                sh 'docker-compose up'
            }
        }

        stage('Destroy the infrastructure') {
            steps {
                timeout(time:5, unit:'DAYS'){
                    input message:'Approve terminate'
                }
                sh """
                docker image prune -af
                """
            }
        }

    }

    post {
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
            // sh 'terraform destroy --auto-approve'
        }
        failure {
            echo 'Clean-up due to failure'
            sh """
                docker image prune -af
                terraform destroy --auto-approve
                """
        }
    }
}
