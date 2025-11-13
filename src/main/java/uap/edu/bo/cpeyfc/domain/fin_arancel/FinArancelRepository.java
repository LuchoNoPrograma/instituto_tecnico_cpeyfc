package uap.edu.bo.cpeyfc.domain.fin_arancel;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Repository
public interface FinArancelRepository extends JpaRepository<FinArancel, Integer> {

  @Query(nativeQuery = true, value = "SELECT * FROM vista_aranceles_vigentes")
  List<Map<String, Object>> vistaArancelesVigentes();

  @Query(nativeQuery = true, value = """
      SELECT * FROM fn_obtener_aranceles_programa(:id_programa_aprobado)
      """)
  List<Map<String, Object>> obtenerArancelesPrograma(Integer id_programa_aprobado);

  @Query(nativeQuery = true, value = """
      SELECT fn_registrar_arancel(
          :id_fin_concepto_pago, :id_programa_aprobado, :id_tipo_beneficiario,
          :monto_base, :fecha_inicio_vigencia, :fecha_fin_vigencia,
          :descripcion, :user_reg
      )
      """)
  Integer registrarArancel(
      Integer id_fin_concepto_pago,
      Integer id_programa_aprobado,
      Integer id_tipo_beneficiario,
      BigDecimal monto_base,
      LocalDate fecha_inicio_vigencia,
      LocalDate fecha_fin_vigencia,
      String descripcion,
      Integer user_reg
  );

  @Query(nativeQuery = true, value = """
      SELECT fn_modificar_arancel(
          :id_arancel, :monto_base, :fecha_inicio_vigencia,
          :fecha_fin_vigencia, :descripcion, :estado_arancel, :user_mod
      )
      """)
  String modificarArancel(
      Integer id_arancel,
      BigDecimal monto_base,
      LocalDate fecha_inicio_vigencia,
      LocalDate fecha_fin_vigencia,
      String descripcion,
      String estado_arancel,
      Integer user_mod
  );

  @Query(nativeQuery = true, value = """
      SELECT fn_eliminar_arancel(:id_arancel, :user_mod)
      """)
  String eliminarArancel(Integer id_arancel, Integer user_mod);

  @Query(nativeQuery = true, value = """
      SELECT * FROM fn_calcular_arancel_con_descuento(
          :id_fin_concepto_pago, :id_programa_aprobado,
          :id_tipo_beneficiario, :id_convenio
      )
      """)
  Map<String, Object> calcularArancelConDescuento(
      Integer id_fin_concepto_pago,
      Integer id_programa_aprobado,
      Integer id_tipo_beneficiario,
      Integer id_convenio
  );
}
