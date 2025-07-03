package uap.edu.bo.cpeyfc.security;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;


@RestController
@RequiredArgsConstructor
public class AuthenticationApi {

    private final AuthenticationManager authenticationManager;
    private final JwtSecurityConfigUserDetailsService jwtSecurityConfigUserDetailsService;
    private final JwtSecurityConfigTokenService jwtSecurityConfigTokenService;
    private final PasswordEncoder passwordEncoder;
    private final ResetPasswordRepository resetPasswordRepository;

    @PostMapping("/api/authenticate")
    public AuthenticationResponse authenticate(
            @RequestBody @Valid final AuthenticationRequest authenticationRequest) {
        try {
            authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(
                    authenticationRequest.getNombreUsuario(), authenticationRequest.getPassword()));
        } catch (final BadCredentialsException ex) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }

        final JwtSecurityConfigUserDetails userDetails = jwtSecurityConfigUserDetailsService.loadUserByUsername(authenticationRequest.getNombreUsuario());
        final AuthenticationResponse authenticationResponse = new AuthenticationResponse();
        authenticationResponse.setAccessToken(jwtSecurityConfigTokenService.generateToken(userDetails));
        return authenticationResponse;
    }

    @GetMapping("/api/usuario/reset-password/{idUsuario}")
    public ResponseEntity<?> resetPasswordPorId(@PathVariable Integer idUsuario) {
        try {
            // Obtener CI
            String ci = resetPasswordRepository.obtenerCIPorUsuario(idUsuario);

            if (ci == null || ci.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "No se encontró CI para el usuario ID: " + idUsuario));
            }

            // Encriptar contraseña
            String passwordHash = passwordEncoder.encode(ci);

            // Actualizar usuario
            Integer filasAfectadas = resetPasswordRepository.actualizarPasswordPorId(idUsuario, passwordHash);

            if (filasAfectadas == 0) {
                return ResponseEntity.badRequest().body(Map.of("error", "No se pudo actualizar el usuario ID: " + idUsuario));
            }

            return ResponseEntity.ok(Map.of("mensaje", "Contraseña actualizada exitosamente para usuario ID: " + idUsuario + " - Nueva contraseña: " + ci));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }


}
