package com.periferia.prueba.repository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/**
 * Implementación custom: en vez de dejar que Spring Data ejecute un DELETE
 * físico (que el trigger trg_soft_delete_publicacion cancela), actualiza
 * directamente la columna eliminado a 0.
 *
 * @author daniel.barrera
 */
@Repository
public class PublicacionRepositoryImpl implements PublicacionRepositoryCustom {

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    @Transactional
    public void deleteById(Long id) {
        entityManager.createQuery("UPDATE Publicacion p SET p.eliminado = 0 WHERE p.id = :id")
                .setParameter("id", id)
                .executeUpdate();
    }
}
