package uap.edu.bo.cpeyfc.domain.tgr_revision_monografia;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.eje_administrativo.EjeAdministrativo;
import uap.edu.bo.cpeyfc.domain.eje_docente.EjeDocente;
import uap.edu.bo.cpeyfc.domain.tgr_monografia.TgrMonografia;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "tgr_revision_monografia", indexes = {
  @Index(name = "monografia_es_revisada_fk", columnList = "id_tgr_monografia"),
  @Index(name = "revisado_por_administrativo_fk", columnList = "id_eje_administrativo"),
  @Index(name = "revisado_por_un_docente_fk", columnList = "id_eje_docente")
})
public class TgrRevisionMonografia extends Auditoria {
  @Id
  @ColumnDefault("nextval('tgr_revision_monografia_id_tgr_revision_monografia_seq')")
  @Column(name = "id_tgr_revision_monografia", nullable = false)
  private Integer idTgrRevisionMonografia;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_tgr_monografia", nullable = false)
  private TgrMonografia tgrMonografia;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_eje_administrativo")
  private EjeAdministrativo ejeAdministrativo;

  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_eje_docente")
  private EjeDocente ejeDocente;

  @Column(name = "fecha_hora_designacion", nullable = false)
  private LocalDate fechaHoraDesignacion;

  @Column(name = "es_aprobador_final")
  private Boolean esAprobadorFinal;

  @Column(name = "fecha_hora_revision")
  private LocalDate fechaHoraRevision;

  @Column(name = "estado_revision_monografia", nullable = false, length = 35)
  private String estadoRevisionMonografia;

}