# Manual Deployment Guide (VPS & Local)

This guide covers how to manually deploy and run the application step-by-step on a fresh **VPS server** or in your **local development environment**.

---

## 1. Initial VPS Server Setup (One-Time Only)

When you first provision a new Ubuntu VPS (AWS EC2, DigitalOcean, Hetzner, etc.):

### Step 1: Connect to your Server via SSH
```bash
ssh ubuntu@YOUR_SERVER_IP
```

### Step 2: Clone the Project Repository
```bash
sudo mkdir -p /var/www
sudo chown -R $USER:$USER /var/www
cd /var/www

git clone https://github.com/YOUR_USERNAME/fullstack-devops.git
cd fullstack-devops
```

### Step 3: Run the Initial VPS Setup Script
Execute [`scripts/setup-vps.sh`](file:///c:/Users/Kyle%20Ando/Desktop/practice/fullstack-devops/scripts/setup-vps.sh) to install Docker, Docker Compose, and configure system permissions:
```bash
bash scripts/setup-vps.sh
```
> **Note**: After running `setup-vps.sh`, log out (`exit`) and SSH back in so user group permissions take effect.

---

## 2. Manual Deployment Steps (Updating Production)

Whenever you want to manually update the live application on your server:

### Option A: Using the Deployment Script (Recommended)
```bash
# Connect to your server
ssh ubuntu@YOUR_SERVER_IP

# Navigate to project folder
cd /var/www/fullstack-devops

# Execute deployment script
bash scripts/deploy.sh
```

### Option B: Executing Individual Docker Commands
```bash
# 1. Pull latest changes
git pull origin main

# 2. Rebuild and restart containers in detached mode
docker compose up -d --build

# 3. Clean up dangling image layers
docker image prune -f
```

---

## 3. Running Locally for Development

To run the full stack (Nginx + Client + Server) on your local computer:

### Step 1: Ensure Docker Desktop is Running
Make sure Docker Desktop is started on Windows/Mac.

### Step 2: Start Containers with Docker Compose
From the root directory of the workspace:
```bash
docker compose up --build
```

### Step 3: Access Applications in Browser
* **Frontend (Client)**: [http://localhost/](http://localhost/) (routed via Nginx)
* **Backend API (Server)**: [http://localhost/api/](http://localhost/api/) (routed via Nginx)
* **Direct Server Port**: [http://localhost:8000/](http://localhost:8000/)

### Step 4: Stopping Services
Press `Ctrl + C` in your terminal or run:
```bash
docker compose down
```
