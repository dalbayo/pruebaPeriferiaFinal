package com.periferia.prueba.controller;

import org.springframework.web.bind.annotation.*;

import com.periferia.prueba.dto.LoginRequestDto;
import com.periferia.prueba.dto.TokenResponseDto;
import com.periferia.prueba.model.Usuario;
import com.periferia.prueba.repository.UsuarioRepository;
import com.periferia.prueba.security.jwt.JwtService;
import com.periferia.prueba.security.jwt.UserDetailsImpl;
import com.periferia.prueba.service.IUsuarioService;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import java.util.HashMap;

@RestController
@RequestMapping("/api/auth")
// @CrossOrigin(origins = "http://localhost:4000")
public class AuthController {

    @Autowired
    private IUsuarioService usuarioService;

    @Autowired
    private AuthenticationManager authenticationManager;
    @Autowired
    private JwtService jwtService;
    @Autowired
    private UserDetailsService userDetailsService;

    @Autowired
    private PasswordEncoder passwordEncoder; // Inyecta el bean de BCrypt

    // AquÃ­ inyectarÃ­as tu repositorio para guardar el refresh token en SQL Server
    // private final RefreshTokenRepository refreshTokenRepository;

    // 1. LOGIN: Genera ambos tokens por primera vez
    @PostMapping("/login")
    public ResponseEntity<TokenResponseDto> login(@RequestBody LoginRequestDto request) {
        // Valida contra SQL Server

        String claveCifrada = passwordEncoder.encode(request.password());
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password()));
        // LoginRequestDto loginProcesado = new LoginRequestDto(request.username(),
        // claveCifrada);

        UserDetails user = userDetailsService.loadUserByUsername(request.username());
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken();

        LocalDateTime expiryDate = LocalDateTime.now().plusMinutes(10);

        LocalDateTime refreshTokenExpiry = LocalDateTime.now().plusDays(7);
        Usuario usuario = usuarioService
                .findByUsername(request.username())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // 7. Guardar tokens
        usuarioService.actualizarTokens(
                usuario.getId(),
                accessToken,
                expiryDate,
                refreshToken,
                refreshTokenExpiry);

        return ResponseEntity.ok(new TokenResponseDto(accessToken, refreshToken));
    }

    /**
     * GET protegido por JWT: valida el Access Token (vía JwtAuthFilter) y
     * devuelve el usuario autenticado. Requisito "Endpoint GET/POST de login":
     * POST /login autentica y emite tokens; este GET confirma que el token
     * sigue siendo válido y quién es el usuario dueño.
     */
    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> me(@AuthenticationPrincipal UserDetailsImpl currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        Usuario usuario = currentUser.getUsuario();

        Map<String, Object> body = new HashMap<>();
        body.put("id", usuario.getId());
        body.put("username", usuario.getUsername());
        body.put("activo", usuario.getActivo());
        body.put("tipoDocumento", usuario.getTipoDocumento());
        body.put("numeroDocumento", usuario.getNumeroDocumento());

        return ResponseEntity.ok(body);
    }

    /**
     * REFRESH TOKEN
     *
     * Recibe un Refresh Token y genera:
     * - nuevo Access Token
     * - nuevo Refresh Token
     */
    @PostMapping("/refresh")
    public ResponseEntity<TokenResponseDto> refresh(
            @RequestBody Map<String, String> request) {

        String refreshToken = request.get("refreshToken");

        // Validación básica
        if (refreshToken == null || refreshToken.isBlank()) {
            throw new RuntimeException(
                    "El refreshToken es obligatorio");
        }

        // 1. Buscar usuario por REFRESH TOKEN
        Usuario usuario = usuarioService
                .findByRefreshToken(refreshToken)
                .orElseThrow(() -> new RuntimeException(
                        "Refresh token inválido"));

        // 2. Validar usuario
        if (!Boolean.TRUE.equals(usuario.getActivo())) {
            throw new RuntimeException(
                    "El usuario está inactivo");
        }

        // 3. Validar eliminación lógica
        if (usuario.getEliminado() == null ||
                usuario.getEliminado() != 1) {

            throw new RuntimeException(
                    "El usuario no está disponible");
        }

        // 4. Validar expiración del Refresh Token
        if (usuario.getRefreshTokenExpiry() == null ||
                usuario.getRefreshTokenExpiry()
                        .isBefore(LocalDateTime.now())) {

            throw new RuntimeException(
                    "El refresh token ha expirado");
        }

        // 5. Obtener UserDetails
        UserDetails userDetails = new UserDetailsImpl(usuario);

        // 6. Generar NUEVO Access Token
        String newAccessToken = jwtService.generateAccessToken(userDetails);

        // 7. Generar NUEVO Refresh Token
        String newRefreshToken = jwtService.generateRefreshToken();

        // 8. Nuevas fechas de expiración
        LocalDateTime newExpiryDate = LocalDateTime.now().plusMinutes(10);

        LocalDateTime newRefreshTokenExpiry = LocalDateTime.now().plusDays(7);

        // 9. Actualizar ambos tokens
        usuarioService.actualizarTokens(
                usuario.getId(),
                newAccessToken,
                newExpiryDate,
                newRefreshToken,
                newRefreshTokenExpiry);

        // 10. Retornar nuevos tokens
        return ResponseEntity.ok(
                new TokenResponseDto(
                        newAccessToken,
                        newRefreshToken));
    }

    // 2. REFRESH: Genera un nuevo Access Token (Cada 10 min)
    @PostMapping("/refresh2")
    public ResponseEntity<TokenResponseDto> refresh2(@RequestBody Map<String, String> request) {
        String refreshToken = request.get("refreshToken");

        // Usamos .map directamente sobre el Optional, sin .get()
        return usuarioService.findByToken(refreshToken)
                .map(usuario -> {
                    // 1. Validar expiraciÃ³n usando Instant (coherente con tu entidad)
                    // Ajustado para LocalDateTime (coherente con el esquema de BD y la entidad)
                    if (usuario.getExpiryDate() != null &&
                            usuario.getExpiryDate().isBefore(java.time.LocalDateTime.now())) {

                        throw new RuntimeException("El token de actualizaciÃ³n ha expirado");
                    }
                    // 2. Generar nuevo Access Token
                    UserDetails user = new UserDetails() {

                        @Override
                        public String getUsername() {
                            // TODO Auto-generated method stub
                            return null;
                        }

                        @Override
                        public String getPassword() {
                            // TODO Auto-generated method stub
                            return null;
                        }

                        @Override
                        public Collection<? extends GrantedAuthority> getAuthorities() {
                            // TODO Auto-generated method stub
                            return null;
                        }
                    };

                    String newAccessToken = jwtService.generateAccessToken(new UserDetailsImpl(usuario));

                    // 3. Rotar Refresh Token
                    String newRefreshToken = jwtService.generateRefreshToken();
                    usuario.setToken(refreshToken);
                    // Definir nueva expiraciÃ³n (7 dÃ­as en formato Instant)
                    // Ejemplo de actualizaciÃ³n a 7 dÃ­as
                    usuario.setExpiryDate(java.time.LocalDateTime.now().plusDays(7));

                    usuarioService.save(usuario); // Recomendado usar el servicio en lugar del repositorio

                    return ResponseEntity.ok(new TokenResponseDto(newAccessToken, newRefreshToken));
                })
                .orElseThrow(() -> new RuntimeException("Token de actualizaciÃ³n no encontrado"));
    }

}
