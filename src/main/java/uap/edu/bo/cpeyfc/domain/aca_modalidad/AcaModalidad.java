package uap.edu.bo.cpeyfc.domain.aca_modalidad;

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
@Table(name = "aca_modalidad")
public class AcaModalidad extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_modalidad_id_aca_modalidad_seq')")
  @Column(name = "id_aca_modalidad", nullable = false)
  private Integer idAcaModalidad;

  @Column(name = "nombre_modalidad", nullable = false, length = 50)
  private String nombreModalidad;

  @Column(name = "estado_modalidad", nullable = false, length = 35)
  private String estadoModalidad;

}