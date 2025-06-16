package uap.edu.bo.cpeyfc.domain.seg_designa;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class SegDesignaService {

    private final RepositorioGenericoCrud repositorio;
    private final SegDesignaRepository segDesignaRepository;

}
