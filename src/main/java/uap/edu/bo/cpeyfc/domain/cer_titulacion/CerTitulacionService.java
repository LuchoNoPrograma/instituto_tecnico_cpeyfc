package uap.edu.bo.cpeyfc.domain.cer_titulacion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class CerTitulacionService {

    private final RepositorioGenericoCrud repositorio;
    private final CerTitulacionRepository cerTitulacionRepository;

}
