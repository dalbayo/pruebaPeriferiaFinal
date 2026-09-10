import { Component } from '@angular/core';
import {
  AbstractControl,
  NonNullableFormBuilder,
  ReactiveFormsModule,
  ValidationErrors,
  ValidatorFn,
  Validators,
} from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { AuthApiService } from '../../services/auth-api.service';
import { Router, RouterLink } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { NgToastService } from 'ng-angular-popup';

@Component({
  selector: 'app-signup',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    RouterLink,
  ],
  templateUrl: './signup.component.html',
  styleUrl: './signup.component.scss',
})
export class SignupComponent {
  // Tipado inferido desde el fb.group() del constructor (Angular 17 Typed
  // Reactive Forms) — ver nota en login.component.ts.
  signupForm;
  signupError: string = '';

  passwordMatchValidator: ValidatorFn = (
    control: AbstractControl,
  ): ValidationErrors | null => {
    const password = control.get('password');
    const confirmPassword = control.get('confirmPassword');

    if (password?.invalid) return null;

    if (password?.value !== confirmPassword?.value) {
      confirmPassword?.setErrors({ passwordMismatch: true });
      return { passwordMismatch: true };
    }

    confirmPassword?.setErrors(null);
    return null;
  };

  constructor(
    private fb: NonNullableFormBuilder,
    private authApiService: AuthApiService,
    private router: Router,
    private toastService: NgToastService,
  ) {
    this.signupForm = this.fb.group(
      {
        username: ['', Validators.required],
        password: ['', [Validators.required, Validators.minLength(6)]],
        confirmPassword: ['', Validators.required],
      },
      { validators: this.passwordMatchValidator },
    );
  }

  onSubmit() {
    if (this.signupForm.valid) {
      const { username, password } = this.signupForm.getRawValue();
      this.authApiService.register(username, password).subscribe({
        next: () => {
          this.toastService.success(
            'Usuario creado exitosamente',
            'REGISTRO EXITOSO',
            4000,
          );
          this.router.navigate(['/login']);
        },
        error: (err: HttpErrorResponse) => {
          this.signupError = this.getErrorMessage(err);
          this.toastService.danger(this.signupError, 'ERROR DE REGISTRO', 4000);
        },
      });
    }
  }

  getErrorMessage(err: HttpErrorResponse): string {
    return (
      err.error?.message ||
      'Ocurrió un error desconocido. Intenta de nuevo.'
    );
  }
}
