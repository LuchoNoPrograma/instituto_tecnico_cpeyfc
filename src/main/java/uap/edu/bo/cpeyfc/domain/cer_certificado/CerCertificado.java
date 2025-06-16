package uap.edu.bo.cpeyfc.domain.cer_certificado;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.eje_administrativo.EjeAdministrativo;
import uap.edu.bo.cpeyfc.domain.ins_matricula.InsMatricula;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "cer_certificado", indexes = {
  @Index(name = "administrativo_emite_certificad", columnList = "id_eje_administrativo"),
  @Index(name = "matricula_obtiene_certificados_", columnList = "cod_ins_matricula")
})
public class CerCertificado extends Auditoria {
  @Id
  @ColumnDefault("nextval('cer_certificado_id_cer_certificado_seq')")
  @Column(name = "id_cer_certificado", nullable = false)
  private Integer idCerCertificado;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_eje_administrativo", nullable = false)
  private EjeAdministrativo ejeAdministrativo;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "cod_ins_matricula", nullable = false)
  private InsMatricula insMatricula;

  @Column(name = "tipo_certificado", nullable = false, length = 35)
  private String tipoCertificado;

  @Column(name = "estado_certificado", nullable = false, length = 35)
  private String estadoCertificado;

}