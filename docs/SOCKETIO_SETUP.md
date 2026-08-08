# 🔌 Socket.io Setup & Nginx Integration Guide

This guide explains how to integrate **Socket.io** into your fullstack application (Next.js frontend + Express backend) running behind an **Nginx Reverse Proxy** in Docker.

---

## 🏗️ Architecture & Connection Flow

```
[ Next.js Frontend ] ──(ws://localhost:8000)──► [ Nginx Reverse Proxy (Port 8000) ]
                                                           │
                                            (proxy_pass http://server:8000)
                                                           │
                                                           ▼
                                               [ Express + Socket.io Server ]
```

---

## 1. ⚙️ Nginx Configuration (`nginx/default.conf`)

WebSockets require explicit HTTP header upgrades (`Upgrade: websocket` and `Connection: upgrade`). Without these, Socket.io cannot upgrade from HTTP long-polling to WebSockets.

Ensure your **Port 8000** server block in `nginx/default.conf` looks like this:

```nginx
# Server Proxy (Port 8000)
server {
    listen 8000;
    server_name localhost;

    location / {
        proxy_pass http://server:8000;
        proxy_http_version 1.1;

        # Mandatory WebSocket upgrade headers for Socket.io
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;

        # Extended timeouts to prevent Nginx from dropping idle WebSocket connections after 60s
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}
```

---

## 2. 🖥️ Express Backend Setup

### Installation
```bash
npm install socket.io
```

### Server Code Example (`server/index.js` or `server.mjs`)
Attach Socket.io to an HTTP server and configure **CORS** for the Next.js client (`http://localhost:3000`):

```javascript
import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';

const app = express();
const httpServer = createServer(app);

const io = new Server(httpServer, {
  cors: {
    origin: "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

io.on("connection", (socket) => {
  console.log("Client connected:", socket.id);

  socket.on("ping", (data) => {
    console.log("Received ping:", data);
    socket.emit("pong", { message: "Hello from server!" });
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });
});

const PORT = process.env.PORT || 8000;
httpServer.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
```

---

## 3. 💻 Next.js Frontend Setup

### Installation
```bash
npm install socket.io-client
```

### Client Code Example (`client/app/page.tsx` or React Component)
Connect to the Socket.io server running at `http://localhost:8000`:

```typescript
"use client";

import { useEffect, useState } from "react";
import { io, Socket } from "socket.io-client";

let socket: Socket;

export default function RealtimeComponent() {
  const [status, setStatus] = useState("Disconnected");

  useEffect(() => {
    // Connect to port 8000 (proxied by Nginx)
    socket = io("http://localhost:8000", {
      transports: ["websocket", "polling"]
    });

    socket.on("connect", () => {
      setStatus(`Connected (ID: ${socket.id})`);
    });

    socket.on("pong", (data) => {
      console.log("Server response:", data);
    });

    socket.on("disconnect", () => {
      setStatus("Disconnected");
    });

    return () => {
      socket.disconnect();
    };
  }, []);

  const sendPing = () => {
    socket.emit("ping", { time: new Date() });
  };

  return (
    <div>
      <p>Status: {status}</p>
      <button onClick={sendPing}>Send Ping to Server</button>
    </div>
  );
}
```

---

## 4. 🐳 Docker Compose Port Allocation

> [!WARNING]
> **Avoid Port Conflicts!** Do not map `ports:` in both `client`/`server` AND `nginx` in `docker-compose.yml`.

In `docker-compose.yml`, the `ports` mapping format is **`"HOST_PORT:CONTAINER_PORT"`**:
* **Left Side (`3000`/`8000`)**: Host Machine port accessed by your browser (`http://localhost:3000` / `http://localhost:8000`).
* **Right Side (`3000`/`8000`)**: Port inside the Nginx container referenced by `listen 3000;` and `listen 8000;` in `nginx/default.conf`.

Ensure `docker-compose.yml` routes traffic through Nginx:

```yaml
services:
  client:
    build:
      context: ./client
      dockerfile: Dockerfile
    container_name: fullstack-devops-client
    restart: always

  server:
    build:
      context: ./server
      dockerfile: Dockerfile
    container_name: fullstack-devops-server
    restart: always

  nginx:
    image: nginx:alpine
    container_name: fullstack-devops-nginx
    ports:
      - "3000:3000" # [Host Machine Port - CLIENT] : [Inside Nginx Container Port]
      - "8000:8000" # [Host Machine Port - SERVER] : [Inside Nginx Container Port]
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - client
      - server
    restart: always
```

---

## 5. 🔍 Verification & Troubleshooting

### How to Verify WebSockets are Working
1. Open Browser Dev Tools (`F12`) $\rightarrow$ **Network** tab.
2. Filter by **WS** (WebSockets).
3. Look for the request to `ws://localhost:8000/socket.io/?EIO=4&transport=websocket`.
4. The HTTP status code should be `101 Switching Protocols`.

### Common Issues
* **`ERR_CONNECTION_REFUSED`**: Check if `fullstack-devops-nginx` container is running and binding to `0.0.0.0:8000`.
* **CORS Error in Browser Console**: Ensure `origin: "http://localhost:3000"` is specified in your backend `new Server(httpServer, { cors: { ... } })`.
* **Disconnections every 60 seconds**: Ensure `proxy_read_timeout 86400s;` is set in `nginx/default.conf`.
