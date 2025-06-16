package uap.edu.bo.cpeyfc.domain.cer_certificado;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class CerCertificadoService {

    private final RepositorioGenericoCrud repositorio;
    private final CerCertificadoRepository cerCertificadoRepository;

}
