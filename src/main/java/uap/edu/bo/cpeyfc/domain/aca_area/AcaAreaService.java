package uap.edu.bo.cpeyfc.domain.aca_area;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaAreaService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaAreaRepository acaAreaRepository;

}
