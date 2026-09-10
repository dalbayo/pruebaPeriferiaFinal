package com.periferia.prueba.controller;

import com.periferia.prueba.model.Categoria;
import com.periferia.prueba.model.Publicacion;
import com.periferia.prueba.model.Usuario;
import com.periferia.prueba.security.jwt.UserDetailsImpl;
import com.periferia.prueba.service.IPublicacionService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PublicacionControllerTest {

    @Mock
    private IPublicacionService publicacionService;

    @InjectMocks
    private PublicacionController publicacionController;

    private Usuario usuarioAutenticado() {
        return Usuario.builder().id(1L).username("dbarrera").build();
    }

    private UserDetailsImpl currentUser(Usuario usuario) {
        return new UserDetailsImpl(usuario);
    }

    private Publicacion publicacionValida() {
        return Publicacion.builder()
                .id(10L)
                .titulo("Mi publicación")
                .contenido("Contenido")
                .slug("mi-publicacion-123")
                .estado((short) 0)
                .eliminado((short) 1)
                .build();
    }

    // ---------- LISTAR (tipo) ----------

    @Test
    void publicaciones_tipo0_devuelveTodas() {
        List<Publicacion> todas = List.of(publicacionValida());
        when(publicacionService.findAll()).thenReturn(todas);

        ResponseEntity<List<Publicacion>> respuesta =
                publicacionController.publicaciones(0, currentUser(usuarioAutenticado()));

        assertThat(respuesta.getBody()).isEqualTo(todas);
        verify(publicacionService).findAll();
        verify(publicacionService, never()).findByUsuarioId(any());
        verify(publicacionService, never()).findByUsuarioIdNot(any());
    }

    @Test
    void publicaciones_tipo1_devuelveSoloDelUsuarioDelToken() {
        Usuario usuario = usuarioAutenticado();
        List<Publicacion> mias = List.of(publicacionValida());
        when(publicacionService.findByUsuarioId(1L)).thenReturn(mias);

        ResponseEntity<List<Publicacion>> respuesta =
                publicacionController.publicaciones(1, currentUser(usuario));

        assertThat(respuesta.getBody()).isEqualTo(mias);
        verify(publicacionService).findByUsuarioId(1L);
        verify(publicacionService, never()).findAll();
    }

    @Test
    void publicaciones_tipo2_devuelveDeOtrosUsuarios() {
        Usuario usuario = usuarioAutenticado();
        List<Publicacion> deOtros = List.of(publicacionValida());
        when(publicacionService.findByUsuarioIdNot(1L)).thenReturn(deOtros);

        ResponseEntity<List<Publicacion>> respuesta =
                publicacionController.publicaciones(2, currentUser(usuario));

        assertThat(respuesta.getBody()).isEqualTo(deOtros);
        verify(publicacionService).findByUsuarioIdNot(1L);
    }

    // ---------- OBTENER ----------

    @Test
    void obtener_existente_retornaPublicacion() {
        Publicacion publicacion = publicacionValida();
        when(publicacionService.findById(10L)).thenReturn(Optional.of(publicacion));

        ResponseEntity<Publicacion> respuesta = publicacionController.obtener(10L);

        assertThat(respuesta.getBody()).isEqualTo(publicacion);
    }

    @Test
    void obtener_inexistente_lanzaExcepcion() {
        when(publicacionService.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> publicacionController.obtener(99L))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("no encontrada");
    }

    // ---------- CREAR ----------

    @Test
    void crear_sinUsuarioEnBody_asignaAutorDelToken() {
        Usuario autorToken = usuarioAutenticado();
        Publicacion request = Publicacion.builder()
                .titulo("Nueva")
                .contenido("Contenido nuevo")
                .build();

        when(publicacionService.save(any(Publicacion.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        ResponseEntity<Publicacion> respuesta =
                publicacionController.crear(request, currentUser(autorToken));

        assertThat(respuesta.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        Publicacion guardada = respuesta.getBody();
        assertThat(guardada).isNotNull();
        assertThat(guardada.getUsuario().getId()).isEqualTo(1L);
        assertThat(guardada.getSlug()).isNotBlank();
        assertThat(guardada.getEstado()).isEqualTo((short) 0);
        assertThat(guardada.getEliminado()).isEqualTo((short) 1);
    }

    @Test
    void crear_conUsuarioEnBody_respetaAutorDelBody() {
        Usuario autorToken = usuarioAutenticado();
        Usuario autorBody = Usuario.builder().id(2L).build();
        Publicacion request = Publicacion.builder()
                .titulo("Nueva")
                .contenido("Contenido")
                .usuario(autorBody)
                .build();

        when(publicacionService.save(any(Publicacion.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        ResponseEntity<Publicacion> respuesta =
                publicacionController.crear(request, currentUser(autorToken));

        assertThat(respuesta.getBody().getUsuario().getId()).isEqualTo(2L);
    }

    @Test
    void crear_conSlugExplicito_noLoSobreescribe() {
        Usuario autorToken = usuarioAutenticado();
        Publicacion request = Publicacion.builder()
                .titulo("Nueva")
                .contenido("Contenido")
                .slug("slug-fijo")
                .build();

        when(publicacionService.save(any(Publicacion.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        ResponseEntity<Publicacion> respuesta =
                publicacionController.crear(request, currentUser(autorToken));

        assertThat(respuesta.getBody().getSlug()).isEqualTo("slug-fijo");
    }

    // ---------- EDITAR ----------

    @Test
    void editar_existente_actualizaSoloCamposNoNulos() {
        Publicacion existente = publicacionValida();
        Publicacion cambios = Publicacion.builder()
                .titulo("Título editado")
                .build();

        when(publicacionService.findById(10L)).thenReturn(Optional.of(existente));
        when(publicacionService.save(any(Publicacion.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        ResponseEntity<Publicacion> respuesta = publicacionController.editar(10L, cambios);

        assertThat(respuesta.getBody().getTitulo()).isEqualTo("Título editado");
        // contenido no vino en el body -> se conserva el original
        assertThat(respuesta.getBody().getContenido()).isEqualTo("Contenido");
    }

    @Test
    void editar_conCategoriaId_actualizaCategoria() {
        Publicacion existente = publicacionValida();
        Categoria nuevaCategoria = Categoria.builder().id(5L).build();
        Publicacion cambios = Publicacion.builder().categoria(nuevaCategoria).build();

        when(publicacionService.findById(10L)).thenReturn(Optional.of(existente));
        when(publicacionService.save(any(Publicacion.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        ResponseEntity<Publicacion> respuesta = publicacionController.editar(10L, cambios);

        assertThat(respuesta.getBody().getCategoria().getId()).isEqualTo(5L);
    }

    @Test
    void editar_inexistente_lanzaExcepcion() {
        when(publicacionService.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> publicacionController.editar(99L, publicacionValida()))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("no encontrada");
    }

    // ---------- ELIMINAR ----------

    @Test
    void eliminar_llamaAlServiceYDevuelveNoContent() {
        ResponseEntity<Void> respuesta = publicacionController.eliminar(10L);

        assertThat(respuesta.getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);
        verify(publicacionService).deleteById(10L);
    }
}
