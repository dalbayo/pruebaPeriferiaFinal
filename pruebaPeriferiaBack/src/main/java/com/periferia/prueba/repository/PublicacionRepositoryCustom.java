package com.periferia.prueba.repository;

/**
 * Fragmento custom de PublicacionRepository: permite sobrescribir el delete
 * generado por Spring Data (DELETE físico) para hacer un soft-delete en su
 * lugar, ya que el trigger BEFORE DELETE de Postgres cancela el DELETE
 * físico y deja el statement de Hibernate en 0 filas afectadas
 * (ObjectOptimisticLockingFailureException).
 */
public interface PublicacionRepositoryCustom {
    void deleteById(Long id);
}
