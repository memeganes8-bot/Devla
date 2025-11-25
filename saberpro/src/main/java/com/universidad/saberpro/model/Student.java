package com.universidad.saberpro.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * 🎓 ENTIDAD STUDENT - VERSIÓN SIMPLIFICADA
 * 
 * Solo maneja:
 * - Código de registro (identification)
 * - Primer apellido (lastName)
 * - Programa y tipo
 */

@Entity
@Table(name = "students")
public class Student {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    // ⭐ CÓDIGO DE REGISTRO (único para login)
    // Ejemplos: EK2083007722, EK2083340703, etc.
    @Column(nullable = false, unique = true, length = 20)
    private String identification;
    
    // ⭐ PRIMER APELLIDO (lo único que muestras)
    @Column(nullable = false, length = 100)
    private String lastName;
    
    // Programa académico
    @Column(nullable = false)
    private String program;
    
    // Tipo de programa
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private com.universidad.saberpro.model.enums.ProgramType programType;
    
    // Año de matrícula
    @Column(nullable = false)
    private Integer enrollmentYear;
    
    // ¿Está activo?
    @Column(nullable = false)
    private Boolean active = true;
    
    // Fechas de auditoría
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // =====================================
    // CONSTRUCTORES
    // =====================================
    
    public Student() {
    }
    
    public Student(String identification, String lastName, String program, 
                   com.universidad.saberpro.model.enums.ProgramType programType, 
                   Integer enrollmentYear) {
        this.identification = identification;
        this.lastName = lastName;
        this.program = program;
        this.programType = programType;
        this.enrollmentYear = enrollmentYear;
        this.active = true;
    }
    
    // =====================================
    // MÉTODOS DE JPA
    // =====================================
    
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    // =====================================
    // MÉTODO DE UTILIDAD
    // =====================================
    
    /**
     * Obtiene el nombre para mostrar (solo apellido)
     */
    public String getDisplayName() {
        return lastName;
    }
    
    // =====================================
    // GETTERS Y SETTERS
    // =====================================
    
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getIdentification() {
        return identification;
    }
    
    public void setIdentification(String identification) {
        this.identification = identification;
    }
    
    public String getLastName() {
        return lastName;
    }
    
    public void setLastName(String lastName) {
        this.lastName = lastName;
    }
    
    public String getProgram() {
        return program;
    }
    
    public void setProgram(String program) {
        this.program = program;
    }
    
    public com.universidad.saberpro.model.enums.ProgramType getProgramType() {
        return programType;
    }
    
    public void setProgramType(com.universidad.saberpro.model.enums.ProgramType programType) {
        this.programType = programType;
    }
    
    public Integer getEnrollmentYear() {
        return enrollmentYear;
    }
    
    public void setEnrollmentYear(Integer enrollmentYear) {
        this.enrollmentYear = enrollmentYear;
    }
    
    public Boolean getActive() {
        return active;
    }
    
    public void setActive(Boolean active) {
        this.active = active;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    @Override
    public String toString() {
        return "Student{" +
                "id=" + id +
                ", identification='" + identification + '\'' +
                ", lastName='" + lastName + '\'' +
                ", program='" + program + '\'' +
                '}';
    }
}