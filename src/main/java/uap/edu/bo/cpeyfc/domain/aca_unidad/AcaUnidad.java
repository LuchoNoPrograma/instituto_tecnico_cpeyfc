package uap.edu.bo.cpeyfc.domain.aca_unidad;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import uap.edu.bo.cpeyfc.config.Auditoria;

/**
 * Entidad: aca_unidad
 * Descripción: Catálogo de unidades académicas y administrativas de la institución
 */
@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "aca_unidad")
public class AcaUnidad extends Auditoria {

  /**
   * ID de la unidad académica
   */
  @Id
  @ColumnDefault("nextval('aca_unidad_id_aca_unidad_seq')")
  @Column(name = "id_aca_unidad", nullable = false)
  private Integer idAcaUnidad;

  /**
   * Nombre de la unidad (Ej: Escuela Técnica, Gabinete Psicopedagógico)
   */
  @Column(name = "nombre_unidad", nullable = false, length = 100)
  private String nombreUnidad;

  /**
   * Descripción opcional de la unidad
   */
  @Column(name = "descripcion", columnDefinition = "TEXT")
  private String descripcion;

  /**
   * Estado de la unidad (ACTIVO, ELIMINADO)
   */
  @Column(name = "estado_unidad", nullable = false, length = 35)
  private String estadoUnidad;
}
