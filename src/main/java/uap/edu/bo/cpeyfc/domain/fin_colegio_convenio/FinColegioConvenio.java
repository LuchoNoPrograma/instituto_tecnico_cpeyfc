package uap.edu.bo.cpeyfc.domain.fin_colegio_convenio;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_colegio.AcaColegio;
import uap.edu.bo.cpeyfc.domain.fin_convenio.FinConvenio;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_colegio_convenio", indexes = {
  @Index(name = "idx_colegio_conv_colegio", columnList = "id_aca_colegio"),
  @Index(name = "idx_colegio_conv_convenio", columnList = "id_fin_convenio")
})
public class FinColegioConvenio extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_fin_colegio_convenio", nullable = false)
  private Integer idFinColegioConvenio;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_colegio", nullable = false)
  private AcaColegio acaColegio;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_fin_convenio", nullable = false)
  private FinConvenio finConvenio;

  @Column(name = "fecha_inicio", nullable = false)
  private LocalDate fechaInicio;

  @Column(name = "fecha_fin")
  private LocalDate fechaFin;

  @Column(name = "estado_colegio_convenio", nullable = false, length = 35)
  private String estadoColegioConvenio; // ACTIVO, VENCIDO, SUSPENDIDO, ELIMINADO

}
