package uap.edu.bo.cpeyfc.security;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.auth0.jwt.interfaces.JWTVerifier;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;


@Service
@Slf4j
public class JwtSecurityConfigTokenService {

    private static final Duration JWT_TOKEN_VALIDITY = Duration.ofMinutes(60);

    private final Algorithm hmac512;
    private final JWTVerifier verifier;

    public JwtSecurityConfigTokenService(@Value("${securityConfig.secret}") final String secret) {
        this.hmac512 = Algorithm.HMAC512(secret);
        this.verifier = JWT.require(this.hmac512).build();
    }

    public String generateToken(final UserDetails userDetails) {
        final Instant now = Instant.now();

        // Obtener ID del usuario si es JwtSecurityConfigUserDetails
        Integer userId = null;
        if (userDetails instanceof JwtSecurityConfigUserDetails) {
            userId = ((JwtSecurityConfigUserDetails) userDetails).getIdSegUsuario();
        }

        // Separar roles y tareas de authorities para claims específicos
        List<String> roles = new ArrayList<>();
        List<String> tareas = new ArrayList<>();

        for (GrantedAuthority authority : userDetails.getAuthorities()) {
            String auth = authority.getAuthority();
            if (auth.startsWith("ROLE_")) {
                roles.add(auth.replace("ROLE_", ""));
            } else if (auth.startsWith("PERM_")) {
                tareas.add(auth.replace("PERM_", ""));
            }
        }

        return JWT.create()
          .withSubject(userDetails.getUsername())
          .withClaim("userId", userId)
          .withArrayClaim("roles", roles.toArray(String[]::new))
          .withArrayClaim("tareas", tareas.toArray(String[]::new))
          // Mantener authorities para compatibilidad con Spring Security
          .withArrayClaim("authorities", userDetails.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .toArray(String[]::new))
          .withIssuer("app")
          .withIssuedAt(now)
          .withExpiresAt(now.plus(JWT_TOKEN_VALIDITY))
          .sign(this.hmac512);
    }

    public DecodedJWT validateToken(final String token) {
        try {
            return verifier.verify(token);
        } catch (final JWTVerificationException verificationEx) {
            log.warn("token invalid: {}", verificationEx.getMessage());
            return null;
        }
    }

}
