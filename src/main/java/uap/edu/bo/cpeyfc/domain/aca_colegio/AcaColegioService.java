package uap.edu.bo.cpeyfc.domain.aca_colegio;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaColegioService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaColegioRepository acaColegioRepository;

}
