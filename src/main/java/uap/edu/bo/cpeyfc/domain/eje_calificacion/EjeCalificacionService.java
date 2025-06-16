package uap.edu.bo.cpeyfc.domain.eje_calificacion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class EjeCalificacionService {

    private final RepositorioGenericoCrud repositorio;
    private final EjeCalificacionRepository ejeCalificacionRepository;

}
