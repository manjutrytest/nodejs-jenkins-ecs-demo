#!/bin/bash

REGION="eu-north-1"
ENV_NAME="nodejs-jenkins-demo"

echo "🗑️ Cleaning up resources..."

# Delete stacks in reverse order
aws cloudformation delete-stack --stack-name ${ENV_NAME}-ecs --region ${REGION}
echo "Waiting for ECS stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name ${ENV_NAME}-ecs --region ${REGION}

aws cloudformation delete-stack --stack-name ${ENV_NAME}-alb --region ${REGION}
echo "Waiting for ALB stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name ${ENV_NAME}-alb --region ${REGION}

aws cloudformation delete-stack --stack-name ${ENV_NAME}-jenkins --region ${REGION}
echo "Waiting for Jenkins stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name ${ENV_NAME}-jenkins --region ${REGION}

aws cloudformation delete-stack --stack-name ${ENV_NAME}-ecr --region ${REGION}
echo "Waiting for ECR stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name ${ENV_NAME}-ecr --region ${REGION}

aws cloudformation delete-stack --stack-name ${ENV_NAME}-iam --region ${REGION}
echo "Waiting for IAM stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name ${ENV_NAME}-iam --region ${REGION}

aws cloudformation delete-stack --stack-name ${ENV_NAME}-security --region ${REGION}
echo "Waiting for Security stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name ${ENV_NAME}-security --region ${REGION}

aws cloudformation delete-stack --stack-name ${ENV_NAME}-vpc --region ${REGION}
echo "Waiting for VPC stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name ${ENV_NAME}-vpc --region ${REGION}

echo "✅ All resources cleaned up!"
