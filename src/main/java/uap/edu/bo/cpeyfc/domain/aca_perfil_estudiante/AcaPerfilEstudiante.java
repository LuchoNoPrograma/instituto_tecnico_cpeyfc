package uap.edu.bo.cpeyfc.domain.aca_perfil_estudiante;

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
@Table(name = "aca_perfil_estudiante")
public class AcaPerfilEstudiante extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_perfil_estudiante_id_aca_perfil_estudiante_seq')")
  @Column(name = "id_aca_perfil_estudiante", nullable = false)
  private Integer idAcaPerfilEstudiante;

  @Column(name = "nombre_perfil", nullable = false, length = 50)
  private String nombrePerfil;

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "estado_perfil_estudiante", nullable = false, length = 35)
  private String estadoPerfilEstudiante;

}
