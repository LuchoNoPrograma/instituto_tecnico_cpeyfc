package uap.edu.bo.cpeyfc.domain.ins_preinscripcion;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class InsPreinscripcionService {

    private final RepositorioGenericoCrud repositorio;
    private final InsPreinscripcionRepository insPreinscripcionRepository;

}
