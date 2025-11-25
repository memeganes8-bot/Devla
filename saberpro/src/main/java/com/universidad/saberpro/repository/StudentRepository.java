package com.universidad.saberpro.repository;

import com.universidad.saberpro.model.Student;
import com.universidad.saberpro.model.enums.ProgramType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 🗄️ REPOSITORY DE STUDENT - VERSIÓN SIMPLIFICADA
 * 
 * Solo busca por:
 * - identification (código)
 * - lastName (apellido)
 */
@Repository
public interface StudentRepository extends JpaRepository<Student, Long> {
    
    // =====================================
    // BÚSQUEDA POR CÓDIGO (CLAVE PARA LOGIN)
    // =====================================
    
    /**
     * ⭐ Busca estudiante por código de registro
     * Este es el método principal para el login
     */
    Optional<Student> findByIdentification(String identification);
    
    /**
     * Verifica si existe un código
     */
    boolean existsByIdentification(String identification);
    
    // =====================================
    // BÚSQUEDA POR APELLIDO O CÓDIGO
    // =====================================
    
    /**
     * ⭐ Busca por apellido
     */
    List<Student> findByLastNameContainingIgnoreCase(String lastName);
    
    /**
     * ⭐ Busca por código O apellido (para búsqueda general)
     */
    List<Student> findByIdentificationContainingIgnoreCaseOrLastNameContainingIgnoreCase(
        String identification, String lastName
    );
    
    // =====================================
    // BÚSQUEDA POR PROGRAMA
    // =====================================
    
    /**
     * Busca por programa académico
     */
    List<Student> findByProgram(String program);
    
    /**
     * ⭐ Busca por tipo de programa (Tecnológico/Profesional)
     */
    List<Student> findByProgramType(ProgramType programType);
    
    /**
     * Busca por programa y año
     */
    List<Student> findByProgramAndEnrollmentYear(String program, Integer year);
    
    // =====================================
    // FILTROS DE ESTADO
    // =====================================
    
    /**
     * Busca estudiantes activos
     */
    List<Student> findByActiveTrue();
    
    /**
     * Busca estudiantes inactivos
     */
    List<Student> findByActiveFalse();
    
    // =====================================
    // CONTADORES
    // =====================================
    
    /**
     * Cuenta estudiantes por programa
     */
    long countByProgram(String program);
    
    /**
     * Cuenta estudiantes activos
     */
    long countByActiveTrue();
    
    /**
     * Cuenta por tipo de programa
     */
    long countByProgramType(ProgramType programType);
}