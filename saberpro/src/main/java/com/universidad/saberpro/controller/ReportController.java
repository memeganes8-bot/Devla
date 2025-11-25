package com.universidad.saberpro.controller;

import com.universidad.saberpro.model.Benefit;
import com.universidad.saberpro.model.Result;
import com.universidad.saberpro.model.Student;
import com.universidad.saberpro.model.enums.BenefitType;
import com.universidad.saberpro.repository.BenefitRepository;
import com.universidad.saberpro.service.ResultService;
import com.universidad.saberpro.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

/**
 * Controlador para reportes del sistema
 */
@Controller
@RequestMapping("/reports")
public class ReportController {
    
    @Autowired
    private StudentService studentService;
    
    @Autowired
    private ResultService resultService;
    
    @Autowired
    private BenefitRepository benefitRepository;
    
    /**
     * Informe General - Todos los estudiantes y sus resultados
     */
    @GetMapping("/general")
    public String informeGeneral(Model model) {
        List<Student> students = studentService.obtenerActivos();
        List<Result> results = resultService.obtenerTodos();
        
        model.addAttribute("students", students);
        model.addAttribute("results", results);
        model.addAttribute("totalStudents", students.size());
        model.addAttribute("totalResults", results.size());
        
        return "reports/general";
    }
    
    /**
     * Informe Detallado - Por estudiante especifico
     */
    @GetMapping("/detailed/{studentId}")
    public String informeDetallado(@PathVariable Long studentId, Model model) {
        Student student = studentService.buscarPorId(studentId)
            .orElseThrow(() -> new RuntimeException("Estudiante no encontrado"));
        
        List<Result> results = resultService.obtenerResultadosPorEstudiante(studentId);
        boolean canGraduate = resultService.puedeGraduar(studentId);
        
        model.addAttribute("student", student);
        model.addAttribute("results", results);
        model.addAttribute("canGraduate", canGraduate);
        
        return "reports/detailed";
    }
    
    /**
     * Informe de Beneficios - Estudiantes que obtuvieron beneficios
     */
    @GetMapping("/beneficios")
    public String informeBeneficios(Model model) {
        // Obtener todos los beneficios excepto NONE
        List<Benefit> benefits = benefitRepository.findByBenefitTypeNot(BenefitType.NONE);
        
        // Estadisticas
        long totalWithBenefits = benefits.size();
        long totalWithScholarship = benefitRepository.countByScholarshipPercentageGreaterThan(0);
        long withReportExemption = benefitRepository.countByReportExemptionTrue();
        
        // Por tipo de beneficio
        long advanced = benefitRepository.countByBenefitType(BenefitType.ADVANCED);
        long intermediate = benefitRepository.countByBenefitType(BenefitType.INTERMEDIATE);
        long basic = benefitRepository.countByBenefitType(BenefitType.BASIC);
        
        model.addAttribute("benefits", benefits);
        model.addAttribute("totalWithBenefits", totalWithBenefits);
        model.addAttribute("totalWithScholarship", totalWithScholarship);
        model.addAttribute("withReportExemption", withReportExemption);
        model.addAttribute("advanced", advanced);
        model.addAttribute("intermediate", intermediate);
        model.addAttribute("basic", basic);
        
        return "reports/beneficios";
    }
    
    /**
     * Informe de estudiantes que NO pueden graduarse
     */
    @GetMapping("/no-graduables")
    public String informeNoGraduables(Model model) {
        List<Result> resultsNoGraduables = resultService.obtenerResultadosQueNoPuedenGraduar();
        
        model.addAttribute("results", resultsNoGraduables);
        model.addAttribute("total", resultsNoGraduables.size());
        
        return "reports/no-graduables";
    }
}