package uap.edu.bo.cpeyfc.domain.eje_calificacion;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.eje_criterio_eval.EjeCriterioEval;
import uap.edu.bo.cpeyfc.domain.eje_programacion.EjeProgramacion;

import java.math.BigDecimal;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "eje_calificacion", indexes = {
  @Index(name = "calificacion_en_base_a_criterio", columnList = "id_eje_criterio_eval"),
  @Index(name = "programacion_tiene_calificacion", columnList = "id_eje_programacion")
})
public class EjeCalificacion extends Auditoria {
  @Id
  @ColumnDefault("nextval('eje_calificacion_id_eje_calificacion_seq')")
  @Column(name = "id_eje_calificacion", nullable = false)
  private Integer idEjeCalificacion;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_eje_criterio_eval", nullable = false)
  private EjeCriterioEval ejeCriterioEval;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_eje_programacion", nullable = false)
  private EjeProgramacion ejeProgramacion;

  @Column(name = "nota", precision = 5, scale = 2)
  private BigDecimal nota;

  @Column(name = "estado_calificacion", nullable = false, length = 35)
  private String estadoCalificacion;

}