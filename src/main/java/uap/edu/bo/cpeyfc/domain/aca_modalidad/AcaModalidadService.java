package uap.edu.bo.cpeyfc.domain.aca_modalidad;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AcaModalidadService {
  private final RepositorioGenericoCrud repositorio;
  private final AcaModalidadRepository acaModalidadRepository;

  public List<Map<String, Object>> vistaModalidadesActivas() {
    return acaModalidadRepository.vistaModalidadesActivas();
  }
}
