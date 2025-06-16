package uap.edu.bo.cpeyfc.domain.seg_ocupa;

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
public class SegOcupaId implements Serializable {
  private static final long serialVersionUID = 1564878401622328061L;
  @Column(name = "id_seg_rol", nullable = false)
  private Integer idSegRol;

  @Column(name = "id_seg_usuario", nullable = false)
  private Integer idSegUsuario;

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || Hibernate.getClass(this) != Hibernate.getClass(o)) return false;
    SegOcupaId entity = (SegOcupaId) o;
    return Objects.equals(this.idSegRol, entity.idSegRol) &&
           Objects.equals(this.idSegUsuario, entity.idSegUsuario);
  }

  @Override
  public int hashCode() {
    return Objects.hash(idSegRol, idSegUsuario);
  }

}