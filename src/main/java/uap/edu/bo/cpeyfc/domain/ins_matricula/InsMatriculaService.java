package uap.edu.bo.cpeyfc.domain.ins_matricula;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class InsMatriculaService {

    private final RepositorioGenericoCrud repositorio;
    private final InsMatriculaRepository insMatriculaRepository;
    private final PasswordEncoder passwordEncoder;

    public String matricularPreinscrito(Integer idPreinscripcion, Integer idGrupo,
                                        String ci, String tipoMatricula, Integer userReg) {
        // Generar credenciales
        String nombreUsuario = ci; // CI como nombre de usuario
        String passwordTemporal = ci + "2025"; // Password temporal
        String passwordEncriptado = passwordEncoder.encode(passwordTemporal);

        String resultado = insMatriculaRepository.matricularPreinscritoCompleto(
                idPreinscripcion,
                idGrupo,
                nombreUsuario,
                passwordEncriptado,
                userReg,
                tipoMatricula
        );

        return resultado + " - Password temporal: " + passwordTemporal;
    }
}
