package com.universidad.saberpro.model;

import com.universidad.saberpro.model.enums.BenefitType;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * 🎁 ENTIDAD BENEFIT (Beneficio Académico)
 * 
 * Representa los beneficios académicos otorgados según el puntaje.
 * Cada resultado tiene UN beneficio asociado (1:1).
 * El beneficio incluye: nota final, beca, y exoneración de informe.
 */
@Entity
@Table(name = "benefits")
public class Benefit {
    
    // =====================================
    // ATRIBUTOS
    // =====================================
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    // Relación One-to-One con Result (un beneficio pertenece a un resultado)
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "result_id", nullable = false, unique = true)
    private Result result;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private BenefitType benefitType;
    
    // ✅ CORREGIDO: Quitamos precision y scale para Double
    @Column(nullable = false)
    private Double grade;
    
    @Column(nullable = false)
    private Integer scholarshipPercentage;
    
    @Column(nullable = false)
    private Boolean reportExemption;
    
    @Column(length = 500)
    private String description;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    // =====================================
    // CONSTRUCTORES
    // =====================================
    
    public Benefit() {
        // Constructor vacío requerido por JPA
    }
    
    public Benefit(Result result, BenefitType benefitType, Double grade, 
                   Integer scholarshipPercentage, Boolean reportExemption) {
        this.result = result;
        this.benefitType = benefitType;
        this.grade = grade;
        this.scholarshipPercentage = scholarshipPercentage;
        this.reportExemption = reportExemption;
        this.description = generateDescription();
    }
    
    // =====================================
    // MÉTODOS ESPECIALES DE JPA
    // =====================================
    
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.description == null || this.description.isEmpty()) {
            this.description = generateDescription();
        }
    }
    
    // =====================================
    // MÉTODOS DE UTILIDAD
    // =====================================
    
    /**
     * Verifica si el beneficio incluye beca
     */
    public boolean hasScholarship() {
        return scholarshipPercentage != null && scholarshipPercentage > 0;
    }
    
    /**
     * Genera una descripción legible del beneficio
     */
    public String generateDescription() {
        if (benefitType == BenefitType.NONE) {
            return "Sin beneficios académicos";
        }
        
        StringBuilder desc = new StringBuilder();
        desc.append("Nota final: ").append(grade);
        
        if (hasScholarship()) {
            desc.append(" | Beca: ").append(scholarshipPercentage).append("%");
        }
        
        if (reportExemption) {
            desc.append(" | Exoneración de informe final");
        }
        
        return desc.toString();
    }
    
    /**
     * Calcula el monto de la beca (asumiendo un costo base)
     */
    public double calculateScholarshipAmount(double graduationCost) {
        if (!hasScholarship()) {
            return 0.0;
        }
        return graduationCost * (scholarshipPercentage / 100.0);
    }
    
    /**
     * Obtiene el nombre del tipo de beneficio
     */
    public String getBenefitTypeName() {
        return benefitType != null ? benefitType.getDisplayName() : "";
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
    
    public Result getResult() {
        return result;
    }
    
    public void setResult(Result result) {
        this.result = result;
    }
    
    public BenefitType getBenefitType() {
        return benefitType;
    }
    
    public void setBenefitType(BenefitType benefitType) {
        this.benefitType = benefitType;
    }
    
    public Double getGrade() {
        return grade;
    }
    
    public void setGrade(Double grade) {
        this.grade = grade;
    }
    
    public Integer getScholarshipPercentage() {
        return scholarshipPercentage;
    }
    
    public void setScholarshipPercentage(Integer scholarshipPercentage) {
        this.scholarshipPercentage = scholarshipPercentage;
    }
    
    public Boolean getReportExemption() {
        return reportExemption;
    }
    
    public void setReportExemption(Boolean reportExemption) {
        this.reportExemption = reportExemption;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    // =====================================
    // toString
    // =====================================
    
    @Override
    public String toString() {
        return "Benefit{" +
                "id=" + id +
                ", benefitType=" + benefitType +
                ", grade=" + grade +
                ", scholarshipPercentage=" + scholarshipPercentage +
                ", reportExemption=" + reportExemption +
                '}';
    }
}