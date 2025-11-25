package com.universidad.saberpro.controller;

import com.universidad.saberpro.model.Student;
import com.universidad.saberpro.service.StudentService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Optional;

/**
 * 🔐 CONTROLADOR DE LOGIN
 * 
 * Maneja la autenticación de:
 * - Coordinador (usuario + contraseña)
 * - Estudiante (SOLO CÓDIGO - sin contraseña)
 */
@Controller
public class LoginController {
    
    @Autowired
    private StudentService studentService;
    
    // ============================================
    // PÁGINA DE INICIO
    // ============================================
    
    @GetMapping("/")
    public String index() {
        return "index";
    }
    
    /**
     * Redirección genérica de /login
     * Por si alguien intenta acceder a /login directamente
     */
    @GetMapping("/login")
    public String loginGenerico() {
        return "redirect:/";
    }
    
    // ============================================
    // LOGIN COORDINADOR
    // ============================================
    
    @GetMapping("/coordinacion/login")
    public String loginCoordinacion() {
        return "coordinacion/login";
    }
    
    @PostMapping("/coordinacion/login")
    public String procesarLoginCoordinacion(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            HttpSession session,
            RedirectAttributes redirectAttributes) {
        
        // Validación simple (después se puede mejorar con Spring Security)
        if ("admin".equals(username) && "admin123".equals(password)) {
            session.setAttribute("userType", "COORDINACION");
            session.setAttribute("username", username);
            return "redirect:/coordinacion/dashboard";
        } else {
            redirectAttributes.addFlashAttribute("error", 
                "Usuario o contraseña incorrectos");
            return "redirect:/coordinacion/login";
        }
    }
    
    @GetMapping("/coordinacion/dashboard")
    public String dashboardCoordinacion(HttpSession session, Model model) {
        // Verificar sesión
        if (session.getAttribute("userType") == null || 
            !"COORDINACION".equals(session.getAttribute("userType"))) {
            return "redirect:/coordinacion/login";
        }
        
        model.addAttribute("username", session.getAttribute("username"));
        return "coordinacion/dashboard";
    }
    
    // ============================================
    // LOGIN ESTUDIANTE - SOLO CÓDIGO
    // ============================================
    
    @GetMapping("/estudiante/login")
    public String loginEstudiante() {
        return "estudiante/login";
    }
    
    /**
     * ⭐ Login solo con código de registro
     * Ya no requiere contraseña
     */
    @PostMapping("/estudiante/login")
    public String procesarLoginEstudiante(
            @RequestParam("identification") String identification,
            HttpSession session,
            RedirectAttributes redirectAttributes) {
        
        // Limpiar el código (quitar espacios, convertir a mayúsculas)
        String codigo = identification.trim().toUpperCase();
        
        // Validar que no esté vacío
        if (codigo.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", 
                "Por favor ingresa tu código de registro");
            return "redirect:/estudiante/login";
        }
        
        // Buscar estudiante por código
        Optional<Student> studentOpt = studentService.buscarPorIdentificacion(codigo);
        
        if (studentOpt.isPresent()) {
            Student student = studentOpt.get();
            
            // Verificar que esté activo
            if (!student.getActive()) {
                redirectAttributes.addFlashAttribute("error", 
                    "Tu cuenta está inactiva. Contacta a coordinación.");
                return "redirect:/estudiante/login";
            }
            
            // ⭐ Guardar en sesión - SOLO APELLIDO
            session.setAttribute("userType", "ESTUDIANTE");
            session.setAttribute("studentId", student.getId());
            session.setAttribute("studentName", student.getLastName());
            
            // Mensaje de bienvenida
            redirectAttributes.addFlashAttribute("mensaje", 
                "¡Bienvenido/a, " + student.getLastName() + "!");
            
            return "redirect:/estudiante/dashboard";
            
        } else {
            redirectAttributes.addFlashAttribute("error", 
                "Código de registro no encontrado. Verifica e intenta nuevamente.");
            return "redirect:/estudiante/login";
        }
    }
    
    // ============================================
    // LOGOUT
    // ============================================
    
    @GetMapping("/logout")
    public String logout(HttpSession session, RedirectAttributes redirectAttributes) {
        // Cerrar sesión
        session.invalidate();
        
        // Mensaje de éxito
        redirectAttributes.addFlashAttribute("mensaje", "Sesión cerrada exitosamente");
        
        return "redirect:/";
    }
}

/**
 * =====================================
 * RESUMEN DE RUTAS
 * =====================================
 * 
 * PÚBLICAS:
 * GET  /                          → Página de inicio
 * GET  /login                     → Redirige a inicio
 * GET  /estudiante/login          → Formulario login estudiante
 * POST /estudiante/login          → Procesar login estudiante
 * GET  /coordinacion/login        → Formulario login coordinador
 * POST /coordinacion/login        → Procesar login coordinador
 * 
 * PROTEGIDAS (requieren sesión):
 * GET  /coordinacion/dashboard    → Dashboard coordinador
 * GET  /estudiante/dashboard      → Dashboard estudiante (en EstudianteController)
 * GET  /logout                    → Cerrar sesión
 * 
 * =====================================
 * CREDENCIALES
 * =====================================
 * 
 * COORDINADOR:
 * - Usuario: admin
 * - Contraseña: admin123
 * 
 * ESTUDIANTES:
 * - Solo código de registro (sin contraseña)
 * - Ejemplo: EK2083007722
 */