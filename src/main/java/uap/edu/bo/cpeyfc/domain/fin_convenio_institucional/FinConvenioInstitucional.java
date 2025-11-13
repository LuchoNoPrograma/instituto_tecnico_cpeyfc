package uap.edu.bo.cpeyfc.domain.fin_convenio_institucional;

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
@Table(name = "fin_convenio_institucional", indexes = {
  @Index(name = "idx_convenio_institucion", columnList = "nombre_institucion"),
  @Index(name = "idx_convenio_vigencia", columnList = "fecha_inicio_convenio, fecha_fin_convenio")
})
public class FinConvenioInstitucional extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_convenio", nullable = false)
  private Integer idConvenio;

  @Column(name = "nombre_institucion", nullable = false, length = 200)
  private String nombreInstitucion;

  @Column(name = "tipo_institucion", nullable = false, length = 50)
  private String tipoInstitucion;

  @Column(name = "nit", length = 20)
  private String nit;

  @Column(name = "contacto_nombre", length = 150)
  private String contactoNombre;

  @Column(name = "contacto_telefono", length = 20)
  private String contactoTelefono;

  @Column(name = "contacto_email", length = 100)
  private String contactoEmail;

  @Column(name = "fecha_inicio_convenio", nullable = false)
  private LocalDate fechaInicioConvenio;

  @Column(name = "fecha_fin_convenio")
  private LocalDate fechaFinConvenio;

  @Column(name = "observaciones", columnDefinition = "TEXT")
  private String observaciones;

  @Column(name = "estado_convenio", nullable = false, length = 20)
  private String estadoConvenio;
}
