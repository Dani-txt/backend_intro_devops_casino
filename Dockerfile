#Etapa 1: instalar dependencias
FROM node:20-alpine AS dependencies
LABEL descripcion="API del casino-Vidal"
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev 

#Etapa 2: runtime 
FROM node:20-alpine AS runtime
WORKDIR /app

COPY --from=dependencies --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node src ./src
COPY --chown=node:node package.json ./

RUN mkdir -p /data && chown -R node:node /data

USER node
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://127.0.0.1:3000/health',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["node", "src/server.js"]