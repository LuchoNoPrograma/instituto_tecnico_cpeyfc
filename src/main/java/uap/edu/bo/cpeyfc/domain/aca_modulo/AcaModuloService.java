package uap.edu.bo.cpeyfc.domain.aca_modulo;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaModuloService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaModuloRepository acaModuloRepository;

}
