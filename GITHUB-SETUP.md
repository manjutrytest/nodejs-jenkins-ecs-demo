# GitHub Repository Setup Guide

## Step 1: Create GitHub Repository

1. **Go to GitHub**: https://github.com
2. **Sign in** to your account (or create one if needed)
3. **Click the "+" icon** in top right → "New repository"
4. **Repository settings**:
   - Repository name: `nodejs-jenkins-ecs-demo`
   - Description: `Node.js CI/CD with Jenkins, Docker, ECR, and ECS`
   - Visibility: Public or Private (your choice)
   - ✅ **DO NOT** initialize with README, .gitignore, or license
5. **Click "Create repository"**

## Step 2: Initialize Local Git Repository

Open PowerShell in your project folder and run:

```powershell
cd C:\Users\mangowra\nodejs-jenkins-ecs-demo

# Initialize git repository
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: Jenkins + Docker + ECR + ECS setup"
```

## Step 3: Connect to GitHub

Replace `YOUR_USERNAME` with your GitHub username:

```powershell
# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-ecs-demo.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**If prompted for credentials:**
- Username: Your GitHub username
- Password: Use a **Personal Access Token** (not your password)

### Create Personal Access Token (if needed)

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Name: `Jenkins CI/CD`
4. Expiration: 90 days (or your preference)
5. Select scopes:
   - ✅ `repo` (all)
   - ✅ `admin:repo_hook` (for webhooks)
6. Click "Generate token"
7. **Copy the token** (you won't see it again!)
8. Use this token as your password when pushing

## Step 4: Verify Repository

```powershell
# Check remote
git remote -v

# Should show:
# origin  https://github.com/YOUR_USERNAME/nodejs-jenkins-ecs-demo.git (fetch)
# origin  https://github.com/YOUR_USERNAME/nodejs-jenkins-ecs-demo.git (push)
```

Visit your repository: `https://github.com/YOUR_USERNAME/nodejs-jenkins-ecs-demo`

## Step 5: Configure Jenkins to Use This Repository

1. **Access Jenkins**: http://13.60.61.246:8080

2. **Get initial password**:
   ```powershell
   ssh ec2-user@13.60.61.246 "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
   ```

3. **Complete Jenkins setup**:
   - Install suggested plugins
   - Install additional plugins:
     - Docker Pipeline
     - Amazon ECR
     - Pipeline: AWS Steps
     - GitHub Integration
   - Create admin user

4. **Create Pipeline Job**:
   - Click "New Item"
   - Name: `nodejs-demo-pipeline`
   - Type: Pipeline
   - Click OK

5. **Configure Pipeline**:
   - **General** section:
     - ✅ GitHub project
     - Project url: `https://github.com/YOUR_USERNAME/nodejs-jenkins-ecs-demo/`
   
   - **Build Triggers**:
     - ✅ GitHub hook trigger for GITScm polling
   
   - **Pipeline** section:
     - Definition: Pipeline script from SCM
     - SCM: Git
     - Repository URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-ecs-demo.git`
     - Credentials: Add → Jenkins
       - Kind: Username with password
       - Username: Your GitHub username
       - Password: Your Personal Access Token
       - ID: github-credentials
       - Description: GitHub Access
     - Branch: `*/main`
     - Script Path: `jenkins/Jenkinsfile`
   
   - Click **Save**

## Step 6: Setup GitHub Webhook (for automatic builds)

1. **Go to your GitHub repository**
2. **Settings** → **Webhooks** → **Add webhook**
3. **Configure webhook**:
   - Payload URL: `http://13.60.61.246:8080/github-webhook/`
   - Content type: `application/json`
   - Which events: "Just the push event"
   - ✅ Active
4. **Click "Add webhook"**

## Step 7: Test the Pipeline

### Option A: Manual Build
1. In Jenkins, click your pipeline job
2. Click "Build Now"
3. Watch the build progress

### Option B: Trigger via Git Push
```powershell
# Make a small change
echo "# Jenkins CI/CD Demo" >> README.md
git add README.md
git commit -m "Test webhook trigger"
git push origin main
```

Jenkins should automatically start building!

## Common Issues & Solutions

### Issue: Git not found
```powershell
# Install Git for Windows
winget install Git.Git
# Or download from: https://git-scm.com/download/win
```

### Issue: Authentication failed
- Use Personal Access Token, not password
- Make sure token has `repo` scope
- Token format: `ghp_xxxxxxxxxxxxxxxxxxxx`

### Issue: Jenkins can't clone repository
- Check credentials in Jenkins
- Make sure repository is accessible (public or credentials are correct)
- Verify Jenkins has internet access

### Issue: Webhook not triggering
- Check webhook delivery in GitHub (Settings → Webhooks → Recent Deliveries)
- Ensure Jenkins URL is accessible from internet
- Security group allows port 8080 from 0.0.0.0/0

## Quick Reference Commands

```powershell
# Check status
git status

# View commit history
git log --oneline

# Create new branch
git checkout -b feature/new-feature

# Push changes
git add .
git commit -m "Your message"
git push origin main

# Pull latest changes
git pull origin main

# View remote URL
git remote -v
```

## Next Steps After Repository Setup

1. ✅ Repository created and pushed
2. ✅ Jenkins configured with repository
3. ✅ Webhook setup for auto-deployment
4. ⏭️ Run first build to push Docker image to ECR
5. ⏭️ Verify ECS tasks are running
6. ⏭️ Test application via ALB URL

Your CI/CD pipeline is now ready! Any push to `main` branch will trigger:
1. Jenkins detects change via webhook
2. Builds Docker image
3. Pushes to ECR
4. Updates ECS service
5. ECS performs rolling deployment
