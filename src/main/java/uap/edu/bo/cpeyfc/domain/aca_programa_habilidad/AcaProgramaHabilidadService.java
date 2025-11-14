package uap.edu.bo.cpeyfc.domain.aca_programa_habilidad;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AcaProgramaHabilidadService {
  private final AcaProgramaHabilidadRepository acaProgramaHabilidadRepository;

  public Integer registrarHabilidadPrograma(
      Integer id_aca_programa,
      String nombre_habilidad,
      Integer user_reg) {
    return acaProgramaHabilidadRepository.registrarHabilidadPrograma(
        id_aca_programa,
        nombre_habilidad,
        user_reg
    );
  }

  public String modificarHabilidadPrograma(
      Integer id_programa_habilidad,
      String nombre_habilidad,
      String estado_programa_habilidad,
      Integer user_mod) {
    return acaProgramaHabilidadRepository.modificarHabilidadPrograma(
        id_programa_habilidad,
        nombre_habilidad,
        estado_programa_habilidad,
        user_mod
    );
  }

  public String eliminarHabilidadPrograma(
      Integer id_programa_habilidad,
      Integer user_mod) {
    return acaProgramaHabilidadRepository.eliminarHabilidadPrograma(
        id_programa_habilidad,
        user_mod
    );
  }

  public List<Map<String, Object>> asignarHabilidadesPrograma(
      Integer id_aca_programa,
      String[] habilidades,
      Integer user_reg) {
    return acaProgramaHabilidadRepository.asignarHabilidadesPrograma(
        id_aca_programa,
        habilidades,
        user_reg
    );
  }

  public List<Map<String, Object>> listarHabilidadesPorPrograma(
      Integer id_aca_programa) {
    return acaProgramaHabilidadRepository.listarHabilidadesPorPrograma(
        id_aca_programa
    );
  }
}