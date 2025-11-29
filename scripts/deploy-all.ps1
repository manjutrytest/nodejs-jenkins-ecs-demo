$REGION = "eu-north-1"
$ENV_NAME = "nodejs-jenkins-demo"

Write-Host "Deploying infrastructure..." -ForegroundColor Green

Write-Host "Deploying VPC..." -ForegroundColor Cyan
aws cloudformation deploy --template-file infra/01-vpc-networking.yml --stack-name "$ENV_NAME-vpc" --region $REGION

Write-Host "Deploying IAM Roles..." -ForegroundColor Cyan
aws cloudformation deploy --template-file infra/03-iam-roles.yml --stack-name "$ENV_NAME-iam" --capabilities CAPABILITY_NAMED_IAM --region $REGION

Write-Host "Deploying ECR..." -ForegroundColor Cyan
aws cloudformation deploy --template-file infra/04-ecr.yml --stack-name "$ENV_NAME-ecr" --region $REGION

Write-Host "Deploying Jenkins EC2..." -ForegroundColor Cyan
aws cloudformation deploy --template-file infra/05-jenkins-ec2.yml --stack-name "$ENV_NAME-jenkins" --region $REGION

Write-Host "Deploying ALB..." -ForegroundColor Cyan
aws cloudformation deploy --template-file infra/06-alb.yml --stack-name "$ENV_NAME-alb" --region $REGION

$JENKINS_IP = aws cloudformation describe-stacks --stack-name "$ENV_NAME-jenkins" --query 'Stacks[0].Outputs[?OutputKey==``JenkinsPublicIP``].OutputValue' --output text --region $REGION

Write-Host "Infrastructure deployed!" -ForegroundColor Green
Write-Host "Jenkins URL: http://$JENKINS_IP:8080" -ForegroundColor Yellow
