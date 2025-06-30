package uap.edu.bo.cpeyfc.domain.ins_matricula;

import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.Map;

@Log4j2
@Service
@RequiredArgsConstructor
public class InsMatriculaService {

    private final RepositorioGenericoCrud repositorio;
    private final InsMatriculaRepository insMatriculaRepository;
    private final PasswordEncoder passwordEncoder;

    public String matricularPreinscrito(Integer idPreinscripcion, Integer idGrupo, Integer userReg) {
        Map<String, Object> resultado = insMatriculaRepository.matricularPreinscritoCompleto(idPreinscripcion, idGrupo, userReg);

        Boolean usuarioExistia = (Boolean) resultado.get("usuario_existia");
        String mensaje = (String) resultado.get("mensaje");

        if (!usuarioExistia) {
            String passwordTemporal = (String) resultado.get("password_temporal");
            Integer idUsuario = (Integer) resultado.get("id_usuario");

            String passwordHash = passwordEncoder.encode(passwordTemporal);
            String confirmado = insMatriculaRepository.activarUsuarioMatricula(idUsuario, passwordHash);
            log.info(confirmado);
            return mensaje + " - Password temporal: " + passwordTemporal;
        }

        return mensaje + " - Usuario existente utilizado";
    }
}
