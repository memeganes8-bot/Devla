package com.universidad.saberpro.repository;

import com.universidad.saberpro.model.Benefit;
import com.universidad.saberpro.model.Result;
import com.universidad.saberpro.model.enums.BenefitType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository para la entidad Benefit
 * 
 * Gestiona el acceso a datos de beneficios academicos.
 * Spring Data JPA implementa automaticamente estos metodos.
 */
@Repository
public interface BenefitRepository extends JpaRepository<Benefit, Long> {
    
    /**
     * Busca el beneficio asociado a un resultado especifico
     * 
     * @param result El resultado del cual buscar el beneficio
     * @return Optional con el beneficio si existe
     */
    Optional<Benefit> findByResult(Result result);
    
    /**
     * Busca beneficios por tipo
     * 
     * Ejemplo: Todos los beneficios ADVANCED (nota 5.0)
     * 
     * @param benefitType El tipo de beneficio a buscar
     * @return Lista de beneficios del tipo especificado
     */
    List<Benefit> findByBenefitType(BenefitType benefitType);
    
    /**
     * Busca todos los beneficios EXCEPTO el tipo especificado
     * 
     * Se usa para obtener solo beneficios con valor (sin NONE)
     * Ejemplo: findByBenefitTypeNot(BenefitType.NONE) retorna todos los beneficios reales
     * 
     * @param benefitType El tipo de beneficio a excluir
     * @return Lista de beneficios que NO son del tipo especificado
     */
    List<Benefit> findByBenefitTypeNot(BenefitType benefitType);
    
    /**
     * Busca beneficios con beca (porcentaje mayor al especificado)
     * 
     * Ejemplo: findByScholarshipPercentageGreaterThan(0) retorna todos con beca
     * 
     * @param percentage El porcentaje minimo (generalmente 0)
     * @return Lista de beneficios con beca
     */
    List<Benefit> findByScholarshipPercentageGreaterThan(Integer percentage);
    
    /**
     * Busca beneficios con exoneracion de informe
     * 
     * @return Lista de beneficios que incluyen exoneracion
     */
    List<Benefit> findByReportExemptionTrue();
    
    /**
     * Cuenta beneficios por tipo
     * 
     * @param benefitType El tipo de beneficio a contar
     * @return Numero de beneficios del tipo especificado
     */
    long countByBenefitType(BenefitType benefitType);
    
    /**
     * Cuenta beneficios que tienen beca
     * 
     * @param percentage El porcentaje minimo (generalmente 0)
     * @return Numero de beneficios con beca
     */
    long countByScholarshipPercentageGreaterThan(Integer percentage);
    
    /**
     * Cuenta beneficios con exoneracion de informe
     * 
     * @return Numero de beneficios con exoneracion
     */
    long countByReportExemptionTrue();
    
    /**
     * Verifica si existe un beneficio para un resultado
     * 
     * @param result El resultado a verificar
     * @return true si existe un beneficio asociado
     */
    boolean existsByResult(Result result);
}

/**
 * NOTAS SOBRE SPRING DATA JPA:
 * 
 * Spring Data JPA implementa AUTOMATICAMENTE estos metodos
 * solo leyendo el nombre del metodo. No necesitas escribir SQL.
 * 
 * Patron de nombres:
 * - findBy[Propiedad]             → Busca por propiedad
 * - findBy[Propiedad]Not          → Busca excluyendo el valor
 * - findBy[Propiedad]GreaterThan  → Busca mayores que
 * - findBy[Propiedad]True/False   → Busca booleanos
 * - countBy[Propiedad]            → Cuenta registros
 * - existsBy[Propiedad]           → Verifica existencia
 * 
 * Ejemplos de uso:
 * 
 * // Obtener beneficios con valor (sin NONE)
 * List<Benefit> conBeneficios = benefitRepository.findByBenefitTypeNot(BenefitType.NONE);
 * 
 * // Contar estudiantes con beca
 * long conBeca = benefitRepository.countByScholarshipPercentageGreaterThan(0);
 * 
 * // Buscar beneficio de un resultado
 * Optional<Benefit> beneficio = benefitRepository.findByResult(resultado);
 */