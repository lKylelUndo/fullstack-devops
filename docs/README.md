# Project Documentation Index

Welcome to the project documentation! The guides have been separated based on deployment workflow:

---

## 📚 Documentation Guides

### 🤖 1. [Automatic Deployment Guide (CI/CD)](./AUTOMATIC_DEPLOYMENT.md)
* **Target Audience**: Continuous Integration / Continuous Deployment.
* **Topics Covered**: GitHub Actions workflow (`.github/workflows/ci.yml`), setting up GitHub SSH secrets, and automated triggering of `scripts/deploy.sh` on push to `main`.

---

### 🛠️ 2. [Manual Deployment Guide (VPS & Local)](./MANUAL_DEPLOYMENT.md)
* **Target Audience**: Developers setting up servers manually or running locally.
* **Topics Covered**: One-time server provisioning with `scripts/setup-vps.sh`, manual deployment commands with `scripts/deploy.sh`, and local Docker Compose commands.

---

### 🏗️ 3. [Core DevOps & Infrastructure Architecture](./DEVOPS_SETUP.md)
* **Target Audience**: Infrastructure & System Architecture.
* **Topics Covered**: Nginx reverse proxy configuration (`nginx/default.conf`), Docker multi-stage builds, Node.js 22 upgrade, `.dockerignore` optimizations, and Compose specs.
