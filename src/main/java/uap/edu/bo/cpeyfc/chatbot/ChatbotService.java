package uap.edu.bo.cpeyfc.chatbot;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatbotService {

  private final GeminiService geminiService;
  private final JdbcTemplate jdbcTemplate;

  /**
   * Procesa un mensaje del chatbot obteniendo contexto de programas
   */
  public ChatbotResponse procesarMensaje(ChatbotRequest request) {
    try {
      // Obtener información actualizada de programas
      String contextoProgramas = obtenerContextoProgramas();

      // Enviar a Gemini con el contexto
      String respuesta = geminiService.enviarMensaje(request.getMensaje(), contextoProgramas);

      return ChatbotResponse.exito(respuesta);

    } catch (Exception e) {
      log.error("Error al procesar mensaje del chatbot", e);
      return ChatbotResponse.error("Lo siento, ocurrió un error al procesar tu consulta. Por favor intenta nuevamente.");
    }
  }

  /**
   * Obtiene el contexto de programas ofertados desde la base de datos
   */
  private String obtenerContextoProgramas() {
    try {
      String sql = """
        SELECT
          pap.id_aca_programa_aprobado,
          p.nombre_programa,
          a.nombre_area,
          m.nombre_modalidad,
          pe.plan_anho,
          g.nombre_grupo,
          g.fecha_fin_inscripcion,
          g.precio_matricula,
          g.precio_colegiatura,
          CASE
            WHEN g.fecha_fin_inscripcion >= CURRENT_DATE THEN 'INSCRIPCIONES ABIERTAS'
            WHEN g.fecha_inicio_inscripcion > CURRENT_DATE THEN 'PROXIMAMENTE'
            ELSE 'INSCRIPCIONES CERRADAS'
          END as estado_inscripcion,
          (SELECT COUNT(*) FROM ins_preinscripcion pre WHERE pre.id_ins_grupo = g.id_ins_grupo) as total_preinscritos
        FROM ins_grupo g
        INNER JOIN aca_programa_aprobado pap ON g.id_aca_programa_aprobado = pap.id_aca_programa_aprobado
        INNER JOIN aca_version v ON pap.id_aca_version = v.id_aca_version
        INNER JOIN aca_plan_estudio pe ON v.id_aca_plan_estudio = pe.id_aca_plan_estudio
        INNER JOIN aca_programa p ON pe.id_aca_programa = p.id_aca_programa
        INNER JOIN aca_area a ON p.id_aca_area = a.id_aca_area
        INNER JOIN aca_modalidad m ON pe.id_aca_modalidad = m.id_aca_modalidad
        WHERE g.estado = 'ACTIVO'
        AND pap.estado = 'APROBADO'
        ORDER BY g.fecha_fin_inscripcion DESC
      """;

      List<Map<String, Object>> programas = jdbcTemplate.queryForList(sql);

      if (programas.isEmpty()) {
        return "Actualmente no hay programas disponibles. Por favor contacta con la institución para más información.";
      }

      StringBuilder contexto = new StringBuilder();
      contexto.append("PROGRAMAS TÉCNICOS DISPONIBLES:\n\n");

      for (Map<String, Object> programa : programas) {
        contexto.append(String.format("""
          - Programa: %s
            Área: %s
            Modalidad: %s
            Plan: %s
            Grupo: %s
            Estado: %s
            Fecha límite de inscripción: %s
            Precio matrícula: Bs. %.2f
            Precio colegiatura mensual: Bs. %.2f
            Preinscritos actuales: %d

          """,
          programa.get("nombre_programa"),
          programa.get("nombre_area"),
          programa.get("nombre_modalidad"),
          programa.get("plan_anho") != null ? "Plan " + programa.get("plan_anho") : "Información disponible próximamente",
          programa.get("nombre_grupo"),
          programa.get("estado_inscripcion"),
          programa.get("fecha_fin_inscripcion"),
          programa.get("precio_matricula") != null ? ((Number) programa.get("precio_matricula")).doubleValue() : 0.0,
          programa.get("precio_colegiatura") != null ? ((Number) programa.get("precio_colegiatura")).doubleValue() : 0.0,
          programa.get("total_preinscritos") != null ? ((Number) programa.get("total_preinscritos")).longValue() : 0L
        ));
      }

      contexto.append("\n");
      contexto.append("INFORMACIÓN GENERAL:\n");
      contexto.append("- Instituto: Centro Psicopedagógico de Educación y Formación Continua (CPEyFC)\n");
      contexto.append("- Universidad: Universidad Amazónica de Pando (UAP)\n");
      contexto.append("- Tipo: Instituto Técnico\n");
      contexto.append("- Enfoque: Formación técnica especializada con orientación práctica\n");

      return contexto.toString();

    } catch (Exception e) {
      log.error("Error al obtener contexto de programas", e);
      return "Información de programas no disponible temporalmente.";
    }
  }
}
