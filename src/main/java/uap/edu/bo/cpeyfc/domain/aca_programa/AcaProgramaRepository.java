package uap.edu.bo.cpeyfc.domain.aca_programa;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaProgramaRepository extends JpaRepository<AcaPrograma, Integer> {

  // ========== MÉTODOS ANTIGUOS (mantener compatibilidad) ==========
  @Query(nativeQuery = true, value = "SELECT * FROM vista_aca_programas_activos")
  List<Map<String, Object>> vistaProgramasActivos();

  // ========== MÉTODOS NUEVOS ==========
  @Deprecated
  @Query(nativeQuery = true, value = "SELECT * FROM vista_programas_con_habilidades")
  List<Map<String, Object>> vistaProgramasConHabilidades();

  @Query(nativeQuery = true, value = "SELECT * FROM vista_programas_admin")
  List<Map<String, Object>> vistaProgramasAdmin();

  @Query(value = """
      SELECT fn_registrar_programa(
        :id_aca_area, :nombre_programa, :sigla, 
        :objetivo, :imagen_url, :user_reg)
      """, nativeQuery = true)
  Integer registrarPrograma(Integer id_aca_area,
                            String nombre_programa,
                            String sigla,
                            String objetivo,
                            String imagen_url,
                            Integer user_reg);

  @Query(value = """
      SELECT fn_modificar_programa(
        :id_aca_programa, :id_aca_area, :nombre_programa, :sigla,
        :objetivo, :imagen_url, :user_mod)
      """, nativeQuery = true)
  String modificarPrograma(Integer id_aca_programa,
                           Integer id_aca_area,
                           String nombre_programa,
                           String sigla,
                           String objetivo,
                           String imagen_url,
                           Integer user_mod);
}