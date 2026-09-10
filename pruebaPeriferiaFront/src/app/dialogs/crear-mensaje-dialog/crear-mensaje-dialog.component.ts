import { Component, inject } from '@angular/core';
import { NgIf } from '@angular/common';
import {
  NonNullableFormBuilder,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { PublicacionesStore } from '../../store/publicaciones.store';
import { Publicacion } from '../../models/publicacion.model';

// Pantalla "Crear publicación" simple: solo mensaje + fecha de publicación
// (con valor por defecto = hoy al abrir/guardar). Usa PublicacionesStore
// (NgRx SignalStore) para la mutacion y el refresco de la lista.
@Component({
  selector: 'app-crear-mensaje-dialog',
  templateUrl: './crear-mensaje-dialog.component.html',
  styleUrls: ['./crear-mensaje-dialog.component.scss'],
  standalone: true,
  imports: [
    NgIf,
    MatDialogModule,
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
  ],
})
export class CrearMensajeDialogComponent {
  // Tipado inferido desde el fb.group() del constructor (Angular 17 Typed
  // Reactive Forms).
  mensajeForm;
  guardando = false;
  mensajeError = '';

  private store = inject(PublicacionesStore);

  constructor(
    private fb: NonNullableFormBuilder,
    private dialogRef: MatDialogRef<CrearMensajeDialogComponent>,
  ) {
    this.mensajeForm = this.fb.group({
      mensaje: ['', Validators.required],
      fechaPublicacion: [this.hoyComoInputDate()],
    });
  }

  private hoyComoInputDate(): string {
    const hoy = new Date();
    const mes = String(hoy.getMonth() + 1).padStart(2, '0');
    const dia = String(hoy.getDate()).padStart(2, '0');
    return `${hoy.getFullYear()}-${mes}-${dia}`;
  }

  guardar(): void {
    if (this.mensajeForm.invalid) {
      this.mensajeForm.markAllAsTouched();
      return;
    }

    const { mensaje, fechaPublicacion } = this.mensajeForm.getRawValue();

    this.guardando = true;
    this.mensajeError = '';
    this.store.crearMensaje(mensaje, fechaPublicacion).subscribe({
      next: (creada: Publicacion) => {
        this.guardando = false;
        this.dialogRef.close(creada);
      },
      error: (err: HttpErrorResponse) => {
        this.guardando = false;
        this.mensajeError =
          err.error?.message || 'No se pudo publicar el mensaje.';
      },
    });
  }

  cancelar(): void {
    this.dialogRef.close();
  }
}
