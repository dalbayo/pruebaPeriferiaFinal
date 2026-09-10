package com.periferia.prueba.repository;

import com.periferia.prueba.model.Usuario;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;

/**
 * Mismo motivo que PublicacionRepositoryImplIT: usuario tiene trigger
 * trg_soft_delete_usuario, mismo tipo de conflicto con deleteById().
 *
 * Requiere Docker corriendo en la máquina donde se ejecuta "mvn test".
 */
@Testcontainers
@SpringBootTest
class UsuarioRepositoryImplIT {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>(DockerImageName.parse("postgres:16-alpine"))
            .withInitScript("db/01-schema.sql");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private EntityManager entityManager;

    @Test
    void deleteById_noLanzaExcepcionYHaceSoftDelete() {
        Usuario usuario = usuarioRepository.save(Usuario.builder()
                .username("it-user-del-" + System.nanoTime())
                .activo(true)
                .eliminado((short) 1)
                .build());

        Long id = usuario.getId();

        assertThatCode(() -> usuarioRepository.deleteById(id)).doesNotThrowAnyException();

        entityManager.clear();

        Optional<Usuario> resultado = usuarioRepository.findById(id);
        assertThat(resultado).isPresent();
        assertThat(resultado.get().getEliminado()).isEqualTo((short) 0);
    }
}
