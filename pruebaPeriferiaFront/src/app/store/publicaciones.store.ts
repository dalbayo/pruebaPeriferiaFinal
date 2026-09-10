import { inject } from '@angular/core';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { tap } from 'rxjs';
import { PublicacionService } from '../services/publicacion.service';
import {
  Publicacion,
  PublicacionCreateRequest,
} from '../models/publicacion.model';

// Manejo de estado de publicaciones con NgRx SignalStore. Centraliza la lista
// (items), el estado de carga/error y el filtro actual (tipo: 0 todas, 1 mias,
// 2 de otros usuarios). Las llamadas HTTP siguen viviendo en PublicacionService.
export interface PublicacionesState {
  items: Publicacion[];
  loading: boolean;
  error: string;
  tipo: number;
}

const initialState: PublicacionesState = {
  items: [],
  loading: false,
  error: '',
  tipo: 0,
};

export const PublicacionesStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),
  withMethods((store, publicacionService = inject(PublicacionService)) => {
    const cargar = (tipo: number = store.tipo()): void => {
      patchState(store, { loading: true, error: '', tipo });
      publicacionService.getPublicaciones(tipo).subscribe({
        next: (items) => patchState(store, { items, loading: false }),
        error: (err) =>
          patchState(store, {
            loading: false,
            error:
              err?.error?.message || 'No se pudieron cargar las publicaciones.',
          }),
      });
    };

    return {
      cargar,

      crear(request: PublicacionCreateRequest) {
        return publicacionService
          .crearPublicacion(request)
          .pipe(tap(() => cargar(store.tipo())));
      },

      actualizar(id: number, request: PublicacionCreateRequest) {
        return publicacionService
          .actualizarPublicacion(id, request)
          .pipe(tap(() => cargar(store.tipo())));
      },

      // Pantalla "Crear publicación" simple: solo mensaje + fecha (default hoy).
      // El titulo (requerido por el backend) se deriva del mensaje.
      crearMensaje(mensaje: string, fechaPublicacion: string) {
        const titulo =
          mensaje.length > 60 ? `${mensaje.substring(0, 57)}...` : mensaje;
        const request: PublicacionCreateRequest = {
          titulo,
          contenido: mensaje,
          estado: 1,
          fechaPublicacion,
        };
        return publicacionService
          .crearPublicacion(request)
          .pipe(tap(() => cargar(store.tipo())));
      },

      eliminar(id: number) {
        patchState(store, { error: '' });
        publicacionService.eliminarPublicacion(id).subscribe({
          next: () => cargar(store.tipo()),
          error: (err) =>
            patchState(store, {
              error: err?.error?.message || 'No se pudo eliminar la publicación.',
            }),
        });
      },
    };
  }),
);
