package uap.edu.bo.cpeyfc.domain.fin_detalle_arancel;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.fin_arancel.FinArancel;
import uap.edu.bo.cpeyfc.domain.fin_concepto_arancel.FinConceptoArancel;

import java.math.BigDecimal;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_detalle_arancel", indexes = {
  @Index(name = "idx_detalle_arancel_arancel", columnList = "id_fin_arancel")
})
public class FinDetalleArancel extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_fin_detalle_arancel", nullable = false)
  private Integer idFinDetalleArancel;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_fin_arancel", nullable = false)
  private FinArancel finArancel;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_fin_concepto_arancel", nullable = false)
  private FinConceptoArancel finConceptoArancel;

  @Column(name = "monto_concepto", nullable = false, precision = 10, scale = 2)
  private BigDecimal montoConcepto;

  @Column(name = "orden_aplicacion", nullable = false)
  private Integer ordenAplicacion;

}
