package uap.edu.bo.cpeyfc.domain.fin_tipo_beneficiario;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import uap.edu.bo.cpeyfc.config.Auditoria;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_tipo_beneficiario")
public class FinTipoBeneficiario extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_tipo_beneficiario", nullable = false)
  private Integer idTipoBeneficiario;

  @Column(name = "nombre_tipo", nullable = false, length = 100)
  private String nombreTipo;

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "estado_tipo_beneficiario", nullable = false, length = 20)
  private String estadoTipoBeneficiario;
}
