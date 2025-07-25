package uap.edu.bo.cpeyfc.domain.eje_criterio_eval;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.eje_docente.EjeDocente;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "eje_criterio_eval", indexes = {
  @Index(name = "fk_eje_crit_docente_define_criterio", columnList = "id_eje_docente")
})
public class EjeCriterioEval extends Auditoria {
  @Id
  @ColumnDefault("nextval('eje_criterio_eval_id_eje_criterio_eval_seq')")
  @Column(name = "id_eje_criterio_eval", nullable = false)
  private Integer idEjeCriterioEval;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_eje_docente", nullable = false)
  private EjeDocente ejeDocente;

  @Column(name = "nombre_crit", nullable = false, length = 25)
  private String nombreCrit;

  @Column(name = "descripcion", length = 155)
  private String descripcion;

  @Column(name = "ponderacion", nullable = false)
  private Integer ponderacion;

  @Column(name = "orden", nullable = false)
  private Integer orden;

  @Column(name = "estado_criterio_eval", nullable = false, length = 35)
  private String estadoCriterioEval;

}