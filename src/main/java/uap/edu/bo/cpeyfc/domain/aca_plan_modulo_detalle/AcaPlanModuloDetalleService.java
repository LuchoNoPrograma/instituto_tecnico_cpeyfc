package uap.edu.bo.cpeyfc.domain.aca_plan_modulo_detalle;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaPlanModuloDetalleService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaPlanModuloDetalleRepository acaPlanModuloDetalleRepository;

}
