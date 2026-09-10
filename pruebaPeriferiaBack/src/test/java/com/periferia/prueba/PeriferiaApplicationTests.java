package com.periferia.prueba;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

// Perfil "test" -> H2 en memoria (ver application-test.properties). Sin esto
// el contexto intenta conectar contra el Postgres real de
// application.properties y falla/cuelga si no está corriendo.
@SpringBootTest
@ActiveProfiles("test")
class PeriferiaApplicationTests {

	@Test
	void contextLoads() {
	}

}
