package com.periferia.prueba.service;

import com.periferia.prueba.model.Publicacion;
import java.util.List;
import java.util.Optional;

public interface IPublicacionService {
    List<Publicacion> findAll();
    Optional<Publicacion> findById(Long id);

    Optional<Publicacion> findBySlug(String slug);
    Publicacion save(Publicacion entity);
    void deleteById(Long id);
}
