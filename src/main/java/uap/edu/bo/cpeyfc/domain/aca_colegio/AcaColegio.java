package uap.edu.bo.cpeyfc.domain.aca_colegio;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import uap.edu.bo.cpeyfc.config.Auditoria;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_colegio", indexes = {
  @Index(name = "idx_colegio_nombre", columnList = "nombre_colegio"),
  @Index(name = "idx_colegio_tipo", columnList = "tipo_colegio")
})
public class AcaColegio extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_aca_colegio", nullable = false)
  private Integer idAcaColegio;

  @Column(name = "nombre_colegio", nullable = false, length = 200)
  private String nombreColegio;

  @Column(name = "direccion", columnDefinition = "TEXT")
  private String direccion;

  @Column(name = "director_nombre", length = 150)
  private String directorNombre;

  @Column(name = "director_email", length = 100)
  private String directorEmail;

  @Column(name = "telefono", length = 20)
  private String telefono;

  @Column(name = "tipo_colegio", nullable = false, length = 35)
  private String tipoColegio; // PUBLICO, PRIVADO, CONVENIO

  @Column(name = "nivel_educativo", length = 100)
  private String nivelEducativo;

  @Column(name = "estado_colegio", nullable = false, length = 35)
  private String estadoColegio; // ACTIVO, INACTIVO, ELIMINADO

}
