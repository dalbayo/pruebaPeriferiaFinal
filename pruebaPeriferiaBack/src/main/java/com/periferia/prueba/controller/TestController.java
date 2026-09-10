package com.periferia.prueba.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;

/**
 * Controlador público de prueba/healthcheck. Expone un endpoint
 * simple para verificar que el backend está en línea, sin requerir
 * autenticación.
 *
 * @author daniel.barrera
 */
@RestController
@RequestMapping("/test")
// @CrossOrigin(origins = "*", methods = {RequestMethod.GET, RequestMethod.POST,
// RequestMethod.PUT, RequestMethod.DELETE})
public class TestController {

    @GetMapping("/status")
    public Map<String, String> getStatus() {
        Map<String, String> response = new HashMap<>();
        response.put("estado", "OK");
        response.put("mensaje", "Backend de prueba Periferia conectado exitosamente");
        return response;
    }
}
