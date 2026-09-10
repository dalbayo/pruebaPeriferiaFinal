package com.periferia.prueba.exception;

/**
 * Recurso solicitado (usuario, categoría, publicación, etc.) no existe.
 * Mapeada a 404 en ManejadorGlobalDeExcepciones.
 *
 * @author daniel.barrera
 */
public class RecursoNoEncontradoExcepcion extends RuntimeException {

    public RecursoNoEncontradoExcepcion(String mensaje) {
        super(mensaje);
    }
}
