# =============================================================================
# Dockerfile - Frontend Angular 17 (periferia-frontend)
# Multi-stage build: compila con Node y sirve el resultado con Nginx.
# =============================================================================

# ---------- Etapa 1: build ----------
FROM node:20-alpine AS build
WORKDIR /app

# Cacheamos dependencias primero (capa reutilizable si package.json no cambia)
COPY package.json package-lock.json ./
# Cambia esto:
# RUN npm ci
# Por esto:
RUN npm install
 
# Ahora copiamos el código y compilamos con la configuración "docker"
# (src/environments/environment.docker.ts -> apiConfig relativo, ver nginx.conf)
COPY . .
RUN npm run build -- --configuration=docker

# ---------- Etapa 2: nginx ----------
FROM nginx:1.27-alpine AS runtime

COPY --from=build /app/dist/pruebaperiferia-frontend/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=5 \
    CMD wget -q --spider http://127.0.0.1:80/ || exit 1
