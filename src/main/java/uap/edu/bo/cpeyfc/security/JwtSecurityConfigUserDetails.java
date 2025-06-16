package uap.edu.bo.cpeyfc.security;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;

import java.util.Collection;


/**
 * Extension of Spring Security User class to store additional data.
 */
@Getter
public class JwtSecurityConfigUserDetails extends User {

  private final Integer idSegUsuario;

  public JwtSecurityConfigUserDetails(final Integer idSegUsuario, final String username, final String hash, final Collection<? extends GrantedAuthority> authorities) {
    super(username, hash, true, true, true, true, authorities);
    this.idSegUsuario = idSegUsuario;
  }

  public JwtSecurityConfigUserDetails(final Integer idSegUsuario, final String username, final String hash, final Collection<? extends GrantedAuthority> authorities, final boolean accountNonExpired, final boolean accountNonLocked, final boolean credentialsNonExpired, final boolean enabled) {
    super(username, hash, enabled, accountNonExpired, credentialsNonExpired, accountNonLocked, authorities);
    this.idSegUsuario = idSegUsuario;
  }
}