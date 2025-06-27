package uap.edu.bo.cpeyfc.domain.ins_preinscripcion;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;

public interface InsPreinscripcionRepository extends JpaRepository<InsPreinscripcion, Integer> {
  @Query(value = "SELECT fn_registrar_preinscripcion(:nombre, :ap_paterno, :ap_materno, :ci, :celular, :correo, :fecha_nacimiento, :id_aca_programa_aprobado, :user_reg)", nativeQuery = true)
  String registrarPreinscripcion(String nombre, String ap_paterno, String ap_materno,
                                 String ci, String celular, String correo,
                                 LocalDate fecha_nacimiento, Integer id_aca_programa_aprobado,
                                 Integer user_reg);
}