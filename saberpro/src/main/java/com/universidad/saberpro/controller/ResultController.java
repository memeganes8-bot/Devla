package com.universidad.saberpro.controller;

import com.universidad.saberpro.model.Result;
import com.universidad.saberpro.model.Student;
import com.universidad.saberpro.model.enums.TestType;
import com.universidad.saberpro.service.ResultService;
import com.universidad.saberpro.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.List;

/**
 * Controlador para gestionar resultados de pruebas Saber
 */
@Controller
@RequestMapping("/results")
public class ResultController {
    
    @Autowired
    private ResultService resultService;
    
    @Autowired
    private StudentService studentService;
    
    /**
     * Lista todos los resultados
     */
    @GetMapping
    public String listar(Model model) {
        List<Result> results = resultService.obtenerTodos();
        model.addAttribute("results", results);
        model.addAttribute("totalResults", results.size());
        return "results/list";
    }
    
    /**
     * Muestra el formulario para registrar un nuevo resultado
     */
    @GetMapping("/new")
    public String mostrarFormularioCrear(Model model) {
        List<Student> students = studentService.obtenerActivos();
        model.addAttribute("students", students);
        model.addAttribute("testTypes", TestType.values());
        model.addAttribute("titulo", "Registrar Nuevo Resultado");
        return "results/form";
    }
    
    /**
     * Guarda un nuevo resultado
     */
    @PostMapping
    public String crear(@RequestParam Long studentId,
                       @RequestParam TestType testType,
                       @RequestParam Integer score,
                       @RequestParam String testDate,
                       @RequestParam(required = false) String observations,
                       RedirectAttributes redirectAttributes) {
        try {
            // Convertir fecha
            LocalDate date = LocalDate.parse(testDate);
            
            // Registrar resultado (calcula beneficio automáticamente)
            Result result = resultService.registrarResultado(
                studentId, 
                testType, 
                score, 
                date, 
                observations
            );
            
            // Mensaje de éxito
            redirectAttributes.addFlashAttribute("mensaje", 
                "Resultado registrado exitosamente. Beneficio calculado automáticamente.");
            redirectAttributes.addFlashAttribute("tipo", "success");
            
            // Información del beneficio
            if (result.getBenefit() != null) {
                redirectAttributes.addFlashAttribute("benefitInfo", 
                    result.getBenefit().generateDescription());
            }
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("mensaje", 
                "Error al registrar resultado: " + e.getMessage());
            redirectAttributes.addFlashAttribute("tipo", "danger");
        }
        
        return "redirect:/results";
    }
    
    /**
     * Muestra el detalle de un resultado
     */
    @GetMapping("/{id}")
    public String ver(@PathVariable Long id, Model model) {
        Result result = resultService.buscarPorId(id)
            .orElseThrow(() -> new RuntimeException("Resultado no encontrado"));
        
        model.addAttribute("result", result);
        return "results/detail";
    }
    
    /**
     * Elimina un resultado
     */
    @GetMapping("/delete/{id}")
    public String eliminar(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            resultService.eliminarResultado(id);
            redirectAttributes.addFlashAttribute("mensaje", "Resultado eliminado exitosamente");
            redirectAttributes.addFlashAttribute("tipo", "success");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("mensaje", "Error: " + e.getMessage());
            redirectAttributes.addFlashAttribute("tipo", "danger");
        }
        return "redirect:/results";
    }
    
    /**
     * Lista resultados de un estudiante específico
     */
    @GetMapping("/student/{studentId}")
    public String listarPorEstudiante(@PathVariable Long studentId, Model model) {
        Student student = studentService.buscarPorId(studentId)
            .orElseThrow(() -> new RuntimeException("Estudiante no encontrado"));
        
        List<Result> results = resultService.obtenerResultadosPorEstudiante(studentId);
        
        model.addAttribute("student", student);
        model.addAttribute("results", results);
        model.addAttribute("totalResults", results.size());
        
        return "results/list";
    }
}