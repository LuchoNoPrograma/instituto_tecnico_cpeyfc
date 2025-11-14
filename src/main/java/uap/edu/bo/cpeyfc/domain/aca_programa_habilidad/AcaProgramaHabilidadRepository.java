package uap.edu.bo.cpeyfc.domain.aca_programa_habilidad;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaProgramaHabilidadRepository extends JpaRepository<AcaProgramaHabilidad, Integer> {

  @Query(value = """
      SELECT fn_registrar_habilidad_programa(
        :id_aca_programa, :nombre_habilidad, :user_reg)
      """, nativeQuery = true)
  Integer registrarHabilidadPrograma(Integer id_aca_programa,
                                     String nombre_habilidad,
                                     Integer user_reg);

  @Query(value = """
      SELECT fn_modificar_habilidad_programa(
        :id_programa_habilidad, :nombre_habilidad, 
        :estado_programa_habilidad, :user_mod)
      """, nativeQuery = true)
  String modificarHabilidadPrograma(Integer id_programa_habilidad,
                                    String nombre_habilidad,
                                    String estado_programa_habilidad,
                                    Integer user_mod);

  @Query(value = """
      SELECT fn_eliminar_habilidad_programa(
        :id_programa_habilidad, :user_mod)
      """, nativeQuery = true)
  String eliminarHabilidadPrograma(Integer id_programa_habilidad,
                                   Integer user_mod);

  @Query(value = """
      SELECT * FROM fn_asignar_habilidades_programa(
        :id_aca_programa, :habilidades, :user_reg)
      """, nativeQuery = true)
  List<Map<String, Object>> asignarHabilidadesPrograma(Integer id_aca_programa,
                                                       String[] habilidades,
                                                       Integer user_reg);

  @Query(value = """
      SELECT 
        h.id_programa_habilidad,
        h.id_aca_programa,
        h.nombre_habilidad,
        h.estado_programa_habilidad,
        h.fecha_reg,
        h.user_reg,
        h.fecha_mod,
        h.user_mod
      FROM aca_programa_habilidad h
      WHERE h.id_aca_programa = :id_aca_programa
        AND h.estado_programa_habilidad = 'ACTIVO'
      ORDER BY h.nombre_habilidad
      """, nativeQuery = true)
  List<Map<String, Object>> listarHabilidadesPorPrograma(Integer id_aca_programa);
}