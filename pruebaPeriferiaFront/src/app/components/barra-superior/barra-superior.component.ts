import { Component, EventEmitter, inject, OnInit, Output } from '@angular/core';
import { RouterLink } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatMenuModule } from '@angular/material/menu';
import { NgClass, SlicePipe, TitleCasePipe } from '@angular/common';
import { MatDialog } from '@angular/material/dialog';
import { CerrarSesionDialogComponent } from '../../dialogs/cerrar-sesion-dialog/cerrar-sesion-dialog.component';
import { AuthStore } from '../../store/auth.store';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-barra-superior',
  templateUrl: './barra-superior.component.html',
  styleUrls: ['./barra-superior.component.scss'],
  standalone: true,
  imports: [
    MatToolbarModule,
    MatButtonModule,
    MatIconModule,
    RouterLink,
    MatMenuModule,
    SlicePipe,
    MatSlideToggleModule,
    NgClass,
    TitleCasePipe,
    TranslateModule,
  ],
})
export class BarraSuperiorComponent implements OnInit {
  temaOscuro = false;
  @Output() cambioMenuLateral = new EventEmitter<void>();
  public dialog = inject(MatDialog);
  public authStore = inject(AuthStore);
  translate = inject(TranslateService);

  username = this.authStore.username;
  sesionIniciada = this.authStore.sesionIniciada;

  ngOnInit(): void {
    this.inicializarTema();
    this.translate.setDefaultLang('en');
  }

  alternarMenu() {
    this.cambioMenuLateral.emit();
  }

  alternarTema() {
    this.temaOscuro = !this.temaOscuro;
    if (this.temaOscuro) {
      document.body.classList.add('dark');
    } else {
      document.body.classList.remove('dark');
    }
    localStorage.setItem('dark-theme', JSON.stringify(this.temaOscuro));
  }

  inicializarTema() {
    const savedTheme = localStorage.getItem('dark-theme');

    if (savedTheme !== null) {
      this.temaOscuro = JSON.parse(savedTheme);
    } else {
      this.temaOscuro = false;
    }

    if (this.temaOscuro) {
      document.body.classList.add('dark');
    } else {
      document.body.classList.remove('dark');
    }
  }

  abrirDialogoCerrarSesion() {
    const dialogRef = this.dialog.open(CerrarSesionDialogComponent, {
      width: '350px',
    });
    dialogRef.afterClosed().subscribe((result) => {});
  }

  cambiarIdioma(idioma: string) {
    this.translate.use(idioma);
  }
}
