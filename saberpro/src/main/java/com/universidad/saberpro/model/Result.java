package com.universidad.saberpro.model;

import com.universidad.saberpro.model.enums.TestType;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 📊 ENTIDAD RESULT (Resultado de prueba Saber)
 * 
 * Representa un resultado de prueba Saber TyT o PRO.
 * Cada estudiante puede tener múltiples resultados (1:N).
 * Cada resultado tiene UN beneficio asociado (1:1).
 */
@Entity
@Table(name = "results")
public class Result {
    
    // =====================================
    // ATRIBUTOS
    // =====================================
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    // Relación Many-to-One con Student (un estudiante tiene muchos resultados)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TestType testType;
    
    @Column(nullable = false)
    private Integer score;
    
    @Column(nullable = false)
    private LocalDate testDate;
    
    @Column(length = 500)
    private String observations;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    // Relación One-to-One con Benefit (un resultado tiene un beneficio)
    @OneToOne(mappedBy = "result", cascade = CascadeType.ALL, orphanRemoval = true)
    private Benefit benefit;
    
    // =====================================
    // CONSTRUCTORES
    // =====================================
    
    public Result() {
        // Constructor vacío requerido por JPA
    }
    
    public Result(Student student, TestType testType, Integer score, LocalDate testDate) {
        this.student = student;
        this.testType = testType;
        this.score = score;
        this.testDate = testDate;
    }
    
    // =====================================
    // MÉTODOS ESPECIALES DE JPA
    // =====================================
    
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
    
    // =====================================
    // MÉTODOS DE UTILIDAD
    // =====================================
    
    /**
     * Valida que el puntaje esté dentro del rango permitido
     */
    public boolean isValidScore() {
        return testType != null && testType.isValidScore(score);
    }
    
    /**
     * Verifica si el estudiante puede graduarse con este resultado
     * TyT: >= 80
     * PRO: >= 120
     */
    public boolean allowsGraduation() {
        if (testType == TestType.SABER_TYT) {
            return score >= 80;
        } else { // SABER_PRO
            return score >= 120;
        }
    }
    
    /**
     * Obtiene el rango de calificación del resultado
     */
    public String getScoreRange() {
        if (testType == TestType.SABER_TYT) {
            if (score >= 171) return "Excelente (171-200)";
            if (score >= 151) return "Sobresaliente (151-170)";
            if (score >= 120) return "Bueno (120-150)";
            if (score >= 80) return "Aceptable (80-119)";
            return "No permite graduación (<80)";
        } else { // SABER_PRO
            if (score >= 241) return "Excelente (241-300)";
            if (score >= 211) return "Sobresaliente (211-240)";
            if (score >= 180) return "Bueno (180-210)";
            if (score >= 120) return "Aceptable (120-179)";
            return "No permite graduación (<120)";
        }
    }
    
    /**
     * Obtiene el nombre del tipo de prueba
     */
    public String getTestTypeName() {
        return testType != null ? testType.getDisplayName() : "";
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
    
    public Student getStudent() {
        return student;
    }
    
    public void setStudent(Student student) {
        this.student = student;
    }
    
    public TestType getTestType() {
        return testType;
    }
    
    public void setTestType(TestType testType) {
        this.testType = testType;
    }
    
    public Integer getScore() {
        return score;
    }
    
    public void setScore(Integer score) {
        this.score = score;
    }
    
    public LocalDate getTestDate() {
        return testDate;
    }
    
    public void setTestDate(LocalDate testDate) {
        this.testDate = testDate;
    }
    
    public String getObservations() {
        return observations;
    }
    
    public void setObservations(String observations) {
        this.observations = observations;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public Benefit getBenefit() {
        return benefit;
    }
    
    public void setBenefit(Benefit benefit) {
        this.benefit = benefit;
    }
    
    // =====================================
    // toString
    // =====================================
    
    @Override
    public String toString() {
        return "Result{" +
                "id=" + id +
                ", testType=" + testType +
                ", score=" + score +
                ", testDate=" + testDate +
                ", allowsGraduation=" + allowsGraduation() +
                '}';
    }
}