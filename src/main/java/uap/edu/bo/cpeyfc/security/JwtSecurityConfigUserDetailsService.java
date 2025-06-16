package uap.edu.bo.cpeyfc.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuario;

import java.util.List;


@Service
@Slf4j
public class JwtSecurityConfigUserDetailsService implements UserDetailsService {

    private final RepositorioGenericoCrud repositorio;

    public JwtSecurityConfigUserDetailsService(final RepositorioGenericoCrud repositorio) {
        this.repositorio = repositorio;
    }

    @Override
    public JwtSecurityConfigUserDetails loadUserByUsername(final String username) {
        final SegUsuario segUsuario = repositorio.buscarPorTexto(SegUsuario.class, SegUsuario.Fields.nombreUsuario, username).get(0);
        if (segUsuario == null) {
            log.warn("user not found: {}", username);
            throw new UsernameNotFoundException("User " + username + " not found");
        }
        final String role = "docente".equals(username) ? UserRoles.DOCENTE : 
                ("administrativo".equals(username) ? UserRoles.ADMINISTRATIVO : 
                ("desarrollo".equals(username) ? UserRoles.DESARROLLO : UserRoles.MATRICULADO));
        final List<SimpleGrantedAuthority> authorities = List.of(new SimpleGrantedAuthority(role));
        return new JwtSecurityConfigUserDetails(segUsuario.getIdSegUsuario(), username, segUsuario.getContrasenaHash(), authorities);
    }

}
