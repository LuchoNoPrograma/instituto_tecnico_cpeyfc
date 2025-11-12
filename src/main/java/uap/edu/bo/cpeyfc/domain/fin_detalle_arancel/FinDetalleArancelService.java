package uap.edu.bo.cpeyfc.domain.fin_detalle_arancel;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class FinDetalleArancelService {

    private final RepositorioGenericoCrud repositorio;
    private final FinDetalleArancelRepository finDetalleArancelRepository;

}
