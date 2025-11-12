package uap.edu.bo.cpeyfc.domain.eje_area_evaluacion;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_programa_aprobado.AcaProgramaAprobado;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "eje_area_evaluacion", indexes = {
  @Index(name = "idx_area_eval_programa", columnList = "id_aca_programa_aprobado")
})
public class EjeAreaEvaluacion extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_eje_area_evaluacion", nullable = false)
  private Integer idEjeAreaEvaluacion;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_programa_aprobado")
  private AcaProgramaAprobado acaProgramaAprobado; // NULL = área genérica

  @Column(name = "nombre_area", nullable = false, length = 100)
  private String nombreArea; // Listening, Speaking, Reading, Writing, Vocabulary, Grammar

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "orden", nullable = false)
  private Integer orden;

  @Column(name = "estado_area_evaluacion", nullable = false, length = 35)
  private String estadoAreaEvaluacion; // ACTIVO, INACTIVO, ELIMINADO

}
