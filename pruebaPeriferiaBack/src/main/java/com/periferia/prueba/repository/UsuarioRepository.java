package com.periferia.prueba.repository;

import com.periferia.prueba.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;
import org.springframework.stereotype.Repository;

/**
 * Repositorio Spring Data JPA para la entidad Usuario, incluyendo
 * búsquedas por username/token/refresh token y la actualización
 * atómica de los tokens de sesión (actualizarTokens).
 *
 * @author daniel.barrera
 */
@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByUsername(String username);

    Optional<Usuario> findByToken(String token); // Clave para el refresh

    Optional<Usuario> findByRefreshToken(String refreshToken);

    @Modifying
    @Query("""
                UPDATE Usuario u
                   SET u.token = :token,
                       u.expiryDate = :expiryDate,
                       u.refreshToken = :refreshToken,
                       u.refreshTokenExpiry = :refreshTokenExpiry
                 WHERE u.id = :usuarioId
            """)
    int actualizarTokens(
            @Param("usuarioId") Long usuarioId,
            @Param("token") String token,
            @Param("expiryDate") LocalDateTime expiryDate,
            @Param("refreshToken") String refreshToken,
            @Param("refreshTokenExpiry") LocalDateTime refreshTokenExpiry);
}
