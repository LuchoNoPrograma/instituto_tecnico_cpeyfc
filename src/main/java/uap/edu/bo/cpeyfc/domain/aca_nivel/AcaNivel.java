package uap.edu.bo.cpeyfc.domain.aca_nivel;

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
@Table(name = "aca_nivel")
public class AcaNivel extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_nivel_id_aca_nivel_seq')")
  @Column(name = "id_aca_nivel", nullable = false)
  private Integer idAcaNivel;

  @Column(name = "nombre_nivel", nullable = false, length = 100)
  private String nombreNivel;

  @Column(name = "estado_nivel", nullable = false, length = 35)
  private String estadoNivel;

}