package uap.edu.bo.cpeyfc.domain.eje_area_evaluacion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class EjeAreaEvaluacionService {

    private final RepositorioGenericoCrud repositorio;
    private final EjeAreaEvaluacionRepository ejeAreaEvaluacionRepository;

}
