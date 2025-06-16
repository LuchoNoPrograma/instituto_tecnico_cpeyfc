package uap.edu.bo.cpeyfc.domain.eje_docente;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class EjeDocenteService {

    private final RepositorioGenericoCrud repositorio;
    private final EjeDocenteRepository ejeDocenteRepository;

}
