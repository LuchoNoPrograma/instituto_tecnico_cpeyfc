package uap.edu.bo.cpeyfc.domain.ins_preinscripcion;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_programa_aprobado.AcaProgramaAprobado;
import uap.edu.bo.cpeyfc.domain.prs_persona.PrsPersona;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "ins_preinscripcion", indexes = {
  @Index(name = "programa_recibe_preinscripcione", columnList = "id_aca_programa_aprobado"),
  @Index(name = "persona_realiza_preinscripcione", columnList = "id_prs_persona")
})
public class InsPreinscripcion extends Auditoria {
  @Id
  @ColumnDefault("nextval('ins_preinscripcion_id_ins_preinscripcion_seq')")
  @Column(name = "id_ins_preinscripcion", nullable = false)
  private Integer idInsPreinscripcion;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_programa_aprobado", nullable = false)
  private AcaProgramaAprobado acaProgramaAprobado;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_prs_persona", nullable = false)
  private PrsPersona prsPersona;

  @Column(name = "estado_preinscripcion", nullable = false, length = 35)
  private String estadoPreinscripcion;

}