package uap.edu.bo.cpeyfc.domain.seg_tarea;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.seg_rol.SegRol;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "seg_tarea", indexes = {
  @Index(name = "rol_agrupa_tarea_fk", columnList = "id_seg_rol")
})
public class SegTarea extends Auditoria {
  @Id
  @ColumnDefault("nextval('seg_tarea_id_seg_tarea_seq')")
  @Column(name = "id_seg_tarea", nullable = false)
  private Integer idSegTarea;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_seg_rol", nullable = false)
  private SegRol segRol;

  @Column(name = "nombre_tarea", nullable = false, length = 50)
  private String nombreTarea;

  @Column(name = "descripcion", length = Integer.MAX_VALUE)
  private String descripcion;

  @Column(name = "estado_tarea", nullable = false, length = 35)
  private String estadoTarea;

}