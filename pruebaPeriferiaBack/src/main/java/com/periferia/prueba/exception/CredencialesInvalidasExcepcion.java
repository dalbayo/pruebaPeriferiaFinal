package com.periferia.prueba.exception;

/**
 * Token, refresh token o credenciales no válidas / expiradas / de un
 * usuario inactivo o no disponible. Mapeada a 401 en
 * ManejadorGlobalDeExcepciones.
 */
public class CredencialesInvalidasExcepcion extends RuntimeException {

    public CredencialesInvalidasExcepcion(String mensaje) {
        super(mensaje);
    }
}
