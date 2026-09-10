import { Component, ViewChild } from '@angular/core';
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { MatSidenav, MatSidenavModule } from '@angular/material/sidenav';
import { PiePaginaComponent } from './components/pie-pagina/pie-pagina.component';
import { RouterLink, RouterOutlet } from '@angular/router';
import { MatListModule } from '@angular/material/list';
import { BarraSuperiorComponent } from './components/barra-superior/barra-superior.component';
import { NgToastModule, ToasterPosition } from 'ng-angular-popup';
import { TranslateModule } from '@ngx-translate/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
  standalone: true,
  imports: [
    BarraSuperiorComponent,
    MatSidenavModule,
    MatListModule,
    RouterLink,
    RouterOutlet,
    PiePaginaComponent,
    NgToastModule,
    TranslateModule,
  ],
})
export class AppComponent {
  esMovil: boolean = false;
  sidenavAbierto = true;

  ToasterPosition = ToasterPosition;

  @ViewChild('sidenav') sidenav!: MatSidenav;

  constructor(private breakpointObserver: BreakpointObserver) {
    this.esMovil = this.breakpointObserver.isMatched(Breakpoints.Handset);
    if (this.esMovil) {
      this.sidenavAbierto = false;
    }
  }
}
