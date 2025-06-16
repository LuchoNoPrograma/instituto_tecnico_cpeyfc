package uap.edu.bo.cpeyfc.domain.aca_programa;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaProgramaService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaProgramaRepository acaProgramaRepository;

}
