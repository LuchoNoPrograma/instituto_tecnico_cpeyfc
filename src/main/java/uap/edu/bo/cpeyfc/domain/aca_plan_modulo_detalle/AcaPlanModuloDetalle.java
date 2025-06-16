package uap.edu.bo.cpeyfc.domain.aca_plan_modulo_detalle;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_modulo.AcaModulo;
import uap.edu.bo.cpeyfc.domain.aca_nivel.AcaNivel;
import uap.edu.bo.cpeyfc.domain.aca_plan_estudio.AcaPlanEstudio;

import java.math.BigDecimal;
import java.sql.Types;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_plan_modulo_detalle", indexes = {
  @Index(name = "nivel_organiza_plan_modulo_deta", columnList = "id_aca_nivel"),
  @Index(name = "plan_estudio_contiene_modulos_d", columnList = "id_aca_plan_estudio"),
  @Index(name = "modulo_esta_en_un_plan_estudio_", columnList = "id_aca_modulo")
})
public class AcaPlanModuloDetalle extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_plan_modulo_detalle_id_aca_plan_modulo_detalle_seq')")
  @Column(name = "id_aca_plan_modulo_detalle", nullable = false)
  private Integer idAcaPlanModuloDetalle;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_nivel", nullable = false)
  private AcaNivel acaNivel;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_plan_estudio", nullable = false)
  private AcaPlanEstudio acaPlanEstudio;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_modulo", nullable = false)
  private AcaModulo acaModulo;

  @Column(name = "carga_horaria", nullable = false)
  private Integer cargaHoraria;

  @Column(name = "creditos", nullable = false, precision = 6, scale = 2)
  private BigDecimal creditos;

  @Column(name = "orden", nullable = false)
  private Integer orden;

  @JdbcTypeCode(Types.CHAR)
  @Column(name = "sigla", nullable = false, columnDefinition = "CHAR(10) NOT NULL")
  private String sigla;

  @Column(name = "competencia", length = Integer.MAX_VALUE)
  private String competencia;

  @Column(name = "estado_plan_modulo_detalle", nullable = false, length = 35)
  private String estadoPlanModuloDetalle;

}