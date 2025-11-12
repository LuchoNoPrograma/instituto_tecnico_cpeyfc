package uap.edu.bo.cpeyfc.domain.aca_titulo_certificado;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import uap.edu.bo.cpeyfc.config.Auditoria;

@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_titulo_certificado")
public class AcaTituloCertificado extends Auditoria {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_aca_titulo_certificado", nullable = false)
  private Integer idAcaTituloCertificado;

  @Column(name = "nombre_titulo", nullable = false, unique = true, length = 200)
  private String nombreTitulo;

  @Column(name = "tipo_certificacion", nullable = false, length = 50)
  private String tipoCertificacion; // TITULO, CERTIFICADO, DIPLOMA, CONSTANCIA

  @Column(name = "nivel_academico", nullable = false, length = 50)
  private String nivelAcademico; // TECNICO_MEDIO, TECNICO_SUPERIOR, LICENCIATURA, CURSO_CORTO, DIPLOMADO

  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  @Column(name = "requiere_creditos_minimos")
  private Integer requireCreditosMinimos;

  @Column(name = "requiere_horas_minimas")
  private Integer requiereHorasMinimas;

  @Column(name = "estado_titulo", nullable = false, length = 35)
  private String estadoTitulo; // ACTIVO, INACTIVO, ELIMINADO

}
