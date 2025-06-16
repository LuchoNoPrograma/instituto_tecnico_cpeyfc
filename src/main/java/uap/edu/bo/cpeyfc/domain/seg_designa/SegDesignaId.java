package uap.edu.bo.cpeyfc.domain.seg_designa;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.Hibernate;

import java.io.Serializable;
import java.util.Objects;

@Getter
@Setter
@Embeddable
public class SegDesignaId implements Serializable {
  private static final long serialVersionUID = 30366053889670316L;
  @Column(name = "id_seg_tarea", nullable = false)
  private Integer idSegTarea;

  @Column(name = "id_seg_usuario", nullable = false)
  private Integer idSegUsuario;

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || Hibernate.getClass(this) != Hibernate.getClass(o)) return false;
    SegDesignaId entity = (SegDesignaId) o;
    return Objects.equals(this.idSegTarea, entity.idSegTarea) &&
           Objects.equals(this.idSegUsuario, entity.idSegUsuario);
  }

  @Override
  public int hashCode() {
    return Objects.hash(idSegTarea, idSegUsuario);
  }

}