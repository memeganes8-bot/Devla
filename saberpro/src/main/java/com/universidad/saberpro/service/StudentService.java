package com.universidad.saberpro.service;

import com.universidad.saberpro.model.Student;
import com.universidad.saberpro.model.enums.ProgramType;
import com.universidad.saberpro.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * 🎓 SERVICE DE STUDENT
 * 
 * Capa de lógica de negocio para estudiantes
 */
@Service
@Transactional
public class StudentService {
    
    @Autowired
    private StudentRepository studentRepository;
    
    // =====================================
    // MÉTODOS BÁSICOS
    // =====================================
    
    public List<Student> listarTodos() {
        return studentRepository.findAll();
    }
    
    public List<Student> obtenerTodos() {
        return listarTodos();
    }
    
    public Optional<Student> buscarPorId(Long id) {
        return studentRepository.findById(id);
    }
    
    public Student guardar(Student student) {
        return studentRepository.save(student);
    }
    
    public void eliminar(Long id) {
        studentRepository.deleteById(id);
    }
    
    // =====================================
    // MÉTODOS DE BÚSQUEDA
    // =====================================
    
    /**
     * ⭐ CLAVE: Buscar por código de registro (identification)
     * Usado para el login de estudiantes
     */
    public Optional<Student> buscarPorIdentificacion(String identification) {
        return studentRepository.findByIdentification(identification);
    }
    
    /**
     * ⭐ Buscar por apellido O código
     * Busca en ambos campos al mismo tiempo
     */
    public List<Student> buscar(String query) {
        return studentRepository
            .findByIdentificationContainingIgnoreCaseOrLastNameContainingIgnoreCase(query, query);
    }
    
    // =====================================
    // MÉTODOS DE FILTRADO
    // =====================================
    
    public List<Student> listarActivos() {
        return studentRepository.findByActiveTrue();
    }
    
    public List<Student> obtenerActivos() {
        return listarActivos();
    }
    
    public List<Student> buscarPorTipoPrograma(ProgramType programType) {
        return studentRepository.findByProgramType(programType);
    }
    
    // =====================================
    // CONTADORES
    // =====================================
    
    public long contarTodos() {
        return studentRepository.count();
    }
    
    public long contarActivos() {
        return studentRepository.countByActiveTrue();
    }
    
    // =====================================
    // CRUD OPERATIONS
    // =====================================
    
    public Student crearEstudiante(Student student) {
        // Validar que no exista el código
        if (studentRepository.existsByIdentification(student.getIdentification())) {
            throw new RuntimeException("Ya existe un estudiante con ese código de registro");
        }
        
        return guardar(student);
    }
    
    /**
     * ⭐ ACTUALIZADO: Solo actualiza campos que existen
     */
    public Student actualizarEstudiante(Long id, Student studentData) {
        Student student = buscarPorId(id)
            .orElseThrow(() -> new RuntimeException("Estudiante no encontrado"));
        
        // Actualizar solo los campos que tenemos
        student.setLastName(studentData.getLastName());
        student.setProgram(studentData.getProgram());
        student.setProgramType(studentData.getProgramType());
        student.setEnrollmentYear(studentData.getEnrollmentYear());
        student.setActive(studentData.getActive());
        
        return guardar(student);
    }
    
    /**
     * Eliminar (desactivar) estudiante
     */
    public void eliminarEstudiante(Long id) {
        Student student = buscarPorId(id)
            .orElseThrow(() -> new RuntimeException("Estudiante no encontrado"));
        
        student.setActive(false);
        guardar(student);
    }
}