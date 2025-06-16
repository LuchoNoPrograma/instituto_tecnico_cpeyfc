package uap.edu.bo.cpeyfc.domain.seg_rol;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class SegRolService {

    private final RepositorioGenericoCrud repositorio;
    private final SegRolRepository segRolRepository;

}
