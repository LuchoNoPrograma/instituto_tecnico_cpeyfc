package uap.edu.bo.cpeyfc.domain.seg_ocupa;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.seg_rol.SegRol;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuario;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "seg_ocupa", indexes = {
  @Index(name = "rol_se_ocupa_fk", columnList = "id_seg_rol"),
  @Index(name = "usuario_ocupa_fk", columnList = "id_seg_usuario")
})
public class SegOcupa extends Auditoria {
  @EmbeddedId
  private SegOcupaId idSegOcupa;

  @MapsId("idSegRol")
  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_seg_rol", nullable = false)
  private SegRol segRol;

  @MapsId("idSegUsuario")
  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_seg_usuario", nullable = false)
  private SegUsuario segUsuario;

  @Column(name = "estado_ocupa", nullable = false, length = 35)
  private String estadoOcupa;

}