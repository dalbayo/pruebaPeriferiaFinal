package com.periferia.prueba.service.impl;

import com.periferia.prueba.model.PublicacionAdjunto;
import com.periferia.prueba.repository.PublicacionAdjuntoRepository;
import com.periferia.prueba.service.IPublicacionAdjuntoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PublicacionAdjuntoServiceImpl implements IPublicacionAdjuntoService {
    private final PublicacionAdjuntoRepository repository;

    @Override @Transactional(readOnly = true)
    public List<PublicacionAdjunto> findAll() { return repository.findAll(); }
    @Override @Transactional(readOnly = true)
    public Optional<PublicacionAdjunto> findById(Long id) { return repository.findById(id); }
    @Override @Transactional
    public PublicacionAdjunto save(PublicacionAdjunto entity) { return repository.save(entity); }
    @Override @Transactional
    public void deleteById(Long id) { repository.deleteById(id); }
}
