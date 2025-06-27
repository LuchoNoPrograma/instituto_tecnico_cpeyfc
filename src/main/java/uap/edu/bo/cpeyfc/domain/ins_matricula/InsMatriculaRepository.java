package uap.edu.bo.cpeyfc.domain.ins_matricula;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface InsMatriculaRepository extends JpaRepository<InsMatricula, Integer> {
  @Query(value = "SELECT fn_matricular_preinscrito_completo(:id_ins_preinscripcion, :id_ins_grupo, :nombre_usuario, :contrasena_hash, :user_reg, :tipo_matricula)", nativeQuery = true)
  String matricularPreinscritoCompleto(Integer id_ins_preinscripcion,
                                       Integer id_ins_grupo,
                                       String nombre_usuario,
                                       String contrasena_hash,
                                       Integer user_reg,
                                       String tipo_matricula);
}