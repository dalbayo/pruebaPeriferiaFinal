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
  selector: 'app-login',
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
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
})
export class LoginComponent {
  // Tipado inferido desde el fb.group() del constructor (Angular 17 Typed
  // Reactive Forms): si renombras un campo aquí sin actualizar onSubmit()/el
  // template, el compilador avisa en vez de dejar el valor en undefined.
  loginForm;
  loginError: string = '';

  private authStore = inject(AuthStore);

  constructor(
    private router: Router,
    private fb: NonNullableFormBuilder,
    private toastService: NgToastService,
  ) {
    this.loginForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required],
    });
  }

  onSubmit() {
    const { username, password } = this.loginForm.getRawValue();

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
        this.loginError = this.getErrorMessage(err);
        this.toastService.danger(
          this.loginError,
          'ERROR DE INICIO DE SESIÓN',
          4000,
        );
      },
    });
  }

  getErrorMessage(err: HttpErrorResponse): string {
    return (
      err.error?.message ||
      'Usuario o contraseña incorrectos. Intenta de nuevo.'
    );
  }
}
