package uap.edu.bo.cpeyfc.domain.fin_concepto_pago;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import uap.edu.bo.cpeyfc.config.Auditoria;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_concepto_pago")
public class FinConceptoPago extends Auditoria {
  @Id
  @ColumnDefault("nextval('fin_concepto_pago_id_fin_concepto_pago_seq')")
  @Column(name = "id_fin_concepto_pago", nullable = false)
  private Integer idFinConceptoPago;

  @Column(name = "nombre_concepto", nullable = false, length = 35)
  private String nombreConcepto;

  @Column(name = "descripcion", length = Integer.MAX_VALUE)
  private String descripcion;

  @Column(name = "estado_concepto_pago", nullable = false, length = 35)
  private String estadoConceptoPago;

}