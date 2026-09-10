package com.periferia.prueba.repository;

import com.periferia.prueba.model.Publicacion;
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
 * Test de integración con Postgres real (Testcontainers), corriendo el
 * script.sql completo -- trigger trg_soft_delete_publicacion incluido --
 * para verificar que PublicacionRepositoryImpl#deleteById hace el
 * soft-delete explícito (UPDATE eliminado=0) sin chocar con el trigger.
 *
 * Antes del fix, un deleteById() estándar de JpaRepository tiraba
 * ObjectOptimisticLockingFailureException porque el trigger cancelaba el
 * DELETE físico y Hibernate veía 0 filas afectadas.
 *
 * Requiere Docker corriendo en la máquina donde se ejecuta "mvn test".
 */
@Testcontainers
@SpringBootTest
class PublicacionRepositoryImplIT {

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
    private PublicacionRepository publicacionRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private EntityManager entityManager;

    @Test
    void deleteById_noLanzaExcepcionYHaceSoftDelete() {
        Usuario autor = usuarioRepository.save(Usuario.builder()
                .username("it-user-" + System.nanoTime())
                .activo(true)
                .eliminado((short) 1)
                .build());

        Publicacion publicacion = publicacionRepository.save(Publicacion.builder()
                .usuario(autor)
                .titulo("Publicación de integración")
                .slug("it-publicacion-" + System.nanoTime())
                .contenido("Contenido de prueba")
                .estado((short) 0)
                .eliminado((short) 1)
                .build());

        Long id = publicacion.getId();

        assertThatCode(() -> publicacionRepository.deleteById(id)).doesNotThrowAnyException();

        entityManager.clear();

        Optional<Publicacion> resultado = publicacionRepository.findById(id);
        assertThat(resultado).isPresent();
        assertThat(resultado.get().getEliminado()).isEqualTo((short) 0);
    }
}
