package uap.edu.bo.cpeyfc.domain.aca_gestion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaGestionService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaGestionRepository acaGestionRepository;

}
