package uap.edu.bo.cpeyfc.domain.prs_persona;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import uap.edu.bo.cpeyfc.config.Auditoria;

import java.time.LocalDate;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "prs_persona")
public class PrsPersona extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_prs_persona", nullable = false)
  private Integer id_prs_persona;

  @Column(name = "nombre", nullable = false, length = 35)
  private String nombre;

  @Column(name = "ap_paterno", nullable = false, length = 55)
  private String ap_paterno;

  @Column(name = "ap_materno", length = 55)
  private String ap_materno;

  @Column(name = "ci", nullable = false, length = 20)
  private String ci;

  @Column(name = "nro_celular", nullable = false, length = 20)
  private String nro_celular;

  @Column(name = "correo", length = 55)
  private String correo;

  @Column(name = "fecha_nacimiento", nullable = false)
  private LocalDate fecha_nacimiento;

  @Column(name = "estado_persona", nullable = false, length = 35)
  private String estado_persona;

}