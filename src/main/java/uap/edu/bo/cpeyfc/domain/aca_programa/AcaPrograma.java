package uap.edu.bo.cpeyfc.domain.aca_programa;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_area.AcaArea;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_programa", indexes = {
  @Index(name = "programa_clasificado_por_area_f", columnList = "id_aca_area")
})
public class AcaPrograma extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_programa_id_aca_programa_seq')")
  @Column(name = "id_aca_programa", nullable = false)
  private Integer idAcaPrograma;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_area", nullable = false)
  private AcaArea acaArea;

  @Column(name = "nombre_programa", nullable = false, length = 100)
  private String nombrePrograma;

  @Column(name = "sigla", length = 15)
  private String sigla;

  @Column(name = "estado_programa", nullable = false, length = 35)
  private String estadoPrograma;

}