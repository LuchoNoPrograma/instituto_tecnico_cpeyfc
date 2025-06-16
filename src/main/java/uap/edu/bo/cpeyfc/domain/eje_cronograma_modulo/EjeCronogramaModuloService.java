package uap.edu.bo.cpeyfc.domain.eje_cronograma_modulo;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class EjeCronogramaModuloService {

    private final RepositorioGenericoCrud repositorio;
    private final EjeCronogramaModuloRepository ejeCronogramaModuloRepository;

}
