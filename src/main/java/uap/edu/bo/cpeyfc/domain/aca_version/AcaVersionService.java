package uap.edu.bo.cpeyfc.domain.aca_version;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AcaVersionService {

  private final RepositorioGenericoCrud repositorio;
  private final AcaVersionRepository acaVersionRepository;

  public List<Map<String, Object>> vistaVersionesActivas() {
    return acaVersionRepository.vistaVersionesActivas();
  }
}
