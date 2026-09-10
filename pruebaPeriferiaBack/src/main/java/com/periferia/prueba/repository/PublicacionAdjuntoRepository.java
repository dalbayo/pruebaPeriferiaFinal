package com.periferia.prueba.repository;

import com.periferia.prueba.model.PublicacionAdjunto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PublicacionAdjuntoRepository extends JpaRepository<PublicacionAdjunto, Long> {
}
