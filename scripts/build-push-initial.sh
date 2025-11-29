#!/bin/bash

REGION="eu-north-1"
ACCOUNT_ID="047861165149"
ECR_REPO="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/nodejs-demo-app"

echo "🔨 Building and pushing initial Docker image..."

# Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REPO}

# Build image
echo "🐳 Building Docker image..."
cd app
docker build -t ${ECR_REPO}:latest .

# Push to ECR
echo "📤 Pushing to ECR..."
docker push ${ECR_REPO}:latest

echo ""
echo "✅ Initial image pushed successfully!"
echo "📦 Image: ${ECR_REPO}:latest"
