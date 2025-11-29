#!/bin/bash

REGION="eu-north-1"
ENV_NAME="nodejs-jenkins-demo"

echo "🚀 Deploying infrastructure to ${REGION}..."

# Deploy VPC
echo "📦 Deploying VPC..."
aws cloudformation deploy \
  --template-file infra/01-vpc-networking.yml \
  --stack-name ${ENV_NAME}-vpc \
  --region ${REGION}

# Deploy Security Groups
echo "🔒 Deploying Security Groups..."
aws cloudformation deploy \
  --template-file infra/02-security-groups.yml \
  --stack-name ${ENV_NAME}-security \
  --region ${REGION}

# Deploy IAM Roles
echo "👤 Deploying IAM Roles..."
aws cloudformation deploy \
  --template-file infra/03-iam-roles.yml \
  --stack-name ${ENV_NAME}-iam \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ${REGION}

# Deploy ECR
echo "📦 Deploying ECR..."
aws cloudformation deploy \
  --template-file infra/04-ecr.yml \
  --stack-name ${ENV_NAME}-ecr \
  --region ${REGION}

# Deploy Jenkins EC2
echo "🔧 Deploying Jenkins EC2..."
aws cloudformation deploy \
  --template-file infra/05-jenkins-ec2.yml \
  --stack-name ${ENV_NAME}-jenkins \
  --region ${REGION}

# Deploy ALB
echo "⚖️ Deploying Application Load Balancer..."
aws cloudformation deploy \
  --template-file infra/06-alb.yml \
  --stack-name ${ENV_NAME}-alb \
  --region ${REGION}

# Get Jenkins URL
JENKINS_IP=$(aws cloudformation describe-stacks \
  --stack-name ${ENV_NAME}-jenkins \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsPublicIP`].OutputValue' \
  --output text \
  --region ${REGION})

echo ""
echo "✅ Infrastructure deployed successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Wait 5-10 minutes for Jenkins to initialize"
echo "2. Access Jenkins at: http://${JENKINS_IP}:8080"
echo "3. Get initial admin password:"
echo "   ssh ec2-user@${JENKINS_IP} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
echo "4. Build and push initial Docker image"
echo "5. Deploy ECS cluster with: ./scripts/deploy-ecs.sh"
