package uap.edu.bo.cpeyfc.domain.ins_grupo;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class InsGrupoService {

    private final RepositorioGenericoCrud repositorio;
    private final InsGrupoRepository insGrupoRepository;

}
