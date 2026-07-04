# casino-backend

Backend desarrollado en **Node.js + Express** para **VidalCasino**, correspondiente a la **Evaluación Parcial 3 (EP3)** de la asignatura **Introducción a Herramientas DevOps (ISY1101)**.

La aplicación expone una **API REST** para autenticación, gestión de usuarios, juegos de casino e historial de transacciones. Se ejecuta como un microservicio dentro de **Amazon EKS**, utilizando **PostgreSQL** como base de datos compartida con los demás servicios.

---

# Arquitectura

```text
                   casino-frontend
                    (LoadBalancer)
                           │
                           ▼
                 casino-backend (3000)
                           │
                           ▼
                     PostgreSQL
```

El servicio se comunica únicamente mediante un **Service ClusterIP**, por lo que no es accesible directamente desde Internet.

---

# Stack

| Capa                 | Tecnología              |
| -------------------- | ----------------------- |
| Runtime              | Node.js 20              |
| Framework            | Express 4               |
| Base de datos        | PostgreSQL 16           |
| Autenticación        | JWT                     |
| Encriptación         | bcryptjs                |
| Cliente PostgreSQL   | pg                      |
| Contenedores         | Docker                  |
| Orquestación         | Kubernetes (Amazon EKS) |
| Registro de imágenes | Amazon ECR              |
| CI/CD                | GitHub Actions          |

---

# Estructura del proyecto

```text
casino-backend/
│
├── src/
│   ├── server.js
│   ├── db/
│   │   ├── pool.js
│   │   └── seed.js
│   ├── middleware/
│   │   └── auth.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── users.js
│   │   ├── games.js
│   │   └── transactions.js
│   └── games/
│       ├── slots.js
│       ├── roulette.js
│       └── blackjack.js
│
├── db/
│   └── init.sql
│
├── kubernetes/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── hpa.yaml
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── Dockerfile
├── .dockerignore
├── package.json
├── .env.example
└── README.md
```

---

# Variables de entorno

| Variable       | Descripción                     |
| -------------- | ------------------------------- |
| PORT           | Puerto del servidor             |
| JWT_SECRET     | Clave para firmar y validar JWT |
| JWT_EXPIRES_IN | Tiempo de expiración del token  |
| DB_HOST        | Host de PostgreSQL              |
| DB_PORT        | Puerto de PostgreSQL            |
| DB_USER        | Usuario                         |
| DB_PASSWORD    | Contraseña                      |
| DB_NAME        | Nombre de la base de datos      |
| CORS_ORIGIN    | Orígenes permitidos             |

En Kubernetes estas variables se cargan desde un **Secret**, evitando almacenar credenciales dentro del repositorio.

---

# Endpoints principales

## Autenticación

| Método | Endpoint             |
| ------ | -------------------- |
| POST   | `/api/auth/register` |
| POST   | `/api/auth/login`    |

## Usuario

| Método | Endpoint                     |
| ------ | ---------------------------- |
| GET    | `/api/usuarios/me`           |
| POST   | `/api/usuarios/me/depositar` |
| GET    | `/api/transacciones`         |

## Juegos

| Método | Endpoint                        |
| ------ | ------------------------------- |
| GET    | `/api/juegos`                   |
| POST   | `/api/juegos/slots/jugar`       |
| POST   | `/api/juegos/roulette/jugar`    |
| POST   | `/api/juegos/blackjack/iniciar` |
| POST   | `/api/juegos/blackjack/accion`  |

## Salud

| Método | Endpoint  | Descripción                       |
| ------ | --------- | --------------------------------- |
| GET    | `/livez`  | Verifica que el proceso esté vivo |
| GET    | `/readyz` | Verifica conexión con PostgreSQL  |

Estas rutas son utilizadas por Kubernetes para las **Liveness** y **Readiness Probes**.

---

# Ejecución local

## Requisitos

* Node.js 20
* PostgreSQL 16

## Instalar dependencias

```bash
npm install
```

## Configurar variables

```bash
cp .env.example .env
```

Editar el archivo `.env` con las credenciales correspondientes.

## Ejecutar

```bash
npm start
```

Disponible en:

```text
http://localhost:3000
```

## Pruebas
Este repo **ya incluye pruebas unitarias** (Jest) de la lógica de juegos y del
middleware de autenticación:
```bash
npm ci
npm test
```

