package uap.edu.bo.cpeyfc.domain.aca_certificacion_programa;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_programa_aprobado.AcaProgramaAprobado;
import uap.edu.bo.cpeyfc.domain.aca_titulo_certificado.AcaTituloCertificado;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_certificacion_programa", indexes = {
  @Index(name = "idx_cert_prog_programa", columnList = "id_aca_programa_aprobado"),
  @Index(name = "idx_cert_prog_titulo", columnList = "id_aca_titulo_certificado")
})
public class AcaCertificacionPrograma extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_aca_certificacion_programa", nullable = false)
  private Integer idAcaCertificacionPrograma;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_programa_aprobado", nullable = false)
  private AcaProgramaAprobado acaProgramaAprobado;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_titulo_certificado", nullable = false)
  private AcaTituloCertificado acaTituloCertificado;

  @Column(name = "nombre_certificacion", nullable = false, length = 200)
  private String nombreCertificacion;

  @Column(name = "tipo_certificacion_programa", nullable = false, length = 35)
  private String tipoCertificacionPrograma; // INTERMEDIA, TERMINAL

  @Column(name = "periodos_requeridos", nullable = false)
  private Integer periodosRequeridos;

  @Column(name = "creditos_requeridos")
  private Integer creditosRequeridos;

  @Column(name = "horas_academicas_requeridas")
  private Integer horasAcademicasRequeridas;

  @Column(name = "orden_secuencial", nullable = false)
  private Integer ordenSecuencial;

  @Column(name = "estado_certificacion_programa", nullable = false, length = 35)
  private String estadoCertificacionPrograma; // ACTIVO, INACTIVO, ELIMINADO

}
