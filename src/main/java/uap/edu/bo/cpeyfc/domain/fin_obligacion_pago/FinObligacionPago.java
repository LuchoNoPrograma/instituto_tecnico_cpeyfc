package uap.edu.bo.cpeyfc.domain.fin_obligacion_pago;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_parametro_programa.AcaParametroPrograma;
import uap.edu.bo.cpeyfc.domain.fin_concepto_pago.FinConceptoPago;
import uap.edu.bo.cpeyfc.domain.ins_matricula.InsMatricula;

import java.math.BigDecimal;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_obligacion_pago", indexes = {
  @Index(name = "matricula_tiene_obligaciones_pa", columnList = "cod_ins_matricula"),
  @Index(name = "obligacion_pago_por_concepto_fk", columnList = "id_fin_concepto_pago"),
  @Index(name = "obligacion_pago_aplicada_con_pa", columnList = "id_aca_parametro")
})
public class FinObligacionPago extends Auditoria {
  @Id
  @ColumnDefault("nextval('fin_obligacion_pago_id_fin_obligacion_pago_seq')")
  @Column(name = "id_fin_obligacion_pago", nullable = false)
  private Integer idFinObligacionPago;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "cod_ins_matricula", nullable = false)
  private InsMatricula insMatricula;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_fin_concepto_pago", nullable = false)
  private FinConceptoPago finConceptoPago;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_parametro")
  private AcaParametroPrograma acaParametroPrograma;

  @Column(name = "monto_sin_descuento", nullable = false, precision = 10, scale = 2)
  private BigDecimal montoSinDescuento;

  @Column(name = "monto_con_descuento", nullable = false, precision = 10, scale = 2)
  private BigDecimal montoConDescuento;

  @Column(name = "observacion", length = 500)
  private String observacion;

  @Column(name = "estado_obligacion_pago", nullable = false, length = 35)
  private String estadoObligacionPago;

}