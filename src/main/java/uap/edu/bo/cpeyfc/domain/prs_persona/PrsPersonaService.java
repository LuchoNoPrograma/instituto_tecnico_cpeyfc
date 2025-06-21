package uap.edu.bo.cpeyfc.domain.prs_persona;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PrsPersonaService {

    private final RepositorioGenericoCrud repositorio;
    private final PrsPersonaRepository prsPersonaRepository;

    public List<Map<String, Object>> vistaPersonasActivas(){
        return prsPersonaRepository.vistaPersonasActivas();
    }

    public String registrarPersona(String nombre, String ap_paterno, String ap_materno,
                                   String ci, String nro_celular, String correo,
                                   LocalDate fecha_nacimiento, Integer user_reg) {
        return prsPersonaRepository.registrarPersona(nombre, ap_paterno, ap_materno,
          ci, nro_celular, correo,
          fecha_nacimiento, user_reg);
    }

    public String modificarPersona(Integer id_persona, String nombre, String ap_paterno,
                                   String ap_materno, String ci, String nro_celular,
                                   String correo, LocalDate fecha_nacimiento, Integer user_mod) {
        return prsPersonaRepository.modificarPersona(id_persona, nombre, ap_paterno,
          ap_materno, ci, nro_celular,
          correo, fecha_nacimiento, user_mod);
    }
}
