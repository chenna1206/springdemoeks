pipeline {

    agent any

    environment {

        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '911291530745'
        ECR_REPOSITORY = 'springbooteks'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_NAME = "${ECR_REGISTRY}/${ECR_REPOSITORY}"
        EKS_CLUSTER = 'springboot-eks-cluster'
        K8S_DEPLOYMENT = 'springboot-eks'
        K8S_CONTAINER = 'springboot-eks'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                bat 'mvnw.cmd clean test'
            }
        }

        stage('Build JAR') {
            steps {
                bat 'mvnw.cmd clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                bat 'docker build -t %IMAGE_NAME%:%BUILD_NUMBER% .'
            }
        }

      /*   stage('Login to ECR') {
            steps {
                bat '''
                    aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_REGISTRY%
                '''
            }
        } */

        stage('Login to ECR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-ecr',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    bat '''
                        echo AWS Region: %AWS_REGION%
                        echo ECR Registry: %ECR_REGISTRY%
                        aws sts get-caller-identity
                        aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_REGISTRY%
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                bat 'docker push %IMAGE_NAME%:%BUILD_NUMBER%'
            }
        }

        stage('Configure EKS') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-ecr',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    bat '''
                        aws sts get-caller-identity
                        aws eks update-kubeconfig --region %AWS_REGION% --name %EKS_CLUSTER%
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-ecr',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    bat '''
                        aws sts get-caller-identity
                        kubectl apply -f deployment/deployment.yaml
                        kubectl apply -f deployment/service.yaml
                    '''
                }
            }
        }

        stage('Update Image') {
            steps {
                bat '''
                    kubectl set image deployment/%K8S_DEPLOYMENT% %K8S_CONTAINER%=%IMAGE_NAME%:%BUILD_NUMBER%
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                bat '''
                    kubectl rollout status deployment/%K8S_DEPLOYMENT% --timeout=5m
                '''
            }
        }
    }

    post {
        success {
            echo '======================================'
            echo 'Deployment successful!'
            echo '======================================'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}