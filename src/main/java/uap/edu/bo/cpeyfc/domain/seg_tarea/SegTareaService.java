package uap.edu.bo.cpeyfc.domain.seg_tarea;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class SegTareaService {

    private final RepositorioGenericoCrud repositorio;
    private final SegTareaRepository segTareaRepository;

}
