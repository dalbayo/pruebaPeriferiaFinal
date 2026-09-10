package com.periferia.prueba.repository;

/**
 * Fragmento custom de UsuarioRepository: mismo motivo que
 * PublicacionRepositoryCustom — evita el DELETE físico que el trigger
 * trg_soft_delete_usuario cancela.
 *
 * @author daniel.barrera
 */
public interface UsuarioRepositoryCustom {
    void deleteById(Long id);
}
