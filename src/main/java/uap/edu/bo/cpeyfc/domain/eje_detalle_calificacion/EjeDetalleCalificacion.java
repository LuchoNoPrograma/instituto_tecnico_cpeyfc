package uap.edu.bo.cpeyfc.domain.eje_detalle_calificacion;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.eje_calificacion.EjeCalificacion;
import uap.edu.bo.cpeyfc.domain.eje_area_evaluacion.EjeAreaEvaluacion;

import java.math.BigDecimal;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "eje_detalle_calificacion", indexes = {
  @Index(name = "idx_detalle_calif_calif", columnList = "id_eje_calificacion"),
  @Index(name = "idx_detalle_calif_area", columnList = "id_eje_area_evaluacion")
})
public class EjeDetalleCalificacion extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_eje_detalle_calificacion", nullable = false)
  private Integer idEjeDetalleCalificacion;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_eje_calificacion", nullable = false)
  private EjeCalificacion ejeCalificacion;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_eje_area_evaluacion", nullable = false)
  private EjeAreaEvaluacion ejeAreaEvaluacion;

  @Column(name = "nota_progress_test", precision = 5, scale = 2)
  private BigDecimal notaProgressTest;

  @Column(name = "nota_class_performance", precision = 5, scale = 2)
  private BigDecimal notaClassPerformance;

  @Column(name = "comentario_docente", columnDefinition = "TEXT")
  private String comentarioDocente;

  @Column(name = "nota_final_area", nullable = false, precision = 5, scale = 2)
  private BigDecimal notaFinalArea;

  @Column(name = "estado_detalle_calificacion", nullable = false, length = 35)
  private String estadoDetalleCalificacion; // ACTIVO, ELIMINADO

}
