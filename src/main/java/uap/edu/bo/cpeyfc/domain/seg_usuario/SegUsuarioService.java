package uap.edu.bo.cpeyfc.domain.seg_usuario;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class SegUsuarioService {

    private final RepositorioGenericoCrud repositorio;
    private final SegUsuarioRepository segUsuarioRepository;

}
