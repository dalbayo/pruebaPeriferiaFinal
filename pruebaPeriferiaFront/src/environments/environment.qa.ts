// Ambiente qa (`ng serve --configuration=qa`, `ng build --configuration=qa`)
// TODO: reemplazar host/port con el servidor real de qa del backend Java (JWT)
export const environment = {
    production: false,
    envName: 'qa',
    apiConfig: {
        protocol: 'https',
        host: 'qa-api.pruebaperiferia.com',
        port: 443
    }
  };
