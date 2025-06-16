package uap.edu.bo.cpeyfc.domain.aca_modulo;

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
@Table(name = "aca_modulo")
public class AcaModulo extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_modulo_id_aca_modulo_seq')")
  @Column(name = "id_aca_modulo", nullable = false)
  private Integer idAcaModulo;

  @Column(name = "nombre_modulo", nullable = false, length = 100)
  private String nombreModulo;

  @Column(name = "estado_modulo", nullable = false, length = 35)
  private String estadoModulo;

}