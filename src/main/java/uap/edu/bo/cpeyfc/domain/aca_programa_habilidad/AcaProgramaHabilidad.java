package uap.edu.bo.cpeyfc.domain.aca_programa_habilidad;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "aca_programa_habilidad")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AcaProgramaHabilidad {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_programa_habilidad")
  private Integer idProgramaHabilidad;

  @Column(name = "id_aca_programa", nullable = false)
  private Integer idAcaPrograma;

  @Column(name = "nombre_habilidad", nullable = false, length = 100)
  private String nombreHabilidad;

  @Column(name = "estado_programa_habilidad", nullable = false, length = 20)
  private String estadoProgramaHabilidad;

  @Column(name = "fecha_reg", nullable = false)
  private LocalDateTime fechaReg;

  @Column(name = "user_reg", nullable = false)
  private Integer userReg;

  @Column(name = "fecha_mod")
  private LocalDateTime fechaMod;

  @Column(name = "user_mod")
  private Integer userMod;
}