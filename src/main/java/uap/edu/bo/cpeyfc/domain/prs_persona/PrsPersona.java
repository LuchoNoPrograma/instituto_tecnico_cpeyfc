package uap.edu.bo.cpeyfc.domain.prs_persona;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import uap.edu.bo.cpeyfc.config.Auditoria;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "prs_persona")
public class PrsPersona extends Auditoria {
  @Id
  @ColumnDefault("nextval('prs_persona_id_prs_persona_seq')")
  @Column(name = "id_prs_persona", nullable = false)
  private Integer idPrsPersona;

  @Column(name = "nombre", nullable = false, length = 35)
  private String nombre;

  @Column(name = "ap_paterno", nullable = false, length = 55)
  private String apPaterno;

  @Column(name = "ap_materno", length = 55)
  private String apMaterno;

  @Column(name = "ci", nullable = false, length = 20)
  private String ci;

  @Column(name = "nro_celular", nullable = false, length = 20)
  private String nroCelular;

  @Column(name = "correo", length = 55)
  private String correo;

  @Column(name = "fecha_nacimiento", nullable = false)
  private LocalDate fechaNacimiento;

  @Column(name = "estado_persona", nullable = false, length = 35)
  private String estadoPersona;

}