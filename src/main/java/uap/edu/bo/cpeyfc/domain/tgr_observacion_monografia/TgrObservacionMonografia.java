package uap.edu.bo.cpeyfc.domain.tgr_observacion_monografia;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.tgr_revision_monografia.TgrRevisionMonografia;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "tgr_observacion_monografia", indexes = {
  @Index(name = "revision_monografia_recibe_obse", columnList = "id_tgr_revision_monografia")
})
public class TgrObservacionMonografia extends Auditoria {
  @Id
  @ColumnDefault("nextval('tgr_observacion_monografia_id_tgr_observacion_monografia_seq')")
  @Column(name = "id_tgr_observacion_monografia", nullable = false)
  private Integer idTgrObservacionMonografia;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_tgr_revision_monografia", nullable = false)
  private TgrRevisionMonografia tgrRevisionMonografia;

  @Column(name = "descripcion", nullable = false, length = 1)
  private String descripcion;

  @Column(name = "estado_observacion_monografia", nullable = false, length = 35)
  private String estadoObservacionMonografia;

}