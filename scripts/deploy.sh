#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================="
echo "🚀 Starting Deployment Process..."
echo "========================================="

# 1. Pull latest code from main branch - TAKE NOTE SOMETIMES PULL ORIGIN MAIN WILL FAIL - MUST USE MASTER 
echo "📥 Pulling latest updates from git repository..."
git pull origin master

# 2. Rebuild and restart containers via Docker Compose
echo "📦 Building and starting Docker containers..."
docker compose up -d --build

# 3. Clean up dangling/unused images to save disk space
echo "🧹 Pruning old unused Docker images..."
docker image prune -f

echo "========================================="
echo "✅ Deployment completed successfully!"
echo "========================================="
