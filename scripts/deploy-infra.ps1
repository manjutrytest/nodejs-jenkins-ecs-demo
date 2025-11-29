$REGION = "eu-north-1"
$ENV_NAME = "nodejs-jenkins-demo"

Write-Host "🚀 Deploying infrastructure to $REGION..." -ForegroundColor Green

# Deploy VPC
Write-Host "`n📦 Deploying VPC..." -ForegroundColor Cyan
aws cloudformation deploy `
  --template-file infra/01-vpc-networking.yml `
  --stack-name "$ENV_NAME-vpc" `
  --region $REGION

# Deploy Security Groups
Write-Host "`n🔒 Deploying Security Groups..." -ForegroundColor Cyan
$sgTemplate = @"
AWSTemplateFormatVersion: '2010-09-09'
Description: Security Groups for Jenkins and ECS

Parameters:
  EnvironmentName:
    Type: String
    Default: nodejs-jenkins-demo

Resources:
  JenkinsSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for Jenkins EC2
      VpcId: 
        Fn::ImportValue: !Sub `${EnvironmentName}-VPCId
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 8080
          ToPort: 8080
          CidrIp: 0.0.0.0/0
          Description: Jenkins Web UI
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
          Description: SSH
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: !Sub `${EnvironmentName}-jenkins-sg

  ALBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for Application Load Balancer
      VpcId: 
        Fn::ImportValue: !Sub `${EnvironmentName}-VPCId
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: !Sub `${EnvironmentName}-alb-sg

  ECSSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for ECS tasks
      VpcId: 
        Fn::ImportValue: !Sub `${EnvironmentName}-VPCId
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 3000
          ToPort: 3000
          SourceSecurityGroupId: !Ref ALBSecurityGroup
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: !Sub `${EnvironmentName}-ecs-sg

Outputs:
  JenkinsSecurityGroup:
    Value: !Ref JenkinsSecurityGroup
    Export:
      Name: !Sub `${EnvironmentName}-JenkinsSecurityGroup

  ALBSecurityGroup:
    Value: !Ref ALBSecurityGroup
    Export:
      Name: !Sub `${EnvironmentName}-ALBSecurityGroup

  ECSSecurityGroup:
    Value: !Ref ECSSecurityGroup
    Export:
      Name: !Sub `${EnvironmentName}-ECSSecurityGroup
"@

$sgTemplate | Out-File -FilePath "infra/02-security-groups-temp.yml" -Encoding UTF8
aws cloudformation deploy `
  --template-file infra/02-security-groups-temp.yml `
  --stack-name "$ENV_NAME-security" `
  --region $REGION

# Deploy IAM Roles
Write-Host "`n👤 Deploying IAM Roles..." -ForegroundColor Cyan
aws cloudformation deploy `
  --template-file infra/03-iam-roles.yml `
  --stack-name "$ENV_NAME-iam" `
  --capabilities CAPABILITY_NAMED_IAM `
  --region $REGION

# Deploy ECR
Write-Host "`n📦 Deploying ECR..." -ForegroundColor Cyan
aws cloudformation deploy `
  --template-file infra/04-ecr.yml `
  --stack-name "$ENV_NAME-ecr" `
  --region $REGION

# Deploy Jenkins EC2
Write-Host "`n🔧 Deploying Jenkins EC2..." -ForegroundColor Cyan
aws cloudformation deploy `
  --template-file infra/05-jenkins-ec2.yml `
  --stack-name "$ENV_NAME-jenkins" `
  --region $REGION

# Deploy ALB
Write-Host "`n⚖️ Deploying Application Load Balancer..." -ForegroundColor Cyan
aws cloudformation deploy `
  --template-file infra/06-alb.yml `
  --stack-name "$ENV_NAME-alb" `
  --region $REGION

# Get Jenkins URL
$JENKINS_IP = aws cloudformation describe-stacks `
  --stack-name "$ENV_NAME-jenkins" `
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsPublicIP`].OutputValue' `
  --output text `
  --region $REGION

Write-Host "`n✅ Infrastructure deployed successfully!" -ForegroundColor Green
Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Wait 5-10 minutes for Jenkins to initialize"
Write-Host "2. Access Jenkins at: http://$JENKINS_IP:8080"
Write-Host "3. Get initial admin password"
Write-Host "4. Build and push initial Docker image"
Write-Host "5. Deploy ECS cluster"
