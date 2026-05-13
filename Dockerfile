#Importamos node (el compilador)
FROM node:20-alpine AS builder
#Buena paractica de metadatos descriptivos
LABEL descripcion="API del casino - evaluacion 2"
#Directorio de la app
WORKDIR /app
#Se copia el package con las dependencias (caché de docker las reutiliza si no cambian)
COPY package*.json ./
#Instalación de dependencias en producción
RUN npm install --omit=dev
#Se copia todo el resto del proyecto
COPY . .

#Etapa del runtime
FROM node:20-alpine AS runtime

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY package.json ./
RUN addgroup -S app && adduser -S app -G app
USER app
#Puerto que expone contenedor
EXPOSE 3000

#Comando ejcutable al iniciar contenedor
CMD ["node", "src/server.js"]