package com.periferia.prueba.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import com.periferia.prueba.model.Usuario;
import com.periferia.prueba.repository.UsuarioRepository;
import com.periferia.prueba.security.jwt.UserDetailsImpl;

/**
 * Implementación de UserDetailsService usada por Spring Security
 * para cargar un Usuario por su username durante el proceso de
 * autenticación.
 *
 * @author daniel.barrera
 */
@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String username)
            throws UsernameNotFoundException {

        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));

        return new UserDetailsImpl(usuario);
    }
}
