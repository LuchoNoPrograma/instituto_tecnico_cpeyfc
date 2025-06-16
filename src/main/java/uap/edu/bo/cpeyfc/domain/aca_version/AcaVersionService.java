package uap.edu.bo.cpeyfc.domain.aca_version;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaVersionService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaVersionRepository acaVersionRepository;

}
