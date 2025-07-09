package uap.edu.bo.cpeyfc.security;

import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuario;

public interface ResetPasswordRepository extends JpaRepository<SegUsuario, Integer> {
  @Query(value = """
        SELECT COALESCE(p.ci, '') as ci
        FROM seg_usuario u
        LEFT JOIN eje_docente d ON u.id_seg_usuario = d.id_seg_usuario AND d.estado_docente != 'ELIMINADO'
        LEFT JOIN eje_administrativo a ON u.id_seg_usuario = a.id_seg_usuario AND a.estado_administrativo != 'ELIMINADO'
        LEFT JOIN ins_matricula m ON u.id_seg_usuario = m.id_seg_usuario AND m.estado_matricula != 'ELIMINADO'
        LEFT JOIN prs_persona p ON (d.id_prs_persona = p.id_prs_persona OR a.id_prs_persona = p.id_prs_persona OR m.id_prs_persona = p.id_prs_persona)
        WHERE u.id_seg_usuario = :id_usuario
        AND u.estado_usuario != 'ELIMINADO'
        AND p.estado_persona != 'ELIMINADO'
        LIMIT 1
        """, nativeQuery = true)
  String obtenerCIPorUsuario(Integer id_usuario);

  @Modifying
  @Transactional
  @Query(value = """
        UPDATE seg_usuario
        SET contrasena_hash = :password_hash,
            estado_usuario = 'ACTIVO',
            fecha_mod = NOW(),
            user_mod = 1
        WHERE id_seg_usuario = :id_usuario
        AND estado_usuario != 'ELIMINADO'
        """, nativeQuery = true)
  Integer actualizarPasswordPorId(Integer id_usuario, String password_hash);
}