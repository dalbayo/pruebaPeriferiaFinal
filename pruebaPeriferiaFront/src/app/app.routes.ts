import { Routes } from '@angular/router';
import { PageNotFoundComponent } from './components/page-not-found/page-not-found.component';
import { LoginComponent } from './components/login/login.component';
import { SignupComponent } from './components/signup/signup.component';
import { ForgotPasswordComponent } from './components/forgot-password/forgot-password.component';
import { authGuard } from './guards/auth.guard';
import { LoginRedirectsComponent } from './components/login-redirects/login-redirects.component';
import { MisPublicacionesComponent } from './components/mis-publicaciones/mis-publicaciones.component';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  {
    path: 'login',
    component: LoginComponent,
    canActivate: [authGuard],
    title: 'Login',
  },
  { path: 'signup', component: SignupComponent, title: 'Signup' },
  {
    path: 'forgot-password',
    component: ForgotPasswordComponent,
    title: 'Forgot Password',
  },
  { path: 'login-redirect', component: LoginRedirectsComponent },
  {
    path: 'publicaciones',
    component: MisPublicacionesComponent,
    canActivate: [authGuard],
    title: 'Mis publicaciones',
  },
  { path: '**', component: PageNotFoundComponent },
];
