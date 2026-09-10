package com.periferia.prueba.service.impl;

import com.periferia.prueba.model.Publicacion;
import com.periferia.prueba.repository.PublicacionRepository;
import com.periferia.prueba.service.IPublicacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PublicacionServiceImpl implements IPublicacionService {
    private final PublicacionRepository repository;

    @Override @Transactional(readOnly = true)
    public List<Publicacion> findAll() { return repository.findAll(); }
    @Override @Transactional(readOnly = true)
    public Optional<Publicacion> findById(Long id) { return repository.findById(id); }
    @Override @Transactional
    public Publicacion save(Publicacion entity) { return repository.save(entity); }
    @Override @Transactional
    public void deleteById(Long id) { repository.deleteById(id); }

    @Override
    @Transactional(readOnly = true)
    public Optional<Publicacion> findBySlug(String slug) {
        return repository.findBySlug(slug);
    }
}
