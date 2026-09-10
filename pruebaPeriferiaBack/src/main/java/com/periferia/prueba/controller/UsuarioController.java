package com.periferia.prueba.controller;

import com.periferia.prueba.exception.RecursoNoEncontradoExcepcion;
import com.periferia.prueba.model.Usuario;
import com.periferia.prueba.service.IUsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CRUD de usuarios. Protegido por JwtAuthFilter (SecurityConfig:
 * anyRequest().authenticated()) — requiere header
 * "Authorization: Bearer {accessToken}" obtenido en /api/auth/login.
 *
 * @author daniel.barrera
 */
@RestController
@RequestMapping("/api/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final IUsuarioService usuarioService;
    private final PasswordEncoder passwordEncoder;

    @GetMapping
    public ResponseEntity<List<Usuario>> listar() {
        List<Usuario> usuarios = usuarioService.findAll();
        usuarios.forEach(this::ocultarPassword);
        return ResponseEntity.ok(usuarios);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Usuario> obtener(@PathVariable Long id) {
        return usuarioService.findById(id)
                .map(usuario -> {
                    ocultarPassword(usuario);
                    return ResponseEntity.ok(usuario);
                })
                .orElseThrow(() -> new RecursoNoEncontradoExcepcion("Usuario no encontrado"));
    }

    @PostMapping
    public ResponseEntity<Usuario> crear(@RequestBody Usuario request) {
        request.setId(null);
        request.setPassword(passwordEncoder.encode(request.getPassword()));

        if (request.getActivo() == null) {
            request.setActivo(true);
        }
        if (request.getEliminado() == null) {
            request.setEliminado((short) 1);
        }

        Usuario creado = usuarioService.save(request);
        ocultarPassword(creado);
        return ResponseEntity.status(HttpStatus.CREATED).body(creado);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Usuario> editar(@PathVariable Long id, @RequestBody Usuario request) {
        Usuario usuario = usuarioService.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoExcepcion("Usuario no encontrado"));

        if (request.getUsername() != null) {
            usuario.setUsername(request.getUsername());
        }
        if (request.getTipoDocumento() != null) {
            usuario.setTipoDocumento(request.getTipoDocumento());
        }
        if (request.getNumeroDocumento() != null) {
            usuario.setNumeroDocumento(request.getNumeroDocumento());
        }

        if (request.getActivo() != null) {
            usuario.setActivo(request.getActivo());
        }
        if (request.getEliminado() != null) {
            usuario.setEliminado(request.getEliminado());
        }
        // Password solo se actualiza si viene en el body (evita re-hashear el hash
        // guardado)
        if (request.getPassword() != null && !request.getPassword().isBlank()) {
            usuario.setPassword(passwordEncoder.encode(request.getPassword()));
        }

        Usuario actualizado = usuarioService.save(usuario);
        ocultarPassword(actualizado);
        return ResponseEntity.ok(actualizado);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        usuarioService.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // No exponer el hash de password en las respuestas.
    private void ocultarPassword(Usuario usuario) {
        usuario.setPassword(null);
    }
}
