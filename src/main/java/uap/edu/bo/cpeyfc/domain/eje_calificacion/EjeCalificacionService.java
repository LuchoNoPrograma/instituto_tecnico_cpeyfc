package uap.edu.bo.cpeyfc.domain.eje_calificacion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class EjeCalificacionService {

    private final RepositorioGenericoCrud repositorio;
    private final EjeCalificacionRepository ejeCalificacionRepository;

    // === VISTAS DE CALIFICACIONES ===

    public List<Map<String, Object>> obtenerCalificacionesPorMatricula(Integer codMatricula) {
        return ejeCalificacionRepository.vistaCalificacionesPorMatricula(codMatricula);
    }

    public List<Map<String, Object>> obtenerCalificacionesPorCi(String ci) {
        return ejeCalificacionRepository.vistaCalificacionesPorCi(ci);
    }

}
