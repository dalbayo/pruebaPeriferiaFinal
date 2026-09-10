package com.periferia.prueba.service.impl;

import com.periferia.prueba.model.Categoria;
import com.periferia.prueba.repository.CategoriaRepository;
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
class CategoriaServiceImplTest {

    @Mock
    private CategoriaRepository repository;

    @InjectMocks
    private CategoriaServiceImpl service;

    private Categoria categoria;

    @BeforeEach
    void setUp() {
        categoria = Categoria.builder()
                .id(1L)
                .nombre("Tecnología")
                .slug("tecnologia")
                .build();
    }

    @Test
    void findAll_retornaListaDeCategorias() {
        when(repository.findAll()).thenReturn(List.of(categoria));

        List<Categoria> resultado = service.findAll();

        assertThat(resultado).hasSize(1).containsExactly(categoria);
        verify(repository).findAll();
    }

    @Test
    void findById_existente_retornaCategoria() {
        when(repository.findById(1L)).thenReturn(Optional.of(categoria));

        Optional<Categoria> resultado = service.findById(1L);

        assertThat(resultado).isPresent().contains(categoria);
    }

    @Test
    void findById_inexistente_retornaVacio() {
        when(repository.findById(99L)).thenReturn(Optional.empty());

        Optional<Categoria> resultado = service.findById(99L);

        assertThat(resultado).isEmpty();
    }

    @Test
    void findBySlug_existente_retornaCategoria() {
        when(repository.findBySlug("tecnologia")).thenReturn(Optional.of(categoria));

        Optional<Categoria> resultado = service.findBySlug("tecnologia");

        assertThat(resultado).isPresent();
        assertThat(resultado.get().getNombre()).isEqualTo("Tecnología");
    }

    @Test
    void save_persisteYRetornaCategoria() {
        when(repository.save(categoria)).thenReturn(categoria);

        Categoria resultado = service.save(categoria);

        assertThat(resultado).isEqualTo(categoria);
        verify(repository).save(categoria);
    }

    @Test
    void deleteById_invocaRepository() {
        service.deleteById(1L);

        verify(repository).deleteById(1L);
    }
}
