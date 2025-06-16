package uap.edu.bo.cpeyfc.domain.prs_persona;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class PrsPersonaService {

    private final RepositorioGenericoCrud repositorio;
    private final PrsPersonaRepository prsPersonaRepository;

}
