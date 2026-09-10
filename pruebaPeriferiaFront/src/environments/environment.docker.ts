// Ambiente para el contenedor Docker (nginx sirve el build Y hace de proxy
// de /api/v1/ hacia backend:8080 dentro de la red de docker-compose — ver
// nginx.conf). host vacío = AuthApiService/CategoriaService/PublicacionService
// arman la URL como ruta relativa (mismo origen que el navegador), sin
// necesidad de configurar CORS en el backend.
export const environment = {
    production: true,
    envName: 'docker',
    apiConfig: {
        protocol: '',
        host: '',
        port: 0
    }
  };
