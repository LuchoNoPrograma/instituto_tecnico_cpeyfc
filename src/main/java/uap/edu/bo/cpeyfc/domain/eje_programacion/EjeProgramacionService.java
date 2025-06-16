package uap.edu.bo.cpeyfc.domain.eje_programacion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class EjeProgramacionService {

    private final RepositorioGenericoCrud repositorio;
    private final EjeProgramacionRepository ejeProgramacionRepository;

}
