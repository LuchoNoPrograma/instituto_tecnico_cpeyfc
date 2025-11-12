package uap.edu.bo.cpeyfc.domain.aca_periodo;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_gestion.AcaGestion;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_periodo", indexes = {
  @Index(name = "idx_periodo_gestion", columnList = "id_aca_gestion"),
  @Index(name = "idx_periodo_estado", columnList = "estado_periodo")
})
public class AcaPeriodo extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_aca_periodo", nullable = false)
  private Integer idAcaPeriodo;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_gestion", nullable = false)
  private AcaGestion acaGestion;

  @Column(name = "codigo_periodo", nullable = false, length = 20)
  private String codigoPeriodo; // ej: 2025-1, 2025-2

  @Column(name = "nombre_periodo", nullable = false, length = 100)
  private String nombrePeriodo;

  @Column(name = "tipo_periodo", nullable = false, length = 35)
  private String tipoPeriodo; // SEMESTRE, TRIMESTRE, BIMESTRE, CUATRIMESTRE, ANUAL

  @Column(name = "numero_periodo", nullable = false)
  private Integer numeroPeriodo; // 1, 2, 3...

  @Column(name = "fecha_inicio", nullable = false)
  private LocalDate fechaInicio;

  @Column(name = "fecha_fin", nullable = false)
  private LocalDate fechaFin;

  @Column(name = "estado_periodo", nullable = false, length = 35)
  private String estadoPeriodo; // ACTIVO, FINALIZADO, ELIMINADO

}
