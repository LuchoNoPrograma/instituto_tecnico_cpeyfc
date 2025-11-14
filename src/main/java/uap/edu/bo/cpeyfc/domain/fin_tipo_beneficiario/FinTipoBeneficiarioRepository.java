package uap.edu.bo.cpeyfc.domain.fin_tipo_beneficiario;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface FinTipoBeneficiarioRepository extends JpaRepository<FinTipoBeneficiario, Integer> {

  @Query(nativeQuery = true, value = """
      SELECT * FROM fin_tipo_beneficiario
      WHERE estado_tipo_beneficiario != 'ELIMINADO'
      ORDER BY nombre_tipo
      """)
  List<Map<String, Object>> obtenerTiposBeneficiarioActivos();

  @Query(nativeQuery = true, value = """
      SELECT fn_registrar_tipo_beneficiario(:nombre_tipo, :descripcion, :user_reg)
      """)
  Integer registrarTipoBeneficiario(String nombre_tipo, String descripcion, Integer user_reg);

  @Query(nativeQuery = true, value = """
      SELECT fn_modificar_tipo_beneficiario(
          :id_tipo_beneficiario, :nombre_tipo, :descripcion,
          :estado_tipo_beneficiario, :user_mod
      )
      """)
  String modificarTipoBeneficiario(
      Integer id_tipo_beneficiario,
      String nombre_tipo,
      String descripcion,
      String estado_tipo_beneficiario,
      Integer user_mod
  );

  @Query(nativeQuery = true, value = """
      SELECT fn_eliminar_tipo_beneficiario(:id_tipo_beneficiario, :user_mod)
      """)
  String eliminarTipoBeneficiario(Integer id_tipo_beneficiario, Integer user_mod);
}
