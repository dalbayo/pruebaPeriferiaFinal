import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { Categoria } from '../models/categoria.model';

@Injectable({
  providedIn: 'root',
})
export class CategoriaService {
  private readonly baseUrl = `${environment.apiConfig.protocol}://${environment.apiConfig.host}:${environment.apiConfig.port}/api/v1/api/categorias`;

  constructor(private http: HttpClient) {}

  // El token JWT se agrega automaticamente via authInterceptor.
  getCategorias(): Observable<Categoria[]> {
    return this.http.get<Categoria[]>(this.baseUrl);
  }
}
