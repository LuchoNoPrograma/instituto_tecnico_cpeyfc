package uap.edu.bo.cpeyfc.domain.eje_docente;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.prs_persona.PrsPersona;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuario;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "eje_docente", indexes = {
  @Index(name = "persona_puede_ser_docente_fk", columnList = "id_prs_persona"),
  @Index(name = "docente_tiene_usuario_fk", columnList = "id_seg_usuario")
})
public class EjeDocente extends Auditoria {
  @Id
  @ColumnDefault("nextval('eje_docente_id_eje_docente_seq')")
  @Column(name = "id_eje_docente", nullable = false)
  private Integer idEjeDocente;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_prs_persona", nullable = false)
  private PrsPersona prsPersona;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_seg_usuario", nullable = false)
  private SegUsuario segUsuario;

  @Column(name = "nro_resolucion")
  private Integer nroResolucion;

  @Column(name = "estado_docente", nullable = false, length = 35)
  private String estadoDocente;

}