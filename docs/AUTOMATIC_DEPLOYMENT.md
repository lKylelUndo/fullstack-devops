# Automatic Deployment Guide (CI/CD Pipeline)

This guide covers the fully automated deployment workflow using **GitHub Actions** and **SSH** to continuously deploy your application whenever code is pushed to the `main` branch.

---

## 1. Automated Pipeline Overview

```mermaid
flowchart LR
    Push(["👨‍💻 Developer Push to main"]) --> GHA["🤖 GitHub Actions Triggered"]
    
    subgraph ci_phase ["CI Phase (GitHub Runners)"]
        GHA --> ClientCI["Client: npm ci & build"]
        GHA --> ServerCI["Server: npm ci & build"]
    end

    subgraph cd_phase ["CD Phase (SSH Deployment)"]
        ClientCI --> SSH["SSH into Production VPS"]
        ServerCI --> SSH
        SSH --> RunScript["Run scripts/deploy.sh"]
        RunScript --> Rebuild["docker compose up -d --build"]
    end

    Rebuild --> Production(["🌐 Live Production App"])
```

---

## 2. GitHub Repository Secrets Setup

To allow GitHub Actions to SSH into your production server automatically, add the following encrypted secrets in GitHub (**Settings > Secrets and variables > Actions**):

| Secret Name | Description | Example Value |
| :--- | :--- | :--- |
| `VPS_HOST` | Public IP address or domain of your VPS | `192.0.2.1` |
| `VPS_USERNAME` | SSH username | `ubuntu` or `root` |
| `VPS_SSH_KEY` | Private SSH key matching `~/.ssh/authorized_keys` on server | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `VPS_PORT` | SSH Port (default is 22) | `22` |

---

## 3. GitHub Actions CI/CD Workflow (`.github/workflows/ci.yml`)

Here is the complete automated workflow including CI checks and automated SSH deployment:

```yaml
name: "CI/CD Pipeline"

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  client-ci:
    name: "Client CI (Build Check)"
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./client
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
          cache-dependency-path: client/package-lock.json
      - run: npm ci
      - run: npm run build

  server-ci:
    name: "Server CI (Build Check)"
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./server
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
          cache-dependency-path: server/package-lock.json
      - run: npm ci
      - run: npm run build

  deploy-cd:
    name: "Automated VPS Deployment"
    needs: [client-ci, server-ci]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - name: "Executing remote SSH commands"
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          port: ${{ secrets.VPS_PORT || 22 }}
          script: |
            cd /var/www/fullstack-devops
            bash scripts/deploy.sh
```

---

## 4. How the Automated Script Works

When GitHub Actions SSHs into your server, it executes [`scripts/deploy.sh`](file:///c:/Users/Kyle%20Ando/Desktop/practice/fullstack-devops/scripts/deploy.sh):

1. **`git pull origin main`**: Pulls latest committed code.
2. **`docker compose up -d --build`**: Builds updated images and performs zero-downtime container swaps.
3. **`docker image prune -f`**: Deletes outdated image layers to keep VPS disk space clean.
