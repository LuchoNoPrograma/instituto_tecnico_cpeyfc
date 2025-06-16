package uap.edu.bo.cpeyfc.domain.cer_impresion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class CerImpresionService {

    private final RepositorioGenericoCrud repositorio;
    private final CerImpresionRepository cerImpresionRepository;

}
