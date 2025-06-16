package uap.edu.bo.cpeyfc.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuario;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuarioRepository;
import uap.edu.bo.cpeyfc.domain.seg_ocupa.SegOcupaRepository;
import uap.edu.bo.cpeyfc.domain.seg_designa.SegDesignaRepository;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;


@Service
@Slf4j
public class JwtSecurityConfigUserDetailsService implements UserDetailsService {

    private final SegUsuarioRepository segUsuarioRepository;
    private final SegOcupaRepository segOcupaRepository;
    private final SegDesignaRepository segDesignaRepository;

    public JwtSecurityConfigUserDetailsService(
      final SegUsuarioRepository segUsuarioRepository,
      final SegOcupaRepository segOcupaRepository,
      final SegDesignaRepository segDesignaRepository) {
        this.segUsuarioRepository = segUsuarioRepository;
        this.segOcupaRepository = segOcupaRepository;
        this.segDesignaRepository = segDesignaRepository;
    }

    @Override
    public JwtSecurityConfigUserDetails loadUserByUsername(final String username) {
        log.debug("Cargando usuario: {}", username);

        final SegUsuario segUsuario = segUsuarioRepository
          .findByNombreUsuario(username)
          .orElseThrow(() -> {
              log.warn("Usuario no encontrado: {}", username);
              return new UsernameNotFoundException("Usuario no encontrado: " + username);
          });

        // Verificar que el usuario esté activo
        if (!"ACTIVO".equals(segUsuario.getEstadoUsuario())) {
            log.warn("Usuario inactivo: {}", username);
            throw new UsernameNotFoundException("Usuario inactivo: " + username);
        }

        // Obtener authorities (roles y tareas)
        final Collection<GrantedAuthority> authorities = getAuthorities(segUsuario.getIdSegUsuario());

        log.debug("Usuario {} cargado con {} authorities", username, authorities.size());

        return new JwtSecurityConfigUserDetails(
          segUsuario.getIdSegUsuario(),
          segUsuario.getNombreUsuario(),
          segUsuario.getContrasenaHash(),
          authorities
        );
    }

    private Collection<GrantedAuthority> getAuthorities(Integer usuarioId) {
        List<GrantedAuthority> authorities = new ArrayList<>();

        try {
            // Obtener roles del usuario y agregarlos con prefijo ROLE_
            List<String> roles = segOcupaRepository.findRolesByUsuarioId(usuarioId);
            for (String rol : roles) {
                authorities.add(new SimpleGrantedAuthority("ROLE_" + rol.toUpperCase()));
                log.debug("Agregado rol: ROLE_{}", rol.toUpperCase());
            }

            // Obtener tareas/permisos del usuario (directas + por roles)
            List<String> tareas = segDesignaRepository.findAllTareasForUsuario(usuarioId);
            for (String tarea : tareas) {
                authorities.add(new SimpleGrantedAuthority("PERM_" + tarea.toUpperCase()));
                log.debug("Agregado permiso: PERM_{}", tarea.toUpperCase());
            }
        } catch (Exception e) {
            log.warn("Error obteniendo authorities para usuario {}, asignando rol por defecto", usuarioId, e);
        }

        // Si no tiene ningún rol/tarea, asignar rol por defecto
        if (authorities.isEmpty()) {
            log.warn("Usuario {} sin roles ni tareas asignadas, asignando rol por defecto", usuarioId);
            authorities.add(new SimpleGrantedAuthority("ROLE_MATRICULADO"));
        }

        return authorities;
    }
}