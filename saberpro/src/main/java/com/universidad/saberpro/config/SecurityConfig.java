package com.universidad.saberpro.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

/**
 * 🔓 CONFIGURACIÓN DE SEGURIDAD
 * 
 * Desactiva Spring Security para usar autenticación manual con sesiones
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            // Permitir todas las peticiones sin autenticación
            .authorizeHttpRequests(auth -> auth
                .anyRequest().permitAll()
            )
            // Desactivar CSRF (para desarrollo)
            .csrf(csrf -> csrf.disable())
            // Desactivar el formulario de login de Spring Security
            .formLogin(form -> form.disable())
            // Desactivar HTTP Basic
            .httpBasic(basic -> basic.disable());
        
        return http.build();
    }
}

/**
 * NOTA: Esta configuración desactiva completamente Spring Security
 * y permite que uses tu propio sistema de autenticación con sesiones.
 * 
 * Más adelante puedes activarlo correctamente si lo necesitas.
 */