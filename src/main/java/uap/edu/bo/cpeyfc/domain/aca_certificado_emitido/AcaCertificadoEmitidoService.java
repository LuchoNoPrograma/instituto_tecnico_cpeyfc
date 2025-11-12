package uap.edu.bo.cpeyfc.domain.aca_certificado_emitido;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaCertificadoEmitidoService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaCertificadoEmitidoRepository acaCertificadoEmitidoRepository;

}
