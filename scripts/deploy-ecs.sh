#!/bin/bash

REGION="eu-north-1"
ENV_NAME="nodejs-jenkins-demo"
ACCOUNT_ID="047861165149"

echo "🚀 Deploying ECS Cluster..."

# Get ECR URI
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/nodejs-demo-app:latest"

# Deploy ECS
aws cloudformation deploy \
  --template-file infra/07-ecs-cluster.yml \
  --stack-name ${ENV_NAME}-ecs \
  --parameter-overrides ImageUri=${ECR_URI} \
  --region ${REGION}

# Get ALB DNS
ALB_DNS=$(aws cloudformation describe-stacks \
  --stack-name ${ENV_NAME}-alb \
  --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
  --output text \
  --region ${REGION})

echo ""
echo "✅ ECS Cluster deployed successfully!"
echo ""
echo "🌐 Application URL: http://${ALB_DNS}"
echo ""
echo "📋 Test the application:"
echo "   curl http://${ALB_DNS}"
echo "   curl http://${ALB_DNS}/health"
