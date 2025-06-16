package uap.edu.bo.cpeyfc.domain.seg_usuario;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface SegUsuarioRepository extends JpaRepository<SegUsuario, Integer> {

  /**
   * Busca usuario por nombre de usuario
   */
  Optional<SegUsuario> findByNombreUsuario(String nombreUsuario);

  /**
   * Busca usuario por nombre de usuario ignorando mayúsculas/minúsculas
   */
  @Query("SELECT u FROM SegUsuario u WHERE UPPER(u.nombreUsuario) = UPPER(:nombreUsuario)")
  Optional<SegUsuario> findByNombreUsuarioIgnoreCase(@Param("nombreUsuario") String nombreUsuario);

  /**
   * Verifica si existe un usuario con el nombre dado
   */
  boolean existsByNombreUsuario(String nombreUsuario);

  /**
   * Cuenta usuarios por nombre (para validación de unicidad)
   */
  @Query("SELECT COUNT(u) FROM SegUsuario u WHERE UPPER(u.nombreUsuario) = UPPER(:nombreUsuario)")
  Long countByNombreUsuarioIgnoreCase(@Param("nombreUsuario") String nombreUsuario);
}