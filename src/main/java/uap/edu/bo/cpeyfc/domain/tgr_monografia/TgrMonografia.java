package uap.edu.bo.cpeyfc.domain.tgr_monografia;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.ins_matricula.InsMatricula;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "tgr_monografia", indexes = {
  @Index(name = "matricula_presenta_monografias_", columnList = "cod_ins_matricula")
})
public class TgrMonografia extends Auditoria {
  @Id
  @ColumnDefault("nextval('tgr_monografia_id_tgr_monografia_seq')")
  @Column(name = "id_tgr_monografia", nullable = false)
  private Integer idTgrMonografia;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "cod_ins_matricula", nullable = false)
  private InsMatricula insMatricula;

  @Column(name = "titulo_monografia", nullable = false)
  private String tituloMonografia;

  @Column(name = "estado_monografia", nullable = false, length = 35)
  private String estadoMonografia;

  @Column(name = "nota_final", nullable = false)
  private Integer notaFinal;

  @Column(name = "fecha_defensa")
  private LocalDate fechaDefensa;

  @Column(name = "archivo_uri", length = 1)
  private String archivoUri;

}