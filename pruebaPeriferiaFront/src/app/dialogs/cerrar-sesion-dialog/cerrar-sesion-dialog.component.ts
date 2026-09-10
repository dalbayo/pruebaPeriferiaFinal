import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';

import {
  MatDialogModule,
  MatDialogActions,
  MatDialogClose,
  MatDialogContent,
  MatDialogTitle,
  MatDialogRef,
} from '@angular/material/dialog';
import { AuthStore } from '../../store/auth.store';
import { Router } from '@angular/router';

@Component({
  selector: 'app-cerrar-sesion-dialog',
  standalone: true,
  imports: [
    MatDialogModule,
    MatDialogTitle,
    MatDialogContent,
    MatDialogActions,
    MatDialogClose,
    MatButtonModule,
  ],
  templateUrl: './cerrar-sesion-dialog.component.html',
  styleUrl: './cerrar-sesion-dialog.component.scss',
})
export class CerrarSesionDialogComponent {
  private authStore = inject(AuthStore);

  constructor(
    private router: Router,
    private dialogRef: MatDialogRef<CerrarSesionDialogComponent>,
  ) {}

  confirmarCierreSesion() {
    this.authStore.logout();
    this.router.navigate(['/']);
    this.dialogRef.close();
  }
}
