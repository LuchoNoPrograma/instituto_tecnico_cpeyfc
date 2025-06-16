package uap.edu.bo.cpeyfc.domain.seg_usuario;

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
@Table(name = "seg_usuario")
public class SegUsuario extends Auditoria {
  @Id
  @ColumnDefault("nextval('seg_usuario_id_seg_usuario_seq')")
  @Column(name = "id_seg_usuario", nullable = false)
  private Integer idSegUsuario;

  @Column(name = "nombre_usuario", length = 50)
  private String nombreUsuario;

  @Column(name = "contrasena_hash")
  private String contrasenaHash;

  @Column(name = "estado_usuario", nullable = false, length = 35)
  private String estadoUsuario;

}