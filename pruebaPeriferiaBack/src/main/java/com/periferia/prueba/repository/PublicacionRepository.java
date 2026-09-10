package com.periferia.prueba.repository;

import com.periferia.prueba.model.Publicacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PublicacionRepository extends JpaRepository<Publicacion, Long> {
    Optional<Publicacion> findBySlug(String slug);

    List<Publicacion> findByUsuarioId(Long usuarioId);

    List<Publicacion> findByUsuarioIdNot(Long usuarioId);
}
