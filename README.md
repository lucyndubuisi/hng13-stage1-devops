# DevOps Stage 1 - Automated Deployment Script

This project contains a Bash script (`deploy.sh`) that simulates a full automated deployment pipeline.

## What it Does
- Accepts user inputs for repository and server configuration.
- Clones a Dockerized app.
- Checks for Docker configuration.
- Simulates SSH connection, server setup, and Nginx configuration.
- Logs all actions and handles errors.

## How to Run
```bash
chmod +x deploy.sh
./deploy.sh
