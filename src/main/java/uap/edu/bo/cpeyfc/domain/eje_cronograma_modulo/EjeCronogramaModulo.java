package uap.edu.bo.cpeyfc.domain.eje_cronograma_modulo;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_plan_modulo_detalle.AcaPlanModuloDetalle;
import uap.edu.bo.cpeyfc.domain.eje_docente.EjeDocente;
import uap.edu.bo.cpeyfc.domain.ins_grupo.InsGrupo;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "eje_cronograma_modulo", indexes = {
  @Index(name = "grupo_tiene_cronogramas_modulo_", columnList = "id_ins_grupo"),
  @Index(name = "cronograma_modulo_ejecuta_plan_", columnList = "id_aca_plan_modulo_detalle"),
  @Index(name = "docente_se_le_asigna_cronograma", columnList = "id_eje_docente")
})
public class EjeCronogramaModulo extends Auditoria {
  @Id
  @ColumnDefault("nextval('eje_cronograma_modulo_id_eje_cronograma_modulo_seq')")
  @Column(name = "id_eje_cronograma_modulo", nullable = false)
  private Integer idEjeCronogramaModulo;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_ins_grupo", nullable = false)
  private InsGrupo insGrupo;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_plan_modulo_detalle", nullable = false)
  private AcaPlanModuloDetalle acaPlanModuloDetalle;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_eje_docente")
  private EjeDocente ejeDocente;

  @Column(name = "fecha_inicio")
  private LocalDate fechaInicio;

  @Column(name = "fecha_fin")
  private LocalDate fechaFin;

  @Column(name = "estado_cronograma_modulo", nullable = false, length = 35)
  private String estadoCronogramaModulo;

}