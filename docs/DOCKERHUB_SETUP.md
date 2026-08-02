# Docker Hub Setup & Registry Guide

This guide covers how to set up **Docker Hub**, build & tag production images, push them to the registry, and configure your VPS to pull pre-built images.

---

## 1. Why Use Docker Hub?

* **Faster VPS Deployments**: Your VPS downloads ready-to-run compiled images instead of compiling TypeScript/Next.js on the server (saving CPU and RAM).
* **Version Control**: Every deployment can be tagged with a specific version (e.g. `:v1.0.0`, `:latest`, or `:github-sha`).

---

## 2. Step 1: Create Docker Hub Account & Repository

1. Go to [hub.docker.com](https://hub.docker.com) and sign up for a free account.
2. Note your **Docker Hub Username** (e.g., `myusername`).
3. Create two public or private repositories:
   - `fullstack-devops-client`
   - `fullstack-devops-server`
4. Create an Access Token (**Account Settings > Security > New Access Token**):
   - Token Description: `GitHub Actions CI`
   - Permissions: `Read, Write`
   - Copy the generated token!

---

## 3. Step 2: Manual Building & Pushing to Docker Hub

You can manually build and push images from your local terminal:

```bash
# 1. Log in to Docker Hub
docker login -u YOUR_DOCKERHUB_USERNAME

# 2. Build and Tag the Server Image
docker build -t YOUR_DOCKERHUB_USERNAME/fullstack-devops-server:latest ./server

# 3. Build and Tag the Client Image
docker build -t YOUR_DOCKERHUB_USERNAME/fullstack-devops-client:latest ./client

# 4. Push Images to Docker Hub
docker push YOUR_DOCKERHUB_USERNAME/fullstack-devops-server:latest
docker push YOUR_DOCKERHUB_USERNAME/fullstack-devops-client:latest
```

---

## 4. Step 3: Automating Docker Hub Push with GitHub Actions

Add your Docker Hub credentials to GitHub Secrets (**Settings > Secrets > Actions**):
- `DOCKERHUB_USERNAME`: `YOUR_DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`: `YOUR_GENERATED_ACCESS_TOKEN`

Update `.github/workflows/ci.yml` to automatically build & push to Docker Hub:

```yaml
  build-and-push:
    name: "Build & Push to Docker Hub"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: "Log in to Docker Hub"
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: "Build & Push Server Image"
        uses: docker/build-push-action@v5
        with:
          context: ./server
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/fullstack-devops-server:latest

      - name: "Build & Push Client Image"
        uses: docker/build-push-action@v5
        with:
          context: ./client
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/fullstack-devops-client:latest
```

---

## 5. Step 4: Configuring `docker-compose.yml` to use Docker Hub Images

On your VPS, update `docker-compose.yml` to pull pre-built images directly from Docker Hub:

```yaml
services:

  client:
    image: YOUR_DOCKERHUB_USERNAME/fullstack-devops-client:latest
    container_name: fullstack-devops-client
    restart: always

  server:
    image: YOUR_DOCKERHUB_USERNAME/fullstack-devops-server:latest
    container_name: fullstack-devops-server
    restart: always

  nginx:
    image: nginx:alpine
    container_name: fullstack-devops-nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - client
      - server
    restart: always
```
