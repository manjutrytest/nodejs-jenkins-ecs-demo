# Architecture Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                              │
│                          Region: eu-north-1                         │
└─────────────────────────────────────────────────────────────────────┘

                            ┌──────────────┐
                            │   Internet   │
                            └──────┬───────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
            ┌──────────┐   ┌──────────┐   ┌──────────┐
            │ Developer│   │  Users   │   │  GitHub  │
            │ Laptop   │   │          │   │ Webhook  │
            └──────────┘   └──────────┘   └──────────┘
                    │              │              │
                    │              │              │
┌───────────────────┼──────────────┼──────────────┼───────────────────┐
│                   │              │              │                   │
│  VPC              │              │              │                   │
│  10.0.0.0/16      │              │              │                   │
│                   │              │              │                   │
│  ┌────────────────┼──────────────┼──────────────┼────────────────┐  │
│  │ Public Subnet 1│              │              │                │  │
│  │ 10.0.1.0/24    │              │              │                │  │
│  │ AZ: eu-north-1a│              │              │                │  │
│  │                ▼              ▼              ▼                │  │
│  │         ┌──────────┐   ┌──────────┐   ┌──────────┐          │  │
│  │         │ Jenkins  │   │   ALB    │   │   NAT    │          │  │
│  │         │   EC2    │   │          │   │ Gateway  │          │  │
│  │         │ t3.medium│   │          │   │          │          │  │
│  │         └────┬─────┘   └────┬─────┘   └──────────┘          │  │
│  │              │              │                                │  │
│  └──────────────┼──────────────┼────────────────────────────────┘  │
│                 │              │                                    │
│  ┌──────────────┼──────────────┼────────────────────────────────┐  │
│  │ Public Subnet 2              │                                │  │
│  │ 10.0.2.0/24                  │                                │  │
│  │ AZ: eu-north-1b              │                                │  │
│  │                              ▼                                │  │
│  │                       ┌──────────┐                            │  │
│  │                       │   ALB    │                            │  │
│  │                       │          │                            │  │
│  │                       └────┬─────┘                            │  │
│  │                            │                                  │  │
│  └────────────────────────────┼──────────────────────────────────┘  │
│                               │                                     │
│                               │                                     │
│  ┌────────────────────────────┼──────────────────────────────────┐  │
│  │ ECS Fargate Tasks          │                                  │  │
│  │                            ▼                                  │  │
│  │                     ┌─────────────┐                           │  │
│  │                     │   Task 1    │                           │  │
│  │                     │  Container  │                           │  │
│  │                     │  Node.js    │                           │  │
│  │                     │  Port 3000  │                           │  │
│  │                     └─────────────┘                           │  │
│  │                     ┌─────────────┐                           │  │
│  │                     │   Task 2    │                           │  │
│  │                     │  Container  │                           │  │
│  │                     │  Node.js    │                           │  │
│  │                     │  Port 3000  │                           │  │
│  │                     └─────────────┘                           │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        Supporting Services                          │
└─────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
    │     ECR      │         │  CloudWatch  │         │     IAM      │
    │  Container   │         │     Logs     │         │    Roles     │
    │   Registry   │         │              │         │              │
    └──────────────┘         └──────────────┘         └──────────────┘
           │                        ▲                        │
           │                        │                        │
           └────────────────────────┴────────────────────────┘
                          Used by all services


## Component Details

┌─────────────────────────────────────────────────────────────────────┐
│                         Jenkins EC2 Server                          │
├─────────────────────────────────────────────────────────────────────┤
│ Instance Type: t3.medium                                            │
│ OS: Amazon Linux 2023                                               │
│ Installed:                                                          │
│   - Jenkins                                                         │
│   - Docker                                                          │
│   - AWS CLI                                                         │
│   - Node.js 18                                                      │
│   - Git                                                             │
│ Security Group: Port 8080 (Jenkins), Port 22 (SSH)                 │
│ IAM Role: ECR push, ECS update permissions                         │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    Application Load Balancer                        │
├─────────────────────────────────────────────────────────────────────┤
│ Type: Application Load Balancer                                     │
│ Scheme: Internet-facing                                             │
│ Listeners: HTTP:80                                                  │
│ Target Group: ECS tasks on port 3000                                │
│ Health Check: /health endpoint                                      │
│ Availability Zones: 2 (eu-north-1a, eu-north-1b)                   │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         ECS Fargate Cluster                         │
├─────────────────────────────────────────────────────────────────────┤
│ Cluster: nodejs-demo-cluster                                        │
│ Service: nodejs-demo-service                                        │
│ Desired Count: 2 tasks                                              │
│ Task Definition:                                                    │
│   - CPU: 256 (.25 vCPU)                                            │
│   - Memory: 512 MB                                                  │
│   - Container: Node.js 18 Alpine                                    │
│   - Port: 3000                                                      │
│ Deployment: Rolling update                                          │
│ Network Mode: awsvpc                                                │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                      ECR Container Registry                         │
├─────────────────────────────────────────────────────────────────────┤
│ Repository: nodejs-demo-app                                         │
│ Image Scanning: Enabled                                             │
│ Lifecycle Policy: Keep last 10 images                               │
│ Images: Tagged with build numbers + latest                          │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         Security Groups                             │
├─────────────────────────────────────────────────────────────────────┤
│ Jenkins SG:                                                         │
│   - Inbound: 8080 (HTTP), 22 (SSH) from 0.0.0.0/0                 │
│   - Outbound: All                                                   │
│                                                                     │
│ ALB SG:                                                             │
│   - Inbound: 80 (HTTP) from 0.0.0.0/0                             │
│   - Outbound: All                                                   │
│                                                                     │
│ ECS SG:                                                             │
│   - Inbound: 3000 from ALB SG only                                 │
│   - Outbound: All                                                   │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                            IAM Roles                                │
├─────────────────────────────────────────────────────────────────────┤
│ Jenkins Role:                                                       │
│   - ECR: Push images                                                │
│   - ECS: Update services, describe services                         │
│                                                                     │
│ ECS Task Execution Role:                                            │
│   - ECR: Pull images                                                │
│   - CloudWatch: Write logs                                          │
│                                                                     │
│ ECS Task Role:                                                      │
│   - Application runtime permissions                                 │
└─────────────────────────────────────────────────────────────────────┘

## Network Flow

```
User Request Flow:
    User → Internet → ALB (Port 80) → ECS Task (Port 3000) → Response

Jenkins Build Flow:
    Jenkins → ECR (Push image) → ECS (Pull image) → Deploy

Logging Flow:
    ECS Task → CloudWatch Logs → /ecs/nodejs-jenkins-demo
```

## High Availability

- **Multi-AZ**: Tasks run in 2 availability zones
- **Auto-healing**: ECS restarts failed tasks automatically
- **Load Balancing**: ALB distributes traffic across healthy tasks
- **Health Checks**: ALB monitors /health endpoint every 30s
- **Rolling Updates**: Zero-downtime deployments

## Scalability

- **Horizontal**: Increase task count (currently 2)
- **Vertical**: Increase CPU/memory per task
- **Auto-scaling**: Can add based on CPU/memory/requests
- **Load Balancer**: Handles thousands of requests/second
