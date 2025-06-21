package uap.edu.bo.cpeyfc.domain.prs_persona;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface PrsPersonaRepository extends JpaRepository<PrsPersona, Integer> {
  @Query(nativeQuery = true, value = "select * from vista_personas_activas")
  List<Map<String, Object>> vistaPersonasActivas();

  @Query(value = """
        SELECT fn_registrar_persona(
            :nombre, :ap_paterno, :ap_materno, :ci, :nro_celular,
            :correo, :fecha_nacimiento, :user_reg)
        """, nativeQuery = true)
  String registrarPersona(@Param("nombre") String nombre,
                          @Param("ap_paterno") String ap_paterno,
                          @Param("ap_materno") String ap_materno,
                          @Param("ci") String ci,
                          @Param("nro_celular") String nro_celular,
                          @Param("correo") String correo,
                          @Param("fecha_nacimiento") LocalDate fecha_nacimiento,
                          @Param("user_reg") Integer user_reg);

  @Query(value = """
        SELECT fn_modificar_persona(
            :id_persona, :nombre, :ap_paterno, :ap_materno, :ci,
            :nro_celular, :correo, :fecha_nacimiento, :user_mod)
        """, nativeQuery = true)
  String modificarPersona(@Param("id_persona") Integer id_persona,
                          @Param("nombre") String nombre,
                          @Param("ap_paterno") String ap_paterno,
                          @Param("ap_materno") String ap_materno,
                          @Param("ci") String ci,
                          @Param("nro_celular") String nro_celular,
                          @Param("correo") String correo,
                          @Param("fecha_nacimiento") LocalDate fecha_nacimiento,
                          @Param("user_mod") Integer user_mod);
}