package uap.edu.bo.cpeyfc.domain.pub_noticia;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldNameConstants;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import uap.edu.bo.cpeyfc.config.Auditoria;
import uap.edu.bo.cpeyfc.domain.aca_unidad.AcaUnidad;

import java.time.LocalDate;

/**
 * Entidad: pub_noticia
 * Descripción: Noticias institucionales publicadas en carrusel web
 */
@FieldNameConstants
@Getter
@Setter
@Entity
@Table(name = "pub_noticia", indexes = {
    @Index(name = "fk_pub_noticia_unidad", columnList = "id_aca_unidad")
})
public class PubNoticia extends Auditoria {

  /**
   * ID de la noticia
   */
  @Id
  @ColumnDefault("nextval('pub_noticia_id_pub_noticia_seq')")
  @Column(name = "id_pub_noticia", nullable = false)
  private Integer idPubNoticia;

  /**
   * Unidad académica que publica la noticia
   */
  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @OnDelete(action = OnDeleteAction.RESTRICT)
  @JoinColumn(name = "id_aca_unidad", nullable = false)
  private AcaUnidad acaUnidad;

  /**
   * Título de la noticia
   */
  @Column(name = "titulo", nullable = false, length = 255)
  private String titulo;

  /**
   * Resumen o descripción breve de la noticia
   */
  @Column(name = "resumen", nullable = false, columnDefinition = "TEXT")
  private String resumen;

  /**
   * URI/ruta de la imagen de portada
   */
  @Column(name = "imagen_uri", length = 500)
  private String imagenUri;

  /**
   * URL externa para más información (opcional)
   */
  @Column(name = "enlace_externo", length = 500)
  private String enlaceExterno;

  /**
   * Fecha de publicación/vigencia de la noticia
   */
  @Column(name = "fecha_noticia", nullable = false)
  private LocalDate fechaNoticia;

  /**
   * Marca si la noticia debe destacarse en el carrusel
   */
  @ColumnDefault("false")
  @Column(name = "es_destacada")
  private Boolean esDestacada;

  /**
   * Orden de prioridad para ordenamiento (mayor = más prioritario)
   */
  @ColumnDefault("0")
  @Column(name = "orden_prioridad")
  private Integer ordenPrioridad;

  /**
   * Estado de la noticia (ACTIVO, INACTIVO, ELIMINADO)
   */
  @Column(name = "estado_noticia", nullable = false, length = 35)
  private String estadoNoticia;
}
