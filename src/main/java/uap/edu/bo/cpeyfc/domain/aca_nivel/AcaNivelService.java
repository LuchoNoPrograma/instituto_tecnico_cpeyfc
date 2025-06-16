package uap.edu.bo.cpeyfc.domain.aca_nivel;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaNivelService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaNivelRepository acaNivelRepository;

}
