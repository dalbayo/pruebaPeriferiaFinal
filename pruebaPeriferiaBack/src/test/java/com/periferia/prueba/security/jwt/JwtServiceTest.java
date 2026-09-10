package com.periferia.prueba.security.jwt;

import com.periferia.prueba.model.Usuario;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.junit.jupiter.api.Test;

import java.security.Key;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class JwtServiceTest {

    // Debe coincidir con la SECRET_KEY definida en JwtService para poder
    // parsear el token generado y validar su contenido.
    private static final String SECRET_KEY = "cO92JkZ+9v1Lh3R5sT/p1Xq8N9m7A2z5B8vK9wE3f0o=";

    private final JwtService jwtService = new JwtService();

    @Test
    void generateAccessToken_incluyeUsernameComoSubject() {
        Usuario usuario = Usuario.builder().username("dbarrera").build();
        UserDetailsImpl userDetails = new UserDetailsImpl(usuario);

        String token = jwtService.generateAccessToken(userDetails);

        assertThat(token).isNotBlank();

        Key key = Keys.hmacShaKeyFor(Decoders.BASE64.decode(SECRET_KEY));
        String subject = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();

        assertThat(subject).isEqualTo("dbarrera");
    }

    @Test
    void generateRefreshToken_generaUuidValidoYUnico() {
        String token1 = jwtService.generateRefreshToken();
        String token2 = jwtService.generateRefreshToken();

        assertThat(token1).isNotEqualTo(token2);
        assertThat(UUID.fromString(token1)).isNotNull();
        assertThat(UUID.fromString(token2)).isNotNull();
    }
}
