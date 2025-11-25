package com.universidad.saberpro.service;

import com.universidad.saberpro.model.Benefit;
import com.universidad.saberpro.model.Result;
import com.universidad.saberpro.model.enums.BenefitType;
import com.universidad.saberpro.model.enums.TestType;
import org.springframework.stereotype.Service;

/**
 * ⭐ SERVICIO CRÍTICO: CALCULA LOS BENEFICIOS AUTOMÁTICAMENTE
 * 
 * Este servicio aplica las reglas del Acuerdo 01-009 de la UTS
 * para calcular beneficios según el puntaje obtenido.
 * 
 * 🎯 FUNCIÓN PRINCIPAL:
 * - Recibe un Result (con puntaje y tipo de prueba)
 * - Calcula automáticamente el Benefit según las reglas
 * - Retorna el Benefit listo para guardar
 */
@Service
public class BenefitCalculatorService {
    
    /**
     * Calcula el beneficio para un resultado dado
     * 
     * @param result El resultado de la prueba
     * @return El beneficio calculado
     */
    public Benefit calculateBenefit(Result result) {
        TestType testType = result.getTestType();
        Integer score = result.getScore();
        
        // Validar datos
        if (testType == null || score == null) {
            throw new IllegalArgumentException("El resultado debe tener tipo de prueba y puntaje");
        }
        
        // Calcular según el tipo de prueba
        if (testType == TestType.SABER_TYT) {
            return calculateBenefitTyT(result, score);
        } else { // SABER_PRO
            return calculateBenefitPro(result, score);
        }
    }
    
    /**
     * 📊 Calcula beneficios para Saber TyT (0-200 puntos)
     * 
     * REGLAS OFICIALES:
     * - < 80: No puede graduarse (sin beneficio)
     * - 80-119: Sin beneficio (pero puede graduarse)
     * - 120-150: Nota 4.5, exoneración informe
     * - 151-170: Nota 4.7, exoneración informe, 50% beca
     * - 171-200: Nota 5.0, exoneración informe, 100% beca
     */
    private Benefit calculateBenefitTyT(Result result, Integer score) {
        
        // 171-200: Excelente
        if (score >= 171) {
            return new Benefit(
                result,
                BenefitType.ADVANCED,
                5.0,
                100,
                true
            );
        }
        
        // 151-170: Sobresaliente
        if (score >= 151) {
            return new Benefit(
                result,
                BenefitType.INTERMEDIATE,
                4.7,
                50,
                true
            );
        }
        
        // 120-150: Bueno
        if (score >= 120) {
            return new Benefit(
                result,
                BenefitType.BASIC,
                4.5,
                0,
                true
            );
        }
        
        // 80-119 o < 80: Sin beneficio
        return new Benefit(
            result,
            BenefitType.NONE,
            0.0,
            0,
            false
        );
    }
    
    /**
     * 📊 Calcula beneficios para Saber PRO (0-300 puntos)
     * 
     * REGLAS OFICIALES:
     * - < 120: No puede graduarse (sin beneficio)
     * - 120-179: Sin beneficio (pero puede graduarse)
     * - 180-210: Nota 4.5, exoneración informe
     * - 211-240: Nota 4.7, exoneración informe, 50% beca
     * - 241-300: Nota 5.0, exoneración informe, 100% beca
     */
    private Benefit calculateBenefitPro(Result result, Integer score) {
        
        // 241-300: Excelente
        if (score >= 241) {
            return new Benefit(
                result,
                BenefitType.ADVANCED,
                5.0,
                100,
                true
            );
        }
        
        // 211-240: Sobresaliente
        if (score >= 211) {
            return new Benefit(
                result,
                BenefitType.INTERMEDIATE,
                4.7,
                50,
                true
            );
        }
        
        // 180-210: Bueno
        if (score >= 180) {
            return new Benefit(
                result,
                BenefitType.BASIC,
                4.5,
                0,
                true
            );
        }
        
        // 120-179 o < 120: Sin beneficio
        return new Benefit(
            result,
            BenefitType.NONE,
            0.0,
            0,
            false
        );
    }
    
    /**
     * Verifica si un estudiante puede graduarse con este puntaje
     * 
     * @param testType Tipo de prueba (TyT o PRO)
     * @param score Puntaje obtenido
     * @return true si puede graduarse, false si no
     */
    public boolean canGraduateWithScore(TestType testType, Integer score) {
        if (testType == TestType.SABER_TYT) {
            return score >= 80;
        } else { // SABER_PRO
            return score >= 120;
        }
    }
    
    /**
     * Obtiene el puntaje mínimo para graduarse según el tipo de prueba
     * 
     * @param testType Tipo de prueba
     * @return 80 para TyT, 120 para PRO
     */
    public int getMinimumGraduationScore(TestType testType) {
        return testType == TestType.SABER_TYT ? 80 : 120;
    }
    
    /**
     * Obtiene una descripción legible del beneficio obtenido
     * 
     * @param benefit El beneficio a describir
     * @return Texto descriptivo con emojis
     */
    public String getBenefitDescription(Benefit benefit) {
        if (benefit == null || benefit.getBenefitType() == BenefitType.NONE) {
            return "Sin beneficios académicos. Puntaje insuficiente.";
        }
        
        StringBuilder desc = new StringBuilder();
        desc.append("✅ Beneficio obtenido: ").append(benefit.getBenefitTypeName()).append("\n");
        desc.append("📝 Nota final: ").append(benefit.getGrade()).append("\n");
        
        if (benefit.hasScholarship()) {
            desc.append("💰 Beca derechos de grado: ").append(benefit.getScholarshipPercentage()).append("%\n");
        }
        
        if (benefit.getReportExemption()) {
            desc.append("📋 Exoneración de informe final de trabajo de grado\n");
        }
        
        return desc.toString();
    }
}