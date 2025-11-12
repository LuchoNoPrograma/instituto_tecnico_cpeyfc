package uap.edu.bo.cpeyfc.domain.fin_arancel;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_programa_aprobado.AcaProgramaAprobado;
import uap.edu.bo.cpeyfc.domain.aca_periodo.AcaPeriodo;
import uap.edu.bo.cpeyfc.domain.aca_tipo_estudiante.AcaTipoEstudiante;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "fin_arancel", indexes = {
  @Index(name = "idx_arancel_programa", columnList = "id_aca_programa_aprobado"),
  @Index(name = "idx_arancel_periodo", columnList = "id_aca_periodo"),
  @Index(name = "idx_arancel_tipo_est", columnList = "id_aca_tipo_estudiante")
})
public class FinArancel extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_fin_arancel", nullable = false)
  private Integer idFinArancel;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_programa_aprobado", nullable = false)
  private AcaProgramaAprobado acaProgramaAprobado;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_periodo")
  private AcaPeriodo acaPeriodo;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_tipo_estudiante", nullable = false)
  private AcaTipoEstudiante acaTipoEstudiante;

  @Column(name = "nombre_arancel", nullable = false, length = 200)
  private String nombreArancel;

  @Column(name = "nro_resolucion", length = 50)
  private String nroResolucion;

  @Column(name = "fecha_aprobacion")
  private LocalDate fechaAprobacion;

  @Column(name = "fecha_inicio_vigencia", nullable = false)
  private LocalDate fechaInicioVigencia;

  @Column(name = "fecha_fin_vigencia")
  private LocalDate fechaFinVigencia;

  @Column(name = "estado_arancel", nullable = false, length = 35)
  private String estadoArancel; // ACTIVO, VENCIDO, ELIMINADO

}
