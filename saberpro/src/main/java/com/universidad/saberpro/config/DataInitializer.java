package com.universidad.saberpro.config;

import com.universidad.saberpro.model.Student;
import com.universidad.saberpro.model.enums.ProgramType;
import com.universidad.saberpro.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

/**
 * 🚀 DATA INITIALIZER - VERSIÓN SIMPLIFICADA
 * 
 * Carga datos iniciales de estudiantes
 * Solo necesita: código + apellido + programa
 */
@Component
public class DataInitializer implements CommandLineRunner {
    
    @Autowired
    private StudentService studentService;
    
    @Override
    public void run(String... args) throws Exception {
        System.out.println("🚀 Iniciando carga de datos...");
        
        // Solo cargar si no hay estudiantes
        if (studentService.contarTodos() == 0) {
            cargarEstudiantesDeEjemplo();
            System.out.println("✅ Datos de ejemplo cargados exitosamente");
        } else {
            System.out.println("ℹ️ Ya existen estudiantes en la base de datos");
        }
    }
    
    /**
     * Carga estudiantes de ejemplo
     */
    private void cargarEstudiantesDeEjemplo() {
        // Estudiantes Tecnológicos
        crearEstudiante("EK2083007722", "BARBOSA", "Tecnología en Sistemas", ProgramType.TECNOLOGICO, 2020);
        crearEstudiante("EK2083340703", "PARRA", "Tecnología en Sistemas", ProgramType.TECNOLOGICO, 2020);
        crearEstudiante("EK2083040545", "QUINTERO", "Tecnología en Electrónica", ProgramType.TECNOLOGICO, 2020);
        crearEstudiante("EK2083025381", "ANAYA", "Tecnología en Sistemas", ProgramType.TECNOLOGICO, 2020);
        crearEstudiante("EK2083025335", "FLOR", "Tecnología en Sistemas", ProgramType.TECNOLOGICO, 2020);
        
        // Estudiantes Profesionales
        crearEstudiante("EK2083122648", "GARCIA", "Ingeniería de Sistemas", ProgramType.PROFESIONAL, 2018);
        crearEstudiante("EK2083024805", "MANCISALVA", "Ingeniería Electrónica", ProgramType.PROFESIONAL, 2018);
        crearEstudiante("EK2083187351", "MENDOZA", "Ingeniería de Sistemas", ProgramType.PROFESIONAL, 2018);
        crearEstudiante("EK2083233820", "BELTRAN", "Ingeniería Civil", ProgramType.PROFESIONAL, 2019);
        crearEstudiante("EK2083030016", "SANTAMARIA", "Ingeniería Industrial", ProgramType.PROFESIONAL, 2019);
        
        System.out.println("✅ " + studentService.contarTodos() + " estudiantes cargados");
    }
    
    /**
     * ⭐ NUEVO CONSTRUCTOR SIMPLIFICADO
     * Solo necesita: código + apellido + programa + tipo + año
     */
    private void crearEstudiante(String codigo, String apellido, String programa, 
                                  ProgramType tipo, Integer año) {
        try {
            Student student = new Student(
                codigo,      // identification
                apellido,    // lastName
                programa,    // program
                tipo,        // programType
                año          // enrollmentYear
            );
            
            studentService.guardar(student);
            System.out.println("✓ Creado: " + codigo + " - " + apellido);
            
        } catch (Exception e) {
            System.err.println("❌ Error creando estudiante " + codigo + ": " + e.getMessage());
        }
    }
}