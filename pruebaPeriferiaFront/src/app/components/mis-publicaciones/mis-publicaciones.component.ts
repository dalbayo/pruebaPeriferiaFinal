import { Component, inject, OnInit } from '@angular/core';
import { NgIf, NgFor } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { AgGridModule } from 'ag-grid-angular';
import {
  CellClickedEvent,
  ColDef,
  GridOptions,
  ValueFormatterParams,
} from 'ag-grid-community';
import { PublicacionesStore } from '../../store/publicaciones.store';
import {
  EstadoPublicacion,
  Publicacion,
  TipoFiltroPublicaciones,
} from '../../models/publicacion.model';
import { PublicacionFormDialogComponent } from '../../dialogs/publicacion-form-dialog/publicacion-form-dialog.component';
import { CrearMensajeDialogComponent } from '../../dialogs/crear-mensaje-dialog/crear-mensaje-dialog.component';
import { EliminarDialogComponent } from '../../dialogs/eliminar-dialog/eliminar-dialog.component';

const ESTADO_LABELS: Record<EstadoPublicacion, string> = {
  0: 'Borrador',
  1: 'Publicado',
  2: 'Archivado',
};

/** 0 = todas, 1 = mis publicaciones, 2 = publicaciones de otros usuarios (debe coincidir con backend) */
export const FILTRO_TIPOS: { valor: TipoFiltroPublicaciones; etiqueta: string }[] = [
  { valor: 0, etiqueta: 'Todas las publicaciones' },
  { valor: 1, etiqueta: 'Mis publicaciones' },
  { valor: 2, etiqueta: 'Publicaciones de otros usuarios' },
];

@Component({
  selector: 'app-mis-publicaciones',
  standalone: true,
  imports: [
    AgGridModule,
    NgIf,
    NgFor,
    FormsModule,
    MatDialogModule,
    MatButtonModule,
  ],
  templateUrl: './mis-publicaciones.component.html',
  styleUrls: ['./mis-publicaciones.component.scss'],
})
export class MisPublicacionesComponent implements OnInit {
  filtroTipos = FILTRO_TIPOS;
  tipoSeleccionado: TipoFiltroPublicaciones = 0;

  // Nombre elegido para que coincida con el input [gridOptions] de
  // ag-grid-angular (API de la librería, no se traduce).
  opcionesGrid: GridOptions = {
    pagination: true,
    paginationPageSize: 10,
    rowHeight: 50,
    defaultColDef: {
      sortable: true,
      filter: true,
      resizable: true,
      floatingFilter: true,
    },
    onCellClicked: (event: CellClickedEvent) => {
      if (event.colDef.field !== 'acciones') {
        return;
      }
      const boton = (event.event?.target as HTMLElement)?.closest('button');
      const accion = boton?.getAttribute('data-action');
      if (accion === 'editar') {
        this.abrirEditarPublicacion(event.data as Publicacion);
      } else if (accion === 'eliminar') {
        this.confirmarEliminarPublicacion(event.data as Publicacion);
      }
    },
  };

  // Alimenta el input [columnDefs] de ag-grid-angular.
  definicionesColumnas: ColDef[] = [
    { field: 'id', headerName: 'ID', width: 90 },
    {
      field: 'acciones',
      headerName: 'Acciones',
      width: 190,
      sortable: false,
      filter: false,
      cellRenderer: () =>
        '<button class="btn btn-sm btn-outline-primary me-1" type="button" data-action="editar">Editar</button>' +
        '<button class="btn btn-sm btn-outline-danger" type="button" data-action="eliminar">Eliminar</button>',
    },
    {
      field: 'titulo',
      headerName: 'Título',
      filter: 'agTextColumnFilter',
      flex: 2,
    },
    {
      field: 'resumen',
      headerName: 'Resumen',
      filter: 'agTextColumnFilter',
      flex: 2,
    },
    {
      field: 'estado',
      headerName: 'Estado',
      width: 130,
      valueFormatter: (params: ValueFormatterParams) =>
        ESTADO_LABELS[params.value as EstadoPublicacion] ?? params.value,
    },
    { field: 'fechaPublicacion', headerName: 'Fecha publicación', width: 170 },
    { field: 'creadoEn', headerName: 'Creado en', width: 170 },
  ];

  private store = inject(PublicacionesStore);

  constructor(private dialog: MatDialog) {}

  // Estado (NgRx SignalStore) expuesto al template.
  get datosFilas(): Publicacion[] {
    return this.store.items();
  }

  get cargando(): boolean {
    return this.store.loading();
  }

  get mensajeError(): string {
    return this.store.error();
  }

  ngOnInit(): void {
    this.store.cargar(this.tipoSeleccionado);
  }

  alCambiarFiltro(): void {
    this.store.cargar(this.tipoSeleccionado);
  }

  abrirCrearPublicacion(): void {
    const dialogRef = this.dialog.open(PublicacionFormDialogComponent, {
      width: '600px',
    });

    dialogRef.afterClosed().subscribe((creada) => {
      if (creada) {
        this.store.cargar(this.tipoSeleccionado);
      }
    });
  }

  abrirCrearMensaje(): void {
    const dialogRef = this.dialog.open(CrearMensajeDialogComponent, {
      width: '500px',
    });

    dialogRef.afterClosed().subscribe((creada) => {
      if (creada) {
        this.store.cargar(this.tipoSeleccionado);
      }
    });
  }

  abrirEditarPublicacion(publicacion: Publicacion): void {
    const dialogRef = this.dialog.open(PublicacionFormDialogComponent, {
      width: '600px',
      data: { publicacion },
    });

    dialogRef.afterClosed().subscribe((actualizada) => {
      if (actualizada) {
        this.store.cargar(this.tipoSeleccionado);
      }
    });
  }

  confirmarEliminarPublicacion(publicacion: Publicacion): void {
    const dialogRef = this.dialog.open(EliminarDialogComponent, {
      data: {
        mensaje: `¿Deseas eliminar la publicación "${publicacion.titulo}"?`,
      },
    });

    dialogRef.afterClosed().subscribe((resultado) => {
      if (resultado?.clicked === 'confirmar') {
        this.store.eliminar(publicacion.id);
      }
    });
  }
}
