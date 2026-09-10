package com.periferia.prueba.service;

import com.periferia.prueba.model.Publicacion;

import java.util.List;
import java.util.Optional;

public interface IPublicacionService {
    List<Publicacion> findAll();

    List<Publicacion> findByUsuarioId(Long usuarioId);

    List<Publicacion> findByUsuarioIdNot(Long usuarioId);

    Optional<Publicacion> findById(Long id);

    Optional<Publicacion> findBySlug(String slug);

    Publicacion save(Publicacion entity);

    void deleteById(Long id);
}
