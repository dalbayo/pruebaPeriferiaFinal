# Prueba Periferia — Solución completa (Backend + Frontend + Docker)

Sistema de gestión de publicaciones de Periferia IT Group: backend REST en **Spring Boot 3.4.2 / Java 17** con autenticación JWT, frontend **Angular 17** (standalone components) y base de datos **PostgreSQL**, integrados y desplegables como una sola solución con **Docker Compose**.

```
Frontend Angular 17  →  Nginx  →  Backend API (Spring Boot)  →  PostgreSQL
   (contenedor)         (mismo contenedor, sirve el build     (contenedor)      (contenedor)
                          y hace proxy de /api/v1/)
```

## Estructura del repositorio

```
pruebaPeriferiaFinal/
├── docker-compose.yml          Orquesta los 3 servicios (db, backend, frontend)
├── .env.example                Plantilla de variables de entorno (copiar a .env)
├── db/init/01-schema.sql       Script de creación de esquema (solo 1er arranque de Postgres)
├── pruebaPeriferiaBack/        Backend Spring Boot — ver su propio README.md
└── pruebaPeriferiaFront/       Frontend Angular 17 — ver su propio README.md
```

Cada subproyecto tiene su propio `README.md` con el detalle técnico interno (endpoints, modelo de datos, estructura de componentes, scripts npm/maven, etc.). Este README cubre la **integración de ambos y el despliegue con Docker**.

## Requisitos previos

- Docker Desktop (con Docker Compose v2, incluido en versiones recientes)
- Puertos libres en el host: `5432` (Postgres), `8080` (backend), `8090` (frontend) — configurables, ver más abajo

## Configuración

Copia la plantilla de variables de entorno y ajusta los valores según tu entorno:

```bash
cp .env.example .env
```

Variables disponibles (`.env.example`):

| Variable | Uso | Valor por defecto |
|---|---|---|
| `DB_USER` | Usuario de PostgreSQL | `postgres` |
| `DB_PASSWORD` | Password de PostgreSQL | `root` |
| `DB_EXPOSED_PORT` | Puerto de Postgres publicado en el host | `5432` |
| `BACKEND_EXPOSED_PORT` | Puerto del backend publicado en el host | `8080` |
| `JWT_SECRET` | Clave secreta para firmar los JWT | valor de ejemplo — **cambiar en cualquier entorno real** |
| `JWT_EXPIRATION` | Expiración del access token (ms) | `3600000` (1 hora) |
| `FRONTEND_EXPOSED_PORT` | Puerto del frontend (Nginx) publicado en el host | `8090` |

El archivo `.env` está en `.gitignore` y nunca debe subirse al repositorio — solo `.env.example` (sin secretos reales) va versionado.

## Puesta en marcha con Docker

Desde la raíz del repositorio (`pruebaPeriferiaFinal/`):

```bash
# Construir las 3 imágenes (db usa la imagen oficial, no requiere build)
docker compose build

# Levantar todo en segundo plano
docker compose up -d

# Ver el estado de los contenedores
docker compose ps
```

**Acceso a la aplicación:** `http://localhost:8090`

