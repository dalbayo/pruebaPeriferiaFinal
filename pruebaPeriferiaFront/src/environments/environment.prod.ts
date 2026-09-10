// Ambiente prod (`ng build --configuration=production`, default de `ng build`)
// TODO: reemplazar host/port con el servidor real de produccion del backend Java (JWT)
export const environment = {
    production: true,
    envName: 'prod',
    apiConfig: {
        protocol: 'https',
        host: 'api.pruebaperiferia.com',
        port: 443
    }
  };
