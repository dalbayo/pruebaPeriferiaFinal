package com.periferia.prueba.service.impl;

import com.periferia.prueba.model.Publicacion;
import com.periferia.prueba.repository.PublicacionRepository;
import com.periferia.prueba.service.IPublicacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PublicacionServiceImpl implements IPublicacionService {

    private final PublicacionRepository publicacionRepository;

    @Override
    public List<Publicacion> findAll() {
        return publicacionRepository.findAll();
    }

    @Override
    public List<Publicacion> findByUsuarioId(Long usuarioId) {
        return publicacionRepository.findByUsuarioId(usuarioId);
    }

    @Override
    public List<Publicacion> findByUsuarioIdNot(Long usuarioId) {
        return publicacionRepository.findByUsuarioIdNot(usuarioId);
    }

    @Override
    public Optional<Publicacion> findById(Long id) {
        return publicacionRepository.findById(id);
    }

    @Override
    public Optional<Publicacion> findBySlug(String slug) {
        return publicacionRepository.findBySlug(slug);
    }

    @Override
    public Publicacion save(Publicacion entity) {
        return publicacionRepository.save(entity);
    }

    @Override
    public void deleteById(Long id) {
        publicacionRepository.deleteById(id);
    }
}
