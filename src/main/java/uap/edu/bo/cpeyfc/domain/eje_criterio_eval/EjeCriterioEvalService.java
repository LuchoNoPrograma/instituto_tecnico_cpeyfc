package uap.edu.bo.cpeyfc.domain.eje_criterio_eval;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class EjeCriterioEvalService {

    private final RepositorioGenericoCrud repositorio;
    private final EjeCriterioEvalRepository ejeCriterioEvalRepository;

}
