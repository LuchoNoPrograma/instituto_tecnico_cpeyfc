package uap.edu.bo.cpeyfc.domain.fin_transaccion;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import uap.edu.bo.cpeyfc.config.Auditoria;

import java.math.BigDecimal;
import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_transaccion")
public class FinTransaccion extends Auditoria {
  @Id
  @ColumnDefault("nextval('fin_transaccion_id_fin_transaccion_seq')")
  @Column(name = "id_fin_transaccion", nullable = false)
  private Integer idFinTransaccion;

  @Column(name = "cod_comprobante", nullable = false, length = 35)
  private String codComprobante;

  @Column(name = "total_pago", nullable = false, precision = 10, scale = 2)
  private BigDecimal totalPago;

  @Column(name = "fecha_pago", nullable = false)
  private LocalDate fechaPago;

  @Column(name = "tipo_comprobante", nullable = false, length = 35)
  private String tipoComprobante;

  @Column(name = "observacion", length = 500)
  private String observacion;

  @Column(name = "estado_transaccion", nullable = false, length = 35)
  private String estadoTransaccion;

}