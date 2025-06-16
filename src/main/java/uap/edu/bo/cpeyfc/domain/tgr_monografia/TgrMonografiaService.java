package uap.edu.bo.cpeyfc.domain.tgr_monografia;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class TgrMonografiaService {

    private final RepositorioGenericoCrud repositorio;
    private final TgrMonografiaRepository tgrMonografiaRepository;

}
