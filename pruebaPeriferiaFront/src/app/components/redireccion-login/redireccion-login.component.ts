import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-redireccion-login',
  standalone: true,
  imports: [],
  templateUrl: './redireccion-login.component.html',
  styleUrl: './redireccion-login.component.scss',
})
export class RedireccionLoginComponent {
  constructor(private router: Router) {}

  irAIniciarSesion() {
    this.router.navigate(['/login']);
  }
}
