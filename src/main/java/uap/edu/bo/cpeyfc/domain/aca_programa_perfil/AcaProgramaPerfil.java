package uap.edu.bo.cpeyfc.domain.aca_programa_perfil;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_perfil_estudiante.AcaPerfilEstudiante;
import uap.edu.bo.cpeyfc.domain.aca_programa.AcaPrograma;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_programa_perfil")
public class AcaProgramaPerfil extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_programa_perfil_id_aca_programa_perfil_seq')")
  @Column(name = "id_aca_programa_perfil", nullable = false)
  private Integer idAcaProgramaPerfil;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "id_aca_programa", nullable = false)
  private AcaPrograma acaPrograma;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "id_aca_perfil_estudiante", nullable = false)
  private AcaPerfilEstudiante acaPerfilEstudiante;

  @Column(name = "observaciones", columnDefinition = "TEXT")
  private String observaciones;

  @Column(name = "estado_programa_perfil", nullable = false, length = 35)
  private String estadoProgramaPerfil;

}
