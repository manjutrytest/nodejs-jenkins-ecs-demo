# Project Creation Prompt

This document contains the original prompt used to create this CI/CD pipeline project.

## Original Request

```
I want to deploy nodejs applications using below:

1️⃣ EC2 with Jenkins + Docker
2️⃣ GitHub repo connected to Jenkins
3️⃣ Jenkins builds NodeJS → Docker → ECR → ECS
4️⃣ ECS service deploys new version automatically

My account ID: 047861165149
Region: eu-north-1
```

## What Was Built

A complete production-ready CI/CD pipeline with:

### Infrastructure (CloudFormation)
- VPC with 2 public subnets across 2 AZs
- Security groups for Jenkins, ALB, and ECS
- IAM roles with least-privilege permissions
- Jenkins EC2 server (t3.medium) with Docker
- ECR repository for Docker images
- Application Load Balancer
- ECS Fargate cluster with 2 tasks
- CloudWatch log groups

### Application
- Node.js 18 Express application
- Dockerized with multi-stage build
- Health check endpoint
- Proper logging

### CI/CD Pipeline
- Jenkins pipeline as code (Jenkinsfile)
- Automated builds on git push
- GitHub webhook integration
- Docker image building and tagging
- ECR push with authentication
- ECS rolling deployments
- Zero-downtime updates

### Documentation
- Complete deployment guide
- Architecture diagrams
- Workflow diagrams
- Quick start guide
- Log viewing guide
- Troubleshooting guide

## Key Features Delivered

✅ Fully automated CI/CD pipeline
✅ Infrastructure as Code (CloudFormation)
✅ Zero-downtime deployments
✅ Multi-AZ high availability
✅ Auto-healing and health checks
✅ Comprehensive logging
✅ Security best practices
✅ Cost-optimized (~$76/month)
✅ Production-ready
✅ Well-documented

## Technologies Used

- **Cloud**: AWS (VPC, EC2, ECS, ECR, ALB, CloudWatch, IAM)
- **CI/CD**: Jenkins
- **Containerization**: Docker
- **Orchestration**: ECS Fargate
- **IaC**: CloudFormation
- **Application**: Node.js, Express
- **Version Control**: Git, GitHub

## Time to Deploy

- Infrastructure setup: ~15 minutes
- Jenkins configuration: ~10 minutes
- First deployment: ~5 minutes
- **Total**: ~30 minutes from zero to production

## Deployment Steps Summary

1. Clone repository
2. Configure AWS CLI
3. Run deployment script
4. Setup Jenkins
5. Build initial image
6. Deploy ECS
7. Configure GitHub webhook
8. Done!

## Result

A working CI/CD pipeline where:
- Developers push code to GitHub
- Jenkins automatically builds and tests
- Docker image is created and pushed to ECR
- ECS deploys new version with zero downtime
- Application is live in 3-5 minutes

**Live Demo**: http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/

## Replication

To recreate this project in another AWS account:

```bash
git clone https://github.com/manjutrytest/nodejs-jenkins-ecs-demo.git
cd nodejs-jenkins-ecs-demo
aws configure  # Set your AWS credentials
./scripts/deploy-infra.sh
# Follow QUICKSTART.md for remaining steps
```

## Customization

This project can be easily customized for:
- Different Node.js applications
- Other programming languages (Python, Java, Go, etc.)
- Different AWS regions
- Additional environments (staging, production)
- Auto-scaling policies
- Database integration (RDS)
- Caching layer (ElastiCache)
- CDN (CloudFront)
- SSL/TLS certificates
- Custom domains

## License

MIT - Free to use and modify
