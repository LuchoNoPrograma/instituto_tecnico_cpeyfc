package uap.edu.bo.cpeyfc.chatbot;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatbotService {

  private final GeminiService geminiService;
  private final ChatbotRepository chatbotRepository;

  public ChatbotResponse procesarMensaje(ChatbotRequest request) {
    try {
      String contextoProgramas = construirContextoProgramas();
      String respuesta = geminiService.enviarMensaje(request.getMensaje(), contextoProgramas);
      return ChatbotResponse.exito(respuesta);

    } catch (Exception e) {
      log.error("Error al procesar mensaje del chatbot", e);
      return ChatbotResponse.error("Lo siento, ocurrió un error al procesar tu consulta. Por favor intenta nuevamente.");
    }
  }

  private String construirContextoProgramas() {
    try {
      List<Map<String, Object>> programas = chatbotRepository.vistaChatbotProgramasInfo();
      Map<String, Object> estadisticas = chatbotRepository.vistaChatbotEstadisticasGenerales();

      if (programas.isEmpty()) {
        return "Actualmente no hay programas disponibles. Por favor contacta con la institución para más información.";
      }

      StringBuilder contexto = new StringBuilder();
      contexto.append("=== PROGRAMAS TÉCNICOS DISPONIBLES ===\n\n");

      for (Map<String, Object> programa : programas) {
        String estadoInscripcion = getString(programa, "estado_inscripcion");
        Integer diasRestantes = getInteger(programa, "dias_restantes");

        contexto.append(String.format("""
          📚 PROGRAMA: %s (%s)
             Área: %s
             Modalidad: %s
             Grupo: %s - Gestión %s
             Plan de estudios: %s
             
             📅 INSCRIPCIONES:
             Estado: %s
             Fecha inicio: %s
             Fecha fin: %s
             %s
             
             💰 COSTOS:
             Matrícula: Bs. %.2f
             Colegiatura mensual: Bs. %.2f
             Titulación: Bs. %.2f
             
             📊 INFORMACIÓN ACADÉMICA:
             Total módulos: %d
             Carga horaria total: %d horas
             Estudiantes preinscritos: %d
             Estudiantes matriculados: %d
             
             ⚠️ IMPORTANTE: No se tiene información de horarios específicos en el sistema.
             Para horarios detallados, el usuario debe contactar directamente al CPEyFP.
          
          """,
          getString(programa, "nombre_programa"),
          getString(programa, "programa_sigla"),
          getString(programa, "nombre_area"),
          getString(programa, "nombre_modalidad"),
          getString(programa, "nombre_grupo"),
          getInteger(programa, "gestion_inicio"),
          programa.get("plan_anho") != null ? "Plan " + programa.get("plan_anho") : "Plan vigente",

          estadoInscripcion,
          programa.get("fecha_inicio_inscripcion"),
          programa.get("fecha_fin_inscripcion"),
          diasRestantes > 0 ? String.format("⏰ Quedan %d días para inscribirse", diasRestantes) : "",

          getDecimal(programa, "precio_matricula"),
          getDecimal(programa, "precio_colegiatura"),
          getDecimal(programa, "precio_titulacion"),

          getInteger(programa, "total_modulos"),
          getInteger(programa, "total_horas"),
          getInteger(programa, "total_preinscritos"),
          getInteger(programa, "total_matriculados")
        ));
      }

      // Agregar estadísticas generales
      contexto.append("\n=== ESTADÍSTICAS DEL INSTITUTO ===\n");
      contexto.append(String.format("""
        - Total de programas ofertados: %d
        - Áreas académicas: %d
        - Grupos activos: %d
        - Grupos con inscripción abierta: %d
        - Total estudiantes: %d
        - Docentes registrados: %d
        """,
        getInteger(estadisticas, "total_programas"),
        getInteger(estadisticas, "total_areas"),
        getInteger(estadisticas, "total_grupos"),
        getInteger(estadisticas, "grupos_con_inscripcion_abierta"),
        getInteger(estadisticas, "total_estudiantes"),
        getInteger(estadisticas, "total_docentes")
      ));

      // Información de contacto con WhatsApp
      contexto.append("\n=== INFORMACIÓN DE CONTACTO ===\n");
      contexto.append("""
        📱 WhatsApp: 591 74771457
        🔗 Enlace directo: https://web.whatsapp.com/send?phone=59174771457 .
       
        Para información sobre horarios, requisitos específicos, proceso de inscripción o cualquier duda adicional,
        puedes contactar directamente con el CPEyFP a través de WhatsApp usando el enlace proporcionado.
        """);

      return contexto.toString();

    } catch (Exception e) {
      log.error("Error al construir contexto de programas", e);
      return "Información de programas temporalmente no disponible.";
    }
  }

  // Métodos helper para manejo seguro de tipos
  private String getString(Map<String, Object> map, String key) {
    Object value = map.get(key);
    return value != null ? value.toString() : "";
  }

  private Integer getInteger(Map<String, Object> map, String key) {
    Object value = map.get(key);
    if (value == null) return 0;
    if (value instanceof Number) return ((Number) value).intValue();
    return 0;
  }

  private Double getDecimal(Map<String, Object> map, String key) {
    Object value = map.get(key);
    if (value == null) return 0.0;
    if (value instanceof Number) return ((Number) value).doubleValue();
    return 0.0;
  }
}