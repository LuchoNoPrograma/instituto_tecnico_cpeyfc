package uap.edu.bo.cpeyfc.security;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;


@RestController
public class AuthenticationApi {

    private final AuthenticationManager authenticationManager;
    private final JwtSecurityConfigUserDetailsService jwtSecurityConfigUserDetailsService;
    private final JwtSecurityConfigTokenService jwtSecurityConfigTokenService;

    public AuthenticationApi(final AuthenticationManager authenticationManager,
                             final JwtSecurityConfigUserDetailsService jwtSecurityConfigUserDetailsService,
                             final JwtSecurityConfigTokenService jwtSecurityConfigTokenService) {
        this.authenticationManager = authenticationManager;
        this.jwtSecurityConfigUserDetailsService = jwtSecurityConfigUserDetailsService;
        this.jwtSecurityConfigTokenService = jwtSecurityConfigTokenService;
    }

    @PostMapping("/authenticate")
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

}
