package uap.edu.bo.cpeyfc.domain.aca_certificado_emitido;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_certificacion_programa.AcaCertificacionPrograma;
import uap.edu.bo.cpeyfc.domain.aca_modalidad_graduacion.AcaModalidadGraduacion;
import uap.edu.bo.cpeyfc.domain.prs_persona.PrsPersona;

import java.math.BigDecimal;
import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_certificado_emitido", indexes = {
  @Index(name = "idx_cert_emitido_persona", columnList = "id_prs_persona"),
  @Index(name = "idx_cert_emitido_numero", columnList = "numero_certificado")
})
public class AcaCertificadoEmitido extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_aca_certificado_emitido", nullable = false)
  private Integer idAcaCertificadoEmitido;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_certificacion_programa", nullable = false)
  private AcaCertificacionPrograma acaCertificacionPrograma;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_prs_persona", nullable = false)
  private PrsPersona prsPersona;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_modalidad_graduacion")
  private AcaModalidadGraduacion acaModalidadGraduacion;

  @Column(name = "numero_certificado", nullable = false, unique = true, length = 50)
  private String numeroCertificado;

  @Column(name = "fecha_emision", nullable = false)
  private LocalDate fechaEmision;

  @Column(name = "fecha_vencimiento")
  private LocalDate fechaVencimiento;

  @Column(name = "nota_final", precision = 5, scale = 2)
  private BigDecimal notaFinal;

  @Column(name = "promedio_general", precision = 5, scale = 2)
  private BigDecimal promedioGeneral;

  @Column(name = "archivo_pdf_uri", columnDefinition = "TEXT")
  private String archivoPdfUri;

  @Column(name = "hash_verificacion", length = 100)
  private String hashVerificacion;

  @Column(name = "observaciones", columnDefinition = "TEXT")
  private String observaciones;

  @Column(name = "estado_certificado", nullable = false, length = 35)
  private String estadoCertificado; // EMITIDO, ANULADO, REIMPRESO, ELIMINADO

}
