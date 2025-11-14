package uap.edu.bo.cpeyfc.domain.aca_perfil_estudiante;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import uap.edu.bo.cpeyfc.domain.aca_requisito_perfil.AcaRequisitoPerfilRepository;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AcaPerfilEstudianteService {

  private final AcaPerfilEstudianteRepository acaPerfilRepository;
  private final AcaRequisitoPerfilRepository acaRequisitoPerfilRepository;

  public List<Map<String, Object>> listarPerfilesActivos() {
    return acaPerfilRepository.vistaPerfilesActivos();
  }

  @Transactional(rollbackFor = Exception.class)
  public Integer registrarPerfil(String nombrePerfil, String descripcion, Integer userReg) {
    return acaPerfilRepository.registrarPerfil(nombrePerfil, descripcion, userReg);
  }

  @Transactional(rollbackFor = Exception.class)
  public Boolean modificarPerfil(Integer idPerfil, String nombrePerfil, String descripcion, Integer userMod) {
    return acaPerfilRepository.modificarPerfil(idPerfil, nombrePerfil, descripcion, userMod);
  }

  @Transactional(rollbackFor = Exception.class)
  public Boolean eliminarPerfil(Integer idPerfil, Integer userMod) {
    return acaPerfilRepository.eliminarPerfil(idPerfil, userMod);
  }

  @Transactional(rollbackFor = Exception.class)
  public List<Map<String, Object>> asignarRequisitos(Integer idPerfil, Integer[] requisitos, Integer userReg) {
    return acaRequisitoPerfilRepository.asignarRequisitos(idPerfil, requisitos, userReg);
  }

  public List<Map<String, Object>> obtenerRequisitosAsignados(Integer idPerfil) {
    return acaPerfilRepository.vistaRequisitosPorPerfil(idPerfil);
  }
}
