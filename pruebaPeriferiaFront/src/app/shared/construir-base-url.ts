import { environment } from '../../environments/environment';

/**
 * Arma la URL base de un recurso del backend a partir de environment.apiConfig.
 * Si "host" está vacío (ambiente "docker" — ver environment.docker.ts),
 * devuelve la ruta tal cual (relativa): el navegador la resuelve contra el
 * mismo origen que sirve el frontend, y nginx la reenvía a backend:8080
 * (ver nginx.conf). Así se evita tener que configurar CORS en el backend
 * cuando la app corre detrás de nginx en docker-compose.
 */
export function construirBaseUrl(path: string): string {
  const { protocol, host, port } = environment.apiConfig;
  return host ? `${protocol}://${host}:${port}${path}` : path;
}
