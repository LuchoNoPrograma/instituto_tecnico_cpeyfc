package uap.edu.bo.cpeyfc.domain.aca_tipo_estudiante;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import uap.edu.bo.cpeyfc.config.Auditoria;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_tipo_estudiante")
public class AcaTipoEstudiante extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_aca_tipo_estudiante", nullable = false)
  private Integer idAcaTipoEstudiante;

  @Column(name = "nombre_tipo", nullable = false, unique = true, length = 100)
  private String nombreTipo; // Nacional, Estudiante UAP, Extranjero

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "es_nacional")
  private Boolean esNacional;

  @Column(name = "requiere_documentacion_adicional")
  private Boolean requiereDocumentacionAdicional;

  @Column(name = "estado_tipo_estudiante", nullable = false, length = 35)
  private String estadoTipoEstudiante; // ACTIVO, INACTIVO, ELIMINADO

}
