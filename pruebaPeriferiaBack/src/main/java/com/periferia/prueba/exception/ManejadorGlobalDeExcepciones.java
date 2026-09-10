package com.periferia.prueba.exception;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Manejo centralizado de errores para toda la API. Reemplaza los
 * "new RuntimeException(mensaje)" sueltos de los controllers (que antes
 * caían todos como 500 genérico, muchas veces sin ni siquiera mostrar el
 * mensaje al cliente) por respuestas con el status HTTP correcto y un
 * cuerpo consistente (RFC 7807 ProblemDetail).
 *
 * El stacktrace completo siempre se loguea acá server-side; al cliente solo
 * le llega un mensaje sanitizado.
 */
@RestControllerAdvice
public class ManejadorGlobalDeExcepciones {

    private static final Logger registrador = LoggerFactory.getLogger(ManejadorGlobalDeExcepciones.class);

    @ExceptionHandler(RecursoNoEncontradoExcepcion.class)
    public ProblemDetail manejarRecursoNoEncontrado(RecursoNoEncontradoExcepcion excepcion, WebRequest solicitud) {
        registrador.warn("Recurso no encontrado en {}: {}", rutaDe(solicitud), excepcion.getMessage());
        return construirProblema(HttpStatus.NOT_FOUND, excepcion.getMessage(), solicitud);
    }

    @ExceptionHandler(CredencialesInvalidasExcepcion.class)
    public ProblemDetail manejarCredencialesInvalidas(CredencialesInvalidasExcepcion excepcion, WebRequest solicitud) {
        registrador.warn("Credenciales/token inválido en {}: {}", rutaDe(solicitud), excepcion.getMessage());
        return construirProblema(HttpStatus.UNAUTHORIZED, excepcion.getMessage(), solicitud);
    }

    @ExceptionHandler(ConflictoDeDatosExcepcion.class)
    public ProblemDetail manejarConflictoDeDatos(ConflictoDeDatosExcepcion excepcion, WebRequest solicitud) {
        registrador.warn("Conflicto de datos en {}: {}", rutaDe(solicitud), excepcion.getMessage());
        return construirProblema(HttpStatus.CONFLICT, excepcion.getMessage(), solicitud);
    }

    @ExceptionHandler(SolicitudInvalidaExcepcion.class)
    public ProblemDetail manejarSolicitudInvalida(SolicitudInvalidaExcepcion excepcion, WebRequest solicitud) {
        registrador.warn("Solicitud inválida en {}: {}", rutaDe(solicitud), excepcion.getMessage());
        return construirProblema(HttpStatus.BAD_REQUEST, excepcion.getMessage(), solicitud);
    }

    /**
     * Errores de @Valid sobre un @RequestBody (ej: LoginRequestDto con
     * @NotBlank). Devuelve el detalle campo por campo.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ProblemDetail manejarValidacionInvalida(MethodArgumentNotValidException excepcion, WebRequest solicitud) {
        Map<String, String> errores = new LinkedHashMap<>();
        excepcion.getBindingResult().getFieldErrors().forEach(error ->
                errores.put(error.getField(), error.getDefaultMessage()));

        registrador.warn("Validación fallida en {}: {}", rutaDe(solicitud), errores);

        ProblemDetail problema = construirProblema(HttpStatus.BAD_REQUEST, "Datos de la solicitud inválidos", solicitud);
        problema.setProperty("errores", errores);
        return problema;
    }

    /**
     * Violación de constraint en base de datos (username/slug duplicado,
     * FK inexistente, etc.). Sin esto, Hibernate/Postgres tiraban el
     * stacktrace crudo al cliente como 500.
     */
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ProblemDetail manejarViolacionDeIntegridad(DataIntegrityViolationException excepcion, WebRequest solicitud) {
        registrador.error("Violación de integridad de datos en {}", rutaDe(solicitud), excepcion);
        return construirProblema(HttpStatus.CONFLICT,
                "El dato ya existe o viola una restricción de la base de datos", solicitud);
    }

    /**
     * Usuario/contraseña incorrectos (AuthenticationManager.authenticate
     * en el login). BadCredentialsException extiende AuthenticationException,
     * Spring elige el handler más específico automáticamente.
     */
    @ExceptionHandler(BadCredentialsException.class)
    public ProblemDetail manejarCredencialesDeAutenticacionInvalidas(BadCredentialsException excepcion, WebRequest solicitud) {
        registrador.warn("Login fallido en {}: credenciales incorrectas", rutaDe(solicitud));
        return construirProblema(HttpStatus.UNAUTHORIZED, "Usuario o contraseña incorrectos", solicitud);
    }

    @ExceptionHandler(AuthenticationException.class)
    public ProblemDetail manejarErrorDeAutenticacion(AuthenticationException excepcion, WebRequest solicitud) {
        registrador.warn("Error de autenticación en {}: {}", rutaDe(solicitud), excepcion.getMessage());
        return construirProblema(HttpStatus.UNAUTHORIZED, "No autenticado", solicitud);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ProblemDetail manejarAccesoDenegado(AccessDeniedException excepcion, WebRequest solicitud) {
        registrador.warn("Acceso denegado en {}: {}", rutaDe(solicitud), excepcion.getMessage());
        return construirProblema(HttpStatus.FORBIDDEN, "No tiene permisos para esta operación", solicitud);
    }

    /**
     * Cualquier otra excepción no contemplada arriba. Nunca se le manda al
     * cliente el mensaje real ni el stacktrace — solo se loguea completo
     * acá server-side.
     */
    @ExceptionHandler(Exception.class)
    public ProblemDetail manejarErrorNoContemplado(Exception excepcion, WebRequest solicitud) {
        registrador.error("Error no controlado en {}", rutaDe(solicitud), excepcion);
        return construirProblema(HttpStatus.INTERNAL_SERVER_ERROR,
                "Ocurrió un error inesperado. Contacte al administrador si persiste.", solicitud);
    }

    private ProblemDetail construirProblema(HttpStatus status, String mensaje, WebRequest solicitud) {
        ProblemDetail problema = ProblemDetail.forStatusAndDetail(status, mensaje);
        problema.setProperty("ruta", rutaDe(solicitud));
        return problema;
    }

    private String rutaDe(WebRequest solicitud) {
        return solicitud.getDescription(false).replace("uri=", "");
    }
}
