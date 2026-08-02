# Fullstack DevOps & Infrastructure Guide

This document summarizes the end-to-end DevOps configuration, Docker containerization, CI/CD pipeline setup, and optimization steps implemented in this project.

---

## 1. Project Overview & Architecture

The application is structured as a full-stack monorepo:
* **Client**: Next.js 16 (React 19, TailwindCSS v4) running on port `3000`.
* **Server**: Express v5 REST API written in TypeScript built using `tsdown` (Rolldown bundler) running on port `8000`.
* **Containerization**: Docker multi-stage builds managed via Docker Compose.
* **Continuous Integration**: GitHub Actions CI pipeline running automated builds and checks on push/PR.

---

## 2. Docker Setup & Multi-Stage Builds

Both the `client` and `server` services utilize Docker multi-stage builds (`builder` stage and `runner` stage) to ensure minimal production image size and security.

### Server Dockerfile (`server/Dockerfile`)
```dockerfile
FROM node:22-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:22-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 8000
CMD ["node", "dist/server.mjs"]
```

### Client Dockerfile (`client/Dockerfile`)
```dockerfile
FROM node:22-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:22-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
RUN npm ci --omit=dev

EXPOSE 3000
CMD ["npm", "start"]
```

---

## 3. Node.js Version & `Promise.withResolvers` Resolution

### Issue Encountered
During `docker compose up --build`, the server build failed with:
`TypeError: Promise.withResolvers is not a function` at `tsdown` build phase.

### Cause
`tsdown` (v0.22.14) relies on ECMAScript `Promise.withResolvers`, which requires Node.js **v22.0.0+** (or v20.13.0+). The older `node:20-alpine` base image in Docker lagged behind this requirement.

### Fix Applied
Updated the base images in both `server/Dockerfile` and `client/Dockerfile` from `node:20-alpine` to `node:22-alpine` (aligning with Node 22 specified in GitHub Actions CI).

---

## 4. Docker Build Context Optimization (`.dockerignore`)

### Issue Encountered
Docker context transfer was taking over **94 seconds** uploading **135 MB+** of data for the client build context.

### Cause
Without a `.dockerignore` file, Docker was transferring local `node_modules/`, `.next/` cache, `.git/`, and build artifacts across the Docker daemon socket prior to building.

### Fix Applied
Created `.dockerignore` files for both microservices:

#### `client/.dockerignore` & `server/.dockerignore`:
```gitignore
node_modules
.next
dist
build
.git
.gitignore
npm-debug.log*
.env*
```

### Impact
* **Context transfer size**: Reduced from **135 MB+ down to ~1 MB**.
* **Context transfer speed**: Reduced from **94 seconds down to < 1 second**.

---

## 5. Docker Compose Configuration (`docker-compose.yml`)

The services are orchestrated using Docker Compose:

```yaml
services:
  client:
    build:
      context: ./client
      dockerfile: Dockerfile
    container_name: alumnai-client
    ports:
      - "3000:3000"
    depends_on:
      - server

  server:
    build:
      context: ./server
      dockerfile: Dockerfile
    container_name: alumnai-server
    ports:
      - "8000:8000"
```

---

## 6. GitHub Actions CI Pipeline (`.github/workflows/ci.yml`)

Automated CI workflow triggers on pushes and pull requests to `main`/`master` branches:

### Pipeline Highlights
* **Environment**: Node.js 22 LTS on `ubuntu-latest`.
* **Parallel Jobs**: Separate `client` and `server` jobs.
* **Caching**: `actions/setup-node` caching `npm` dependencies via `package-lock.json`.
* **Verification Steps**: `npm ci` and `npm run build`.

```yaml
name: "CI Pipeline"

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  client:
    name: "Client-CI"
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

  server:
    name: "Server-CI"
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
```

---

## 7. Useful Developer Commands

### Local Development
```bash
# Run server locally
cd server
npm run dev

# Run client locally
cd client
npm run dev
```

### Docker Commands
```bash
# Build and start all services
docker compose up --build

# Run containers in detached mode
docker compose up -d --build

# Stop services
docker compose down
```
