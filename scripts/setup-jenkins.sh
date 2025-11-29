#!/bin/bash

REGION="eu-north-1"
ENV_NAME="nodejs-jenkins-demo"

# Get Jenkins IP
JENKINS_IP=$(aws cloudformation describe-stacks \
  --stack-name ${ENV_NAME}-jenkins \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsPublicIP`].OutputValue' \
  --output text \
  --region ${REGION})

echo "🔧 Jenkins Setup Instructions"
echo "=============================="
echo ""
echo "1. Access Jenkins:"
echo "   URL: http://${JENKINS_IP}:8080"
echo ""
echo "2. Get initial admin password:"
echo "   ssh ec2-user@${JENKINS_IP} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
echo ""
echo "3. Install suggested plugins"
echo ""
echo "4. Install additional plugins:"
echo "   - Docker Pipeline"
echo "   - Amazon ECR"
echo "   - Pipeline: AWS Steps"
echo ""
echo "5. Create a new Pipeline job:"
echo "   - New Item → Pipeline"
echo "   - Configure SCM: Git"
echo "   - Repository URL: <your-github-repo>"
echo "   - Script Path: jenkins/Jenkinsfile"
echo ""
echo "6. Configure AWS credentials (if needed):"
echo "   - Manage Jenkins → Credentials"
echo "   - Add AWS credentials"
echo ""
echo "7. Build the job to trigger deployment!"
