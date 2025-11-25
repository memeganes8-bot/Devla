package com.universidad.saberpro.controller;

import com.universidad.saberpro.model.Result;
import com.universidad.saberpro.model.Student;
import com.universidad.saberpro.service.ResultService;
import com.universidad.saberpro.service.StudentService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Optional;

/**
 * 🎓 CONTROLADOR PARA ESTUDIANTE
 * 
 * Maneja las vistas del portal del estudiante:
 * - Dashboard personal
 * - Mis datos
 * - Mis resultados
 * - Mis beneficios
 */
@Controller
@RequestMapping("/estudiante")
public class EstudianteController {
    
    @Autowired
    private StudentService studentService;
    
    @Autowired
    private ResultService resultService;
    
    /**
     * Dashboard del estudiante
     * Muestra resumen completo
     */
    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        // Verificar sesión
        if (session.getAttribute("userType") == null || 
            !"ESTUDIANTE".equals(session.getAttribute("userType"))) {
            return "redirect:/estudiante/login";
        }
        
        Long studentId = (Long) session.getAttribute("studentId");
        Optional<Student> studentOpt = studentService.buscarPorId(studentId);
        
        if (studentOpt.isPresent()) {
            Student student = studentOpt.get();
            
            // Obtener todos los resultados del estudiante
            List<Result> results = resultService.obtenerResultadosPorEstudiante(studentId);
            
            // Obtener resultado más reciente
            Optional<Result> latestResult = resultService.obtenerResultadoMasReciente(studentId);
            
            // Verificar si puede graduarse
            boolean canGraduate = resultService.puedeGraduar(studentId);
            
            // Enviar datos a la vista
            model.addAttribute("student", student);
            model.addAttribute("results", results);
            model.addAttribute("latestResult", latestResult.orElse(null));
            model.addAttribute("canGraduate", canGraduate);
            model.addAttribute("totalResults", results.size());
            
            return "estudiante/dashboard";
        } else {
            return "redirect:/estudiante/login";
        }
    }
    
    /**
     * Mis datos personales
     */
    @GetMapping("/datos")
    public String misDatos(HttpSession session, Model model) {
        if (session.getAttribute("userType") == null) {
            return "redirect:/estudiante/login";
        }
        
        Long studentId = (Long) session.getAttribute("studentId");
        Optional<Student> studentOpt = studentService.buscarPorId(studentId);
        
        if (studentOpt.isPresent()) {
            model.addAttribute("student", studentOpt.get());
            return "estudiante/datos";
        }
        
        return "redirect:/estudiante/login";
    }
    
    /**
     * Mis resultados
     */
    @GetMapping("/resultados")
    public String misResultados(HttpSession session, Model model) {
        if (session.getAttribute("userType") == null) {
            return "redirect:/estudiante/login";
        }
        
        Long studentId = (Long) session.getAttribute("studentId");
        Optional<Student> studentOpt = studentService.buscarPorId(studentId);
        
        if (studentOpt.isPresent()) {
            Student student = studentOpt.get();
            List<Result> results = resultService.obtenerResultadosPorEstudiante(studentId);
            
            model.addAttribute("student", student);
            model.addAttribute("results", results);
            
            return "estudiante/resultados";
        }
        
        return "redirect:/estudiante/login";
    }
    
    /**
     * Mis beneficios
     */
    @GetMapping("/beneficios")
    public String misBeneficios(HttpSession session, Model model) {
        if (session.getAttribute("userType") == null) {
            return "redirect:/estudiante/login";
        }
        
        Long studentId = (Long) session.getAttribute("studentId");
        Optional<Student> studentOpt = studentService.buscarPorId(studentId);
        
        if (studentOpt.isPresent()) {
            Student student = studentOpt.get();
            List<Result> results = resultService.obtenerResultadosPorEstudiante(studentId);
            
            // Filtrar solo resultados con beneficios
            List<Result> resultsWithBenefits = results.stream()
                .filter(r -> r.getBenefit() != null)
                .toList();
            
            model.addAttribute("student", student);
            model.addAttribute("results", resultsWithBenefits);
            
            return "estudiante/beneficios";
        }
        
        return "redirect:/estudiante/login";
    }
}