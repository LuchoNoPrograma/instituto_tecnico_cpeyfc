package uap.edu.bo.cpeyfc.domain.tgr_revision_monografia;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class TgrRevisionMonografiaService {

    private final RepositorioGenericoCrud repositorio;
    private final TgrRevisionMonografiaRepository tgrRevisionMonografiaRepository;

}
