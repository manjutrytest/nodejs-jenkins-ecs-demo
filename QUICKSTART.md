# 🚀 Quick Start Guide

## After Cloning This Repository

### Option 1: Just Make Code Changes (No AWS Setup Needed)

If infrastructure is already running:

```bash
# 1. Clone
git clone https://github.com/manjutrytest/nodejs-jenkins-ecs-demo.git
cd nodejs-jenkins-ecs-demo

# 2. Edit code
notepad app/server.js  # or use any editor

# 3. Push
git add .
git commit -m "My changes"
git push origin main

# Done! Jenkins auto-deploys in 3-5 minutes
```

### Option 2: Deploy Full Infrastructure (New AWS Account)

```bash
# 1. Clone
git clone https://github.com/manjutrytest/nodejs-jenkins-ecs-demo.git
cd nodejs-jenkins-ecs-demo

# 2. Configure AWS
aws configure
# Enter: Access Key, Secret Key, Region (eu-north-1)

# 3. Deploy (15 minutes)
chmod +x scripts/deploy-infra.sh
./scripts/deploy-infra.sh

# 4. Get Jenkins URL
aws cloudformation describe-stacks \
  --stack-name nodejs-jenkins-demo-jenkins \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsURL`].OutputValue' \
  --output text --region eu-north-1

# 5. Setup Jenkins
# - Access Jenkins URL from step 4
# - Get password: ssh ec2-user@<JENKINS_IP> "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
# - Install suggested plugins + Docker Pipeline, Amazon ECR
# - Create pipeline job pointing to this repo

# 6. Build initial image in Jenkins
# - Click "Build Now" in Jenkins
# - Wait for build to complete

# 7. Deploy ECS
aws cloudformation deploy \
  --template-file infra/07-ecs-cluster.yml \
  --stack-name nodejs-jenkins-demo-ecs \
  --region eu-north-1

# 8. Get app URL
aws cloudformation describe-stacks \
  --stack-name nodejs-jenkins-demo-alb \
  --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
  --output text --region eu-north-1

# Done! Visit the URL to see your app
```

## What You Need

### For Code Changes Only:
- Git
- Text editor
- GitHub access

### For Full Deployment:
- AWS account
- AWS CLI installed
- Git
- 15 minutes

## Test the Live App

```bash
curl http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/
```

Or open in browser: http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/
