import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthStore } from '../store/auth.store';

export const authGuard: CanActivateFn = (route, state) => {
  const router = inject(Router);
  const authStore = inject(AuthStore);

  if (authStore.sesionIniciada() && state.url == '/login') {
    router.navigate(['/publicaciones']);
    return false;
  } else if (!authStore.sesionIniciada() && state.url == '/login') {
    return true;
  } else if (authStore.sesionIniciada()) {
    return true;
  }

  return router.navigate(['/login-redirect']);
};
