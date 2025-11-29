# Deployment Guide

## Prerequisites

- AWS CLI configured with credentials
- Docker installed locally
- Git repository for your code
- EC2 Key Pair (optional, for SSH access)

## Step-by-Step Deployment

### 1. Deploy Infrastructure

```bash
cd nodejs-jenkins-ecs-demo
chmod +x scripts/*.sh
./scripts/deploy-infra.sh
```

This deploys:
- VPC with 2 public subnets
- Security Groups
- IAM Roles
- ECR Repository
- Jenkins EC2 instance
- Application Load Balancer

**Wait 5-10 minutes** for Jenkins to initialize.

### 2. Access Jenkins

Get Jenkins URL:
```bash
aws cloudformation describe-stacks \
  --stack-name nodejs-jenkins-demo-jenkins \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsURL`].OutputValue' \
  --output text \
  --region eu-north-1
```

Get initial admin password:
```bash
# SSH into Jenkins instance
JENKINS_IP=$(aws cloudformation describe-stacks \
  --stack-name nodejs-jenkins-demo-jenkins \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsPublicIP`].OutputValue' \
  --output text \
  --region eu-north-1)

ssh ec2-user@${JENKINS_IP} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'
```

### 3. Configure Jenkins

1. Open Jenkins URL in browser
2. Enter initial admin password
3. Install suggested plugins
4. Install additional plugins:
   - Docker Pipeline
   - Amazon ECR
   - Pipeline: AWS Steps
5. Create admin user

### 4. Build and Push Initial Image

```bash
./scripts/build-push-initial.sh
```

### 5. Deploy ECS Cluster

```bash
./scripts/deploy-ecs.sh
```

### 6. Create Jenkins Pipeline Job

1. In Jenkins: **New Item** → **Pipeline**
2. Name: `nodejs-demo-pipeline`
3. Configure:
   - **Pipeline** section
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: Your GitHub repo URL
   - **Script Path**: `jenkins/Jenkinsfile`
4. Save

### 7. Connect GitHub to Jenkins

**Option A: GitHub Webhook (Recommended)**
1. In GitHub repo: Settings → Webhooks → Add webhook
2. Payload URL: `http://<JENKINS_IP>:8080/github-webhook/`
3. Content type: `application/json`
4. Events: Just the push event
5. Active: ✓

**Option B: Poll SCM**
1. In Jenkins job: Configure → Build Triggers
2. Check "Poll SCM"
3. Schedule: `H/5 * * * *` (every 5 minutes)

### 8. Trigger First Build

Push code to GitHub or click "Build Now" in Jenkins.

Jenkins will:
1. Checkout code
2. Run npm install & test
3. Build Docker image
4. Push to ECR
5. Deploy to ECS

### 9. Verify Deployment

Get application URL:
```bash
aws cloudformation describe-stacks \
  --stack-name nodejs-jenkins-demo-alb \
  --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
  --output text \
  --region eu-north-1
```

Test endpoints:
```bash
curl http://<ALB_DNS>/
curl http://<ALB_DNS>/health
```

## Continuous Deployment

Once setup is complete:

1. Make changes to `app/server.js`
2. Commit and push to GitHub
3. Jenkins automatically:
   - Detects changes
   - Builds new image
   - Pushes to ECR
   - Updates ECS service
4. ECS performs rolling update with zero downtime

## Monitoring

### Jenkins Build Status
- Access Jenkins UI
- View build history and logs

### ECS Service
```bash
aws ecs describe-services \
  --cluster nodejs-demo-cluster \
  --services nodejs-demo-service \
  --region eu-north-1
```

### Application Logs
```bash
aws logs tail /ecs/nodejs-jenkins-demo --follow --region eu-north-1
```

## Troubleshooting

### Jenkins not accessible
- Check security group allows port 8080
- Verify EC2 instance is running
- Check UserData script logs: `ssh ec2-user@<IP> 'sudo cat /var/log/cloud-init-output.log'`

### Docker permission denied in Jenkins
```bash
ssh ec2-user@<JENKINS_IP>
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### ECS tasks not starting
- Check ECR image exists
- Verify task definition is valid
- Check CloudWatch logs for errors

### ALB health checks failing
- Ensure app responds on `/health` endpoint
- Check security group allows ALB → ECS traffic
- Verify container port 3000 is exposed

## Cleanup

Remove all resources:
```bash
./scripts/cleanup.sh
```

## Cost Estimate

- EC2 t3.medium: ~$30/month
- ECS Fargate (2 tasks): ~$20/month
- ALB: ~$20/month
- ECR storage: ~$1/month
- **Total: ~$71/month**

## Security Recommendations

1. **Restrict Jenkins access**: Update security group to allow only your IP
2. **Use HTTPS**: Add SSL certificate to ALB
3. **Secrets management**: Use AWS Secrets Manager for sensitive data
4. **IAM least privilege**: Review and restrict IAM permissions
5. **Enable MFA**: For AWS account access
