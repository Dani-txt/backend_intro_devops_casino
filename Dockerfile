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

#Actualizar la ip a nuestra instancia ec2 del back (actualemnte es la del profe, el ejemplo de la actividad 2.4)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://127.0.0.1:3000/health',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

#Comando ejcutable al iniciar contenedor
CMD ["node", "src/server.js"]


