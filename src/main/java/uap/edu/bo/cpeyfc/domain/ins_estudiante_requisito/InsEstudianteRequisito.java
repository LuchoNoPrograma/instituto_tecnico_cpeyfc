package uap.edu.bo.cpeyfc.domain.ins_estudiante_requisito;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_requisito.AcaRequisito;
import uap.edu.bo.cpeyfc.domain.ins_matricula.InsMatricula;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "ins_estudiante_requisito")
public class InsEstudianteRequisito extends Auditoria {
  @Id
  @ColumnDefault("nextval('ins_estudiante_requisito_id_ins_estudiante_requisito_seq')")
  @Column(name = "id_ins_estudiante_requisito", nullable = false)
  private Integer idInsEstudianteRequisito;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "cod_ins_matricula", nullable = false)
  private InsMatricula insMatricula;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "id_aca_requisito", nullable = false)
  private AcaRequisito acaRequisito;

  @Column(name = "fecha_presentacion")
  private LocalDate fechaPresentacion;

  @ColumnDefault("false")
  @Column(name = "esta_verificado")
  private Boolean estaVerificado;

  @Column(name = "observaciones", columnDefinition = "TEXT")
  private String observaciones;

  @Column(name = "ruta_documento", length = 255)
  private String rutaDocumento;

  @Column(name = "estado_estudiante_requisito", nullable = false, length = 35)
  private String estadoEstudianteRequisito;

}
