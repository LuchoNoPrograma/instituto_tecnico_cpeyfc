package uap.edu.bo.cpeyfc.domain.aca_plan_estudio;

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
@Table(name = "aca_plan_estudio")
public class AcaPlanEstudio extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_plan_estudio_id_aca_plan_estudio_seq')")
  @Column(name = "id_aca_plan_estudio", nullable = false)
  private Integer idAcaPlanEstudio;

  @Column(name = "anho", nullable = false)
  private Integer anho;

  @Column(name = "vigente", nullable = false)
  private Boolean vigente = false;

  @Column(name = "estado_plan_estudio", nullable = false, length = 35)
  private String estadoPlanEstudio;

}