package com.universidad.saberpro.model.enums;

/**
 * 🎓 Tipos de programas académicos
 */
public enum ProgramType {
    TECNOLOGICO("Tecnológico"),
    PROFESIONAL("Profesional");
    
    private final String displayName;
    
    ProgramType(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
