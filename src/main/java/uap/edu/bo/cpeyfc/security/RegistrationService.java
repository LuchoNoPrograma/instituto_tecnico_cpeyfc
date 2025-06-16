package uap.edu.bo.cpeyfc.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuario;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuarioRepository;

import java.time.LocalDateTime;


@Service
@Slf4j
public class RegistrationService {

    private final SegUsuarioRepository segUsuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public RegistrationService(final SegUsuarioRepository segUsuarioRepository,
                               final PasswordEncoder passwordEncoder) {
        this.segUsuarioRepository = segUsuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public void register(final RegistrationRequest registrationRequest) {
        log.info("Registrando nuevo usuario: {}", registrationRequest.getNombreUsuario());

        // Verificar que el usuario no exista
        if (nombreUsuarioExists(registrationRequest.getNombreUsuario())) {
            throw new IllegalArgumentException("El nombre de usuario ya existe: " + registrationRequest.getNombreUsuario());
        }

        final SegUsuario segUsuario = new SegUsuario();
        segUsuario.setNombreUsuario(registrationRequest.getNombreUsuario());
        segUsuario.setContrasenaHash(passwordEncoder.encode(registrationRequest.getPassword()));
        segUsuario.setEstadoUsuario(registrationRequest.getEstadoUsuario());

        // Los campos de auditoría se establecen automáticamente por AuditoriaConfig
        segUsuario.setFechaReg(LocalDateTime.now());

        segUsuarioRepository.save(segUsuario);

        log.info("Usuario registrado exitosamente: {}", registrationRequest.getNombreUsuario());
    }

    public boolean nombreUsuarioExists(final String nombreUsuario) {
        Long count = segUsuarioRepository.countByNombreUsuarioIgnoreCase(nombreUsuario);
        return count > 0;
    }
}