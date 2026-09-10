import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthStore } from '../store/auth.store';

export const authGuard: CanActivateFn = (route, state) => {
  const router = inject(Router);
  const authStore = inject(AuthStore);

  if (authStore.isLoggedIn() && state.url == '/login') {
    router.navigate(['/publicaciones']);
    return false;
  } else if (!authStore.isLoggedIn() && state.url == '/login') {
    return true;
  } else if (authStore.isLoggedIn()) {
    return true;
  }

  return router.navigate(['/login-redirect']);


};