El frontend queda servido por Nginx y hace de único punto de entrada; el navegador nunca llama directamente al backend en `:8080`, todo pasa por el proxy interno de Nginx (ver [Arquitectura de red](#arquitectura-de-red-interna-y-cors)).

Documentación interactiva del backend (Swagger UI), accesible directamente si necesitas probar la API por separado: `http://localhost:8080/api/v1/swagger-ui.html`

### Ver logs

```bash
docker compose logs -f              # todos los servicios
docker compose logs -f frontend     # solo Nginx/Angular
docker compose logs -f backend      # solo Spring Boot
docker compose logs -f db           # solo Postgres
```

### Detener

```bash
docker compose down        # detiene y elimina los contenedores, conserva el volumen de datos
docker compose down -v     # además elimina el volumen periferia_pgdata (borra los datos de la BD)
```

### Reconstruir tras cambios

```bash
docker compose up -d --build frontend   # solo frontend
docker compose up -d --build backend    # solo backend
docker compose up -d --build            # todo
```

## Arquitectura de red interna y CORS

Los 3 servicios comparten la red Docker `periferia-net`. El backend **no es alcanzable directamente desde el navegador del usuario** salvo por el puerto publicado explícitamente para pruebas (`8080`): el flujo normal de la aplicación pasa por Nginx.

`pruebaPeriferiaFront/nginx.conf` sirve el build de Angular como archivos estáticos y además actúa como **reverse proxy**: toda petición a `/api/v1/` se reenvía internamente a `http://backend:8080/api/v1/` (nombre de servicio Docker, resuelto por la red interna de Compose).

Ventaja de este diseño: como el navegador solo habla con un origen (`localhost:8090`), **las peticiones a la API son same-origin** y no hace falta configurar CORS para el flujo dockerizado — se evita así tocar la configuración de CORS del backend (que hoy está abierta con `allowedOriginPatterns("*")`, pensada para desarrollo). Si en algún momento el frontend se sirve desde un dominio distinto al backend (por ejemplo, un despliegue sin este proxy), sí habrá que revisar `SecurityConfig`/`CorsConfig` en el backend.

## Autenticación JWT (resumen de integración)

El backend expone `POST /api/v1/api/auth/login` devolviendo `{ accessToken, refreshToken }`. El frontend:

- Persiste ambos tokens en `localStorage` (`AuthApiService` / `AuthStore`).
- Adjunta `Authorization: Bearer {accessToken}` a cada petición saliente mediante un interceptor HTTP funcional (`authInterceptor`).
- Protege las rutas privadas con `authGuard`, que redirige a login si no hay sesión.

El access token expira según `JWT_EXPIRATION`; el backend expone `POST /api/v1/api/auth/refresh` para rotarlo con el refresh token. Detalle completo del flujo y los endpoints en el README del backend.

## Persistencia de datos

El volumen nombrado `periferia_pgdata` conserva los datos de PostgreSQL entre reinicios de los contenedores. Solo se ejecuta el script `db/init/01-schema.sql` la primera vez que el volumen está vacío (comportamiento estándar de la imagen oficial de Postgres); si necesitas reaplicar el esquema desde cero, usa `docker compose down -v`.

## Desarrollo sin Docker (opcional)

Para trabajar día a día sin reconstruir imágenes cada vez, cada subproyecto puede levantarse por separado en modo desarrollo — ver la sección "Puesta en marcha" de cada README:

- Backend: `./mvnw spring-boot:run` (requiere Postgres accesible en `localhost:5432`, o el contenedor `db` levantado con `docker compose up -d db`)
- Frontend: `npm install && ng serve` (por defecto apunta a `http://localhost:8080`, `environment.ts`)

La configuración `docker` de Angular (`ng build --configuration=docker` / `environment.docker.ts`) es exclusiva del build dentro del contenedor Nginx — no se usa en `ng serve` local.

## Solución de problemas comunes

**El navegador no puede hacer login / errores CORS**
Si accedes por `http://localhost:8090` (vía Docker) no deberías ver errores de CORS — todo es same-origin gracias al proxy de Nginx. Si los ves, revisa que estés entrando por el puerto del frontend y no llamando directamente a `localhost:8080` desde una app corriendo en otro origen.

**401 / 403 al llamar a la API**
Verifica que el `accessToken` se esté enviando (`Authorization: Bearer ...`) y que no haya expirado (`JWT_EXPIRATION`). Si expiró, el frontend debe pasar por `/api/v1/api/auth/refresh`; si el refresh también expiró (7 días), hay que volver a hacer login.

**Puerto ya en uso al levantar Docker**
Ajusta `DB_EXPOSED_PORT`, `BACKEND_EXPOSED_PORT` o `FRONTEND_EXPOSED_PORT` en `.env` a un puerto libre y vuelve a correr `docker compose up -d`.

**Rutas de Angular devuelven 404 al refrescar la página (F5)**
Dentro de Docker esto ya está resuelto: `nginx.conf` usa `try_files $uri $uri/ /index.html;` como fallback para el router de Angular. Si ves 404 en un despliegue distinto (por ejemplo, un hosting estático sin esta regla), hay que replicar esa configuración de fallback en el servidor que sirva el `dist/`.

**`docker compose build` falla con errores de `npm ci` / lock file desincronizado**
`npm ci` exige que `package-lock.json` esté sincronizado con `package.json`. Si editaste dependencias a mano, regenera el lock file antes de reconstruir la imagen:
```bash
cd pruebaPeriferiaFront
rm -rf node_modules package-lock.json
npm install
```

**La base de datos no tiene las tablas esperadas**
El script `db/init/01-schema.sql` solo corre en el primer arranque del volumen `periferia_pgdata`. Si el volumen ya existía de una ejecución anterior, el script no se vuelve a ejecutar. Usa `docker compose down -v` para forzar un volumen limpio y que el script corra de nuevo.

## Restricciones respetadas en esta integración

- No se modificó la lógica de negocio existente del backend.
- No se inventaron endpoints ni credenciales: las rutas documentadas son las que expone `PublicacionController`, `UsuarioController`, `CategoriaController` y `AuthController` tal como están implementados.
- Los secretos (`JWT_SECRET`, credenciales de BD) viven en `.env` (no versionado); `.env.example` solo contiene valores de ejemplo.
- CORS no requirió cambios en el backend gracias al proxy de Nginx dentro del contenedor del frontend.
- Configuración separada por ambiente: `environment.ts` (local), `environment.develop.ts`, `environment.qa.ts`, `environment.prod.ts` y `environment.docker.ts` (exclusivo del build en contenedor).
