package uap.edu.bo.cpeyfc.domain.aca_plan_estudio;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaPlanEstudioRepository extends JpaRepository<AcaPlanEstudio, Integer> {
   @Query(value = "SELECT * FROM vista_plan_estudio_con_contexto", nativeQuery = true)
   List<Map<String, Object>> vistaPlanEstudioConContexto();

   @Query(value = "SELECT fn_registrar_aca_plan_estudio(:anho, :vigente, :user_reg)", nativeQuery = true)
   String registrarPlanEstudio(Integer anho, Boolean vigente, Integer user_reg);

   @Query(nativeQuery = true, value = "SELECT * FROM vista_plan_estudio_detalle WHERE id_aca_plan_estudio = :id")
   Map<String, Object> vistaPlanEstudioDetalle(Integer id);

   @Query(nativeQuery = true, value = "SELECT * FROM vista_programas_asociados_plan WHERE id_aca_plan_estudio = :id")
   List<Map<String, Object>> vistaProgramasAsociadosPlan(Integer id);

   @Query(nativeQuery = true, value = "SELECT * FROM vista_modulos_plan_detalle WHERE id_aca_plan_estudio = :id ORDER BY orden")
   List<Map<String, Object>> vistaModulosPlanDetalle(Integer id);

   @Query(nativeQuery = true, value = "SELECT * FROM vista_plan_estudio_estadisticas WHERE id_aca_plan_estudio = :id")
   Map<String, Object> vistaPlanEstudioEstadisticas(Integer id);

   @Query(nativeQuery = true, value = "SELECT * FROM vista_modulos_disponibles_nivel")
   List<Map<String, Object>> vistaModulosDisponiblesNivel();
}