package uap.edu.bo.cpeyfc.domain.fin_obligacion_pago;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class FinObligacionPagoService {

    private final RepositorioGenericoCrud repositorio;
    private final FinObligacionPagoRepository finObligacionPagoRepository;

}
