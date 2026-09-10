package com.periferia.prueba.repository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/**
 * Implementación custom: actualiza eliminado a 0 en vez de dejar que
 * Spring Data ejecute un DELETE físico.
 */
@Repository
public class UsuarioRepositoryImpl implements UsuarioRepositoryCustom {

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    @Transactional
    public void deleteById(Long id) {
        entityManager.createQuery("UPDATE Usuario u SET u.eliminado = 0 WHERE u.id = :id")
                .setParameter("id", id)
                .executeUpdate();
    }
}
