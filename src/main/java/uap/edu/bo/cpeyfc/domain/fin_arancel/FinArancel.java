package uap.edu.bo.cpeyfc.domain.fin_arancel;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_programa_aprobado.AcaProgramaAprobado;
import uap.edu.bo.cpeyfc.domain.fin_concepto_pago.FinConceptoPago;
import uap.edu.bo.cpeyfc.domain.fin_tipo_beneficiario.FinTipoBeneficiario;

import java.math.BigDecimal;
import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_arancel", indexes = {
  @Index(name = "idx_arancel_concepto", columnList = "id_fin_concepto_pago"),
  @Index(name = "idx_arancel_programa", columnList = "id_aca_programa_aprobado"),
  @Index(name = "idx_arancel_tipo_benef", columnList = "id_tipo_beneficiario"),
  @Index(name = "idx_arancel_vigencia", columnList = "fecha_inicio_vigencia, fecha_fin_vigencia")
})
public class FinArancel extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_arancel", nullable = false)
  private Integer idArancel;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_fin_concepto_pago", nullable = false)
  private FinConceptoPago finConceptoPago;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_programa_aprobado")
  private AcaProgramaAprobado acaProgramaAprobado;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_tipo_beneficiario", nullable = false)
  private FinTipoBeneficiario tipoBeneficiario;

  @Column(name = "monto_base", nullable = false, precision = 10, scale = 2)
  private BigDecimal montoBase;

  @Column(name = "fecha_inicio_vigencia", nullable = false)
  private LocalDate fechaInicioVigencia;

  @Column(name = "fecha_fin_vigencia")
  private LocalDate fechaFinVigencia;

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "estado_arancel", nullable = false, length = 20)
  private String estadoArancel;
}
