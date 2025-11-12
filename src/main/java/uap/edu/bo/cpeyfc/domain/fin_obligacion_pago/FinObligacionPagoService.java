package uap.edu.bo.cpeyfc.domain.fin_obligacion_pago;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FinObligacionPagoService {

    private final RepositorioGenericoCrud repositorio;
    private final FinObligacionPagoRepository finObligacionPagoRepository;

    // === VISTAS DE ESTADO DE CUENTA ===

    public List<Map<String, Object>> obtenerEstadoCuentaPorCi(String ci) {
        return finObligacionPagoRepository.vistaEstadoCuentaPorCi(ci);
    }

}
