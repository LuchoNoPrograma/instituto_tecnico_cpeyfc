package uap.edu.bo.cpeyfc.domain.fin_convenio;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import uap.edu.bo.cpeyfc.config.Auditoria;

import java.math.BigDecimal;
import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_convenio")
public class FinConvenio extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_fin_convenio", nullable = false)
  private Integer idFinConvenio;

  @Column(name = "nombre_convenio", nullable = false, length = 150)
  private String nombreConvenio;

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "tipo_descuento", nullable = false, length = 35)
  private String tipoDescuento; // MONTO_FIJO, PORCENTAJE

  @Column(name = "monto_descuento", precision = 10, scale = 2)
  private BigDecimal montoDescuento;

  @Column(name = "porcentaje_descuento", precision = 5, scale = 2)
  private BigDecimal porcentajeDescuento;

  @Column(name = "fecha_inicio_vigencia", nullable = false)
  private LocalDate fechaInicioVigencia;

  @Column(name = "fecha_fin_vigencia")
  private LocalDate fechaFinVigencia;

  @Column(name = "estado_convenio", nullable = false, length = 35)
  private String estadoConvenio; // ACTIVO, VENCIDO, SUSPENDIDO, ELIMINADO

}
