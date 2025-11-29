# ---------- Stage 1: Build the Next.js application ----------
FROM node:20-alpine AS builder

# Accept build argument for API host
ARG NEXT_PUBLIC_API_HOST=http://localhost:3001

WORKDIR /app

COPY package*.json ./
RUN npm ci && npm cache clean --force

COPY . .

# This ENV is required for Next.js client-side access
ENV NEXT_PUBLIC_API_HOST=${NEXT_PUBLIC_API_HOST} \
    NEXT_TELEMETRY_DISABLED=1

RUN npm run build
