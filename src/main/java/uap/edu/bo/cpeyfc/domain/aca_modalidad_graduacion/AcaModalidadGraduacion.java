package uap.edu.bo.cpeyfc.domain.aca_modalidad_graduacion;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import uap.edu.bo.cpeyfc.config.Auditoria;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_modalidad_graduacion")
public class AcaModalidadGraduacion extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_aca_modalidad_graduacion", nullable = false)
  private Integer idAcaModalidadGraduacion;

  @Column(name = "nombre_modalidad", nullable = false, unique = true, length = 150)
  private String nombreModalidad;

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "requiere_tesis")
  private Boolean requiereTesis;

  @Column(name = "requiere_examen")
  private Boolean requiereExamen;

  @Column(name = "requiere_proyecto")
  private Boolean requiereProyecto;

  @Column(name = "orden", nullable = false)
  private Integer orden;

  @Column(name = "estado_modalidad_graduacion", nullable = false, length = 35)
  private String estadoModalidadGraduacion; // ACTIVO, INACTIVO, ELIMINADO

}
