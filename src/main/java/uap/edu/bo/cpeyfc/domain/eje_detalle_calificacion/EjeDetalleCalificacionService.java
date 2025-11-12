package uap.edu.bo.cpeyfc.domain.eje_detalle_calificacion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class EjeDetalleCalificacionService {

    private final RepositorioGenericoCrud repositorio;
    private final EjeDetalleCalificacionRepository ejeDetalleCalificacionRepository;

}
