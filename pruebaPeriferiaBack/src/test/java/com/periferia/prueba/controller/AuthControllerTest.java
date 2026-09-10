package com.periferia.prueba.controller;

import com.periferia.prueba.dto.LoginRequestDto;
import com.periferia.prueba.dto.TokenResponseDto;
import com.periferia.prueba.model.Usuario;
import com.periferia.prueba.security.jwt.JwtService;
import com.periferia.prueba.service.IUsuarioService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthControllerTest {

    @Mock
    private IUsuarioService usuarioService;
    @Mock
    private AuthenticationManager authenticationManager;
    @Mock
    private JwtService jwtService;
    @Mock
    private UserDetailsService userDetailsService;
    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private AuthController authController;

    private Usuario usuarioValido() {
        return Usuario.builder()
                .id(1L)
                .username("dbarrera")
                .activo(true)
                .eliminado((short) 1)
                .refreshToken("old-refresh")
                .refreshTokenExpiry(LocalDateTime.now().plusDays(1))
                .build();
    }

    // ---------- LOGIN ----------

    @Test
    void login_credencialesValidas_retornaTokens() {
        LoginRequestDto request = new LoginRequestDto("dbarrera", "secreto");
        UserDetails userDetails = User.withUsername("dbarrera").password("secreto").authorities(Collections.emptyList()).build();
        Usuario usuario = usuarioValido();

        when(userDetailsService.loadUserByUsername("dbarrera")).thenReturn(userDetails);
        when(jwtService.generateAccessToken(userDetails)).thenReturn("access-token");
        when(jwtService.generateRefreshToken()).thenReturn("refresh-token");
        when(usuarioService.findByUsername("dbarrera")).thenReturn(Optional.of(usuario));
        when(usuarioService.actualizarTokens(eq(1L), eq("access-token"), any(LocalDateTime.class),
                eq("refresh-token"), any(LocalDateTime.class))).thenReturn(usuario);

        ResponseEntity<TokenResponseDto> respuesta = authController.login(request);

        assertThat(respuesta.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(respuesta.getBody()).isNotNull();
        assertThat(respuesta.getBody().accessToken()).isEqualTo("access-token");
        assertThat(respuesta.getBody().refreshToken()).isEqualTo("refresh-token");
        verify(authenticationManager).authenticate(any());
        verify(usuarioService).actualizarTokens(eq(1L), eq("access-token"), any(LocalDateTime.class),
                eq("refresh-token"), any(LocalDateTime.class));
    }

    @Test
    void login_usuarioNoEncontrado_lanzaExcepcion() {
        LoginRequestDto request = new LoginRequestDto("no-existe", "secreto");
        UserDetails userDetails = User.withUsername("no-existe").password("secreto").authorities(Collections.emptyList()).build();

        when(userDetailsService.loadUserByUsername("no-existe")).thenReturn(userDetails);
        when(jwtService.generateAccessToken(userDetails)).thenReturn("access-token");
        when(jwtService.generateRefreshToken()).thenReturn("refresh-token");
        when(usuarioService.findByUsername("no-existe")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> authController.login(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("no encontrado");
    }

    // ---------- REFRESH ----------

    @Test
    void refresh_tokenValido_retornaNuevosTokens() {
        Usuario usuario = usuarioValido();

        when(usuarioService.findByRefreshToken("old-refresh")).thenReturn(Optional.of(usuario));
        when(jwtService.generateAccessToken(any())).thenReturn("new-access");
        when(jwtService.generateRefreshToken()).thenReturn("new-refresh");
        when(usuarioService.actualizarTokens(eq(1L), eq("new-access"), any(LocalDateTime.class),
                eq("new-refresh"), any(LocalDateTime.class))).thenReturn(usuario);

        Map<String, String> request = new HashMap<>();
        request.put("refreshToken", "old-refresh");

        ResponseEntity<TokenResponseDto> respuesta = authController.refresh(request);

        assertThat(respuesta.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(respuesta.getBody().accessToken()).isEqualTo("new-access");
        assertThat(respuesta.getBody().refreshToken()).isEqualTo("new-refresh");
        verify(usuarioService).actualizarTokens(eq(1L), eq("new-access"), any(LocalDateTime.class),
                eq("new-refresh"), any(LocalDateTime.class));
    }

    @Test
    void refresh_refreshTokenVacio_lanzaExcepcion() {
        Map<String, String> request = new HashMap<>();
        request.put("refreshToken", "");

        assertThatThrownBy(() -> authController.refresh(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("obligatorio");
    }

    @Test
    void refresh_tokenNoEncontrado_lanzaExcepcion() {
        when(usuarioService.findByRefreshToken("no-existe")).thenReturn(Optional.empty());

        Map<String, String> request = new HashMap<>();
        request.put("refreshToken", "no-existe");

        assertThatThrownBy(() -> authController.refresh(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("inválido");
    }

    @Test
    void refresh_usuarioInactivo_lanzaExcepcion() {
        Usuario usuario = usuarioValido();
        usuario.setActivo(false);

        when(usuarioService.findByRefreshToken("old-refresh")).thenReturn(Optional.of(usuario));

        Map<String, String> request = new HashMap<>();
        request.put("refreshToken", "old-refresh");

        assertThatThrownBy(() -> authController.refresh(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("inactivo");
    }

    @Test
    void refresh_usuarioEliminado_lanzaExcepcion() {
        Usuario usuario = usuarioValido();
        usuario.setEliminado((short) 0);

        when(usuarioService.findByRefreshToken("old-refresh")).thenReturn(Optional.of(usuario));

        Map<String, String> request = new HashMap<>();
        request.put("refreshToken", "old-refresh");

        assertThatThrownBy(() -> authController.refresh(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("disponible");
    }

    @Test
    void refresh_tokenExpirado_lanzaExcepcion() {
        Usuario usuario = usuarioValido();
        usuario.setRefreshTokenExpiry(LocalDateTime.now().minusDays(1));

        when(usuarioService.findByRefreshToken("old-refresh")).thenReturn(Optional.of(usuario));

        Map<String, String> request = new HashMap<>();
        request.put("refreshToken", "old-refresh");

        assertThatThrownBy(() -> authController.refresh(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("expirado");
    }
}
