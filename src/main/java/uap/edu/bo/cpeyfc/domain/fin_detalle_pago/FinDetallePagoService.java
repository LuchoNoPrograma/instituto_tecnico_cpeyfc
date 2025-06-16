package uap.edu.bo.cpeyfc.domain.fin_detalle_pago;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class FinDetallePagoService {

    private final RepositorioGenericoCrud repositorio;
    private final FinDetallePagoRepository finDetallePagoRepository;

}
