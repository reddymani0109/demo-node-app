pipeline {
    agent any
    tools{
        nodejs 'nodejs'
    }
    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
        AWS_ACCOUNT_ID = "533538027922"
        ECR_REPOSITORY = "demo-node-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        EB_APPLICATION_NAME = "Demo-Node-Application"
        EB_ENVIRONMENT_NAME = "Demo-Node-Application-dev"
        S3_BUCKET = "elasticbeanstalk-ap-south-1-533538027922"
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages {
        stage("Git Checkout") {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-creds', url: 'https://github.com/reddymani0109/demo-node-app.git']])
            }
        }
        stage("Sonar Scan"){
            steps{
                withSonarQubeEnv(credentialsId: 'sonar-jenkins-token', installationName: 'sonar-server') {
                 bat "npm install -g sonarqube-scanner"
                 bat "sonar-scanner -Dsonar.ProjectVersion=${BUILD_NUMBER}"
                }
                timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
                
            }
        }
        
         stage("Build Docker Image") {
            steps {
                bat " docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG} . "
            }
        }
        stage("Push to AWS ECR") {
            steps {
                withAWS(credentials: 'manikanta-aws-cli-creds', region: "${AWS_DEFAULT_REGION}") {
                    bat " aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com "
                    bat " docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG} "
                }
            }
        }
        stage("EB Deploy") {
            steps {
                bat " 7z a -tzip deployement-package.zip Dockerrun.aws.json "
                withAWS(credentials: 'manikanta-aws-cli-creds', region: "${AWS_DEFAULT_REGION}") {
                    bat """ aws s3 cp deployement-package.zip s3://${S3_BUCKET}/${EB_APPLICATION_NAME}-${IMAGE_TAG}.zip
            aws elasticbeanstalk create-application-version --application-name ${EB_APPLICATION_NAME} --version-label ${IMAGE_TAG} --source-bundle S3Bucket=${S3_BUCKET},S3Key=${EB_APPLICATION_NAME}-${IMAGE_TAG}.zip
            aws elasticbeanstalk update-environment --application-name ${EB_APPLICATION_NAME} --environment-name ${EB_ENVIRONMENT_NAME} --version-label ${IMAGE_TAG}
            """
                }
            }
        }
    }
}
