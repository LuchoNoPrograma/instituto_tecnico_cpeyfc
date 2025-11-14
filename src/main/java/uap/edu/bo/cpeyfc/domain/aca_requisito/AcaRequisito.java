package uap.edu.bo.cpeyfc.domain.aca_requisito;

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
@Table(name = "aca_requisito")
public class AcaRequisito extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_requisito_id_aca_requisito_seq')")
  @Column(name = "id_aca_requisito", nullable = false)
  private Integer idAcaRequisito;

  @Column(name = "nombre_requisito", nullable = false, length = 100)
  private String nombreRequisito;

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "orden_presentacion")
  private Integer ordenPresentacion;

  @Column(name = "estado_requisito", nullable = false, length = 35)
  private String estadoRequisito;

}