<<<<<<< HEAD
# Docker

## Construir imagen

```bash
docker build -t casino-backend .
```

## Ejecutar

```bash
docker run -p 3000:3000 casino-backend
```

---

# Kubernetes

El backend se despliega mediante un **Deployment** y un **Service ClusterIP**.

Los manifiestos incluyen:

* Deployment
* Service
* Horizontal Pod Autoscaler
* Requests y Limits de CPU
* Variables de entorno mediante Secret
* Liveness Probe
* Readiness Probe

Desplegar:

```bash
kubectl apply -f kubernetes/
```

Verificar:

```bash
kubectl get deployments
kubectl get pods
kubectl get svc
kubectl get hpa
```

---

# Liveness y Readiness

El Deployment utiliza las siguientes sondas:

```yaml
livenessProbe:
  httpGet:
    path: /livez
    port: 3000
```

```yaml
readinessProbe:
  httpGet:
    path: /readyz
    port: 3000
```

* **Liveness Probe:** reinicia el contenedor si el proceso deja de responder.
* **Readiness Probe:** evita enviar tráfico mientras el servicio aún no puede conectarse a PostgreSQL.

---

# CI/CD

El despliegue se automatiza mediante **GitHub Actions**.

Cada push a la rama:

```text
deploy
```

ejecuta el siguiente flujo:

```text
Push

↓

Build Docker

↓

Push Amazon ECR

↓

Deploy Amazon EKS
```

Las imágenes se publican con:

* `latest`
* `${{ github.sha }}`
* `vX.Y.Z`

---

# Autoescalado

El backend utiliza un **Horizontal Pod Autoscaler**.

Configuración:

* CPU objetivo: 50%
* Réplicas mínimas: 2
* Réplicas máximas: 6

El número de Pods aumenta automáticamente cuando la utilización de CPU supera el umbral configurado.

---

# Recuperación automática

Si un Pod falla o es eliminado manualmente:

```bash
kubectl delete pod <nombre-del-pod>
```

Kubernetes crea automáticamente una nueva réplica manteniendo la disponibilidad del servicio.

---

# Base de datos

Todos los microservicios comparten una única instancia de **PostgreSQL**.

Las credenciales se almacenan mediante un **Secret de Kubernetes**.

El archivo:

```text
db/init.sql
```

inicializa el esquema de la base de datos durante el primer despliegue.

---

# Comandos útiles

## Ver Pods

```bash
kubectl get pods
```

## Ver Servicios

```bash
kubectl get svc
```

## Ver HPA

```bash
kubectl get hpa
```

## Ver logs

```bash
kubectl logs <pod>
```

## Reiniciar Deployment

```bash
kubectl rollout restart deployment casino-backend
```

---

# Repositorios relacionados

* casino-frontend
* bonos-service
* apuestas-service
* estadisticas-service

Todos los servicios forman parte de la arquitectura de microservicios desplegada sobre **Amazon EKS**.

---

# Autores

**Evaluación Parcial 3**

Introducción a Herramientas DevOps

ISY1101
=======
## Qué debes hacer en este repo (Entrega ET)
Trabaja en tu **fork**, con ramas `dev` (trabajo) y `deploy` (gatilla el pipeline).

1. **Integrar las pruebas al pipeline (obligatorio):** este repo **ya trae pruebas**
   (`npm ci && npm test`). Agrégalas como etapa que **bloquea el deploy** si fallan:
   build → **test** → push a ECR → deploy a EKS.
2. **Dockerfile** del backend (escucha en el puerto **3000**).
3. **Manifiestos de Kubernetes**: `Deployment` + `Service` **ClusterIP**, con
   `livenessProbe`/`readinessProbe` apuntando a `/livez` y `/readyz` (ya
   implementadas) y la config/secretos desde el Secret compartido `casino-secrets`.
4. **Workflow CI/CD** (`.github/workflows/`) gatillado por `deploy`, con la etapa
   de *test*. Credenciales por **GitHub Secrets**.
5. **HPA** (autoescalado por CPU) y autorecuperación de pods.

> El backend es **interno** (ClusterIP): nunca se expone a Internet.
> Transversal (clúster, una sola vez): **Prometheus + Grafana** y el **video**.
>>>>>>> main
