pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '975050198487'
        ECR_REPOSITORY = 'lambda_container'
        IMAGE_TAG = 'latest'
        LAMBDA_FUNCTION_NAME = 'lambda_container'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from your version control system
                checkout scm
                    sh """
			aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin 975050198487.dkr.ecr.us-east-1.amazonaws.com
                    """
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry("https://${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com", 'ecr:login') {
                        def app = docker.build("${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPOSITORY}:${env.IMAGE_TAG}")
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry("https://${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com", 'ecr:login') {
                        def app = docker.image("${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPOSITORY}:${env.IMAGE_TAG}")
                        app.push()
                    }
                }
            }
        }

        stage('Update Lambda Function') {
            steps {
                script {
                    sh """
                    aws lambda update-function-code \
                        --function-name ${env.LAMBDA_FUNCTION_NAME} \
                        --image-uri ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPOSITORY}:${env.IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}
