package uap.edu.bo.cpeyfc.domain.aca_parametro_programa;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaParametroProgramaService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaParametroProgramaRepository acaParametroProgramaRepository;

}
