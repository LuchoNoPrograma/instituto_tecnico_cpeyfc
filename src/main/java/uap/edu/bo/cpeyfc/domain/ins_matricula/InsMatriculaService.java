package uap.edu.bo.cpeyfc.domain.ins_matricula;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class InsMatriculaService {

    private final RepositorioGenericoCrud repositorio;
    private final InsMatriculaRepository insMatriculaRepository;

}
