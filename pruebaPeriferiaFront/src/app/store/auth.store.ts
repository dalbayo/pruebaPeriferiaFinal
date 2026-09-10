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
//
// username/accessToken se mantienen en inglés a propósito: reflejan el
// contrato JSON exacto con el backend (LoginRequestDto.username/password,
// columna "username" de la tabla usuario) — ver models/auth.model.ts.
export interface AuthState {
  username: string | null;
  accessToken: string | null;
  sesionIniciada: boolean;
}

const STORAGE_KEYS = {
  accessToken: 'accessToken',
  username: 'username',
};

const initialState: AuthState = {
  username: null,
  accessToken: null,
  sesionIniciada: false,
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
            sesionIniciada: true,
          }),
        ),
      );
    },

    logout(): void {
      authApiService.logout();
      patchState(store, {
        username: null,
        accessToken: null,
        sesionIniciada: false,
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
        sesionIniciada: !!localStorage.getItem(STORAGE_KEYS.accessToken),
      });
    },
  }),
);
