package uap.edu.bo.cpeyfc.domain.fin_detalle_pago;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.fin_obligacion_pago.FinObligacionPago;
import uap.edu.bo.cpeyfc.domain.fin_transaccion.FinTransaccion;

import java.math.BigDecimal;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_detalle_pago", indexes = {
  @Index(name = "transaccion_se_aplica_mediante_", columnList = "id_fin_transaccion"),
  @Index(name = "obligacion_pago_recibe_detalles", columnList = "id_fin_obligacion_pago")
})
public class FinDetallePago extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_fin_detalle_pago", nullable = false)
  private Integer idFinDetallePago;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_fin_transaccion", nullable = false)
  private FinTransaccion finTransaccion;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_fin_obligacion_pago", nullable = false)
  private FinObligacionPago finObligacionPago;

  @Column(name = "monto_pagado", nullable = false, precision = 8, scale = 2)
  private BigDecimal montoPagado;

  @Column(name = "estado_detalle_pago", nullable = false, length = 35)
  private String estadoDetallePago;

}