# Project Documentation Index

Welcome to the project documentation! The guides are separated by deployment environment and target workflow:

---

## 📚 Documentation Guides

### 🏨 1. [Hostinger VPS Deployment Guide (SSH to Production)](./HOSTINGER_VPS_GUIDE.md)
* **Target Audience**: VPS Hosting (Hostinger, AWS, DigitalOcean, Hetzner).
* **Topics Covered**: Step-by-step from initial SSH connection (`ssh root@ip`), running `setup-vps.sh`, Hostinger DNS configuration, `docker compose up -d`, and enabling free Let's Encrypt SSL.

---

### 🐳 2. [Docker Hub Setup & Registry Guide](./DOCKERHUB_SETUP.md)
* **Target Audience**: Container Registries.
* **Topics Covered**: Creating a Docker Hub account & access token, tagging & pushing images (`docker push`), automating pushes with GitHub Actions, and updating `docker-compose.yml`.

---

### 🤖 3. [Automatic Deployment Guide (CI/CD)](./AUTOMATIC_DEPLOYMENT.md)
* **Target Audience**: Continuous Integration / Continuous Deployment.
* **Topics Covered**: GitHub Actions workflow (`.github/workflows/ci.yml`), setting up GitHub SSH secrets, and automated triggering of `scripts/deploy.sh` on push to `main`/`master`.

---

### 🔄 4. [GitHub Actions & Docker Hub Flowchart Guide](./GITHUB_DOCKERHUB_FLOW.md)
* **Target Audience**: CI/CD & Registry Integration.
* **Topics Covered**: Full start-to-finish process flowchart, step-by-step breakdown, secrets/data matrix, and complete workflow configuration.

---

### 🛠️ 5. [Manual Deployment Guide (VPS & Local)](./MANUAL_DEPLOYMENT.md)
* **Target Audience**: Developers setting up servers manually or running locally.
* **Topics Covered**: One-time server provisioning with `scripts/setup-vps.sh`, manual deployment commands with `scripts/deploy.sh`, and local Docker Compose commands.

---

### 🏗️ 6. [Core DevOps & Infrastructure Architecture](./DEVOPS_SETUP.md)
* **Target Audience**: Infrastructure & System Architecture.
* **Topics Covered**: Nginx reverse proxy configuration (`nginx/default.conf`), Docker multi-stage builds, Node.js 22 upgrade, `.dockerignore` optimizations, and Compose specs.
