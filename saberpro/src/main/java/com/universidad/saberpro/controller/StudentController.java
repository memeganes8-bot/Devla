package com.universidad.saberpro.controller;

import com.universidad.saberpro.model.Student;
import com.universidad.saberpro.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

/**
 * 🎮 CONTROLLER DE STUDENT
 * 
 * ¿Qué hace el Controller?
 * - Recibe peticiones HTTP del navegador
 * - Llama al Service para hacer operaciones
 * - Retorna el nombre de la vista (HTML) a mostrar
 * 
 * Comparación con JSF:
 * 
 * JSF:
 * @ManagedBean
 * @ViewScoped
 * public class ClubController {
 *     public void listar() { ... }
 * }
 * 
 * Spring Boot:
 * @Controller
 * public class StudentController {
 *     @GetMapping("/students")
 *     public String listar() { ... }
 * }
 */

@Controller  // ⭐ Le dice a Spring que esto maneja peticiones web
@RequestMapping("/students")  // ⭐ Todas las URLs empiezan con /students
public class StudentController {
    
    // =====================================
    // INYECCIÓN DEL SERVICE
    // =====================================
    
    @Autowired
    private StudentService studentService;
    
    // =====================================
    // LISTAR ESTUDIANTES
    // =====================================
    
    /**
     * GET /students
     * Muestra la lista de todos los estudiantes
     * 
     * ¿Cómo funciona?
     * 1. Usuario va a http://localhost:8080/students
     * 2. Spring llama este método
     * 3. Obtenemos los estudiantes del service
     * 4. Los ponemos en "model" para enviarlos a la vista
     * 5. Retornamos "students/list" → busca templates/students/list.html
     */
    @GetMapping
    public String listar(Model model) {
        // Obtener estudiantes del service
        List<Student> students = studentService.obtenerActivos();
        
        // Enviar a la vista
        model.addAttribute("students", students);
        model.addAttribute("totalStudents", students.size());
        
        // Retornar nombre de la vista (sin .html)
        return "students/list";  // templates/students/list.html
    }
    
    // =====================================
    // CREAR ESTUDIANTE - FORMULARIO
    // =====================================
    
    /**
     * GET /students/new
     * Muestra el formulario para crear un estudiante
     */
    @GetMapping("/new")
    public String mostrarFormularioCrear(Model model) {
        // Crear un estudiante vacío para el formulario
        model.addAttribute("student", new Student());
        model.addAttribute("titulo", "Crear Estudiante");
        
        return "students/form";  // templates/students/form.html
    }
    
    // =====================================
    // CREAR ESTUDIANTE - GUARDAR
    // =====================================
    
    /**
     * POST /students
     * Guarda un nuevo estudiante
     * 
     * @param student: Spring crea automáticamente el objeto desde el formulario
     * @param redirectAttributes: Para enviar mensajes después del redirect
     */
    @PostMapping
    public String crear(@ModelAttribute Student student, 
                       RedirectAttributes redirectAttributes) {
        try {
            // Guardar usando el service
            studentService.crearEstudiante(student);
            
            // Mensaje de éxito
            redirectAttributes.addFlashAttribute("mensaje", "Estudiante creado exitosamente");
            redirectAttributes.addFlashAttribute("tipo", "success");
            
        } catch (Exception e) {
            // Mensaje de error
            redirectAttributes.addFlashAttribute("mensaje", "Error: " + e.getMessage());
            redirectAttributes.addFlashAttribute("tipo", "error");
        }
        
        // Redirect a la lista
        return "redirect:/students";
    }
    
    // =====================================
    // EDITAR ESTUDIANTE - FORMULARIO
    // =====================================
    
    /**
     * GET /students/edit/1
     * Muestra el formulario para editar un estudiante
     * 
     * @param id: viene de la URL /students/edit/{id}
     */
    @GetMapping("/edit/{id}")
    public String mostrarFormularioEditar(@PathVariable Long id, Model model) {
        // Buscar el estudiante
        Student student = studentService.buscarPorId(id)
            .orElseThrow(() -> new RuntimeException("Estudiante no encontrado"));
        
        // Enviar a la vista
        model.addAttribute("student", student);
        model.addAttribute("titulo", "Editar Estudiante");
        
        return "students/form";
    }
    
    // =====================================
    // EDITAR ESTUDIANTE - GUARDAR
    // =====================================
    
    /**
     * POST /students/update/1
     * Actualiza un estudiante existente
     */
    @PostMapping("/update/{id}")
    public String actualizar(@PathVariable Long id,
                            @ModelAttribute Student student,
                            RedirectAttributes redirectAttributes) {
        try {
            studentService.actualizarEstudiante(id, student);
            
            redirectAttributes.addFlashAttribute("mensaje", "Estudiante actualizado exitosamente");
            redirectAttributes.addFlashAttribute("tipo", "success");
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("mensaje", "Error: " + e.getMessage());
            redirectAttributes.addFlashAttribute("tipo", "error");
        }
        
        return "redirect:/students";
    }
    
    // =====================================
    // VER DETALLE
    // =====================================
    
    /**
     * GET /students/1
     * Muestra los detalles de un estudiante
     */
    @GetMapping("/{id}")
    public String ver(@PathVariable Long id, Model model) {
        Student student = studentService.buscarPorId(id)
            .orElseThrow(() -> new RuntimeException("Estudiante no encontrado"));
        
        model.addAttribute("student", student);
        
        return "students/detail";
    }
    
    // =====================================
    // ELIMINAR ESTUDIANTE
    // =====================================
    
    /**
     * GET /students/delete/1
     * Elimina (desactiva) un estudiante
     */
    @GetMapping("/delete/{id}")
    public String eliminar(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            studentService.eliminarEstudiante(id);
            
            redirectAttributes.addFlashAttribute("mensaje", "Estudiante eliminado exitosamente");
            redirectAttributes.addFlashAttribute("tipo", "success");
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("mensaje", "Error: " + e.getMessage());
            redirectAttributes.addFlashAttribute("tipo", "error");
        }
        
        return "redirect:/students";
    }
    
    // =====================================
    // BUSCAR
    // =====================================
    
    /**
     * GET /students/search?q=juan
     * Busca estudiantes por nombre
     */
    @GetMapping("/search")
    public String buscar(@RequestParam(required = false) String q, Model model) {
        List<Student> students;
        
        if (q == null || q.trim().isEmpty()) {
            students = studentService.obtenerActivos();
        } else {
            students = studentService.buscar(q);
        }
        
        model.addAttribute("students", students);
        model.addAttribute("searchQuery", q);
        
        return "students/list";
    }
}

/**
 * =====================================
 * RESUMEN DE ANOTACIONES
 * =====================================
 * 
 * @Controller          → Esta clase maneja peticiones web
 * @RequestMapping      → Prefijo de todas las URLs
 * @GetMapping          → Petición GET (leer/ver)
 * @PostMapping         → Petición POST (crear/actualizar)
 * @PathVariable        → Variable en la URL (/students/{id})
 * @RequestParam        → Parámetro de query (?q=algo)
 * @ModelAttribute      → Objeto que viene del formulario
 * 
 * Model               → Para enviar datos a la vista
 * RedirectAttributes  → Para enviar mensajes al hacer redirect
 */