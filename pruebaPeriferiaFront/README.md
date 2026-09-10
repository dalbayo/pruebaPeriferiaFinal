# Prueba Periferia — Front (Angular 17)

Aplicación SPA construida con Angular 17 (standalone components) para gestionar **publicaciones** de usuarios autenticados contra un backend propio (Spring Boot / JWT). El proyecto nace como fork de un skeleton CRUD genérico (`pruebaPeriferiaFront`) y ya fue adaptado a un dominio real de publicaciones y categorías, aunque conserva algunos restos del scaffold original (ver [Deuda técnica](#deuda-técnica-y-limitaciones-conocidas)).

## Stack técnico

| Área | Tecnología |
|---|---|
| Framework | Angular 17 (standalone components, sin `NgModule` de features) |
| UI | Angular Material 17, Angular CDK, Bootstrap 5 (grid/dropdowns), Bootstrap Icons, Font Awesome |
| Estado | `@ngrx/signals` (`signalStore`) — no se usa NgRx clásico (store/effects/reducers) |
| Datos tabulares | `ag-grid-angular` / `ag-grid-community` |
| HTTP | `HttpClient` + interceptor funcional (`authInterceptor`) |
| i18n | `@ngx-translate/core` + `@ngx-translate/http-loader` (en/de) |
| Notificaciones | `ng-angular-popup` (toasts) + `MatSnackBar` |
| Testing | Karma + Jasmine (config por defecto de Angular CLI) |
| Lint/format | ESLint (`@angular-eslint`) + Prettier |

`@angular/fire` está instalado y se inicializa en `app.config.ts`, pero **no se usa para autenticación**: la autenticación real es JWT contra un backend HTTP propio (ver más abajo). Es un remanente del scaffold original.

## Estructura del proyecto

```
src/app/
  app.component.ts / .html      Shell: top-nav + sidenav + router-outlet + footer + toaster
  app.config.ts                 providers: router, HttpClient+interceptor, APP_INITIALIZER,
                                 AngularFireModule (no usado para auth), ngx-translate
  app.routes.ts                 Rutas standalone (ver tabla de rutas)

  components/
    login/                      Login (Reactive Forms tipados) contra AuthApiService
    signup/                     Registro + validador de confirmación de password
    forgot-password/            Recuperación de contraseña
    login-redirects/            Pantalla intermedia cuando no hay sesión
    top-nav/                    Navbar: menú, tema claro/oscuro, selector de idioma, sesión
    footer/                     Pie de página
    page-not-found/             404
    mis-publicaciones/          Listado de publicaciones (ag-Grid) + filtro + acciones

  dialogs/
    publicacion-form-dialog/    Alta/edición de publicación (título, resumen, contenido,
                                 estado, categoría, fecha de publicación)
    crear-mensaje-dialog/       Alta simplificada (solo mensaje + fecha) — ver nota abajo
    delete-dialog/              Confirmación genérica de borrado
    logout-dialog/              Confirmación de cierre de sesión
    user-form-dialog/           ⚠️ No funcional actualmente (ver deuda técnica)

  guards/
    auth.guard.ts                Protege /login (redirige si ya hay sesión) y el resto de
                                 rutas privadas (redirige a /login-redirect si no hay sesión)

  interceptors/
    auth.interceptor.ts          Agrega "Authorization: Bearer <accessToken>" a cada request
                                 saliente cuando hay sesión activa

  services/
    auth-api.service.ts          Login/registro/forgot-password + persistencia de sesión
                                 (localStorage) contra el backend JWT
    publicacion.service.ts       CRUD de publicaciones
    categoria.service.ts         Listado de categorías
    init-config.service.ts       APP_INITIALIZER: precarga usuarios de demo (jsonplaceholder)

  store/
    auth.store.ts                SignalStore de sesión (username, accessToken, isLoggedIn)
    publicaciones.store.ts       SignalStore de publicaciones (items, loading, error, tipo)

  models/                        Interfaces TS (Publicacion, Categoria, LoginRequest/Response)
  shared/error-constants.ts      Mapeo de códigos de error estilo Firebase (no usado hoy)
  data.service.ts                Cliente de la API de GitHub, remanente del scaffold (no usado)

src/environments/                environment.ts / .develop / .qa / .prod
src/assets/i18n/                 en.json, de.json (traducciones parciales)
```

### Rutas

| Ruta | Componente | Guard | Notas |
|---|---|---|---|
| `/` | — | — | Redirige a `/login` |
| `/login` | `LoginComponent` | `authGuard` | Si ya hay sesión, redirige a `/publicaciones` |
| `/signup` | `SignupComponent` | — | |
| `/forgot-password` | `ForgotPasswordComponent` | — | |
| `/login-redirect` | `LoginRedirectsComponent` | — | Pantalla intermedia sin sesión |
| `/publicaciones` | `MisPublicacionesComponent` | `authGuard` | Requiere sesión |
| `**` | `PageNotFoundComponent` | — | |

## Funcionalidades

**Autenticación (JWT contra backend propio)**
Login, registro y "olvidé mi contraseña" contra un backend HTTP (no Firebase, pese al SDK instalado). `AuthApiService` persiste `accessToken`, `refreshToken` y `username` en `localStorage`; `AuthStore` (SignalStore) expone el estado reactivo a los componentes y `authInterceptor` añade el header `Authorization` a cada petición saliente. `authGuard` protege `/login` (evita re-login) y el resto de rutas privadas.

**Gestión de publicaciones (CRUD)**
`MisPublicacionesComponent` lista las publicaciones en una tabla ag-Grid (paginación, filtros por columna, orden) con un selector de filtro por tipo (todas / mías / de otros usuarios, valores `0/1/2` que deben coincidir con `PublicacionController` del backend). Crear y editar usan `PublicacionFormDialogComponent` (título, resumen, contenido, estado —borrador/publicado/archivado—, categoría, fecha de publicación); borrar pasa por `DeleteDialogComponent` como confirmación. `PublicacionesStore` centraliza el estado (`items`, `loading`, `error`, `tipo`) y recarga la lista tras cada mutación.

**Categorías**
`CategoriaService` obtiene el listado desde el backend para poblar el selector del formulario de publicaciones.

**Layout, tema e idioma**
`TopNavComponent` + `MatSidenav` + `FooterComponent` arman el shell de la app. Incluye toggle de tema claro/oscuro (persistido en `localStorage`, clase `dark` en `body`) y selector de idioma inglés/alemán vía `ngx-translate`.

## Puesta en marcha

Requisitos: Node.js compatible con Angular CLI 17 (18.13+ o 20.9+) y npm.

```sh
npm install
```

Antes de levantar la app, revisa `src/environments/environment.ts` (perfil `local`, usado por `ng serve` sin flags): por defecto apunta a un backend en `http://localhost:8080`.

```sh
ng serve
# o, explícitamente:
npm run start
```

Disponible en `http://localhost:4200/`. La ruta raíz redirige a `/login`; tras iniciar sesión se navega a `/publicaciones`.

## Scripts disponibles

| Script | Descripción |
|---|---|
| `npm run start` / `start:develop` / `start:qa` | `ng serve` con configuración local / develop / qa |
| `npm run build` | Build con configuración `production` (default) |
| `npm run build:develop` / `build:qa` / `build:prod` | Build con configuración específica |
| `npm run watch` | Build en modo watch, configuración `development` |
| `npm run test` | Tests unitarios (Karma + Jasmine) |
| `npm run lint` | ESLint sobre `src`, con `--fix` |
| `npm run lint:prettier` | Formatea `.html/.scss/.ts` con Prettier |

## Entornos y backend esperado

| Archivo | Perfil | `apiConfig` (protocol/host/port) |
|---|---|---|
| `environment.ts` | local (default) | `http://localhost:8080` |
| `environment.develop.ts` | develop | `http://localhost:8080` *(TODO: reemplazar por el host real de develop)* |
| `environment.qa.ts` | qa | `https://qa-api.pruebaperiferia.com` *(TODO: confirmar)* |
| `environment.prod.ts` | production | `https://api.pruebaperiferia.com` *(TODO: confirmar)* |

Todos los servicios HTTP arman la URL base como `{protocol}://{host}:{port}/api/v1/api/...` (el doble `/api` viene tal cual del backend actual). Endpoints consumidos hoy:

| Método | Endpoint | Uso |
|---|---|---|
| `POST` | `/api/v1/api/auth/login` | Login |
| `POST` | `/api/v1/api/auth/register` | Registro — *ruta asumida, sin confirmar con backend* |
| `POST` | `/api/v1/api/auth/forgot-password` | Recuperar contraseña — *ruta asumida, sin confirmar* |
| `GET` | `/api/v1/api/publicaciones?tipo=0\|1\|2` | Listado (todas / mías / de otros) |
| `POST` | `/api/v1/api/publicaciones` | Crear |
| `PUT` | `/api/v1/api/publicaciones/{id}` | Editar |
| `DELETE` | `/api/v1/api/publicaciones/{id}` | Eliminar |
| `GET` | `/api/v1/api/categorias` | Listado de categorías |

El backend devuelve las entidades JPA tal cual (sin DTO): `usuario` y `categoria` llegan anidados en `Publicacion`, no como IDs planos — ver los comentarios en `src/app/models/publicacion.model.ts` antes de tocar el contrato.

## Internacionalización

`ngx-translate` está configurado con `en` como idioma por defecto y carga los archivos de `src/assets/i18n/`. Hoy la cobertura de traducción es parcial: solo `topnav.home`, `sidenav.*` y el bloque `home.*` (no usado, ver abajo) están traducidos; el resto de las pantallas (login, signup, mis-publicaciones, diálogos) tiene textos en español embebidos directamente en los templates.

## Deuda técnica y limitaciones conocidas

Esto es una lectura honesta del estado actual del código, útil antes de seguir construyendo sobre él:

- **`UserFormDialogComponent` no compila tal como está**: importa `FirestoreDbService` desde `../../services/firestore-db.service`, archivo que no existe en `src/app/services/`. El componente no está referenciado desde ningún otro lugar de la app (no aparece en `mis-publicaciones` ni en rutas), así que probablemente conviene eliminarlo o terminarlo, no dejarlo a medias.
- **`data.service.ts`** (cliente de la API pública de GitHub) y **`shared/error-constants.ts`** (mensajes de error con códigos estilo `auth/wrong-password` de Firebase) son remanentes del scaffold original; no se usan en el flujo actual de auth JWT / publicaciones.
- **`AngularFireModule` se inicializa en `app.config.ts`** con credenciales de Firebase de ejemplo, pero la autenticación real no pasa por Firebase. Si no hay plan de usar Firestore/Firebase Auth a futuro, es una dependencia candidata a remover (reduce bundle y superficie de configuración).
- **`InitConfigService`** hace un `APP_INITIALIZER` que llama a `jsonplaceholder.typicode.com/users` y guarda el resultado en una propiedad sin tipar (`any`) que además no se usa en ningún componente salvo un `console.log` comentado en `AppComponent`. Es otro resto de demo.
- Los `environment.develop.ts`, `environment.qa.ts` y `environment.prod.ts` tienen host/port de backend marcados como `TODO` en el propio código; antes de desplegar hay que confirmarlos.
- Las rutas de `register` y `forgot-password` en `AuthApiService` están marcadas como asumidas (`TODO: confirmar con backend`).
- `error-constants.ts` sugiere que en algún momento hubo manejo de errores por código; hoy los componentes leen `err.error?.message` con fallback a un texto genérico, así que ese mapeo no se está aplicando.
- Archivo suelto `a.txt` en la raíz del repo, sin relación aparente con el proyecto.

## Pendientes sugeridos

- Confirmar y documentar los endpoints reales de `register`/`forgot-password`, y los hosts de `develop`/`qa`/`prod`.
- Decidir si `UserFormDialogComponent`, `data.service.ts` y `@angular/fire` se completan o se eliminan.
- Completar la cobertura de `ngx-translate` para login/signup/mis-publicaciones/diálogos, o retirar el selector de idioma si no es prioridad.
- Añadir tests unitarios para guards, interceptor y stores (`AuthStore`, `PublicacionesStore`), hoy sin cobertura visible más allá de los specs por defecto del CLI.
