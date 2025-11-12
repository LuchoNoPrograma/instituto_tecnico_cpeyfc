package uap.edu.bo.cpeyfc.domain.aca_tipo_estudiante;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaTipoEstudianteService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaTipoEstudianteRepository acaTipoEstudianteRepository;

}
