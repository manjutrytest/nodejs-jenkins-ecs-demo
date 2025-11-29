# Node.js CI/CD with Jenkins, Docker, ECR & ECS

Production-ready CI/CD pipeline deploying Node.js applications to AWS ECS using Jenkins.

## 🚀 Live Demo

- **Application**: http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/
- **Health Check**: http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/health

## 📋 Architecture

```
GitHub Push → Webhook → Jenkins (EC2) → Docker Build → 
ECR Push → ECS Deploy → Rolling Update → Live!
```

**Components:**
- Jenkins CI/CD server on EC2
- Docker containerization
- Amazon ECR for image registry
- ECS Fargate for container orchestration
- Application Load Balancer
- CloudWatch for logging

## ⚡ Quick Start

### For Developers (Make Code Changes)

```bash
# Clone repository
git clone https://github.com/manjutrytest/nodejs-jenkins-ecs-demo.git
cd nodejs-jenkins-ecs-demo

# Make changes
code app/server.js

# Commit and push
git add .
git commit -m "Your changes"
git push origin main

# Jenkins automatically builds and deploys!
```

### For DevOps (Deploy Infrastructure)

```bash
# 1. Configure AWS CLI
aws configure

# 2. Deploy infrastructure
cd nodejs-jenkins-ecs-demo
chmod +x scripts/deploy-infra.sh
./scripts/deploy-infra.sh

# 3. Follow setup instructions in DEPLOYMENT-GUIDE.md
```

## 📁 Project Structure

```
nodejs-jenkins-ecs-demo/
├── app/                          # Node.js application
│   ├── server.js                 # Express application
│   ├── package.json              # Dependencies
│   ├── Dockerfile                # Container definition
│   └── .dockerignore
├── jenkins/
│   └── Jenkinsfile               # CI/CD pipeline definition
├── infra/                        # CloudFormation templates
│   ├── 01-vpc-networking.yml     # VPC, subnets, IGW
│   ├── 03-iam-roles.yml          # IAM roles for Jenkins & ECS
│   ├── 04-ecr.yml                # ECR repository
│   ├── 05-jenkins-ec2.yml        # Jenkins server
│   ├── 06-alb.yml                # Application Load Balancer
│   └── 07-ecs-cluster.yml        # ECS cluster & service
├── scripts/
│   ├── deploy-infra.sh           # Deploy all infrastructure
│   ├── build-push-initial.sh     # Push first Docker image
│   ├── deploy-ecs.sh             # Deploy ECS service
│   ├── setup-jenkins.sh          # Jenkins setup guide
│   └── cleanup.sh                # Remove all resources
└── docs/                         # Documentation
    ├── DEPLOYMENT-GUIDE.md       # Complete deployment guide
    ├── GITHUB-SETUP.md           # GitHub configuration
    ├── ARCHITECTURE.md           # Architecture details
    ├── VIEW-LOGS.md              # Log viewing guide
    ├── UPDATED-PIPELINE.md       # Improved pipeline script
    └── CLONE-AND-USE.md          # Guide for team members
```

## 🎯 Features

- ✅ Automated CI/CD pipeline
- ✅ Zero-downtime deployments
- ✅ Docker containerization
- ✅ Infrastructure as Code (CloudFormation)
- ✅ Auto-scaling capable
- ✅ Load balanced across multiple AZs
- ✅ CloudWatch logging
- ✅ GitHub webhook integration

## 📚 Documentation

- **[Deployment Guide](DEPLOYMENT-GUIDE.md)** - Complete setup instructions
- **[GitHub Setup](GITHUB-SETUP.md)** - Configure GitHub integration
- **[Architecture](ARCHITECTURE.md)** - System architecture details
- **[View Logs](VIEW-LOGS.md)** - Application log viewing
- **[Pipeline Updates](UPDATED-PIPELINE.md)** - Improved Jenkins pipeline
- **[Clone & Use](CLONE-AND-USE.md)** - Guide for team members

## 🔧 Technology Stack

- **Application**: Node.js 18, Express
- **CI/CD**: Jenkins
- **Containerization**: Docker
- **Registry**: Amazon ECR
- **Orchestration**: Amazon ECS Fargate
- **Load Balancing**: Application Load Balancer
- **Infrastructure**: AWS CloudFormation
- **Logging**: CloudWatch Logs
- **Version Control**: Git, GitHub

## 💰 Cost Estimate

Running 24/7 in eu-north-1:
- EC2 t3.medium (Jenkins): ~$30/month
- ECS Fargate (2 tasks): ~$20/month
- Application Load Balancer: ~$20/month
- ECR + Data transfer: ~$6/month
- **Total: ~$76/month**

## 🧹 Cleanup

To remove all resources:

```bash
./scripts/cleanup.sh
```

## 📝 License

MIT License - Feel free to use for learning and projects

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📧 Contact

Repository: https://github.com/manjutrytest/nodejs-jenkins-ecs-demo
