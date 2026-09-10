// Ambiente develop (`ng serve --configuration=develop`, `ng build --configuration=develop`)
// TODO: reemplazar host/port con el servidor real de develop del backend Java (JWT)
export const environment = {
    production: false,
    envName: 'develop',
    apiConfig: {
        protocol: 'http',
        host: 'localhost',
        port: 8080
    }
  };
