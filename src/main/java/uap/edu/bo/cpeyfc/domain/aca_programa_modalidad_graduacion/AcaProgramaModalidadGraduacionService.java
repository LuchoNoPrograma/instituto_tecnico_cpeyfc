package uap.edu.bo.cpeyfc.domain.aca_programa_modalidad_graduacion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaProgramaModalidadGraduacionService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaProgramaModalidadGraduacionRepository acaProgramaModalidadGraduacionRepository;

}
