package uap.edu.bo.cpeyfc.domain.aca_parametro_programa;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_programa_aprobado.AcaProgramaAprobado;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_parametro_programa", indexes = {
  @Index(name = "programa_aprobado_define_parame", columnList = "id_aca_programa_aprobado")
})
public class AcaParametroPrograma extends Auditoria {
  @Id
  @ColumnDefault("nextval('aca_parametro_programa_id_aca_parametro_seq')")
  @Column(name = "id_aca_parametro", nullable = false)
  private Integer idAcaParametroPrograma;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_programa_aprobado", nullable = false)
  private AcaProgramaAprobado acaProgramaAprobado;

  @Column(name = "nombre_param", nullable = false, length = 55)
  private String nombreParam;

  @Column(name = "valor", nullable = false, length = Integer.MAX_VALUE)
  private String valor;

  @Column(name = "tipo_dato_param", nullable = false, length = 35)
  private String tipoDatoParam;

  @Column(name = "fecha_inicio_vigencia")
  private LocalDate fechaInicioVigencia;

  @Column(name = "fecha_fin_vigencia")
  private LocalDate fechaFinVigencia;

  @Column(name = "orden", nullable = false)
  private Integer orden;

  @Column(name = "estado_parametro_programa", nullable = false, length = 35)
  private String estadoParametroPrograma;

}