import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import {
  Publicacion,
  PublicacionCreateRequest,
  TipoFiltroPublicaciones,
} from '../models/publicacion.model';

@Injectable({
  providedIn: 'root',
})
export class PublicacionService {
  private readonly baseUrl = `${environment.apiConfig.protocol}://${environment.apiConfig.host}:${environment.apiConfig.port}/api/v1/api/publicaciones`;

  constructor(private http: HttpClient) {}

  // El token JWT se agrega automaticamente via authInterceptor.
  // tipo: 0 = todas, 1 = mis publicaciones (usuario del token), 2 = publicaciones de otros usuarios.
  getPublicaciones(tipo: TipoFiltroPublicaciones = 0): Observable<Publicacion[]> {
    const params = new HttpParams().set('tipo', tipo.toString());
    return this.http.get<Publicacion[]>(this.baseUrl, { params });
  }

  crearPublicacion(request: PublicacionCreateRequest): Observable<Publicacion> {
    return this.http.post<Publicacion>(this.baseUrl, request);
  }

  actualizarPublicacion(
    id: number,
    request: PublicacionCreateRequest,
  ): Observable<Publicacion> {
    return this.http.put<Publicacion>(`${this.baseUrl}/${id}`, request);
  }

  eliminarPublicacion(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`);
  }
}
