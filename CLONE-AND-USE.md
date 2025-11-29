# Clone and Use This Repository on Another Laptop

## ✅ What's Ready in the Repository

Your GitHub repo contains everything needed:
- ✅ Node.js application code (`app/`)
- ✅ Dockerfile for containerization
- ✅ Jenkins pipeline configuration (`jenkins/Jenkinsfile`)
- ✅ CloudFormation infrastructure templates (`infra/`)
- ✅ Deployment scripts (`scripts/`)
- ✅ Complete documentation

## 🚀 Quick Start on Another Laptop

### Option 1: Just Make Code Changes (Easiest)

If the infrastructure is already running (like now), anyone can:

```bash
# Clone the repository
git clone https://github.com/manjutrytest/nodejs-jenkins-ecs-demo.git
cd nodejs-jenkins-ecs-demo

# Make changes to the app
code app/server.js  # or use any editor

# Commit and push
git add .
git commit -m "Updated application"
git push origin main
```

**That's it!** Jenkins will automatically build and deploy. No AWS setup needed on their laptop.

### Option 2: Deploy Complete Infrastructure (Advanced)

To deploy the entire infrastructure from scratch on another AWS account:

**Prerequisites:**
- AWS CLI installed and configured
- AWS account with admin access
- Git installed

**Steps:**

```bash
# 1. Clone repository
git clone https://github.com/manjutrytest/nodejs-jenkins-ecs-demo.git
cd nodejs-jenkins-ecs-demo

# 2. Configure AWS CLI
aws configure
# Enter: Access Key, Secret Key, Region (eu-north-1), Output format (json)

# 3. Deploy infrastructure
# On Windows:
powershell -ExecutionPolicy Bypass -File scripts\deploy-all.ps1

# On Linux/Mac:
chmod +x scripts/deploy-infra.sh
./scripts/deploy-infra.sh

# 4. Wait 10-15 minutes for deployment

# 5. Get Jenkins URL
aws cloudformation describe-stacks \
  --stack-name nodejs-jenkins-demo-jenkins \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsURL`].OutputValue' \
  --output text \
  --region eu-north-1

# 6. Setup Jenkins (see GITHUB-SETUP.md)

# 7. Build and push initial image (see QUICK-FIX.md)

# 8. Deploy ECS
aws cloudformation deploy \
  --template-file infra/07-ecs-cluster.yml \
  --stack-name nodejs-jenkins-demo-ecs \
  --region eu-north-1
```

## 📋 What They Need

### For Code Changes Only:
- ✅ Git installed
- ✅ Text editor (VS Code, Notepad++, etc.)
- ✅ GitHub account with push access to the repo

### For Full Infrastructure Deployment:
- ✅ AWS account
- ✅ AWS CLI installed and configured
- ✅ Git installed
- ✅ PowerShell (Windows) or Bash (Linux/Mac)

## 🌐 Current Live URLs (Anyone Can Access)

**Application:**
- http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/
- http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/health

**Jenkins:**
- http://13.60.61.246:8080

Anyone can view the application, but only authorized users can access Jenkins or push to GitHub.

## 🔐 Access Control

### GitHub Repository:
- **Public repo**: Anyone can clone and view
- **Push access**: Only collaborators you add
- **To add collaborators**: 
  - Go to: https://github.com/manjutrytest/nodejs-jenkins-ecs-demo/settings/access
  - Click "Add people"
  - Enter their GitHub username

### Jenkins:
- **Access**: Anyone with the URL can access (currently)
- **To secure**: 
  - Login to Jenkins
  - Manage Jenkins → Security
  - Configure authentication

### AWS Resources:
- **Access**: Only your AWS account
- **To share**: Add IAM users or use AWS Organizations

## 📱 Test from Another Laptop (No Setup Required)

Anyone can test the live application:

```bash
# Test the app
curl http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/

# Test health check
curl http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/health
```

Or just open in a browser:
- http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/

## 🔄 Workflow for Team Members

### Developer Workflow:
```bash
# 1. Clone once
git clone https://github.com/manjutrytest/nodejs-jenkins-ecs-demo.git
cd nodejs-jenkins-ecs-demo

# 2. Create feature branch
git checkout -b feature/my-feature

# 3. Make changes
code app/server.js

# 4. Test locally (optional)
cd app
npm install
npm start
# Visit http://localhost:3000

# 5. Commit and push
git add .
git commit -m "Add new feature"
git push origin feature/my-feature

# 6. Create Pull Request on GitHub

# 7. After merge to main, Jenkins auto-deploys
```

## 📦 What's in the Repository

```
nodejs-jenkins-ecs-demo/
├── app/                          # Node.js application
│   ├── server.js                 # Main application
│   ├── package.json              # Dependencies
│   ├── Dockerfile                # Container definition
│   └── .dockerignore
├── jenkins/
│   └── Jenkinsfile               # CI/CD pipeline
├── infra/                        # CloudFormation templates
│   ├── 01-vpc-networking.yml
│   ├── 02-security-groups.yml
│   ├── 03-iam-roles.yml
│   ├── 04-ecr.yml
│   ├── 05-jenkins-ec2.yml
│   ├── 06-alb.yml
│   └── 07-ecs-cluster.yml
├── scripts/                      # Deployment scripts
│   ├── deploy-infra.sh
│   ├── deploy-all.ps1
│   └── cleanup.sh
├── README.md                     # Project overview
├── DEPLOYMENT-GUIDE.md           # Full deployment guide
├── GITHUB-SETUP.md               # GitHub configuration
├── QUICK-FIX.md                  # Troubleshooting
├── SUCCESS.md                    # Success confirmation
└── VIEW-LOGS.md                  # Log viewing guide
```

## 🎯 Use Cases

### 1. Portfolio/Demo
Share the GitHub URL to show your DevOps skills:
- https://github.com/manjutrytest/nodejs-jenkins-ecs-demo

### 2. Team Development
Add team members as collaborators, they can:
- Clone the repo
- Make changes
- Push to trigger auto-deployment

### 3. Learning/Training
Others can:
- Clone and study the code
- Deploy to their own AWS account
- Modify and experiment

### 4. Interview/Presentation
Show the live application:
- Live URL: http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/
- Explain the architecture
- Demonstrate CI/CD by making a live change

## 🛡️ Security Recommendations

Before sharing widely:

1. **Restrict Jenkins access:**
```bash
# Update security group to allow only your IP
aws ec2 authorize-security-group-ingress \
  --group-id sg-0854d6ac5738a6d1c \
  --protocol tcp --port 8080 \
  --cidr YOUR_IP/32 \
  --region eu-north-1
```

2. **Make GitHub repo private** (if needed):
   - Go to: https://github.com/manjutrytest/nodejs-jenkins-ecs-demo/settings
   - Scroll to "Danger Zone"
   - Click "Change visibility"

3. **Add authentication to Jenkins:**
   - Manage Jenkins → Security
   - Enable security realm
   - Create users

4. **Use AWS Secrets Manager** for sensitive data

## ✅ Ready to Share!

Your repository is complete and ready to:
- ✅ Clone on any laptop
- ✅ Deploy to any AWS account
- ✅ Share with team members
- ✅ Use for portfolio/demos
- ✅ Modify and extend

**Repository URL:**
https://github.com/manjutrytest/nodejs-jenkins-ecs-demo

**Live Application:**
http://nodejs-jenkins-demo-alb-295712721.eu-north-1.elb.amazonaws.com/

Great work! 🚀
