import { Component } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { AuthApiService } from '../../services/auth-api.service';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [
    MatSnackBarModule,
    ReactiveFormsModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    RouterLink,
  ],
  templateUrl: './forgot-password.component.html',
  styleUrl: './forgot-password.component.scss',
})
export class ForgotPasswordComponent {
  forgotPasswordForm: FormGroup;

  constructor(
    private formBuilder: FormBuilder,
    private authApiService: AuthApiService,
    private snackBar: MatSnackBar,
  ) {
    this.forgotPasswordForm = this.formBuilder.group({
      username: ['', Validators.required],
    });
  }

  onSubmit() {
    if (this.forgotPasswordForm.valid) {
      const username = this.forgotPasswordForm.get('username')?.value;
      this.authApiService.forgotPassword(username).subscribe({
        next: () => {
          this.snackBar.open(
            'Solicitud de restablecimiento enviada. Revisa tu correo.',
            'Cerrar',
            { duration: 5000 },
          );
        },
        error: (err) => {
          this.snackBar.open(
            `Error: ${err?.error?.message || err.message}`,
            'Cerrar',
            { duration: 5000 },
          );
        },
      });
    }
  }
}
