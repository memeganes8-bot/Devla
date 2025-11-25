package com.universidad.saberpro.model.enums;

/**
 * 👥 Roles de usuario en el sistema
 */
public enum UserRole {
    COORDINACION("Coordinación"),
    ESTUDIANTE("Estudiante");
    
    private final String displayName;
    
    UserRole(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}