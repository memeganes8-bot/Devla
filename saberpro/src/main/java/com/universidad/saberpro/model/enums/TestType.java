package com.universidad.saberpro.model.enums;

/**
 * 📊 Tipos de pruebas Saber
 */
public enum TestType {
    SABER_TYT("Saber TyT", 0, 200),
    SABER_PRO("Saber PRO", 0, 300);
    
    private final String displayName;
    private final int minScore;
    private final int maxScore;
    
    TestType(String displayName, int minScore, int maxScore) {
        this.displayName = displayName;
        this.minScore = minScore;
        this.maxScore = maxScore;
    }
    
    public String getDisplayName() {
        return displayName;
    }
    
    public int getMinScore() {
        return minScore;
    }
    
    public int getMaxScore() {
        return maxScore;
    }
    
    /**
     * Valida si un puntaje está dentro del rango permitido
     */
    public boolean isValidScore(Integer score) {
        if (score == null) {
            return false;
        }
        return score >= minScore && score <= maxScore;
    }
}