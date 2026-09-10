package com.periferia.prueba.service.impl;

import com.periferia.prueba.model.Usuario;
import com.periferia.prueba.repository.UsuarioRepository;
import com.periferia.prueba.service.IUsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UsuarioServiceImpl implements IUsuarioService {
    private final UsuarioRepository repository;

    @Override
    @Transactional(readOnly = true)
    public List<Usuario> findAll() {
        return repository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Usuario> findById(Long id) {
        return repository.findById(id);
    }

    @Override
    @Transactional
    public Usuario save(Usuario entity) {
        return repository.save(entity);
    }

    @Override
    @Transactional
    public void deleteById(Long id) {
        repository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Usuario> findByUsername(String username) {
        return repository.findByUsername(username);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Usuario> findByToken(String token) {
        return repository.findByToken(token);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Usuario> findByRefreshToken(String refreshToken) {
        return repository.findByRefreshToken(refreshToken);
    }

    @Override
    @Transactional
    public Usuario actualizarTokens(
            Long usuarioId,
            String token,
            LocalDateTime expiryDate,
            String refreshToken,
            LocalDateTime refreshTokenExpiry) {

        int registrosActualizados = repository.actualizarTokens(
                usuarioId,
                token,
                expiryDate,
                refreshToken,
                refreshTokenExpiry);

        if (registrosActualizados == 0) {
            throw new IllegalArgumentException(
                    "No se encontró el usuario con id: " + usuarioId);
        }

        return repository.findById(usuarioId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "No se pudo recuperar el usuario con id: " + usuarioId));
    }
}
