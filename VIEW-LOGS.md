# How to View Node.js Application Logs

## Method 1: AWS CLI (Real-time)

**View live logs (streaming):**
```powershell
aws logs tail /ecs/nodejs-jenkins-demo --follow --region eu-north-1
```

**View last 100 lines:**
```powershell
aws logs tail /ecs/nodejs-jenkins-demo --region eu-north-1
```

**View logs from last 30 minutes:**
```powershell
aws logs tail /ecs/nodejs-jenkins-demo --since 30m --region eu-north-1
```

**View logs from specific time:**
```powershell
aws logs tail /ecs/nodejs-jenkins-demo --since 2025-11-29T18:00:00 --region eu-north-1
```

## Method 2: AWS Console

1. Go to: https://console.aws.amazon.com/cloudwatch/
2. Click **Logs** → **Log groups**
3. Find: `/ecs/nodejs-jenkins-demo`
4. Click on it to see all log streams
5. Click any stream to see logs from that container

## Method 3: ECS Console

1. Go to: https://console.aws.amazon.com/ecs/
2. Click **Clusters** → `nodejs-demo-cluster`
3. Click **Services** → `nodejs-demo-service`
4. Click **Tasks** tab
5. Click any running task
6. Click **Logs** tab

## What You'll See in Logs

**Normal startup:**
```
> nodejs-demo-app@1.0.0 start
> node server.js
Server running on port 3000
```

**During deployments (normal):**
```
npm error signal SIGTERM
npm error command failed
```
This is normal - ECS sends SIGTERM to gracefully stop old containers during rolling updates.

**Application errors (if any):**
```
Error: ...
    at ...
```

## Filter Logs

**Only show "Server running" messages:**
```powershell
aws logs tail /ecs/nodejs-jenkins-demo --region eu-north-1 --filter-pattern "Server running"
```

**Only show errors:**
```powershell
aws logs tail /ecs/nodejs-jenkins-demo --region eu-north-1 --filter-pattern "ERROR"
```

## Export Logs

**Save last hour to file:**
```powershell
aws logs tail /ecs/nodejs-jenkins-demo --since 1h --region eu-north-1 > app-logs.txt
```

## Add More Logging to Your App

Edit `app/server.js` to add more console logs:

```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  console.log(`[${new Date().toISOString()}] GET / - ${req.ip}`);
  res.json({
    message: 'Node.js App - Jenkins CI/CD Demo by manju',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production'
  });
});

app.get('/health', (req, res) => {
  console.log(`[${new Date().toISOString()}] Health check`);
  res.json({ status: 'healthy' });
});

app.listen(PORT, () => {
  console.log(`[${new Date().toISOString()}] Server running on port ${PORT}`);
  console.log(`[${new Date().toISOString()}] Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`[${new Date().toISOString()}] Ready to accept connections`);
});

// Log errors
process.on('uncaughtException', (error) => {
  console.error(`[${new Date().toISOString()}] Uncaught Exception:`, error);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error(`[${new Date().toISOString()}] Unhandled Rejection:`, reason);
});
```

Then push to GitHub and it will auto-deploy with better logging!

## Log Retention

Current setting: **7 days**

To change retention:
```powershell
aws logs put-retention-policy --log-group-name /ecs/nodejs-jenkins-demo --retention-in-days 30 --region eu-north-1
```

Options: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 days

## CloudWatch Insights Queries

Go to CloudWatch → Insights and run queries:

**Count requests per minute:**
```
fields @timestamp, @message
| filter @message like /Server running/
| stats count() by bin(5m)
```

**Find errors:**
```
fields @timestamp, @message
| filter @message like /error/
| sort @timestamp desc
```

**Response times (if you add timing logs):**
```
fields @timestamp, @message
| filter @message like /response time/
| stats avg(@message) by bin(1m)
```

## Quick Commands Reference

```powershell
# Live logs
aws logs tail /ecs/nodejs-jenkins-demo --follow --region eu-north-1

# Last 50 lines
aws logs tail /ecs/nodejs-jenkins-demo --region eu-north-1

# Last 5 minutes
aws logs tail /ecs/nodejs-jenkins-demo --since 5m --region eu-north-1

# Save to file
aws logs tail /ecs/nodejs-jenkins-demo --since 1h --region eu-north-1 > logs.txt

# Filter for errors
aws logs tail /ecs/nodejs-jenkins-demo --filter-pattern "ERROR" --region eu-north-1
```
