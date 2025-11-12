package uap.edu.bo.cpeyfc.domain.fin_convenio;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FinConvenioService {

    private final RepositorioGenericoCrud repositorio;
    private final FinConvenioRepository finConvenioRepository;

    // === VISTAS DE CONVENIOS ===

    /**
     * Obtiene todos los convenios con colegios
     */
    public List<Map<String, Object>> obtenerConveniosColegios() {
        return finConvenioRepository.vistaConveniosColegios();
    }

    /**
     * Obtiene solo los convenios vigentes
     */
    public List<Map<String, Object>> obtenerConveniosVigentes() {
        return finConvenioRepository.vistaConveniosVigentes();
    }

}
