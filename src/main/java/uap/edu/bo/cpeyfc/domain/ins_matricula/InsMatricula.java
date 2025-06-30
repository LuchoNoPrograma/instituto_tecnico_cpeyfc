package uap.edu.bo.cpeyfc.domain.ins_matricula;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.ins_grupo.InsGrupo;
import uap.edu.bo.cpeyfc.domain.prs_persona.PrsPersona;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuario;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "ins_matricula", indexes = {
  @Index(name = "grupo_inscribe_matriculas_fk", columnList = "id_ins_grupo"),
  @Index(name = "persona_se_matricula_en_grupo_f", columnList = "id_prs_persona"),
  @Index(name = "matricula_tiene_usuario_fk", columnList = "id_seg_usuario")
})
public class InsMatricula extends Auditoria {
  @Id
  @ColumnDefault("nextval('ins_matricula_cod_ins_matricula_seq')")
  @Column(name = "cod_ins_matricula", nullable = false)
  private Integer insMatricula;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_ins_grupo", nullable = false)
  private InsGrupo insGrupo;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_prs_persona", nullable = false)
  private PrsPersona prsPersona;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_seg_usuario", nullable = false)
  private SegUsuario segUsuario;

  @Column(name = "estado_matricula", nullable = false, length = 35)
  private String estadoMatricula;

  @Column(name = "tipo_matricula", nullable = false, length = 35)
  private String tipoMatricula;
}