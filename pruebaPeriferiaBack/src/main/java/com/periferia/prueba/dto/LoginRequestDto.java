package com.periferia.prueba.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * DTO (record) para la petición de login. Contiene las credenciales
 * enviadas por el cliente, validadas con Bean Validation antes de
 * llegar al controlador.
 *
 * @author daniel.barrera
 */
public record LoginRequestDto(
        @NotBlank String username,
        @NotBlank String password) {
}
