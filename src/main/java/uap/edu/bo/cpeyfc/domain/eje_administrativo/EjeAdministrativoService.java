package uap.edu.bo.cpeyfc.domain.eje_administrativo;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class EjeAdministrativoService {

    private final RepositorioGenericoCrud repositorio;
    private final EjeAdministrativoRepository ejeAdministrativoRepository;

}
