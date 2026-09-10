import { Component, Inject } from '@angular/core';
import {
  MAT_DIALOG_DATA,
  MatDialogRef,
  MatDialogModule,
} from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'app-eliminar-dialog',
  templateUrl: './eliminar-dialog.component.html',
  styleUrls: ['./eliminar-dialog.component.scss'],
  standalone: true,
  imports: [MatDialogModule, MatButtonModule],
})
export class EliminarDialogComponent {
  mensaje = '';

  constructor(
    private dialogRef: MatDialogRef<EliminarDialogComponent>,
    @Inject(MAT_DIALOG_DATA) data: { mensaje: string },
  ) {
    this.mensaje = data ? data.mensaje : '';
  }

  confirmar() {
    this.dialogRef.close({
      clicked: 'confirmar',
    });
  }

  cancelar() {
    this.dialogRef.close({
      clicked: 'cancelar',
    });
  }
}
