package uap.edu.bo.cpeyfc.domain.aca_plan_modulo_detalle;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public interface AcaPlanModuloDetalleRepository extends JpaRepository<AcaPlanModuloDetalle, Integer> {
  @Query(value = """
    SELECT fn_registrar_plan_modulo_detalle(
        :id_aca_plan_estudio, :id_aca_modulo, :id_aca_nivel,
        :carga_horaria, :creditos, :orden, :competencia, :user_reg)
    """, nativeQuery = true)
  String registrarPlanModuloDetalle(Integer id_aca_plan_estudio,
                                    Integer id_aca_modulo,
                                    Integer id_aca_nivel,
                                    Integer carga_horaria,
                                    BigDecimal creditos,
                                    Integer orden,
                                    String competencia,
                                    Integer user_reg);

  @Query(value = """
    SELECT fn_modificar_plan_modulo_detalle(
        :id_aca_plan_modulo_detalle, :id_aca_plan_estudio, :id_aca_modulo,
        :id_aca_nivel, :carga_horaria, :creditos, :orden, :competencia,
        :estado_plan_modulo_detalle, :user_mod)
    """, nativeQuery = true)
  String modificarPlanModuloDetalle(Integer id_aca_plan_modulo_detalle,
                                    Integer id_aca_plan_estudio,
                                    Integer id_aca_modulo,
                                    Integer id_aca_nivel,
                                    Integer carga_horaria,
                                    BigDecimal creditos,
                                    Integer orden,
                                    String competencia,
                                    String estado_plan_modulo_detalle,
                                    Integer user_mod);

  @Query(value = "SELECT * FROM fn_consultar_modulos_por_plan(:id_aca_plan_estudio)", nativeQuery = true)
  List<Map<String, Object>> consultarModulosPorPlan(Integer id_aca_plan_estudio);
}