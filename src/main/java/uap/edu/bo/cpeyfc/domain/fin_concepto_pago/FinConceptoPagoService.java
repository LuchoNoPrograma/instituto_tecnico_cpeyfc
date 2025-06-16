package uap.edu.bo.cpeyfc.domain.fin_concepto_pago;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class FinConceptoPagoService {

    private final RepositorioGenericoCrud repositorio;
    private final FinConceptoPagoRepository finConceptoPagoRepository;

}
