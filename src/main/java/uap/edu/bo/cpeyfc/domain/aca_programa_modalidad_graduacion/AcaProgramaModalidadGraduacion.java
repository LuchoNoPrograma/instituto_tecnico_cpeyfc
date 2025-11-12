package uap.edu.bo.cpeyfc.domain.aca_programa_modalidad_graduacion;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_programa_aprobado.AcaProgramaAprobado;
import uap.edu.bo.cpeyfc.domain.aca_modalidad_graduacion.AcaModalidadGraduacion;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_programa_modalidad_graduacion")
public class AcaProgramaModalidadGraduacion extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_aca_programa_modalidad_graduacion", nullable = false)
  private Integer idAcaProgramaModalidadGraduacion;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_programa_aprobado", nullable = false)
  private AcaProgramaAprobado acaProgramaAprobado;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_modalidad_graduacion", nullable = false)
  private AcaModalidadGraduacion acaModalidadGraduacion;

  @Column(name = "es_modalidad_por_defecto")
  private Boolean esModalidadPorDefecto;

  @Column(name = "orden_prioridad")
  private Integer ordenPrioridad;

  @Column(name = "estado_programa_modalidad", nullable = false, length = 35)
  private String estadoProgramaModalidad; // ACTIVO, INACTIVO, ELIMINADO

}
