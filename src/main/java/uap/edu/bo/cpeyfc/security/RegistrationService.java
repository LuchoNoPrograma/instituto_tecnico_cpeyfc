package uap.edu.bo.cpeyfc.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuario;

import java.util.List;


@Service
@Slf4j
public class RegistrationService {

    private final RepositorioGenericoCrud repositorio;
    private final PasswordEncoder passwordEncoder;

    public RegistrationService(final RepositorioGenericoCrud repositorio, final PasswordEncoder passwordEncoder) {
      this.repositorio = repositorio;
      this.passwordEncoder = passwordEncoder;
    }

    public void register(final RegistrationRequest registrationRequest) {
        log.info("registering new user: {}", registrationRequest.getNombreUsuario());

        final SegUsuario segUsuario = new SegUsuario();
        segUsuario.setNombreUsuario(registrationRequest.getNombreUsuario());
        segUsuario.setContrasenaHash(passwordEncoder.encode(registrationRequest.getPassword()));
        segUsuario.setEstadoUsuario(registrationRequest.getEstadoUsuario());
        repositorio.guardar(segUsuario);
    }

    public boolean nombreUsuarioExists(final String nombreUsuario) {
        String jpql = "SELECT COUNT(u) FROM SegUsuario u WHERE UPPER(u.nombreUsuario) = UPPER(?1)";
        List<Long> resultado = repositorio.ejecutarJpql(jpql, Long.class, nombreUsuario);
        return resultado.get(0) > 0;
    }

}
