package uap.edu.bo.cpeyfc.domain.eje_cronograma_modulo;

import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.time.LocalDate;
import java.util.Map;

@Log4j2
@Service
@RequiredArgsConstructor
public class EjeCronogramaModuloService {

    private final RepositorioGenericoCrud repositorio;
    private final EjeCronogramaModuloRepository ejeCronogramaModuloRepository;
    private final PasswordEncoder passwordEncoder;

    public String modificarCronogramaModulo(Integer idCronograma, Integer idPersona, LocalDate fechaInicio, LocalDate fechaFin, Integer userMod) {
        Map<String, Object> resultado = ejeCronogramaModuloRepository.modificarCronogramaModulo(idCronograma, idPersona, fechaInicio, fechaFin, userMod);

        Boolean usuarioExistia = (Boolean) resultado.get("usuario_existia");
        String mensaje = (String) resultado.get("mensaje");

        if (!usuarioExistia && resultado.get("id_usuario") != null) {
            String passwordTemporal = (String) resultado.get("password_temporal");
            Integer idUsuario = (Integer) resultado.get("id_usuario");
            String ciPersona = (String) resultado.get("ci_persona");

            if (passwordTemporal != null) {
                String passwordHash = passwordEncoder.encode(passwordTemporal);
                String confirmado = ejeCronogramaModuloRepository.activarUsuarioDocente(idUsuario, passwordHash);
                log.info(confirmado);
                return mensaje + " - Docente creado - CI: " + ciPersona + " - Password temporal: " + passwordTemporal;
            }
        }

        return mensaje + (usuarioExistia ? " - Docente existente asignado" : "");
    }
}
