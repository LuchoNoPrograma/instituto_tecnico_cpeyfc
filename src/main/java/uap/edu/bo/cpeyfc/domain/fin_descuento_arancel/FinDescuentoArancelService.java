package uap.edu.bo.cpeyfc.domain.fin_descuento_arancel;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class FinDescuentoArancelService {

    private final RepositorioGenericoCrud repositorio;
    private final FinDescuentoArancelRepository finDescuentoArancelRepository;

}
