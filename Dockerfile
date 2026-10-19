# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Étape 1 — Build du site statique Astro
# ---------------------------------------------------------------------------
# Node 24 est nécessaire : Astro 7 refuse de démarrer sous Node < 22.22.0.
# Nixpacks ne peut pas fournir cette version (son snapshot nixpkgs est figé et
# ne contient que Node 22.19.0), d'où ce Dockerfile.
FROM node:24-alpine AS build

WORKDIR /app

# Les dépendances d'abord : cette couche n'est reconstruite que si le
# package-lock.json change.
COPY package.json package-lock.json ./
RUN npm ci

# Puis le code source
COPY . .

RUN npm run build

# ---------------------------------------------------------------------------
# Étape 2 — Service du site via nginx
# ---------------------------------------------------------------------------
FROM nginx:1.29-alpine AS runtime

# Configuration nginx (cache, compression, en-têtes de sécurité)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Uniquement le résultat du build, pas node_modules ni les sources
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://127.0.0.1/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
