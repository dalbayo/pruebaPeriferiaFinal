package com.periferia.prueba.service;

import com.periferia.prueba.model.PublicacionAdjunto;
import java.util.List;
import java.util.Optional;

public interface IPublicacionAdjuntoService {
    List<PublicacionAdjunto> findAll();
    Optional<PublicacionAdjunto> findById(Long id);

    PublicacionAdjunto save(PublicacionAdjunto entity);
    void deleteById(Long id);
}
