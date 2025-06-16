package uap.edu.bo.cpeyfc.domain.seg_designa;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.seg_tarea.SegTarea;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuario;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "seg_designa", indexes = {
  @Index(name = "tarea_se_designa_a_usuario_fk", columnList = "id_seg_tarea"),
  @Index(name = "usuario_recibe_tareas_designada", columnList = "id_seg_usuario")
})
public class SegDesigna extends Auditoria {
  @EmbeddedId
  private SegDesignaId idSegDesigna;

  @MapsId("idSegTarea")
  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_seg_tarea", nullable = false)
  private SegTarea segTarea;

  @MapsId("idSegUsuario")
  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_seg_usuario", nullable = false)
  private SegUsuario segUsuario;

  @Column(name = "estado_designa", nullable = false, length = 35)
  private String estadoDesigna;

}