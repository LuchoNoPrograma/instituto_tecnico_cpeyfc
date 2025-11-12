package uap.edu.bo.cpeyfc.domain.aca_periodo;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AcaPeriodoService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaPeriodoRepository acaPeriodoRepository;

    // === VISTAS DE PERIODOS ===

    public List<Map<String, Object>> obtenerGestionesPeriodos() {
        return acaPeriodoRepository.vistaGestionesPeriodos();
    }

    public List<Map<String, Object>> obtenerPeriodoActual() {
        return acaPeriodoRepository.vistaPeriodoActual();
    }

}
