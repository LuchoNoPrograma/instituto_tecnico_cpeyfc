package uap.edu.bo.cpeyfc.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.wimdeblauwe.errorhandlingspringbootstarter.UnauthorizedEntryPoint;
import io.github.wimdeblauwe.errorhandlingspringbootstarter.mapper.ErrorCodeMapper;
import io.github.wimdeblauwe.errorhandlingspringbootstarter.mapper.ErrorMessageMapper;
import io.github.wimdeblauwe.errorhandlingspringbootstarter.mapper.HttpStatusMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigTokenService;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetailsService;

import java.util.Arrays;


@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)
@Slf4j
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        // creates hashes with {bcrypt} prefix
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(
      final AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public JwtRequestFilter jwtRequestFilter(
      final JwtSecurityConfigUserDetailsService jwtSecurityConfigUserDetailsService,
      final JwtSecurityConfigTokenService jwtSecurityConfigTokenService) {
        log.info("Configurando JwtRequestFilter con sistema de roles dinámico");
        return new JwtRequestFilter(jwtSecurityConfigUserDetailsService, jwtSecurityConfigTokenService);
    }

    @Bean
    public UnauthorizedEntryPoint unauthorizedEntryPoint(final HttpStatusMapper httpStatusMapper,
                                                         final ErrorCodeMapper errorCodeMapper, final ErrorMessageMapper errorMessageMapper,
                                                         final ObjectMapper objectMapper) {
        return new UnauthorizedEntryPoint(httpStatusMapper, errorCodeMapper, errorMessageMapper, objectMapper);
    }

    @Bean
    public SecurityFilterChain securityConfigFilterChain(final HttpSecurity http,
                                                         final UnauthorizedEntryPoint unauthorizedEntryPoint,
                                                         final JwtRequestFilter jwtRequestFilter) throws Exception {

        log.info("Configurando SecurityFilterChain con autorización basada en roles y tareas de BD");

        return http
          .cors(cors -> cors.configurationSource(corsConfigurationSource()))
          .csrf(csrf -> csrf.ignoringRequestMatchers("/actuator/**", "/authenticate", "/register", "/api/**"))
          .authorizeHttpRequests(authorize -> authorize
            // Endpoints públicos
            .requestMatchers("/authenticate", "/register").permitAll()
            .requestMatchers("/actuator/**").permitAll()
            .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()

            // Endpoints protegidos - ahora usando el sistema dinámico
            .requestMatchers("/admin/**").hasRole("ADMINISTRATIVO")
            .requestMatchers("/docente/**").hasRole("DOCENTE")
            .requestMatchers("/estudiante/**").hasRole("MATRICULADO")
            .requestMatchers("/desarrollo/**").hasRole("DESARROLLO")
            .requestMatchers("/", "/login", "/dashboard", "/admin/**").permitAll()
            .requestMatchers("/css/**", "/js/**", "/images/**", "/webjars/**").permitAll()
            .requestMatchers("/api/auth/check", "/api/auth/user-info").authenticated()
            .anyRequest().permitAll()
          )
          .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
          .exceptionHandling(exception -> exception.authenticationEntryPoint(unauthorizedEntryPoint))
          .addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class)
          .build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Permitir el origen del frontend Vue
        configuration.setAllowedOrigins(Arrays.asList(
          "http://localhost:5173",  // Vite dev server
          "http://localhost:3000",  // Si usas otro puerto
          "http://127.0.0.1:5173"   // Alternativa localhost
        ));

        // Métodos HTTP permitidos
        configuration.setAllowedMethods(Arrays.asList(
          "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"
        ));

        // Headers permitidos
        configuration.setAllowedHeaders(Arrays.asList("*"));

        // Permitir credenciales (importante para JWT)
        configuration.setAllowCredentials(true);

        // Tiempo de cache para preflight requests
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

}