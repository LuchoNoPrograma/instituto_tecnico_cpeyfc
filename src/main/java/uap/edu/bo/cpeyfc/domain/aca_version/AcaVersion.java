package uap.edu.bo.cpeyfc.domain.aca_version;

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
@Table(name = "aca_version")
public class AcaVersion extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_version_id_aca_version_seq')")
  @Column(name = "id_aca_version", nullable = false)
  private Integer idAcaVersion;

  @Column(name = "cod_version", nullable = false, length = 10)
  private String codVersion;

  @Column(name = "estado_version", nullable = false, length = 35)
  private String estadoVersion;

}