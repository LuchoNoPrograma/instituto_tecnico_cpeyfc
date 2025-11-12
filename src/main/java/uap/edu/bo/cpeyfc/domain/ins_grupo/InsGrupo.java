package uap.edu.bo.cpeyfc.domain.ins_grupo;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_programa_aprobado.AcaProgramaAprobado;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "ins_grupo", indexes = {
  @Index(name = "programa_aprobado_tiene_grupos_", columnList = "id_aca_programa_aprobado")
})
public class InsGrupo extends Auditoria {
  @Id
  @ColumnDefault("nextval('ins_grupo_id_ins_grupo_seq')")
  @Column(name = "id_ins_grupo", nullable = false)
  private Integer idInsGrupo;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_programa_aprobado", nullable = false)
  private AcaProgramaAprobado acaProgramaAprobado;

  @Column(name = "nombre_grupo", nullable = false, length = 100)
  private String nombreGrupo;

  @Column(name = "fecha_inicio_inscripcion", nullable = false)
  private LocalDate fechaInicioInscripcion;

  @Column(name = "fecha_fin_inscripcion")
  private LocalDate fechaFinInscripcion;

  @Column(name = "estado_grupo", nullable = false, length = 35)
  private String estadoGrupo;

  @Column(name = "gestion_inicio", nullable = false)
  private Integer gestionInicio;

  @Column(name = "codigo_paralelo", length = 10)
  private String codigoParalelo; // A, B, C, etc.

  @Column(name = "horario", length = 50)
  private String horario; // ej: 15:00-16:30

  @Column(name = "aula", length = 20)
  private String aula; // ej: C-5, D-9

  @Column(name = "fecha_inicio")
  private LocalDate fechaInicio;

  @Column(name = "fecha_fin")
  private LocalDate fechaFin;

}