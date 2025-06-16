package uap.edu.bo.cpeyfc.domain.cer_titulacion;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.ins_matricula.InsMatricula;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "cer_titulacion", indexes = {
  @Index(name = "matricula_obtiene_titulacion_fk", columnList = "cod_ins_matricula")
})
public class CerTitulacion extends Auditoria {
  @Id
  @ColumnDefault("nextval('cer_titulacion_id_cer_titulacion_seq')")
  @Column(name = "id_cer_titulacion", nullable = false)
  private Integer idCerTitulacion;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "cod_ins_matricula", nullable = false)
  private InsMatricula insMatricula;

  @Column(name = "cod_titulo", nullable = false, length = 25)
  private String codTitulo;

  @Column(name = "uri_titulo", nullable = false, length = 1)
  private String uriTitulo;

  @Column(name = "estado_titulacion", nullable = false, length = 35)
  private String estadoTitulacion;

}