package uap.edu.bo.cpeyfc.config;

import com.auth0.jwt.exceptions.TokenExpiredException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.filter.OncePerRequestFilter;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigTokenService;

@Slf4j
public class JwtRequestFilter extends OncePerRequestFilter {

    private final UserDetailsService userDetailsService;
    private final JwtSecurityConfigTokenService jwtSecurityConfigTokenService;
    private final ObjectMapper objectMapper;

    public JwtRequestFilter(final UserDetailsService userDetailsService,
                            final JwtSecurityConfigTokenService jwtSecurityConfigTokenService) {
        this.userDetailsService = userDetailsService;
        this.jwtSecurityConfigTokenService = jwtSecurityConfigTokenService;
        this.objectMapper = new ObjectMapper();
    }

    @Override
    protected void doFilterInternal(final HttpServletRequest request,
                                    final HttpServletResponse response, final FilterChain chain) throws IOException,
      ServletException {

        final String header = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (header == null || !header.startsWith("Bearer ")) {
            chain.doFilter(request, response);
            return;
        }

        final String token = header.substring(7);

        try {
            final DecodedJWT jwt = jwtSecurityConfigTokenService.validateToken(token);

            if (jwt == null || jwt.getSubject() == null) {
                chain.doFilter(request, response);
                return;
            }

            final UserDetails userDetails;
            try {
                userDetails = userDetailsService.loadUserByUsername(jwt.getSubject());
            } catch (final UsernameNotFoundException userNotFoundEx) {
                chain.doFilter(request, response);
                return;
            }

            final UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
              userDetails, null, userDetails.getAuthorities());
            authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authentication);

            chain.doFilter(request, response);

        } catch (TokenExpiredException ex) {
            log.warn("🔒 Token expirado detectado: {}", ex.getMessage());

            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setCharacterEncoding("UTF-8");

            Map<String, Object> errorResponse = Map.of(
              "error", "Token Expirado",
              "message", "Tu sesión ha caducado. Por favor, inicia sesión nuevamente.",
              "token_expired", true,
              "timestamp", System.currentTimeMillis()
            );

            response.getWriter().write(objectMapper.writeValueAsString(errorResponse));
            response.getWriter().flush();
        }
    }
}