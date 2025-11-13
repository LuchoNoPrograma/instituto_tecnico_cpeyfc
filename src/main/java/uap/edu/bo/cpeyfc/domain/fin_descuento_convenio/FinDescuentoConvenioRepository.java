package uap.edu.bo.cpeyfc.domain.fin_descuento_convenio;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Repository
public interface FinDescuentoConvenioRepository extends JpaRepository<FinDescuentoConvenio, Integer> {

  @Query(nativeQuery = true, value = """
      SELECT * FROM fin_descuento_convenio
      WHERE id_convenio = :id_convenio
      AND estado_descuento_convenio != 'ELIMINADO'
      ORDER BY fecha_inicio_vigencia DESC
      """)
  List<Map<String, Object>> obtenerDescuentosPorConvenio(Integer id_convenio);

  @Query(nativeQuery = true, value = """
      SELECT fn_registrar_descuento_convenio(
          :id_convenio, :id_programa_aprobado, :id_fin_concepto_pago,
          :tipo_descuento, :valor_descuento, :fecha_inicio_vigencia,
          :fecha_fin_vigencia, :descripcion, :user_reg
      )
      """)
  Integer registrarDescuentoConvenio(
      Integer id_convenio,
      Integer id_programa_aprobado,
      Integer id_fin_concepto_pago,
      String tipo_descuento,
      BigDecimal valor_descuento,
      LocalDate fecha_inicio_vigencia,
      LocalDate fecha_fin_vigencia,
      String descripcion,
      Integer user_reg
  );

  @Query(nativeQuery = true, value = """
      SELECT fn_modificar_descuento_convenio(
          :id_descuento_convenio, :tipo_descuento, :valor_descuento,
          :fecha_inicio_vigencia, :fecha_fin_vigencia, :descripcion,
          :estado_descuento_convenio, :user_mod
      )
      """)
  String modificarDescuentoConvenio(
      Integer id_descuento_convenio,
      String tipo_descuento,
      BigDecimal valor_descuento,
      LocalDate fecha_inicio_vigencia,
      LocalDate fecha_fin_vigencia,
      String descripcion,
      String estado_descuento_convenio,
      Integer user_mod
  );

  @Query(nativeQuery = true, value = """
      SELECT fn_eliminar_descuento_convenio(:id_descuento_convenio, :user_mod)
      """)
  String eliminarDescuentoConvenio(Integer id_descuento_convenio, Integer user_mod);
}
