package com.periferia.prueba.service.impl;

import com.periferia.prueba.model.Categoria;
import com.periferia.prueba.repository.CategoriaRepository;
import com.periferia.prueba.service.ICategoriaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CategoriaServiceImpl implements ICategoriaService {
    private final CategoriaRepository repository;

    @Override @Transactional(readOnly = true)
    public List<Categoria> findAll() { return repository.findAll(); }
    @Override @Transactional(readOnly = true)
    public Optional<Categoria> findById(Long id) { return repository.findById(id); }
    @Override @Transactional
    public Categoria save(Categoria entity) { return repository.save(entity); }
    @Override @Transactional
    public void deleteById(Long id) { repository.deleteById(id); }

    @Override
    @Transactional(readOnly = true)
    public Optional<Categoria> findBySlug(String slug) {
        return repository.findBySlug(slug);
    }
}
