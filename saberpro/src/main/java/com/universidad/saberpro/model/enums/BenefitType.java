package com.universidad.saberpro.model.enums;

/**
 * 🎁 Tipos de beneficios académicos
 */
public enum BenefitType {
    NONE("Sin beneficio"),
    BASIC("Básico"),
    INTERMEDIATE("Intermedio"),
    ADVANCED("Avanzado");
    
    private final String displayName;
    
    BenefitType(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}