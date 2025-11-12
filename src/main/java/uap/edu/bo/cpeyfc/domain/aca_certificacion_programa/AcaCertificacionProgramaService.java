package uap.edu.bo.cpeyfc.domain.aca_certificacion_programa;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaCertificacionProgramaService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaCertificacionProgramaRepository acaCertificacionProgramaRepository;

}
