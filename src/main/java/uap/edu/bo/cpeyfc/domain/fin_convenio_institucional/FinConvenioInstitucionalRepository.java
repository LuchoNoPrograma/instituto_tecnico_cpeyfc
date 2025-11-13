package uap.edu.bo.cpeyfc.domain.fin_convenio_institucional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Repository
public interface FinConvenioInstitucionalRepository extends JpaRepository<FinConvenioInstitucional, Integer> {

  @Query(nativeQuery = true, value = "SELECT * FROM vista_convenios_vigentes")
  List<Map<String, Object>> vistaConveniosVigentes();

  @Query(nativeQuery = true, value = """
      SELECT * FROM fin_convenio_institucional
      WHERE estado_convenio != 'ELIMINADO'
      ORDER BY nombre_institucion
      """)
  List<Map<String, Object>> obtenerConveniosActivos();

  @Query(nativeQuery = true, value = """
      SELECT fn_registrar_convenio_institucional(
          :nombre_institucion, :tipo_institucion, :nit,
          :contacto_nombre, :contacto_telefono, :contacto_email,
          :fecha_inicio_convenio, :fecha_fin_convenio,
          :observaciones, :user_reg
      )
      """)
  Integer registrarConvenioInstitucional(
      String nombre_institucion,
      String tipo_institucion,
      String nit,
      String contacto_nombre,
      String contacto_telefono,
      String contacto_email,
      LocalDate fecha_inicio_convenio,
      LocalDate fecha_fin_convenio,
      String observaciones,
      Integer user_reg
  );

  @Query(nativeQuery = true, value = """
      SELECT fn_modificar_convenio_institucional(
          :id_convenio, :nombre_institucion, :tipo_institucion, :nit,
          :contacto_nombre, :contacto_telefono, :contacto_email,
          :fecha_inicio_convenio, :fecha_fin_convenio,
          :observaciones, :estado_convenio, :user_mod
      )
      """)
  String modificarConvenioInstitucional(
      Integer id_convenio,
      String nombre_institucion,
      String tipo_institucion,
      String nit,
      String contacto_nombre,
      String contacto_telefono,
      String contacto_email,
      LocalDate fecha_inicio_convenio,
      LocalDate fecha_fin_convenio,
      String observaciones,
      String estado_convenio,
      Integer user_mod
  );

  @Query(nativeQuery = true, value = """
      SELECT fn_eliminar_convenio_institucional(:id_convenio, :user_mod)
      """)
  String eliminarConvenioInstitucional(Integer id_convenio, Integer user_mod);
}
