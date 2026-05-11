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

#Puerto que expone contenedor
EXPOSE 3000

#Comando ejcutable al iniciar contenedor
CMD ["node", "serc/server.js"]