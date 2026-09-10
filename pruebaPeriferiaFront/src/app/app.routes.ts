import { Routes } from '@angular/router';
import { PaginaNoEncontradaComponent } from './components/pagina-no-encontrada/pagina-no-encontrada.component';
import { IniciarSesionComponent } from './components/iniciar-sesion/iniciar-sesion.component';
import { RegistroComponent } from './components/registro/registro.component';
import { RecuperarContrasenaComponent } from './components/recuperar-contrasena/recuperar-contrasena.component';
import { authGuard } from './guards/auth.guard';
import { RedireccionLoginComponent } from './components/redireccion-login/redireccion-login.component';
import { MisPublicacionesComponent } from './components/mis-publicaciones/mis-publicaciones.component';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  {
    path: 'login',
    component: IniciarSesionComponent,
    canActivate: [authGuard],
    title: 'Iniciar sesión',
  },
  { path: 'signup', component: RegistroComponent, title: 'Registro' },
  {
    path: 'forgot-password',
    component: RecuperarContrasenaComponent,
    title: 'Recuperar contraseña',
  },
  { path: 'login-redirect', component: RedireccionLoginComponent },
  {
    path: 'publicaciones',
    component: MisPublicacionesComponent,
    canActivate: [authGuard],
    title: 'Mis publicaciones',
  },
  { path: '**', component: PaginaNoEncontradaComponent },
];
