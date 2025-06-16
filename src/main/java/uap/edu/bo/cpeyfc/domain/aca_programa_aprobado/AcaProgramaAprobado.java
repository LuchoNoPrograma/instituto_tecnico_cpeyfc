package uap.edu.bo.cpeyfc.domain.aca_programa_aprobado;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_modalidad.AcaModalidad;
import uap.edu.bo.cpeyfc.domain.aca_plan_estudio.AcaPlanEstudio;
import uap.edu.bo.cpeyfc.domain.aca_programa.AcaPrograma;
import uap.edu.bo.cpeyfc.domain.aca_version.AcaVersion;

import java.math.BigDecimal;
import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_programa_aprobado", indexes = {
  @Index(name = "programa_tiene_modalidad_fk", columnList = "id_aca_modalidad"),
  @Index(name = "programa_puede_ser_aprobado_fk", columnList = "id_aca_programa"),
  @Index(name = "programa_es_aprobado_con_plan_e", columnList = "id_aca_plan_estudio"),
  @Index(name = "programa_tiene_version_ceub_fk", columnList = "id_aca_version")
})
public class AcaProgramaAprobado extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_programa_aprobado_id_aca_programa_aprobado_seq')")
  @Column(name = "id_aca_programa_aprobado", nullable = false)
  private Integer idAcaProgramaAprobado;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_modalidad", nullable = false)
  private AcaModalidad acaModalidad;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_programa", nullable = false)
  private AcaPrograma acaPrograma;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_plan_estudio")
  private AcaPlanEstudio acaPlanEstudio;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_version", nullable = false)
  private AcaVersion acaVersion;

  @Column(name = "fecha_inicio_vigencia")
  private LocalDate fechaInicioVigencia;

  @Column(name = "fecha_fin_vigencia")
  private LocalDate fechaFinVigencia;

  @Column(name = "estado_programa_aprobado", nullable = false, length = 35)
  private String estadoProgramaAprobado;

  @Column(name = "gestion", nullable = false)
  private Integer gestion;

  @Column(name = "cod_certificado_ceub", length = 55)
  private String codCertificadoCeub;

  @Column(name = "cod_sigla_version", length = 15)
  private String codSiglaVersion;

  @Column(name = "precio_matricula", nullable = false, precision = 8, scale = 2)
  private BigDecimal precioMatricula;

  @Column(name = "precio_colegiatura", nullable = false, precision = 8, scale = 2)
  private BigDecimal precioColegiatura;

  @Column(name = "precio_titulacion", precision = 8, scale = 2)
  private BigDecimal precioTitulacion;

}