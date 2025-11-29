# Architecture Overview

## CI/CD Pipeline Flow

```
┌─────────────┐
│   GitHub    │
│  Repository │
└──────┬──────┘
       │ Push/Webhook
       ▼
┌─────────────────────────────────────┐
│         Jenkins (EC2)               │
│  ┌──────────────────────────────┐  │
│  │  1. Checkout Code            │  │
│  │  2. npm install & test       │  │
│  │  3. Docker Build             │  │
│  │  4. Push to ECR              │  │
│  │  5. Update ECS Service       │  │
│  └──────────────────────────────┘  │
└──────────┬──────────────────────────┘
           │
           ▼
    ┌──────────────┐
    │     ECR      │
    │  (Registry)  │
    └──────┬───────┘
           │
           ▼
    ┌──────────────────────────────┐
    │      ECS Fargate Cluster     │
    │  ┌────────────────────────┐  │
    │  │  Task 1 (Container)    │  │
    │  │  Task 2 (Container)    │  │
    │  └────────────────────────┘  │
    └──────────┬───────────────────┘
               │
               ▼
        ┌─────────────┐
        │     ALB     │
        │ (Port 80)   │
        └──────┬──────┘
               │
               ▼
          ┌─────────┐
          │  Users  │
          └─────────┘
```

## Components

### 1. VPC & Networking
- VPC: 10.0.0.0/16
- 2 Public Subnets (Multi-AZ)
- Internet Gateway
- Route Tables

### 2. Security Groups
- **Jenkins SG**: Ports 8080 (HTTP), 22 (SSH)
- **ALB SG**: Port 80 (HTTP)
- **ECS SG**: Port 3000 (from ALB only)

### 3. IAM Roles
- **Jenkins Role**: ECR push, ECS update permissions
- **ECS Task Execution Role**: Pull images, write logs
- **ECS Task Role**: Application runtime permissions

### 4. Jenkins Server (EC2)
- Instance Type: t3.medium
- OS: Amazon Linux 2023
- Installed: Jenkins, Docker, Git, Node.js, AWS CLI
- Auto-configured via UserData script

### 5. ECR Repository
- Repository: nodejs-demo-app
- Image scanning enabled
- Lifecycle policy: Keep last 10 images

### 6. Application Load Balancer
- Internet-facing
- HTTP (Port 80)
- Health checks: /health endpoint
- Target: ECS tasks on port 3000

### 7. ECS Cluster
- Launch Type: Fargate
- Service: nodejs-demo-service
- Desired Count: 2 tasks
- Task Definition:
  - CPU: 256 (.25 vCPU)
  - Memory: 512 MB
  - Container Port: 3000

## Deployment Flow

1. **Developer pushes code** to GitHub
2. **GitHub webhook** triggers Jenkins build
3. **Jenkins pipeline**:
   - Clones repository
   - Runs `npm install` and `npm test`
   - Builds Docker image
   - Tags image with build number
   - Authenticates to ECR
   - Pushes image to ECR
   - Updates ECS service (force new deployment)
4. **ECS performs rolling update**:
   - Pulls new image from ECR
   - Starts new tasks
   - Waits for health checks
   - Drains old tasks
   - Completes deployment

## High Availability

- **Multi-AZ**: Tasks run across 2 availability zones
- **Auto-scaling**: Can be configured based on CPU/memory
- **Health Checks**: ALB monitors task health
- **Rolling Updates**: Zero-downtime deployments

## Security Features

- Private container networking (awsvpc mode)
- Security groups restrict traffic flow
- IAM roles for least-privilege access
- ECR image scanning for vulnerabilities
- CloudWatch logs for audit trail

## Monitoring & Logging

- **CloudWatch Logs**: Application logs from containers
- **ECS Metrics**: CPU, memory, task count
- **ALB Metrics**: Request count, latency, errors
- **Jenkins**: Build history and logs
