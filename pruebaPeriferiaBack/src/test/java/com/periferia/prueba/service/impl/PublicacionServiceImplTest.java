package com.periferia.prueba.service.impl;

import com.periferia.prueba.model.Publicacion;
import com.periferia.prueba.repository.PublicacionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PublicacionServiceImplTest {

    @Mock
    private PublicacionRepository repository;

    @InjectMocks
    private PublicacionServiceImpl service;

    private Publicacion publicacion;

    @BeforeEach
    void setUp() {
        publicacion = Publicacion.builder()
                .id(1L)
                .titulo("Mi primer post")
                .slug("mi-primer-post")
                .contenido("Contenido de prueba")
                .estado((short) 0)
                .build();
    }

    @Test
    void findAll_retornaListaDePublicaciones() {
        when(repository.findAll()).thenReturn(List.of(publicacion));

        List<Publicacion> resultado = service.findAll();

        assertThat(resultado).hasSize(1).containsExactly(publicacion);
    }

    @Test
    void findById_existente_retornaPublicacion() {
        when(repository.findById(1L)).thenReturn(Optional.of(publicacion));

        Optional<Publicacion> resultado = service.findById(1L);

        assertThat(resultado).isPresent().contains(publicacion);
    }

    @Test
    void findBySlug_existente_retornaPublicacion() {
        when(repository.findBySlug("mi-primer-post")).thenReturn(Optional.of(publicacion));

        Optional<Publicacion> resultado = service.findBySlug("mi-primer-post");

        assertThat(resultado).isPresent();
        assertThat(resultado.get().getTitulo()).isEqualTo("Mi primer post");
    }

    @Test
    void findBySlug_inexistente_retornaVacio() {
        when(repository.findBySlug("no-existe")).thenReturn(Optional.empty());

        Optional<Publicacion> resultado = service.findBySlug("no-existe");

        assertThat(resultado).isEmpty();
    }

    @Test
    void save_persisteYRetornaPublicacion() {
        when(repository.save(publicacion)).thenReturn(publicacion);

        Publicacion resultado = service.save(publicacion);

        assertThat(resultado).isEqualTo(publicacion);
        verify(repository).save(publicacion);
    }

    @Test
    void deleteById_invocaRepository() {
        service.deleteById(1L);

        verify(repository).deleteById(1L);
    }
}
