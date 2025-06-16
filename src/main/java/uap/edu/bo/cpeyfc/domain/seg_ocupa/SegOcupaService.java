package uap.edu.bo.cpeyfc.domain.seg_ocupa;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class SegOcupaService {

    private final RepositorioGenericoCrud repositorio;
    private final SegOcupaRepository segOcupaRepository;

}
