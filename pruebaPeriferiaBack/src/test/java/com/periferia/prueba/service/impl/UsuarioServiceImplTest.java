package com.periferia.prueba.service.impl;

import com.periferia.prueba.model.Usuario;
import com.periferia.prueba.repository.UsuarioRepository;
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
class UsuarioServiceImplTest {

    @Mock
    private UsuarioRepository repository;

    @InjectMocks
    private UsuarioServiceImpl service;

    private Usuario usuario;

    @BeforeEach
    void setUp() {
        usuario = Usuario.builder()
                .id(1L)
                .username("dbarrera")
                .password("hash")
                .token("refresh-token-abc")
                .activo(true)
                .build();
    }

    @Test
    void findAll_retornaListaDeUsuarios() {
        when(repository.findAll()).thenReturn(List.of(usuario));

        List<Usuario> resultado = service.findAll();

        assertThat(resultado).hasSize(1).containsExactly(usuario);
    }

    @Test
    void findById_existente_retornaUsuario() {
        when(repository.findById(1L)).thenReturn(Optional.of(usuario));

        Optional<Usuario> resultado = service.findById(1L);

        assertThat(resultado).isPresent().contains(usuario);
    }

    @Test
    void findByUsername_existente_retornaUsuario() {
        when(repository.findByUsername("dbarrera")).thenReturn(Optional.of(usuario));

        Optional<Usuario> resultado = service.findByUsername("dbarrera");

        assertThat(resultado).isPresent();
        assertThat(resultado.get().getUsername()).isEqualTo("dbarrera");
    }

    @Test
    void findByUsername_inexistente_retornaVacio() {
        when(repository.findByUsername("no-existe")).thenReturn(Optional.empty());

        Optional<Usuario> resultado = service.findByUsername("no-existe");

        assertThat(resultado).isEmpty();
    }

    @Test
    void findByToken_existente_retornaUsuario() {
        when(repository.findByToken("refresh-token-abc")).thenReturn(Optional.of(usuario));

        Optional<Usuario> resultado = service.findByToken("refresh-token-abc");

        assertThat(resultado).isPresent();
        assertThat(resultado.get().getToken()).isEqualTo("refresh-token-abc");
    }

    @Test
    void save_persisteYRetornaUsuario() {
        when(repository.save(usuario)).thenReturn(usuario);

        Usuario resultado = service.save(usuario);

        assertThat(resultado).isEqualTo(usuario);
        verify(repository).save(usuario);
    }

    @Test
    void deleteById_invocaRepository() {
        service.deleteById(1L);

        verify(repository).deleteById(1L);
    }
}
