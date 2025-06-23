package uap.edu.bo.cpeyfc.domain.prs_persona;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

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
  String registrarPersona(String nombre,
                          String ap_paterno,
                          String ap_materno,
                          String ci,
                          String nro_celular,
                          String correo,
                          LocalDate fecha_nacimiento,
                          Integer user_reg);

  @Query(value = """
        SELECT fn_modificar_persona(
            :id_persona, :nombre, :ap_paterno, :ap_materno, :ci,
            :nro_celular, :correo, :fecha_nacimiento, :user_mod)
        """, nativeQuery = true)
  String modificarPersona(Integer id_persona,
                          String nombre,
                          String ap_paterno,
                          String ap_materno,
                          String ci,
                          String nro_celular,
                          String correo,
                          LocalDate fecha_nacimiento,
                          Integer user_mod);
}