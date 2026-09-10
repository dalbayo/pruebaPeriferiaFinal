package com.periferia.prueba.service;

import com.periferia.prueba.model.Categoria;
import java.util.List;
import java.util.Optional;

/**
 * Contrato de servicio para la gestión de categorías (CRUD y
 * búsqueda por slug).
 *
 * @author daniel.barrera
 */
public interface ICategoriaService {
    List<Categoria> findAll();
    Optional<Categoria> findById(Long id);

    Optional<Categoria> findBySlug(String slug);
    Categoria save(Categoria entity);
    void deleteById(Long id);
}
