package com.periferia.prueba.config;

import java.util.Arrays;

import com.periferia.prueba.security.jwt.JwtAuthFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

	private final JwtAuthFilter jwtAuthFilter;

	@Bean
	public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
		return config.getAuthenticationManager();
	}

	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
		/*
		 * http
		 * .cors(cors -> cors.configurationSource(request -> {
		 * var config = new org.springframework.web.cors.CorsConfiguration();
		 * config.setAllowedOrigins(java.util.List.of("http://localhost:4000")); // El
		 * puerto de tu frontend
		 * config.setAllowedMethods(java.util.List.of("GET", "POST", "PUT", "DELETE",
		 * "OPTIONS"));
		 * config.setAllowedHeaders(java.util.List.of("*"));
		 * config.setAllowCredentials(true);
		 * return config;
		 * }))
		 * .csrf(csrf -> csrf.disable())
		 * .authorizeHttpRequests(auth -> auth
		 * .requestMatchers(org.springframework.http.HttpMethod.OPTIONS,
		 * "/**").permitAll() // <-- CLAVE: Permite OPTIONS globalmente
		 * .requestMatchers("/api/auth/**").permitAll()
		 * .anyRequest().authenticated()
		 * );
		 */
		// http
		// .cors(cors -> cors.configurationSource(corsConfigurationSource()))
		// .csrf(csrf -> csrf.disable())
		// .authorizeHttpRequests(auth -> auth
		// .anyRequest().permitAll()
		// );
		// return http.build();
		http
				.cors(cors -> cors.configurationSource(corsConfigurationSource()))
				.csrf(csrf -> csrf.disable())
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
				.authorizeHttpRequests(auth -> auth
						// 1. Permitir acceso público a AuthController
						.requestMatchers("/api/auth/**").permitAll()

						// 2. Permitir acceso público a TestController
						.requestMatchers("/test/**").permitAll()

						// 2b. Permitir acceso público a Swagger/OpenAPI
						.requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()

						// 3. Exigir autenticación para CUALQUIER otra ruta
						.anyRequest().authenticated())
				.addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

		return http.build();
	}

	@Bean
	public CorsConfigurationSource corsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();

		// ESTA ES LA DIFERENCIA: Usamos "Patterns" en lugar de "Origins"
		configuration.setAllowedOriginPatterns(Arrays.asList("*"));

		configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
		configuration.setAllowedHeaders(Arrays.asList("Authorization", "Cache-Control", "Content-Type"));
		configuration.setAllowCredentials(true);

		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);
		return source;
	}

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	/**
	 * JwtAuthFilter es @Component (para poder inyectarle JwtService y
	 * UserDetailsService) y además se agrega a mano a la cadena de Spring
	 * Security (addFilterBefore, arriba). Sin este bean, Spring Boot lo
	 * auto-registra TAMBIÉN como filtro de servlet genérico para "/*",
	 * duplicando su ejecución y descuadrando el orden real de la cadena de
	 * seguridad (causa típica de 403 con token válido). Esto lo desactiva.
	 */
	@Bean
	public FilterRegistrationBean<JwtAuthFilter> jwtAuthFilterRegistration(JwtAuthFilter filter) {
		FilterRegistrationBean<JwtAuthFilter> registration = new FilterRegistrationBean<>(filter);
		registration.setEnabled(false);
		return registration;
	}
}