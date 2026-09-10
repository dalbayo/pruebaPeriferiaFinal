import { inject } from '@angular/core';
import {
  patchState,
  signalStore,
  withHooks,
  withMethods,
  withState,
} from '@ngrx/signals';
import { tap } from 'rxjs';
import { AuthApiService } from '../services/auth-api.service';

// Manejo de estado de autenticacion con NgRx SignalStore. La persistencia real
// (localStorage) y las llamadas HTTP siguen viviendo en AuthApiService; este
// store solo mantiene el estado reactivo (signals) que consumen los componentes.
export interface AuthState {
  username: string | null;
  accessToken: string | null;
  isLoggedIn: boolean;
}

const STORAGE_KEYS = {
  accessToken: 'accessToken',
  username: 'username',
};

const initialState: AuthState = {
  username: null,
  accessToken: null,
  isLoggedIn: false,
};

export const AuthStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),
  withMethods((store, authApiService = inject(AuthApiService)) => ({
    login(username: string, password: string) {
      return authApiService.login(username, password).pipe(
        tap(() =>
          patchState(store, {
            username,
            accessToken: authApiService.getAccessToken(),
            isLoggedIn: true,
          }),
        ),
      );
    },

    logout(): void {
      authApiService.logout();
      patchState(store, {
        username: null,
        accessToken: null,
        isLoggedIn: false,
      });
    },
  })),
  withHooks({
    // Sincroniza el estado inicial del store con lo que ya haya en localStorage
    // (sesion previa persistida por AuthApiService).
    onInit(store) {
      patchState(store, {
        username: localStorage.getItem(STORAGE_KEYS.username),
        accessToken: localStorage.getItem(STORAGE_KEYS.accessToken),
        isLoggedIn: !!localStorage.getItem(STORAGE_KEYS.accessToken),
      });
    },
  }),
);
