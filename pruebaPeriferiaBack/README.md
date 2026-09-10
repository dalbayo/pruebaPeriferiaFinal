# Periferia Backend

Backend REST desarrollado en **Java 17 + Spring Boot 3.4.2** para la gestión de usuarios, categorías y publicaciones de Periferia IT Group, con autenticación **JWT (access + refresh token)** y soporte para exportación de archivos vía **SSH**.

> Prueba técnica — Sistema de Exportación SSH y Backend (Periferia IT Group).

## Tabla de contenido

- [Stack tecnológico](#stack-tecnológico)
- [Arquitectura del proyecto](#arquitectura-del-proyecto)
- [Requisitos previos](#requisitos-previos)
- [Configuración](#configuración)
- [Puesta en marcha](#puesta-en-marcha)
- [Documentación de la API (Swagger)](#documentación-de-la-api-swagger)
- [Autenticación](#autenticación)
- [Endpoints](#endpoints)
- [Manejo de errores](#manejo-de-errores)
- [Modelo de datos](#modelo-de-datos)
- [Pruebas](#pruebas)
- [Docker](#docker)
- [Notas y consideraciones](#notas-y-consideraciones)

## Stack tecnológico

| Componente | Tecnología |
|---|---|
| Lenguaje | Java 17 |
| Framework | Spring Boot 3.4.2 (`spring-boot-starter-parent`) |
| Web | Spring Web (MVC) |
| Seguridad | Spring Security (stateless) + JWT (`io.jsonwebtoken` / jjwt 0.11.5) |
| Persistencia | Spring Data JPA + Hibernate |
| Base de datos | PostgreSQL (runtime) · H2 en memoria (tests de contexto) |
| Documentación API | springdoc-openapi (Swagger UI) |
| SSH | JSch (`com.github.mwiede:jsch`) — exportación de archivos |
| Utilidades | Lombok, Gson |
| Cobertura | JaCoCo |
| Tests de integración | Testcontainers (PostgreSQL real, requiere Docker) |
| Empaquetado | Maven (`mvnw` incluido) |
| Contenedor | Docker multi-stage (Maven+JDK 17 build → JRE 17 runtime) |

## Arquitectura del proyecto

Estructura en capas dentro de `com.periferia.prueba`:

```
src/main/java/com/periferia/prueba/
├── PeriferiaApplication.java      # Bootstrap (excluye auto-config de seguridad por defecto)
├── config/
│   ├── SecurityConfig.java        # Cadena de filtros, CORS, BCrypt, registro del filtro JWT
│   ├── CorsConfig.java            # CORS a nivel WebMvcConfigurer
│   └── OpenApiConfig.java         # Esquema Bearer para Swagger UI
├── controller/
│   ├── AuthController.java        # /api/auth — login, refresh, /me
│   ├── UsuarioController.java     # /api/usuarios — CRUD
│   ├── CategoriaController.java   # /api/categorias — CRUD
│   ├── PublicacionController.java # /api/publicaciones — CRUD
│   └── TestController.java        # /test/status — healthcheck simple, público
├── dto/                           # LoginRequestDto, TokenResponseDto (records)
├── exception/                     # Excepciones de dominio + ManejadorGlobalDeExcepciones (RFC 7807)
├── model/                         # Entidades JPA: Usuario, Categoria, Publicacion
├── repository/                    # Interfaces JpaRepository + repos *Custom/*Impl
├── security/
│   ├── CustomUserDetailsService.java
│   └── jwt/                       # JwtAuthFilter, JwtService, UserDetailsImpl
├── service/                       # Interfaces (IUsuarioService, IPublicacionService, ICategoriaService)
│   └── impl/                      # Implementaciones
└── util/                          # FlexibleLocalDateTimeDeserializer
```

Patrón general: `Controller → Service (interfaz + impl) → Repository (Spring Data JPA)`, con excepciones de dominio traducidas a respuestas HTTP estandarizadas (`ProblemDetail`) por un `@RestControllerAdvice` central.

## Requisitos previos

- JDK 17
- Maven 3.9+ (o usar el wrapper `./mvnw` / `mvnw.cmd` incluido — no requiere Maven instalado)
- PostgreSQL 13+ en ejecución (para el perfil por defecto)
- Docker (opcional, requerido solo para los tests de integración con Testcontainers y para construir la imagen)

## Configuración

La configuración vive en `src/main/resources/application.properties`. Variables relevantes:

```properties
# Servidor
server.port=8080
server.servlet.context-path=/api/v1

# Base de datos (PostgreSQL)
spring.datasource.url=jdbc:postgresql://localhost:5432/prueba_periferia
spring.datasource.username=postgres
spring.datasource.password=root
spring.jpa.hibernate.ddl-auto=update

# SSH (exportación de archivos)
periferia.ssh.host=192.168.1.100
periferia.ssh.port=22
periferia.ssh.user=admin_ssh
periferia.ssh.password=secreto_periferia
periferia.ssh.remote-path=/home/export/files

# JWT
security.jwt.secret-key=<clave-secreta-larga>
security.jwt.expiration-time=3600000
```

**Antes de desplegar en un entorno real**, reemplaza `spring.datasource.password`, las credenciales SSH y `security.jwt.secret-key` por valores propios (idealmente inyectados por variable de entorno o un gestor de secretos, no versionados en el repositorio).

Crea la base de datos y el esquema con el script incluido en `src/test/resources/db/01-schema.sql` (usado también por los tests de integración con Testcontainers), que crea las tablas `usuario`, `perfil`, `usuario_perfil`, `categoria`, `publicacion`, `publicacion_adjunto` y tablas de auditoría.

## Puesta en marcha

```bash
# Clonar y ubicarse en el proyecto
cd pruebaPeriferiaBack

# Levantar en modo desarrollo
./mvnw spring-boot:run

# o generar el JAR ejecutable
./mvnw clean package
java -jar target/periferia-backend-0.0.1-SNAPSHOT.jar
```

La API queda disponible en `http://localhost:8080/api/v1`.

Verificación rápida (endpoint público, sin autenticación):

```bash
curl http://localhost:8080/api/v1/test/status
```

## Documentación de la API (Swagger)

Con la aplicación corriendo:

- Swagger UI: `http://localhost:8080/api/v1/swagger-ui.html`
- OpenAPI JSON: `http://localhost:8080/api/v1/v3/api-docs`

También hay una colección de Postman disponible en `Claude outputs/pruebaPeriferia.postman_collection.json`.

## Autenticación

El backend usa autenticación **stateless** basada en JWT (`SessionCreationPolicy.STATELESS`). Rutas públicas: `/api/auth/**`, `/test/**` y los recursos de Swagger/OpenAPI; **todo lo demás requiere autenticación**.

Flujo:

1. `POST /api/auth/login` con `username` y `password` → devuelve `accessToken` y `refreshToken`.
2. Enviar el access token en cada request protegido: `Authorization: Bearer {accessToken}`.
3. Cuando el access token expira, `POST /api/auth/refresh` con el `refreshToken` devuelve un par de tokens nuevo (rotación de refresh token).
4. `GET /api/auth/me` permite validar el token actual y obtener los datos del usuario autenticado.

Duración configurada: access token controlado por `security.jwt.expiration-time` (ms); en el flujo de login/refresh el refresh token se persiste con expiración de 7 días.

Las contraseñas se almacenan con **BCrypt** (`PasswordEncoder`), nunca en texto plano, y nunca se devuelven en las respuestas de `UsuarioController` (se limpian antes de serializar).

## Endpoints

Todas las rutas tienen como prefijo `/api/v1` (definido en `server.servlet.context-path`).

### Auth — `/api/auth` (público)

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/auth/login` | Autentica `{ username, password }` y devuelve `{ accessToken, refreshToken }` |
| GET | `/api/auth/me` | Devuelve los datos del usuario autenticado (requiere access token válido) |
| POST | `/api/auth/refresh` | Rota tokens a partir de un `refreshToken` válido y no expirado |

### Usuarios — `/api/usuarios` (requiere JWT)

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/usuarios` | Lista todos los usuarios (password oculto) |
| GET | `/api/usuarios/{id}` | Obtiene un usuario por id |
| POST | `/api/usuarios` | Crea un usuario (password se hashea con BCrypt) |
| PUT | `/api/usuarios/{id}` | Actualiza campos del usuario (password solo si se envía) |
| DELETE | `/api/usuarios/{id}` | Elimina un usuario |

### Categorías — `/api/categorias` (requiere JWT)

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/categorias` | Lista todas las categorías |
| GET | `/api/categorias/{id}` | Obtiene una categoría por id |
| POST | `/api/categorias` | Crea una categoría |
| PUT | `/api/categorias/{id}` | Actualiza nombre/slug |
| DELETE | `/api/categorias/{id}` | Elimina una categoría |

### Publicaciones — `/api/publicaciones` (requiere JWT)

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/publicaciones?tipo=0\|1\|2` | `0` (por defecto) todas · `1` solo del usuario autenticado · `2` de otros usuarios |
| GET | `/api/publicaciones/{id}` | Obtiene una publicación por id |
| POST | `/api/publicaciones` | Crea una publicación (autor tomado del token si no viene en el body; genera slug automáticamente si falta) |
| PUT | `/api/publicaciones/{id}` | Actualiza campos de la publicación |
| DELETE | `/api/publicaciones/{id}` | Elimina una publicación |

### Test — `/test` (público)

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/test/status` | Healthcheck simple, sin autenticación |

## Manejo de errores

Todas las excepciones de dominio se centralizan en `ManejadorGlobalDeExcepciones` y se traducen a respuestas **RFC 7807 (`ProblemDetail`)** con el código HTTP correcto:

| Excepción | HTTP | Caso |
|---|---|---|
| `RecursoNoEncontradoExcepcion` | 404 | Usuario / categoría / publicación inexistente |
| `CredencialesInvalidasExcepcion` | 401 | Token / refresh token inválido, expirado o usuario inactivo |
| `SolicitudInvalidaExcepcion` | 400 | Datos de entrada faltantes o mal formados (validación manual) |
| `ConflictoDeDatosExcepcion` / `DataIntegrityViolationException` | 409 | Username o slug duplicado, violación de constraint |
| `MethodArgumentNotValidException` | 400 | Falla de `@Valid` sobre un DTO (incluye detalle por campo) |
| `BadCredentialsException` / `AuthenticationException` | 401 | Login fallido / no autenticado |
| `AccessDeniedException` | 403 | Sin permisos para la operación |
| Cualquier otra excepción | 500 | Mensaje genérico al cliente; stacktrace completo solo en el log del servidor |

## Modelo de datos

Entidades principales (PostgreSQL):

- **usuario** — credenciales, documento de identidad, estado (`activo`, `eliminado`), access/refresh token y sus expiraciones.
- **perfil** / **usuario_perfil** — catálogo de roles y su relación N:M con usuario.
- **categoria** — catálogo de categorías (`nombre`, `slug` únicos).
- **publicacion** — artículos: autor (`usuario_id`), `categoria_id` opcional, `titulo`, `slug` único, `resumen`, `contenido`, `estado` (0 borrador / 1 publicado / 2 archivado), fechas de publicación/creación/actualización y borrado lógico (`eliminado`).
- **publicacion_adjunto** — archivos adjuntos asociados a una publicación.
- Tablas de auditoría adicionales (ver `src/test/resources/db/01-schema.sql` para el script completo).

El borrado de usuarios y categorías es lógico (`eliminado`), reforzado con `CHECK` constraints en base de datos.

## Pruebas

```bash
./mvnw test
```

- **Tests unitarios / de contexto**: usan un perfil de test con **H2 en memoria** (`application-test.properties`), no requieren nada externo corriendo.
- **Tests de integración** (`*RepositoryImplIT` y similares): usan **Testcontainers** con un PostgreSQL real para validar comportamiento específico de triggers/funciones de la base — **requieren Docker corriendo** en la máquina donde se ejecutan.
- **Cobertura**: generada con JaCoCo en cada `mvn test`, reporte HTML en `target/site/jacoco/index.html`.

## Docker

El `Dockerfile` incluido hace un build multi-stage (Maven + JDK 17 para compilar, JRE 17 para ejecutar), corre como usuario no root y expone el puerto `8080`.

```bash
docker build -t periferia-backend .
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/prueba_periferia \
  -e SPRING_DATASOURCE_USERNAME=postgres \
  -e SPRING_DATASOURCE_PASSWORD=root \
  periferia-backend
```

> Las propiedades de `application.properties` pueden sobreescribirse por variable de entorno usando la convención de Spring Boot (`SPRING_DATASOURCE_URL`, `SECURITY_JWT_SECRET_KEY`, etc.).

## Notas y consideraciones

- `SecurityAutoConfiguration` se excluye explícitamente en `PeriferiaApplication` porque la seguridad se configura a mano en `SecurityConfig`.
- El `JwtAuthFilter` se registra manualmente con `addFilterBefore(...)` y además se desactiva su auto-registro genérico como `Filter` de servlet (`FilterRegistrationBean` con `setEnabled(false)`) para evitar que se ejecute dos veces.
- CORS está configurado de forma abierta (`allowedOriginPatterns("*")` con `allowCredentials(true)`) tanto en `SecurityConfig` como en `CorsConfig` — pensado para el entorno de prueba; conviene restringirlo a los orígenes reales antes de producción.
- El endpoint `POST /api/auth/refresh2` coexiste con `POST /api/auth/refresh` como una variante más antigua del flujo de refresco; se recomienda estandarizar en uno solo (`/refresh`) en una futura limpieza.
- Los valores de `application.properties` (credenciales de BD, SSH y `security.jwt.secret-key`) están en el repositorio como valores de ejemplo/desarrollo — deben externalizarse antes de cualquier despliegue real.
