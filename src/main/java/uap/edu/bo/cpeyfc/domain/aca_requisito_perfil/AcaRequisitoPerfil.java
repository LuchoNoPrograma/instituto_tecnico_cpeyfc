package uap.edu.bo.cpeyfc.domain.aca_requisito_perfil;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_perfil_estudiante.AcaPerfilEstudiante;
import uap.edu.bo.cpeyfc.domain.aca_requisito.AcaRequisito;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_requisito_perfil")
public class AcaRequisitoPerfil extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_requisito_perfil_id_aca_requisito_perfil_seq')")
  @Column(name = "id_aca_requisito_perfil", nullable = false)
  private Integer idAcaRequisitoPerfil;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "id_aca_requisito", nullable = false)
  private AcaRequisito acaRequisito;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "id_aca_perfil_estudiante", nullable = false)
  private AcaPerfilEstudiante acaPerfilEstudiante;

  @Column(name = "estado_requisito_perfil", nullable = false, length = 35)
  private String estadoRequisitoPerfil;

}
