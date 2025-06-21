package uap.edu.bo.cpeyfc.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.domain.prs_persona.PrsPersona;
import uap.edu.bo.cpeyfc.domain.tgr_monografia.TgrMonografia;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "tgr_tribunal", indexes = {
  @Index(name = "monografia_tiene_miembro_tribun", columnList = "id_tgr_monografia"),
  @Index(name = "tribunal_es_una_persona_fk", columnList = "id_prs_persona")
})
public class TgrTribunal {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_tgr_tribunal", nullable = false)
  private Integer idTgrTribunal;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_tgr_monografia", nullable = false)
  private TgrMonografia tgrMonografia;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_prs_persona", nullable = false)
  private PrsPersona prsPersona;

  @Column(name = "tipo_tribunal", nullable = false, length = 35)
  private String tipoTribunal;

  @Column(name = "estado_tribunal", nullable = false, length = 35)
  private String estadoTribunal;

  @Column(name = "fecha_reg", nullable = false)
  private LocalDateTime fechaReg;

  @Column(name = "fecha_mod")
  private LocalDateTime fechaMod;

  @Column(name = "user_reg", nullable = false)
  private Integer userReg;

  @Column(name = "user_mod")
  private Integer userMod;

}