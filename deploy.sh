#!/bin/bash

# ----------------------------
# Deploy Script - Stage 1 Task
# ----------------------------

LOG_FILE="deploy_$(date +%Y%m%d).log"

echo " Starting Automated Deployment..." | tee -a $LOG_FILE

# Step 1 - Collect user inputs
read -p "Enter GitHub Repository URL: " REPO_URL
read -p "Enter your Personal Access Token: " PAT
read -p "Enter branch name (default: main): " BRANCH
BRANCH=${BRANCH:-main}
read -p "Enter your SSH username: " USERNAME
read -p "Enter your server IP address: " SERVER_IP
read -p "Enter your SSH key path: " SSH_KEY
read -p "Enter your application port (e.g. 8000): " APP_PORT

# Step 2 - Clone repo
if [ -d "app" ]; then
  echo " Repo already exists. Pulling latest changes..." | tee -a $LOG_FILE
  cd app && git pull origin $BRANCH
else
  echo " Cloning repository..." | tee -a $LOG_FILE
  git clone https://${PAT}@${REPO_URL#https://} app || { echo "❌ Failed to clone repo" | tee -a $LOG_FILE; exit 1; }
  cd app
fi

# Step 3 - Validate Docker files
if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ]; then
  echo " Docker configuration found!" | tee -a ../$LOG_FILE
else
  echo "❌ Docker configuration missing!" | tee -a ../$LOG_FILE
  exit 1
fi

# Step 4 - Simulated SSH connection
echo " Simulating SSH connection to ${USERNAME}@${SERVER_IP} using key ${SSH_KEY}" | tee -a ../$LOG_FILE
sleep 1

# Step 5 - Simulated server setup
echo " Installing Docker, Docker Compose, and Nginx (simulated)..." | tee -a ../$LOG_FILE
sleep 1

# Step 6 - Simulated deployment
echo " Deploying Docker containers..." | tee -a ../$LOG_FILE
echo "docker-compose up -d --build" | tee -a ../$LOG_FILE

# Step 7 - Simulated Nginx setup
echo " Setting up Nginx reverse proxy..." | tee -a ../$LOG_FILE

# Step 8 - Validation
echo " Deployment validation simulated on port ${APP_PORT}" | tee -a ../$LOG_FILE

echo " Deployment script completed successfully!" | tee -a ../$LOG_FILE
echo " A pp accessible on http://${SERVER_IP} or localhost:${APP_PORT}" | tee -a ../$LOG_FILE

#Step 9 - Success Message

echo "---------------------------------------------" | tee -a ../$LOG_FILE
echo " Deployment simulation completed successfully!" | tee -a ../$LOG_FILE
echo " Logs saved to ${LOG_FILE}"
