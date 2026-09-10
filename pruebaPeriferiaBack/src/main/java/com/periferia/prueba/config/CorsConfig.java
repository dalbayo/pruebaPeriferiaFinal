package com.periferia.prueba.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Configuración CORS a nivel de Spring MVC (WebMvcConfigurer). Permite
 * peticiones desde cualquier origen (allowedOriginPatterns) con
 * credenciales habilitadas.
 *
 * @author daniel.barrera
 */
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        // registry.addMapping("/**") // Aplica a todos los endpoints
        // .allowedOrigins("*") // Permite tu frontend
        // //.registry.addMapping("/**")
        // .allowedOrigins("*")
        // .allowedMethods("*")
        // .allowedHeaders("*")
        // // .allowedOrigins("http://localhost:4000") // Permite tu frontend
        // .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
        // .allowedHeaders("*")
        // .allowCredentials(true);
        registry.addMapping("/**").allowedOriginPatterns("*").allowCredentials(true);

    }
}
