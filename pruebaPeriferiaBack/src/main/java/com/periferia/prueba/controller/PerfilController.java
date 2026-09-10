package com.periferia.prueba.controller;

import com.periferia.prueba.model.Perfil;
import com.periferia.prueba.service.IPerfilService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CRUD de perfiles. Protegido por JwtAuthFilter (SecurityConfig:
 * anyRequest().authenticated()).
 */
@RestController
@RequestMapping("/api/perfiles")
@RequiredArgsConstructor
public class PerfilController {

    private final IPerfilService perfilService;

    @GetMapping
    public ResponseEntity<List<Perfil>> listar() {
        return ResponseEntity.ok(perfilService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Perfil> obtener(@PathVariable Long id) {
        return perfilService.findById(id)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new RuntimeException("Perfil no encontrado"));
    }

    @PostMapping
    public ResponseEntity<Perfil> crear(@RequestBody Perfil request) {
        request.setId(null);
        Perfil creado = perfilService.save(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(creado);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Perfil> editar(@PathVariable Long id, @RequestBody Perfil request) {
        Perfil perfil = perfilService.findById(id)
                .orElseThrow(() -> new RuntimeException("Perfil no encontrado"));

        if (request.getNombre() != null) {
            perfil.setNombre(request.getNombre());
        }

        return ResponseEntity.ok(perfilService.save(perfil));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        perfilService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
