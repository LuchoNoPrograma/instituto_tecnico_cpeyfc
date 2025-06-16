package uap.edu.bo.cpeyfc.domain.seg_designa;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SegDesignaRepository extends JpaRepository<SegDesigna, SegDesignaId> {

  /**
   * Obtiene los nombres de las tareas activas asignadas directamente a un usuario
   */
  @Query("""
        SELECT t.nombreTarea 
        FROM SegDesigna d 
        JOIN d.segTarea t 
        WHERE d.segUsuario.idSegUsuario = :usuarioId 
        AND d.estadoDesigna = 'ACTIVO' 
        AND t.estadoTarea = 'ACTIVO'
        """)
  List<String> findTareasByUsuarioId(@Param("usuarioId") Integer usuarioId);

  /**
   * Obtiene todas las tareas disponibles para un usuario (directas + por roles)
   */
  @Query("""
        SELECT DISTINCT t.nombreTarea 
        FROM SegTarea t 
        WHERE t.estadoTarea = 'ACTIVO' 
        AND (
            t.idSegTarea IN (
                SELECT d.segTarea.idSegTarea 
                FROM SegDesigna d 
                WHERE d.segUsuario.idSegUsuario = :usuarioId 
                AND d.estadoDesigna = 'ACTIVO'
            )
            OR 
            t.segRol.idSegRol IN (
                SELECT o.segRol.idSegRol 
                FROM SegOcupa o 
                WHERE o.segUsuario.idSegUsuario = :usuarioId 
                AND o.estadoOcupa = 'ACTIVO' 
                AND o.segRol.estadoRol = 'ACTIVO'
            )
        )
        """)
  List<String> findAllTareasForUsuario(@Param("usuarioId") Integer usuarioId);

  /**
   * Verifica si un usuario tiene una tarea específica
   */
  @Query("""
        SELECT COUNT(d) > 0 
        FROM SegDesigna d 
        JOIN d.segTarea t 
        WHERE d.segUsuario.idSegUsuario = :usuarioId 
        AND UPPER(t.nombreTarea) = UPPER(:nombreTarea)
        AND d.estadoDesigna = 'ACTIVO' 
        AND t.estadoTarea = 'ACTIVO'
        """)
  boolean hasTarea(@Param("usuarioId") Integer usuarioId, @Param("nombreTarea") String nombreTarea);
}