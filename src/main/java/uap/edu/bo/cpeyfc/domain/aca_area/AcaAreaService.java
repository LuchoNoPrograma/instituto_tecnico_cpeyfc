package uap.edu.bo.cpeyfc.domain.aca_area;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AcaAreaService {

  private final RepositorioGenericoCrud repositorio;
  private final AcaAreaRepository acaAreaRepository;

  public List<Map<String, Object>> vistaAreasActivas() {
    return acaAreaRepository.vistaAreasActivas();
  }
}
