package uap.edu.bo.cpeyfc.domain.fin_concepto_arancel;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import uap.edu.bo.cpeyfc.config.Auditoria;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_concepto_arancel")
public class FinConceptoArancel extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_fin_concepto_arancel", nullable = false)
  private Integer idFinConceptoArancel;

  @Column(name = "nombre_concepto", nullable = false, unique = true, length = 100)
  private String nombreConcepto;

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "es_recurrente")
  private Boolean esRecurrente; // Se cobra cada periodo

  @Column(name = "es_unico")
  private Boolean esUnico; // Se cobra una sola vez

  @Column(name = "tipo_concepto", nullable = false, length = 35)
  private String tipoConcepto; // INSCRIPCION, COLEGIATURA, CERTIFICACION, ADMINISTRATIVO, OTROS

  @Column(name = "estado_concepto", nullable = false, length = 35)
  private String estadoConcepto; // ACTIVO, INACTIVO, ELIMINADO

}
