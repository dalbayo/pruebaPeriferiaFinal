package com.periferia.prueba;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;

/**
 * Clase principal de arranque de la aplicación Spring Boot.
 * Excluye la autoconfiguración de seguridad por defecto
 * (SecurityAutoConfiguration), ya que la seguridad se configura
 * manualmente en SecurityConfig, y limita el escaneo de componentes
 * al paquete base com.periferia.prueba.
 *
 * @author daniel.barrera
 */
// Excluimos la configuraciÃ³n de seguridad automÃ¡tica aquÃ­
@SpringBootApplication(exclude = { SecurityAutoConfiguration.class })
@ComponentScan(basePackages = "com.periferia.prueba")
public class PeriferiaApplication {
    public static void main(String[] args) {
        SpringApplication.run(PeriferiaApplication.class, args);
    }
}
