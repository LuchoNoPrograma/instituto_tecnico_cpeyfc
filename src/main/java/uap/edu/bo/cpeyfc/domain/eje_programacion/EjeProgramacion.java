package uap.edu.bo.cpeyfc.domain.eje_programacion;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.eje_cronograma_modulo.EjeCronogramaModulo;
import uap.edu.bo.cpeyfc.domain.ins_matricula.InsMatricula;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "eje_programacion", indexes = {
  @Index(name = "matricula_tiene_programaciones_", columnList = "cod_ins_matricula"),
  @Index(name = "cronograma_modulo_recibe_progra", columnList = "id_eje_cronograma_modulo")
})
public class EjeProgramacion extends Auditoria {
  @Id
  @ColumnDefault("nextval('eje_programacion_id_eje_programacion_seq')")
  @Column(name = "id_eje_programacion", nullable = false)
  private Integer idEjeProgramacion;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "cod_ins_matricula", nullable = false)
  private InsMatricula insMatricula;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_eje_cronograma_modulo")
  private EjeCronogramaModulo ejeCronogramaModulo;

  @Column(name = "observacion")
  private String observacion;

  @Column(name = "fecha_programacion", nullable = false)
  private LocalDate fechaProgramacion;

  @Column(name = "estado_programacion", nullable = false, length = 35)
  private String estadoProgramacion;

  @Column(name = "nota_final")
  private Integer notaFinal;

}