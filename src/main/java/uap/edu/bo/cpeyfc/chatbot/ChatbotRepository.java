package uap.edu.bo.cpeyfc.chatbot;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
@Slf4j
public class ChatbotRepository {

  private final JdbcTemplate jdbcTemplate;

  public List<Map<String, Object>> vistaChatbotProgramasInfo() {
    String sql = "SELECT * FROM vista_chatbot_programas_info";
    return jdbcTemplate.queryForList(sql);
  }

  public Map<String, Object> vistaChatbotEstadisticasGenerales() {
    String sql = "SELECT * FROM vista_chatbot_estadisticas_generales";
    return jdbcTemplate.queryForMap(sql);
  }

  public List<Map<String, Object>> vistaChatbotDescuentosVigentes() {
    String sql = "SELECT * FROM vista_chatbot_descuentos_vigentes";
    return jdbcTemplate.queryForList(sql);
  }

  public List<Map<String, Object>> vistaChatbotNivelesPrograma(Integer idPrograma) {
    String sql = """
      SELECT * FROM vista_chatbot_niveles_programa 
      WHERE id_aca_programa = ?
      """;
    return jdbcTemplate.queryForList(sql, idPrograma);
  }
}