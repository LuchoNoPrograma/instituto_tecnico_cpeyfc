package uap.edu.bo.cpeyfc.domain.aca_requisito;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AcaRequisitoService {

  private final AcaRequisitoRepository acaRequisitoRepository;

  public List<Map<String, Object>> listarRequisitosActivos() {
    return acaRequisitoRepository.vistaRequisitosActivos();
  }

  @Transactional(rollbackFor = Exception.class)
  public Integer registrarRequisito(String nombreRequisito, String descripcion, Integer ordenPresentacion, Integer userReg) {
    return acaRequisitoRepository.registrarRequisito(nombreRequisito, descripcion, ordenPresentacion, userReg);
  }

  @Transactional(rollbackFor = Exception.class)
  public Boolean modificarRequisito(Integer idRequisito, String nombreRequisito, String descripcion, Integer ordenPresentacion, Integer userMod) {
    return acaRequisitoRepository.modificarRequisito(idRequisito, nombreRequisito, descripcion, ordenPresentacion, userMod);
  }

  @Transactional(rollbackFor = Exception.class)
  public Boolean eliminarRequisito(Integer idRequisito, Integer userMod) {
    return acaRequisitoRepository.eliminarRequisito(idRequisito, userMod);
  }
}
