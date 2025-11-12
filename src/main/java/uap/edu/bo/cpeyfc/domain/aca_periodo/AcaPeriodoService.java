package uap.edu.bo.cpeyfc.domain.aca_periodo;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaPeriodoService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaPeriodoRepository acaPeriodoRepository;

}
