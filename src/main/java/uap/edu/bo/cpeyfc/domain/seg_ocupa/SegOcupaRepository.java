package uap.edu.bo.cpeyfc.domain.seg_ocupa;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SegOcupaRepository extends JpaRepository<SegOcupa, SegOcupaId> {

  /**
   * Obtiene los nombres de los roles activos de un usuario
   */
  @Query("""
        SELECT r.nombreRol 
        FROM SegOcupa o 
        JOIN o.segRol r 
        WHERE o.segUsuario.idSegUsuario = :usuarioId 
        AND o.estadoOcupa = 'ACTIVO' 
        AND r.estadoRol = 'ACTIVO'
        """)
  List<String> findRolesByUsuarioId(@Param("usuarioId") Integer usuarioId);

  /**
   * Verifica si un usuario tiene un rol específico
   */
  @Query("""
        SELECT COUNT(o) > 0 
        FROM SegOcupa o 
        JOIN o.segRol r 
        WHERE o.segUsuario.idSegUsuario = :usuarioId 
        AND UPPER(r.nombreRol) = UPPER(:nombreRol)
        AND o.estadoOcupa = 'ACTIVO' 
        AND r.estadoRol = 'ACTIVO'
        """)
  boolean hasRole(@Param("usuarioId") Integer usuarioId, @Param("nombreRol") String nombreRol);
}