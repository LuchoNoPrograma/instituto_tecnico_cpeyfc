package uap.edu.bo.cpeyfc.domain.fin_descuento_arancel;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.fin_arancel.FinArancel;

import java.math.BigDecimal;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_descuento_arancel")
public class FinDescuentoArancel extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_fin_descuento_arancel", nullable = false)
  private Integer idFinDescuentoArancel;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_fin_arancel", nullable = false)
  private FinArancel finArancel;

  @Column(name = "nombre_descuento", nullable = false, length = 150)
  private String nombreDescuento;

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "tipo_descuento", nullable = false, length = 35)
  private String tipoDescuento; // PORCENTAJE, MONTO_FIJO

  @Column(name = "porcentaje_descuento", precision = 5, scale = 2)
  private BigDecimal porcentajeDescuento;

  @Column(name = "monto_descuento", precision = 10, scale = 2)
  private BigDecimal montoDescuento;

  @Column(name = "aplica_desde_periodo")
  private Integer aplicaDesdePeriodo; // A partir de qué número de periodo aplica

  @Column(name = "requiere_validacion")
  private Boolean requiereValidacion;

  @Column(name = "estado_descuento", nullable = false, length = 35)
  private String estadoDescuento; // ACTIVO, INACTIVO, ELIMINADO

}
