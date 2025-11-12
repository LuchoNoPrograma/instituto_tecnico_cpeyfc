package uap.edu.bo.cpeyfc.domain.prs_persona;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
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

  // Relación recursiva: apoderado/tutor
  @ManyToOne(fetch = FetchType.LAZY)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_prs_persona_apoderado")
  private PrsPersona apoderado;

  @Column(name = "tipo_relacion_apoderado", length = 50)
  private String tipoRelacionApoderado; // PADRE, MADRE, TUTOR, etc.

  @Column(name = "telefono_apoderado", length = 20)
  private String telefonoApoderado;

  @Column(name = "email_apoderado", length = 100)
  private String emailApoderado;

  // Colegio de procedencia (se creará después la entity AcaColegio)
  @Column(name = "id_aca_colegio_procedencia")
  private Integer idAcaColegioProcedencia;

}