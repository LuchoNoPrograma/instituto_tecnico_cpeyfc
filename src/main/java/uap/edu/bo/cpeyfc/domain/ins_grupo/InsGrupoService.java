package uap.edu.bo.cpeyfc.domain.ins_grupo;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class InsGrupoService {

    private final RepositorioGenericoCrud repositorio;
    private final InsGrupoRepository insGrupoRepository;

    // === VISTAS DE ESTUDIANTES ===

    public List<Map<String, Object>> obtenerEstudiantesGrupo() {
        return insGrupoRepository.vistaEstudiantesGrupo();
    }

    public List<Map<String, Object>> obtenerEstudiantesPorGrupo(Integer idGrupo) {
        return insGrupoRepository.obtenerEstudiantesPorGrupo(idGrupo);
    }

    public List<Map<String, Object>> obtenerEstudiantePorCi(String ci) {
        return insGrupoRepository.vistaEstudiantePorCi(ci);
    }

}
