# Node.js CI/CD with Jenkins, Docker, ECR & ECS

Complete CI/CD pipeline deploying Node.js applications to AWS ECS using Jenkins.

## Architecture

```
GitHub → Jenkins (EC2) → Docker Build → ECR → ECS Fargate
```

## Components

1. **Jenkins Server** - EC2 instance with Docker
2. **Node.js Application** - Sample Express app
3. **CloudFormation Infrastructure** - VPC, ECS, ECR, IAM
4. **Jenkins Pipeline** - Automated build and deploy

## Quick Start

1. Deploy infrastructure: `./scripts/deploy-infra.sh`
2. Setup Jenkins: `./scripts/setup-jenkins.sh`
3. Configure Jenkins job with provided Jenkinsfile
4. Push code to trigger deployment

## Account Details

- **Account ID**: 047861165149
- **Region**: eu-north-1

## Directory Structure

```
├── app/                    # Node.js application
├── infra/                  # CloudFormation templates
├── jenkins/                # Jenkins configuration
└── scripts/                # Deployment scripts
```
