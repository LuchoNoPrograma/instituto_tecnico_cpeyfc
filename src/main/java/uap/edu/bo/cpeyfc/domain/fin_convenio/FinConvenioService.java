package uap.edu.bo.cpeyfc.domain.fin_convenio;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class FinConvenioService {

    private final RepositorioGenericoCrud repositorio;
    private final FinConvenioRepository finConvenioRepository;

}
