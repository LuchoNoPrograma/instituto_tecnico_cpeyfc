package uap.edu.bo.cpeyfc.domain.fin_concepto_arancel;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class FinConceptoArancelService {

    private final RepositorioGenericoCrud repositorio;
    private final FinConceptoArancelRepository finConceptoArancelRepository;

}
