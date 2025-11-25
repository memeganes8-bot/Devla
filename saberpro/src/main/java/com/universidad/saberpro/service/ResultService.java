package com.universidad.saberpro.service;

import com.universidad.saberpro.model.Benefit;
import com.universidad.saberpro.model.Result;
import com.universidad.saberpro.model.Student;
import com.universidad.saberpro.model.enums.TestType;
import com.universidad.saberpro.repository.BenefitRepository;
import com.universidad.saberpro.repository.ResultRepository;
import com.universidad.saberpro.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * 📊 SERVICIO PARA GESTIONAR RESULTADOS
 * 
 * Este servicio maneja toda la lógica de negocio relacionada con
 * los resultados de las pruebas Saber.
 * 
 * FUNCIONES PRINCIPALES:
 * - Registrar resultados
 * - Calcular beneficios automáticamente
 * - Consultar resultados por estudiante
 * - Validar si puede graduarse
 */
@Service
@Transactional
public class ResultService {
    
    @Autowired
    private ResultRepository resultRepository;
    
    @Autowired
    private BenefitRepository benefitRepository;
    
    @Autowired
    private StudentRepository studentRepository;
    
    @Autowired
    private BenefitCalculatorService benefitCalculatorService;
    
    /**
     * ⭐ MÉTODO PRINCIPAL: Registra un nuevo resultado y calcula su beneficio automáticamente
     * 
     * FLUJO:
     * 1. Busca el estudiante por ID
     * 2. Valida que el puntaje esté en el rango correcto
     * 3. Crea el resultado
     * 4. Guarda el resultado en BD
     * 5. Calcula el beneficio automáticamente
     * 6. Guarda el beneficio en BD
     * 7. Asocia el beneficio al resultado
     * 8. Retorna el resultado completo con su beneficio
     */
    public Result registrarResultado(Long studentId, TestType testType, Integer score, 
                                     LocalDate testDate, String observations) {
        
        // 1. Buscar el estudiante
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Estudiante no encontrado con ID: " + studentId));
        
        // 2. Validar el puntaje
        if (!testType.isValidScore(score)) {
            throw new RuntimeException(
                "Puntaje inválido para " + testType.getDisplayName() + 
                ". Debe estar entre " + testType.getMinScore() + " y " + testType.getMaxScore()
            );
        }
        
        // 3. Crear el resultado
        Result result = new Result(student, testType, score, testDate);
        result.setObservations(observations);
        
        // 4. Guardar el resultado
        result = resultRepository.save(result);
        
        // 5. Calcular el beneficio automáticamente
        Benefit benefit = benefitCalculatorService.calculateBenefit(result);
        benefit.setResult(result);
        
        // 6. Guardar el beneficio
        benefitRepository.save(benefit);
        
        // 7. Asociar el beneficio al resultado
        result.setBenefit(benefit);
        
        return result;
    }
    
    /**
     * Obtiene todos los resultados de un estudiante
     */
    public List<Result> obtenerResultadosPorEstudiante(Long studentId) {
        return resultRepository.findByStudentId(studentId);
    }
    
    /**
     * Obtiene el resultado más reciente de un estudiante
     */
    public Optional<Result> obtenerResultadoMasReciente(Long studentId) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Estudiante no encontrado"));
        return resultRepository.findFirstByStudentOrderByTestDateDesc(student);
    }
    
    /**
     * Obtiene todos los resultados
     */
    public List<Result> obtenerTodos() {
        return resultRepository.findAll();
    }
    
    /**
     * Busca un resultado por ID
     */
    public Optional<Result> buscarPorId(Long id) {
        return resultRepository.findById(id);
    }
    
    /**
     * Elimina un resultado (y su beneficio por cascade)
     */
    public void eliminarResultado(Long id) {
        resultRepository.deleteById(id);
    }
    
    /**
     * Obtiene estudiantes que no pueden graduarse
     * (puntaje inferior al mínimo)
     */
    public List<Result> obtenerResultadosQueNoPuedenGraduar() {
        List<Result> allResults = resultRepository.findAll();
        return allResults.stream()
            .filter(r -> !r.allowsGraduation())
            .toList();
    }
    
    /**
     * Cuenta resultados por tipo de prueba
     */
    public long contarPorTipoPrueba(TestType testType) {
        return resultRepository.countByTestType(testType);
    }
    
    /**
     * Verifica si un estudiante puede graduarse
     * (todos sus resultados deben cumplir el puntaje mínimo)
     */
    public boolean puedeGraduar(Long studentId) {
        List<Result> results = obtenerResultadosPorEstudiante(studentId);
        
        if (results.isEmpty()) {
            return false; // Sin resultados, no puede graduarse
        }
        
        // Verificar que todos los resultados permitan graduación
        return results.stream().allMatch(Result::allowsGraduation);
    }
    
    /**
     * Obtiene resultados por tipo de prueba
     */
    public List<Result> obtenerPorTipoPrueba(TestType testType) {
        return resultRepository.findByTestType(testType);
    }
    
    /**
     * Verifica si ya existe un resultado para un estudiante en una fecha específica
     * (evita duplicados)
     */
    public boolean existeResultadoEnFecha(Long studentId, LocalDate testDate) {
        Student student = studentRepository.findById(studentId).orElse(null);
        if (student == null) {
            return false;
        }
        return resultRepository.existsByStudentAndTestDate(student, testDate);
    }
}