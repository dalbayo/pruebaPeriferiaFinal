package com.periferia.prueba.service.impl;

import com.periferia.prueba.model.Perfil;
import com.periferia.prueba.repository.PerfilRepository;
import com.periferia.prueba.service.IPerfilService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PerfilServiceImpl implements IPerfilService {
    private final PerfilRepository repository;

    @Override
    @Transactional(readOnly = true)
    public List<Perfil> findAll() {
        return repository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Perfil> findById(Long id) {
        return repository.findById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Perfil> findByNombre(String nombre) {
        return repository.findByNombre(nombre);
    }

    @Override
    @Transactional
    public Perfil save(Perfil entity) {
        return repository.save(entity);
    }

    @Override
    @Transactional
    public void deleteById(Long id) {
        repository.deleteById(id);
    }
}
