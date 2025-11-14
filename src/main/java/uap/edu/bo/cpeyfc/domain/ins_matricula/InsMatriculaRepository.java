  package uap.edu.bo.cpeyfc.domain.ins_matricula;

  import org.springframework.data.jpa.repository.JpaRepository;
  import org.springframework.data.jpa.repository.Query;

  import java.util.List;
  import java.util.Map;

  public interface InsMatriculaRepository extends JpaRepository<InsMatricula, Integer> {
    // DEPRECADO - Usar matricularPreinscritoCompletoV2
    @Query(value = """
      SELECT * FROM fn_matricular_preinscrito_completo(
          :id_ins_preinscripcion, 
          :id_ins_grupo, 
          :user_reg, 
          :p_id_parametro_descuento
      )
      """, nativeQuery = true)
    Map<String, Object> matricularPreinscritoCompleto(
      Integer id_ins_preinscripcion,
      Integer id_ins_grupo,
      Integer user_reg,
      Integer p_id_parametro_descuento
    );

    // NUEVO - Sistema de aranceles con tipos de beneficiario
    @Query(value = """
      SELECT * FROM fn_matricular_preinscrito_completo_v2(
          :id_ins_preinscripcion,
          :id_ins_grupo,
          :id_tipo_beneficiario,
          :user_reg,
          :id_convenio
      )
      """, nativeQuery = true)
    Map<String, Object> matricularPreinscritoCompletoV2(
      Integer id_ins_preinscripcion,
      Integer id_ins_grupo,
      Integer id_tipo_beneficiario,
      Integer user_reg,
      Integer id_convenio
    );



    @Query(value = "SELECT * FROM fn_activar_usuario_matricula(:id_usuario, :password_hash)", nativeQuery = true)
    String activarUsuarioMatricula(Integer id_usuario, String password_hash);

    @Query(value = "SELECT * FROM vista_estudiantes_grupo WHERE id_ins_grupo = :id_grupo", nativeQuery = true)
    List<Map<String, Object>> vistaEstudiantesGrupoPorIdGrupo(Integer id_grupo);

    @Query(value = "SELECT * FROM vista_estudiantes_grupo", nativeQuery = true)
    List<Map<String, Object>> vistaEstudiantesGrupo();

    @Query(value = "SELECT * FROM vista_obligaciones_pago_programa", nativeQuery = true)
    List<Map<String, Object>> vistaObligacionesPago();
  }