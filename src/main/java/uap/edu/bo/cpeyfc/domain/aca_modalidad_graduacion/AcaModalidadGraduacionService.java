package uap.edu.bo.cpeyfc.domain.aca_modalidad_graduacion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaModalidadGraduacionService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaModalidadGraduacionRepository acaModalidadGraduacionRepository;

}
