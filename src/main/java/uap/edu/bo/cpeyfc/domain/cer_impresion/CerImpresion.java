package uap.edu.bo.cpeyfc.domain.cer_impresion;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.cer_certificado.CerCertificado;
import uap.edu.bo.cpeyfc.domain.fin_obligacion_pago.FinObligacionPago;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "cer_impresion", indexes = {
  @Index(name = "certificado_registra_impresione", columnList = "id_cer_certificado"),
  @Index(name = "obligacion_pago_financia_impres", columnList = "id_fin_obligacion_pago")
})
public class CerImpresion extends Auditoria {
  @Id
  @ColumnDefault("nextval('cer_impresion_id_cer_impresion_seq')")
  @Column(name = "id_cer_impresion", nullable = false)
  private Integer idCerImpresion;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_cer_certificado", nullable = false)
  private CerCertificado cerCertificado;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_fin_obligacion_pago", nullable = false)
  private FinObligacionPago finObligacionPago;

  @Column(name = "num_impresion", nullable = false)
  private Integer numImpresion;

  @Column(name = "hash_impresion", nullable = false)
  private String hashImpresion;

  @Column(name = "estado_impresion", nullable = false, length = 35)
  private String estadoImpresion;

}