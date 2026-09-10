import { Component, inject } from '@angular/core';
import { AuthStore } from '../../store/auth.store';
import { Router, RouterLink } from '@angular/router';
import {
  NonNullableFormBuilder,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { JsonPipe } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { NgToastService } from 'ng-angular-popup';

@Component({
  selector: 'app-iniciar-sesion',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    JsonPipe,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    RouterLink,
  ],
  templateUrl: './iniciar-sesion.component.html',
  styleUrl: './iniciar-sesion.component.scss',
})
export class IniciarSesionComponent {
  // Tipado inferido desde el fb.group() del constructor (Angular 17 Typed
  // Reactive Forms).
  formulario;
  errorInicioSesion: string = '';

  private authStore = inject(AuthStore);

  constructor(
    private router: Router,
    private fb: NonNullableFormBuilder,
    private toastService: NgToastService,
  ) {
    this.formulario = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required],
    });
  }

  enviar() {
    const { username, password } = this.formulario.getRawValue();

    this.authStore.login(username, password).subscribe({
      next: () => {
        this.toastService.success(
          'Inicio de sesión exitoso',
          'INICIO DE SESIÓN EXITOSO',
          4000,
        );
        this.router.navigateByUrl('/publicaciones');
      },
      error: (err: HttpErrorResponse) => {
        this.errorInicioSesion = this.obtenerMensajeError(err);
        this.toastService.danger(
          this.errorInicioSesion,
          'ERROR DE INICIO DE SESIÓN',
          4000,
        );
      },
    });
  }

  obtenerMensajeError(err: HttpErrorResponse): string {
    return (
      err.error?.message ||
      'Usuario o contraseña incorrectos. Intenta de nuevo.'
    );
  }
}
