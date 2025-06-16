package uap.edu.bo.cpeyfc.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.Optional;

@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
public class AuditoriaConfig {

  @Bean
  public AuditorAware<Integer> auditorProvider() {
    return new SecurityAuditorAware();
  }

  public static class SecurityAuditorAware implements AuditorAware<Integer> {

    @Override
    public Optional<Integer> getCurrentAuditor() {
      Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

      if (authentication == null || !authentication.isAuthenticated() ||
          "anonymousUser".equals(authentication.getPrincipal())) {
        // Usuario por defecto para operaciones del sistema
        return Optional.of(1);
      }

      if (authentication.getPrincipal() instanceof JwtSecurityConfigUserDetails userDetails) {
        return Optional.of(userDetails.getIdSegUsuario());
      }

      // Fallback para usuario sistema
      return Optional.of(1);
    }
  }
}