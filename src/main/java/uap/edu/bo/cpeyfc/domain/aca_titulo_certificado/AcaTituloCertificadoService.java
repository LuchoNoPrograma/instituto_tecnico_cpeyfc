package uap.edu.bo.cpeyfc.domain.aca_titulo_certificado;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaTituloCertificadoService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaTituloCertificadoRepository acaTituloCertificadoRepository;

}
