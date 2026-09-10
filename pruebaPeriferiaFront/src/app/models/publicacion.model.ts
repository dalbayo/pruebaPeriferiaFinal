// Refleja public.publicacion. Se asume que el backend serializa las columnas
// snake_case (usuario_id, categoria_id, ...) como propiedades camelCase en el JSON,
// que es el comportamiento por defecto de Jackson en Spring Boot. Si el backend
// devuelve otro formato (snake_case u otro wrapper), ajustar aqui y en el servicio.
export interface Publicacion {
  id: number;
  usuarioId: number;
  categoriaId: number | null;
  titulo: string;
  slug: string;
  resumen: string | null;
  contenido: string;
  /** 0 = Borrador, 1 = Publicado, 2 = Archivado (confirmar con backend) */
  estado: number;
  fechaPublicacion: string | null;
  creadoEn: string;
  actualizadoEn: string;
  eliminado: number;
}

// Body para POST /api/publicaciones. El backend (PublicacionController.crear)
// recibe la entidad Publicacion tal cual: usuario se asigna solo desde el token,
// slug se genera solo si viene vacio, y categoria (si aplica) va anidada como {id}.
export interface PublicacionCreateRequest {
  titulo: string;
  resumen?: string | null;
  contenido: string;
  /** 0 = Borrador, 1 = Publicado, 2 = Archivado */
  estado: number;
  fechaPublicacion?: string | null;
  categoria?: { id: number } | null;
}
