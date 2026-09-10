import { Categoria } from './categoria.model';

// Refleja public.publicacion. El backend (PublicacionController) devuelve la
// entidad JPA tal cual via Jackson: usuario y categoria estan mapeados como
// @ManyToOne (com.periferia.prueba.model.Publicacion), por lo que llegan como
// objetos anidados ({"usuario": {...}, "categoria": {...} | null}), NO como
// usuarioId/categoriaId planos.
export type EstadoPublicacion = 0 | 1 | 2;

/** 0 = todas, 1 = mis publicaciones, 2 = publicaciones de otros usuarios (debe coincidir con PublicacionController) */
export type TipoFiltroPublicaciones = 0 | 1 | 2;

// Solo los campos de Usuario que la UI necesita. El backend expone la entidad
// completa (incluye password/token porque el controller no usa un DTO), pero
// no los modelamos ni los usamos en el frontend.
export interface UsuarioResumen {
  id: number;
  username: string;
}

export interface Publicacion {
  id: number;
  usuario: UsuarioResumen;
  categoria: Categoria | null;
  titulo: string;
  slug: string;
  resumen: string | null;
  contenido: string;
  /** 0 = Borrador, 1 = Publicado, 2 = Archivado */
  estado: EstadoPublicacion;
  fechaPublicacion: string | null;
  creadoEn: string;
  actualizadoEn: string;
  eliminado: number;
}

// Body para POST/PUT /api/publicaciones. El backend (PublicacionController.crear/
// editar) recibe la entidad Publicacion tal cual: usuario se asigna solo desde el
// token, slug se genera solo si viene vacio, y categoria (si aplica) va anidada
// como {id}.
export interface PublicacionCreateRequest {
  titulo: string;
  resumen?: string | null;
  contenido: string;
  estado: EstadoPublicacion;
  fechaPublicacion?: string | null;
  categoria?: { id: number } | null;
}
