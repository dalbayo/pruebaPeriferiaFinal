import { Component, Inject, OnInit, Optional } from '@angular/core';
import { NgIf, NgFor } from '@angular/common';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import {
  MAT_DIALOG_DATA,
  MatDialogModule,
  MatDialogRef,
} from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { PublicacionService } from '../../services/publicacion.service';
import { CategoriaService } from '../../services/categoria.service';
import {
  Publicacion,
  PublicacionCreateRequest,
} from '../../models/publicacion.model';
import { Categoria } from '../../models/categoria.model';

const ESTADOS = [
  { valor: 0, etiqueta: 'Borrador' },
  { valor: 1, etiqueta: 'Publicado' },
  { valor: 2, etiqueta: 'Archivado' },
];

@Component({
  selector: 'app-publicacion-form-dialog',
  templateUrl: './publicacion-form-dialog.component.html',
  styleUrls: ['./publicacion-form-dialog.component.scss'],
  standalone: true,
  imports: [
    NgIf,
    NgFor,
    MatDialogModule,
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
  ],
})
export class PublicacionFormDialogComponent implements OnInit {
  publicacionForm: FormGroup;
  estados = ESTADOS;
  categorias: Categoria[] = [];
  cargandoCategorias = false;
  guardando = false;
  errorMessage = '';
  editMode = false;

  constructor(
    private fb: FormBuilder,
    private publicacionService: PublicacionService,
    private categoriaService: CategoriaService,
    private dialogRef: MatDialogRef<PublicacionFormDialogComponent>,
    @Optional()
    @Inject(MAT_DIALOG_DATA)
    private data: { publicacion?: Publicacion } | null,
  ) {
    const publicacion = this.data?.publicacion;
    this.editMode = !!publicacion;

    this.publicacionForm = this.fb.group({
      titulo: [
        publicacion?.titulo || '',
        [Validators.required, Validators.maxLength(255)],
      ],
      resumen: [publicacion?.resumen || ''],
      contenido: [publicacion?.contenido || '', Validators.required],
      estado: [publicacion?.estado ?? 0, Validators.required],
      categoriaId: [publicacion?.categoriaId ?? null],
      fechaPublicacion: [
        publicacion?.fechaPublicacion
          ? publicacion.fechaPublicacion.substring(0, 10)
          : this.hoyComoInputDate(),
      ],
    });
  }

  private hoyComoInputDate(): string {
    const hoy = new Date();
    const mes = String(hoy.getMonth() + 1).padStart(2, '0');
    const dia = String(hoy.getDate()).padStart(2, '0');
    return `${hoy.getFullYear()}-${mes}-${dia}`;
  }

  ngOnInit(): void {
    this.cargandoCategorias = true;
    this.categoriaService.getCategorias().subscribe({
      next: (categorias) => {
        this.categorias = categorias;
        this.cargandoCategorias = false;
      },
      error: () => {
        this.cargandoCategorias = false;
      },
    });
  }

  submit(): void {
    if (this.publicacionForm.invalid) {
      this.publicacionForm.markAllAsTouched();
      return;
    }

    const raw = this.publicacionForm.value;
    const request: PublicacionCreateRequest = {
      titulo: raw.titulo,
      resumen: raw.resumen || null,
      contenido: raw.contenido,
      estado: raw.estado,
      fechaPublicacion: raw.fechaPublicacion || null,
      categoria: raw.categoriaId ? { id: raw.categoriaId } : null,
    };

    this.guardando = true;
    this.errorMessage = '';

    const peticion = this.editMode
      ? this.publicacionService.actualizarPublicacion(
          this.data!.publicacion!.id,
          request,
        )
      : this.publicacionService.crearPublicacion(request);

    peticion.subscribe({
      next: (resultado: Publicacion) => {
        this.guardando = false;
        this.dialogRef.close(resultado);
      },
      error: (err) => {
        this.guardando = false;
        this.errorMessage =
          err?.error?.message ||
          (this.editMode
            ? 'No se pudo actualizar la publicación.'
            : 'No se pudo crear la publicación.');
      },
    });
  }

  cancel(): void {
    this.dialogRef.close();
  }
}
