package uap.edu.bo.cpeyfc.domain.aca_plan_estudio;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

@Service
@RequiredArgsConstructor
public class AcaPlanEstudioService {

  private final RepositorioGenericoCrud repositorio;
  private final AcaPlanEstudioRepository acaPlanEstudioRepository;

}
