// Ambiente develop (`ng serve --configuration=develop`, `ng build --configuration=develop`)
// TODO: reemplazar host/port con el servidor real de develop del backend Java (JWT)
export const environment = {
    production: false,
    envName: 'develop',
    apiConfig: {
        protocol: 'http',
        host: 'localhost',
        port: 8080
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
