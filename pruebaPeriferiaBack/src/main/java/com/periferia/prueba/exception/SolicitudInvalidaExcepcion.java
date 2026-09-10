package com.periferia.prueba.exception;

/**
 * Datos de entrada faltantes o mal formados que no llegan a ser detectados
 * por Bean Validation (@Valid) porque son validaciones manuales (ej: campo
 * de un Map, no de un DTO). Mapeada a 400 en ManejadorGlobalDeExcepciones.
 *
 * @author daniel.barrera
 */
public class SolicitudInvalidaExcepcion extends RuntimeException {

    public SolicitudInvalidaExcepcion(String mensaje) {
        super(mensaje);
    }
}
