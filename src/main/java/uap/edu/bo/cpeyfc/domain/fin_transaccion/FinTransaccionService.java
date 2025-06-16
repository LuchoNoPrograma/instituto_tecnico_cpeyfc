package uap.edu.bo.cpeyfc.domain.fin_transaccion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class FinTransaccionService {

    private final RepositorioGenericoCrud repositorio;
    private final FinTransaccionRepository finTransaccionRepository;

}
