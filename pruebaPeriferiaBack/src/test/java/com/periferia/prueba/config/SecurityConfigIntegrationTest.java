package com.periferia.prueba.config;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

/**
 * Verifica la matriz de autorización real de SecurityConfig levantando el
 * contexto completo (filtros de Spring Security incluidos), en vez de
 * confiar en lectura de código. Corre contra H2 (perfil "test") — no
 * necesita Postgres.
 *
 * Motivo: un 403 mal diagnosticado en este proyecto (ruta equivocada,
 * /api/v1/test en vez de /test/status) hubiera salido inmediato acá.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityConfigIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testStatus_esPublico_sinToken() throws Exception {
        mockMvc.perform(get("/test/status"))
                .andExpect(result -> assertThat(result.getResponse().getStatus()).isEqualTo(200));
    }

    @Test
    void apiDocs_esPublico_sinToken() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(result -> assertThat(result.getResponse().getStatus()).isEqualTo(200));
    }

    @Test
    void swaggerUi_esPublico_sinToken() throws Exception {
        mockMvc.perform(get("/swagger-ui/index.html"))
                .andExpect(result -> assertThat(result.getResponse().getStatus()).isEqualTo(200));
    }

    @Test
    void authLogin_noEstaBloqueadoPorAutorizacion_sinToken() throws Exception {
        // No nos importa si el login falla por credenciales (eso es lógica de
        // negocio, no de autorización) — lo que valida este test es que la
        // ruta /api/auth/** nunca responde 403 por falta de token.
        mockMvc.perform(get("/api/auth/login"))
                .andExpect(result -> assertThat(result.getResponse().getStatus()).isNotEqualTo(403));
    }

    @Test
    void usuarios_requiereToken_sinTokenDa403() throws Exception {
        mockMvc.perform(get("/api/usuarios"))
                .andExpect(result -> assertThat(result.getResponse().getStatus()).isEqualTo(403));
    }

    @Test
    void perfiles_requiereToken_sinTokenDa403() throws Exception {
        mockMvc.perform(get("/api/perfiles"))
                .andExpect(result -> assertThat(result.getResponse().getStatus()).isEqualTo(403));
    }

    @Test
    void categorias_requiereToken_sinTokenDa403() throws Exception {
        mockMvc.perform(get("/api/categorias"))
                .andExpect(result -> assertThat(result.getResponse().getStatus()).isEqualTo(403));
    }

    @Test
    void publicaciones_requiereToken_sinTokenDa403() throws Exception {
        mockMvc.perform(get("/api/publicaciones"))
                .andExpect(result -> assertThat(result.getResponse().getStatus()).isEqualTo(403));
    }
}
