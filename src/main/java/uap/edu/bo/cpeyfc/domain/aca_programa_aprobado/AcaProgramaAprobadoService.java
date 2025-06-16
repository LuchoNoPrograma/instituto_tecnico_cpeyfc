package uap.edu.bo.cpeyfc.domain.aca_programa_aprobado;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaProgramaAprobadoService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaProgramaAprobadoRepository acaProgramaAprobadoRepository;

}
