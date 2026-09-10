package com.periferia.prueba.service.impl;

import com.periferia.prueba.model.PublicacionAdjunto;
import com.periferia.prueba.repository.PublicacionAdjuntoRepository;
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
class PublicacionAdjuntoServiceImplTest {

    @Mock
    private PublicacionAdjuntoRepository repository;

    @InjectMocks
    private PublicacionAdjuntoServiceImpl service;

    private PublicacionAdjunto adjunto;

    @BeforeEach
    void setUp() {
        adjunto = PublicacionAdjunto.builder()
                .id(1L)
                .urlArchivo("https://cdn.example.com/archivo.png")
                .tipoMime("image/png")
                .build();
    }

    @Test
    void findAll_retornaListaDeAdjuntos() {
        when(repository.findAll()).thenReturn(List.of(adjunto));

        List<PublicacionAdjunto> resultado = service.findAll();

        assertThat(resultado).hasSize(1).containsExactly(adjunto);
    }

    @Test
    void findById_existente_retornaAdjunto() {
        when(repository.findById(1L)).thenReturn(Optional.of(adjunto));

        Optional<PublicacionAdjunto> resultado = service.findById(1L);

        assertThat(resultado).isPresent().contains(adjunto);
    }

    @Test
    void save_persisteYRetornaAdjunto() {
        when(repository.save(adjunto)).thenReturn(adjunto);

        PublicacionAdjunto resultado = service.save(adjunto);

        assertThat(resultado).isEqualTo(adjunto);
        verify(repository).save(adjunto);
    }

    @Test
    void deleteById_invocaRepository() {
        service.deleteById(1L);

        verify(repository).deleteById(1L);
    }
}
