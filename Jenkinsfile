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
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG} .'
                }
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                script {
                    sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh 'docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}'
                }
            }
        }

        stage('Update Lambda Function') {
            steps {
                script {
                    sh """
                    aws lambda update-function-code \
                        --function-name ${LAMBDA_FUNCTION_NAME} \
                        --image-uri ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}
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
