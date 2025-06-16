package uap.edu.bo.cpeyfc.domain.aca_area;

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
@Table(name = "aca_area")
public class AcaArea extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_area_id_aca_area_seq')")
  @Column(name = "id_aca_area", nullable = false)
  private Integer idAcaArea;

  @Column(name = "nombre_area", nullable = false, length = 100)
  private String nombreArea;

  @Column(name = "estado_area", nullable = false, length = 35)
  private String estadoArea;

}