# pruebaPeriferiaFrontReal

Angular 17 CRUD skeleton, generado a partir de `pruebaPeriferiaFront`, arrancando en el componente de **Login**.

## Que incluye

- Autenticacion con Firebase: Login, Signup, Forgot Password, Auth Guard, Logout.
- Layout general: Top Nav (menu, tema claro/oscuro, selector de idioma), Sidenav, Footer.
- Soporte multilenguaje (ngx-translate, en/de) y tema claro/oscuro.
- Dialogos reutilizables (confirmacion de borrado, logout, formulario de usuario) con Angular Material.
- Pagina 404 y pagina de redireccion cuando no hay sesion.
- Servicios base: `FirebaseAuthService`, `FirestoreDbService`, `InitConfigService`.

No incluye los componentes de demo del proyecto original (tabla con AG-Grid, generador de facturas, github-user, contact-form, mini-features, products/route-demo).

## Instalacion

```sh
npm install
```

## Configuracion

Antes de correr la app, configura tus propias credenciales de Firebase en `src/environments/environment.ts`.

## Uso

```sh
ng serve
```

Disponible en `http://localhost:4200/`. La ruta raiz (`/`) redirige a `/login`; al iniciar sesion se navega a `/home`.

## Arquitectura

```
src/app/
  components/   -> login, signup, forgot-password, login-redirects, top-nav, footer, page-not-found, home
  dialogs/      -> delete-dialog, logout-dialog, user-form-dialog
  guards/       -> auth.guard.ts
  services/     -> firebase-auth, firestore-db, init-config
  shared/       -> error-constants.ts
```
