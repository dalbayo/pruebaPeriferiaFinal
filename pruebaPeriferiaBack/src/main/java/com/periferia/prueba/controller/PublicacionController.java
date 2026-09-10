package com.periferia.prueba.controller;

import com.periferia.prueba.model.Categoria;
import com.periferia.prueba.model.Publicacion;
import com.periferia.prueba.model.Usuario;
import com.periferia.prueba.security.jwt.UserDetailsImpl;
import com.periferia.prueba.service.IPublicacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * CRUD de publicaciones. Protegido por JwtAuthFilter (SecurityConfig:
 * anyRequest().authenticated()) — el usuario autor se toma del token
 * (Authentication principal) cuando el body no trae "usuario.id".
 */
@RestController
@RequestMapping("/api/publicaciones")
@RequiredArgsConstructor
public class PublicacionController {

    private final IPublicacionService publicacionService;

    @GetMapping
    public ResponseEntity<List<Publicacion>> listar() {
        return ResponseEntity.ok(publicacionService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Publicacion> obtener(@PathVariable Long id) {
        return publicacionService.findById(id)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new RuntimeException("Publicación no encontrada"));
    }

    @PostMapping
    public ResponseEntity<Publicacion> crear(
            @RequestBody Publicacion request,
            @AuthenticationPrincipal UserDetailsImpl currentUser) {

        request.setId(null);

        // Si el body no trae usuario, se asigna el dueño del token (autor real).
        if (request.getUsuario() == null || request.getUsuario().getId() == null) {
            Usuario autor = new Usuario();
            autor.setId(currentUser.getUsuario().getId());
            request.setUsuario(autor);
        }

        if (request.getSlug() == null || request.getSlug().isBlank()) {
            request.setSlug(generarSlug(request.getTitulo()));
        }
        if (request.getEstado() == null) {
            request.setEstado((short) 0);
        }
        if (request.getEliminado() == null) {
            request.setEliminado((short) 1);
        }
        request.setCreadoEn(LocalDateTime.now());
        request.setActualizadoEn(LocalDateTime.now());

        Publicacion creada = publicacionService.save(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(creada);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Publicacion> editar(@PathVariable Long id, @RequestBody Publicacion request) {
        Publicacion publicacion = publicacionService.findById(id)
                .orElseThrow(() -> new RuntimeException("Publicación no encontrada"));

        if (request.getTitulo() != null) {
            publicacion.setTitulo(request.getTitulo());
        }
        if (request.getSlug() != null) {
            publicacion.setSlug(request.getSlug());
        }
        if (request.getResumen() != null) {
            publicacion.setResumen(request.getResumen());
        }
        if (request.getContenido() != null) {
            publicacion.setContenido(request.getContenido());
        }
        if (request.getEstado() != null) {
            publicacion.setEstado(request.getEstado());
        }
        if (request.getFechaPublicacion() != null) {
            publicacion.setFechaPublicacion(request.getFechaPublicacion());
        }
        if (request.getEliminado() != null) {
            publicacion.setEliminado(request.getEliminado());
        }
        if (request.getCategoria() != null && request.getCategoria().getId() != null) {
            Categoria categoria = new Categoria();
            categoria.setId(request.getCategoria().getId());
            publicacion.setCategoria(categoria);
        }
        publicacion.setActualizadoEn(LocalDateTime.now());

        return ResponseEntity.ok(publicacionService.save(publicacion));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        publicacionService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    private String generarSlug(String titulo) {
        if (titulo == null || titulo.isBlank()) {
            return "publicacion-" + System.currentTimeMillis();
        }
        String base = titulo.toLowerCase()
                .trim()
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-");
        return base + "-" + System.currentTimeMillis();
    }
}
