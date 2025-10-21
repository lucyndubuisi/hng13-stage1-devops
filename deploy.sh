#!/bin/bash
set -e
trap 'echo "Error on line $LINENO"; exit 1' ERR

LOG_FILE="deploy_$(date +%Y%m%d_%H%M%S).log"

echo "Starting Deployment..." | tee -a "$LOG_FILE"

# Collect user inputs
read -p "GitHub Repository URL: " REPO_URL
read -p "Personal Access Token: " PAT
read -p "Branch (default: main): " BRANCH
BRANCH=${BRANCH:-main}
read -p "SSH Username: " USERNAME
read -p "Server IP Address: " SERVER_IP
read -p "SSH Key Path: " SSH_KEY
read -p "Application Port (e.g., 8000): " APP_PORT

# Validate inputs
for var in REPO_URL PAT USERNAME SERVER_IP SSH_KEY APP_PORT; do
  if [ -z "${!var}" ]; then
    echo "$var is required." | tee -a "$LOG_FILE"
    exit 1
  fi
done

# Clone repository
if [ -d "app" ]; then
  cd app && git pull origin $BRANCH
else
  git clone https://${PAT}@${REPO_URL#https://} app
  cd app
fi

git checkout $BRANCH || git checkout -b $BRANCH

# SSH connectivity check
echo "Testing SSH connection..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP "echo SSH connection successful."

# Prepare server environment
echo "Updating and installing dependencies..."
ssh -i "$SSH_KEY" $USERNAME@$SERVER_IP "sudo apt update -y && sudo apt install -y docker.io docker-compose nginx"

# Cleanup old containers
ssh -i "$SSH_KEY" $USERNAME@$SERVER_IP "sudo docker rm -f myapp || true"

# Transfer project files
echo "Transferring project files to server..."
scp -i "$SSH_KEY" -r . $USERNAME@$SERVER_IP:/home/$USERNAME/app

# Build and run Docker containers
echo "Building and running Docker containers..."
ssh -i "$SSH_KEY" $USERNAME@$SERVER_IP "cd /home/$USERNAME/app && sudo docker build -t myapp . && sudo docker run -d -p $APP_PORT:$APP_PORT --name myapp myapp"

# Configure Nginx as reverse proxy
echo "Configuring Nginx..."
ssh -i "$SSH_KEY" $USERNAME@$SERVER_IP "echo 'server {
    listen 80;
    location / {
        proxy_pass http://localhost:$APP_PORT;
    }
}' | sudo tee /etc/nginx/sites-available/myapp"

ssh -i "$SSH_KEY" $USERNAME@$SERVER_IP "sudo ln -sf /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/ && sudo nginx -t && sudo systemctl reload nginx"

# Validate deployment
echo "Validating deployment..."
ssh -i "$SSH_KEY" $USERNAME@$SERVER_IP "sudo docker ps && sudo systemctl status nginx | grep active"

echo "Deployment completed successfully." | tee -a "$LOG_FILE"

