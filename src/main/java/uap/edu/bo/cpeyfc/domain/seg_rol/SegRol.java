package uap.edu.bo.cpeyfc.domain.seg_rol;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import uap.edu.bo.cpeyfc.config.Auditoria;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "seg_rol")
public class SegRol extends Auditoria {
  @Id
  @ColumnDefault("nextval('seg_rol_id_seg_rol_seq')")
  @Column(name = "id_seg_rol", nullable = false)
  private Integer idSegRol;

  @Column(name = "nombre_rol", nullable = false, length = 50)
  private String nombreRol;

  @Column(name = "descripcion", length = Integer.MAX_VALUE)
  private String descripcion;

  @Column(name = "estado_rol", nullable = false, length = 35)
  private String estadoRol;

}