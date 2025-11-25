package com.universidad.saberpro.repository;

import com.universidad.saberpro.model.Result;
import com.universidad.saberpro.model.Student;
import com.universidad.saberpro.model.enums.TestType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * 📦 REPOSITORY PARA RESULT
 * 
 * En Spring Boot, los Repository son INTERFACES (no clases).
 * Spring Data JPA crea automáticamente la implementación.
 * 
 * Esto es más simple que en JSF donde tenías que crear
 * clases DAO manualmente con EntityManager.
 */
@Repository
public interface ResultRepository extends JpaRepository<Result, Long> {

    /**
     * Busca todos los resultados de un estudiante
     * 
     * Equivalente en JSF:
     * SELECT r FROM Result r WHERE r.student = :student
     */
    List<Result> findByStudent(Student student);

    /**
     * Busca todos los resultados de un estudiante ordenados por fecha descendente
     * (Los más recientes primero)
     */
    List<Result> findByStudentOrderByTestDateDesc(Student student);

    /**
     * Busca todos los resultados de un estudiante por ID
     * 
     * Útil cuando solo tienes el ID del estudiante, no el objeto completo
     */
    List<Result> findByStudentId(Long studentId);

    /**
     * Busca resultados por tipo de prueba
     * 
     * Ejemplo: findByTestType(TestType.SABER_TYT)
     * Retorna todos los resultados de Saber TyT
     */
    List<Result> findByTestType(TestType testType);

    /**
     * Busca el resultado más reciente de un estudiante
     * 
     * Usa Optional porque puede que no exista (estudiante sin resultados)
     */
    Optional<Result> findFirstByStudentOrderByTestDateDesc(Student student);

    /**
     * Busca resultados de un estudiante por tipo de prueba
     * 
     * Ejemplo: Todos los resultados de Saber PRO de Juan
     */
    List<Result> findByStudentAndTestType(Student student, TestType testType);

    /**
     * Busca resultados con puntaje inferior al mínimo (no pueden graduarse)
     * 
     * TyT: < 80, PRO: < 120
     * Útil para generar reportes de estudiantes en riesgo
     */
    List<Result> findByScoreLessThan(Integer score);

    /**
     * Cuenta resultados por estudiante
     * 
     * Retorna long (número de resultados)
     */
    long countByStudent(Student student);

    /**
     * Cuenta resultados por tipo de prueba
     * 
     * Ejemplo: ¿Cuántos estudiantes presentaron Saber TyT?
     */
    long countByTestType(TestType testType);

    /**
     * Verifica si existe un resultado para un estudiante en una fecha específica
     * 
     * Útil para evitar duplicados
     * Retorna true/false
     */
    boolean existsByStudentAndTestDate(Student student, LocalDate testDate);
}