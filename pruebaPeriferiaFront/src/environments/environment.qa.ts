// Ambiente qa (`ng serve --configuration=qa`, `ng build --configuration=qa`)
// TODO: reemplazar host/port con el servidor real de qa del backend Java (JWT)
export const environment = {
    production: false,
    envName: 'qa',
    apiConfig: {
        protocol: 'https',
        host: 'qa-api.pruebaperiferia.com',
        port: 443
    },
    firebaseConfig: {
        apiKey: "AIzaSyCjfImnQkC3ZlPC6fsj_Uns785VhR8nsDs",
        authDomain: "angular17-auth-3b8a1.firebaseapp.com",
        projectId: "angular17-auth-3b8a1",
        storageBucket: "angular17-auth-3b8a1.appspot.com",
        messagingSenderId: "401229346164",
        appId: "1:401229346164:web:d569a61a38978c5c06e821"
    }
  };
