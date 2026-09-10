package com.periferia.prueba.exception;

/**
 * Conflicto con el estado actual de los datos (ej: username o slug
 * duplicado). Mapeada a 409 en ManejadorGlobalDeExcepciones. También la usa
 * el handler de DataIntegrityViolationException para violaciones de
 * constraint unique que vienen directo de la base.
 *
 * @author daniel.barrera
 */
public class ConflictoDeDatosExcepcion extends RuntimeException {

    public ConflictoDeDatosExcepcion(String mensaje) {
        super(mensaje);
    }
}
