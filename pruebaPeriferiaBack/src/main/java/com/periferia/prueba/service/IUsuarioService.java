package com.periferia.prueba.service;

import com.periferia.prueba.model.Usuario;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Contrato de servicio para la gestión de usuarios y la actualización
 * de sus tokens de acceso y refresco (autenticación JWT).
 *
 * @author daniel.barrera
 */
public interface IUsuarioService {
    List<Usuario> findAll();

    Optional<Usuario> findById(Long id);

    Optional<Usuario> findByUsername(String id);

    Optional<Usuario> findByToken(String id);

    Usuario save(Usuario entity);

    void deleteById(Long id);

    Optional<Usuario> findByRefreshToken(String refreshToken);

    Usuario actualizarTokens(
            Long usuarioId,
            String token,
            LocalDateTime expiryDate,
            String refreshToken,
            LocalDateTime refreshTokenExpiry);
}
