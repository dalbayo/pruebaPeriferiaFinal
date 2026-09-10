package com.periferia.prueba.dto;

import lombok.Builder;

/**
 * DTO (record) para la respuesta de autenticación/refresco. Encapsula
 * el access token, el refresh token y sus metadatos (tipo y tiempo
 * de expiración en segundos).
 *
 * @author daniel.barrera
 */
@Builder
public record TokenResponseDto(
        String accessToken,
        String refreshToken,
        String tokenType,
        long expiresIn) {
    // Constructor personalizado para valores por defecto
    public TokenResponseDto(String accessToken, String refreshToken) {
        this(accessToken, refreshToken, "Bearer", 600); // 600 segundos = 10 min
    }
}
