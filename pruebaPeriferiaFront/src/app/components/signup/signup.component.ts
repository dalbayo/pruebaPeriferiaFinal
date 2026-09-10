import { Component } from '@angular/core';
import {
  AbstractControl,
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  ValidationErrors,
  ValidatorFn,
  Validators,
} from '@angular/forms';
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
  signupForm: FormGroup = new FormGroup({});
  signupError: string = '';

  constructor(
    private fb: FormBuilder,
    private authApiService: AuthApiService,
    private router: Router,
    private toastService: NgToastService,
  ) {}

  ngOnInit() {
    this.signupForm = this.fb.group(
      {
        username: ['', Validators.required],
        password: ['', [Validators.required, Validators.minLength(6)]],
        confirmPassword: ['', Validators.required],
      },
      { validator: this.passwordMatchValidator },
    );
  }

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

  onSubmit() {
    if (this.signupForm.valid) {
      const { username, password } = this.signupForm.value;
      this.authApiService.register(username, password).subscribe({
        next: () => {
          this.toastService.success(
            'Usuario creado exitosamente',
            'REGISTRO EXITOSO',
            4000,
          );
          this.router.navigate(['/login']);
        },
        error: (err) => {
          this.signupError = this.getErrorMessage(err);
          this.toastService.danger(this.signupError, 'ERROR DE REGISTRO', 4000);
        },
      });
    }
  }

  getErrorMessage(err: any): string {
    return (
      err?.error?.message ||
      'Ocurrió un error desconocido. Intenta de nuevo.'
    );
  }
}
