package uap.edu.bo.cpeyfc.domain.fin_descuento_convenio;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_programa_aprobado.AcaProgramaAprobado;
import uap.edu.bo.cpeyfc.domain.fin_concepto_pago.FinConceptoPago;
import uap.edu.bo.cpeyfc.domain.fin_convenio_institucional.FinConvenioInstitucional;

import java.math.BigDecimal;
import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_descuento_convenio", indexes = {
  @Index(name = "idx_descuento_convenio", columnList = "id_convenio"),
  @Index(name = "idx_descuento_programa", columnList = "id_aca_programa_aprobado"),
  @Index(name = "idx_descuento_concepto", columnList = "id_fin_concepto_pago"),
  @Index(name = "idx_descuento_vigencia", columnList = "fecha_inicio_vigencia, fecha_fin_vigencia")
})
public class FinDescuentoConvenio extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_descuento_convenio", nullable = false)
  private Integer idDescuentoConvenio;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_convenio", nullable = false)
  private FinConvenioInstitucional convenio;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_programa_aprobado")
  private AcaProgramaAprobado acaProgramaAprobado;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_fin_concepto_pago")
  private FinConceptoPago finConceptoPago;

  @Column(name = "tipo_descuento", nullable = false, length = 20)
  private String tipoDescuento;

  @Column(name = "valor_descuento", nullable = false, precision = 10, scale = 2)
  private BigDecimal valorDescuento;

  @Column(name = "fecha_inicio_vigencia", nullable = false)
  private LocalDate fechaInicioVigencia;

  @Column(name = "fecha_fin_vigencia")
  private LocalDate fechaFinVigencia;

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "estado_descuento_convenio", nullable = false, length = 20)
  private String estadoDescuentoConvenio;
}
