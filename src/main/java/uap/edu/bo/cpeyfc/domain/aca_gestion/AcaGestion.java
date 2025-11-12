package uap.edu.bo.cpeyfc.domain.aca_gestion;

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
@Table(name = "aca_gestion")
public class AcaGestion extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_aca_gestion", nullable = false)
  private Integer idAcaGestion;

  @Column(name = "anio", nullable = false, unique = true)
  private Integer anio;

  @Column(name = "fecha_inicio", nullable = false)
  private LocalDate fechaInicio;

  @Column(name = "fecha_fin", nullable = false)
  private LocalDate fechaFin;

  @Column(name = "estado_gestion", nullable = false, length = 35)
  private String estadoGestion; // ACTIVO, CERRADO, ELIMINADO

}
