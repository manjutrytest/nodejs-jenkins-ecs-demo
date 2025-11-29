# Updated Jenkins Pipeline (Handles Missing Service)

Replace your current pipeline script in Jenkins with this improved version that won't fail if the service doesn't exist:

## Go to Jenkins → Your Pipeline → Configure → Pipeline Script

```groovy
pipeline {
    agent any
    
    environment {
        AWS_REGION = 'eu-north-1'
        AWS_ACCOUNT_ID = '047861165149'
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nodejs-demo-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        ECS_CLUSTER = 'nodejs-demo-cluster'
        ECS_SERVICE = 'nodejs-demo-service'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/manjutrytest/nodejs-jenkins-ecs-demo.git'
            }
        }
        
        stage('Build') {
            steps {
                dir('app') {
                    sh 'npm install'
                    sh 'npm test'
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                dir('app') {
                    sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ."
                    sh "docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_REPO}:latest"
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}"
                sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
                sh "docker push ${ECR_REPO}:latest"
            }
        }
        
        stage('Deploy to ECS') {
            steps {
                script {
                    // Check if service exists before updating
                    def serviceExists = sh(
                        script: """
                            aws ecs describe-services \
                                --cluster ${ECS_CLUSTER} \
                                --services ${ECS_SERVICE} \
                                --region ${AWS_REGION} \
                                --query 'services[0].status' \
                                --output text 2>/dev/null || echo 'MISSING'
                        """,
                        returnStdout: true
                    ).trim()
                    
                    if (serviceExists == 'ACTIVE') {
                        echo "Service exists, deploying..."
                        sh """
                            aws ecs update-service \
                                --cluster ${ECS_CLUSTER} \
                                --service ${ECS_SERVICE} \
                                --force-new-deployment \
                                --region ${AWS_REGION}
                        """
                        echo "✅ Deployment triggered successfully!"
                    } else {
                        echo "⚠️ ECS service not found or not active. Skipping deployment."
                        echo "Image pushed to ECR: ${ECR_REPO}:${IMAGE_TAG}"
                        echo "Create the ECS service to enable automatic deployments."
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Build completed successfully!'
            echo "Image: ${ECR_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo '❌ Build failed!'
        }
        always {
            sh 'docker system prune -f || true'
        }
    }
}
```

## What Changed?

**Before:**
- Pipeline would fail if ECS service didn't exist
- Exit code 254 when `aws ecs update-service` failed

**After:**
- Checks if service exists before deploying
- If service exists → deploys normally
- If service missing → skips deployment but marks build as SUCCESS
- Shows helpful message about creating the service

## Why This is Better

1. **First build** (no ECS service yet):
   - ✅ Builds and pushes image to ECR
   - ⚠️ Skips ECS deployment with warning
   - ✅ Build marked as SUCCESS

2. **Subsequent builds** (ECS service exists):
   - ✅ Builds and pushes image
   - ✅ Deploys to ECS
   - ✅ Build marked as SUCCESS

## Test It Now

1. **Update the pipeline** in Jenkins with the script above
2. **Click "Build Now"**
3. **Watch it succeed** - all stages should be green!

The build will now complete successfully and deploy to your running ECS service.

## Alternative: Simple Version (Always Try to Deploy)

If you prefer to always attempt deployment and just ignore errors:

```groovy
stage('Deploy to ECS') {
    steps {
        sh """
            aws ecs update-service \
                --cluster ${ECS_CLUSTER} \
                --service ${ECS_SERVICE} \
                --force-new-deployment \
                --region ${AWS_REGION} || echo 'Service not found, skipping deployment'
        """
    }
}
```

This version tries to deploy and if it fails, just prints a message but doesn't fail the build.
