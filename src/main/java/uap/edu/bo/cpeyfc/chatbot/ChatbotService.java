package uap.edu.bo.cpeyfc.chatbot;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.domain.aca_perfil_estudiante.AcaPerfilEstudianteRepository;
import uap.edu.bo.cpeyfc.domain.fin_arancel.FinArancelRepository;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatbotService {

  private final GeminiService geminiService;
  private final ChatbotRepository chatbotRepository;
  private final FinArancelRepository finArancelRepository;
  private final AcaPerfilEstudianteRepository acaPerfilRepository;
  private final ChatbotHistorialService historialService;

  public ChatbotResponse procesarMensaje(ChatbotRequest request, String ip) {
    try {
      // Obtener contexto e historial
      String contextoProgramas = construirContextoProgramas();
      String contextoHistorial = historialService.obtenerContextoHistorial(ip);

      // Combinar todo
      String contextoCompleto = contextoProgramas;
      if (!contextoHistorial.isEmpty()) {
        contextoCompleto += "\n" + contextoHistorial;
      }

      // Guardar mensaje del usuario
      historialService.agregarMensaje(ip, "usuario", request.getMensaje());

      // Enviar a Gemini
      String respuesta = geminiService.enviarMensaje(request.getMensaje(), contextoCompleto);

      // Guardar respuesta
      historialService.agregarMensaje(ip, "asistente", respuesta);

      return ChatbotResponse.exito(respuesta);

    } catch (Exception e) {
      log.error("Error al procesar mensaje del chatbot para IP: {}", ip, e);
      return ChatbotResponse.error("Lo siento, ocurrió un error al procesar tu consulta. Por favor intenta nuevamente.");
    }
  }

  public void limpiarHistorial(String ip) {
    historialService.limpiarHistorial(ip);
  }

  private String construirContextoProgramas() {
    try {
      List<Map<String, Object>> programas = chatbotRepository.vistaChatbotProgramasInfo();
      Map<String, Object> estadisticas = chatbotRepository.vistaChatbotEstadisticasGenerales();
      List<Map<String, Object>> descuentos = chatbotRepository.vistaChatbotDescuentosVigentes();

      if (programas.isEmpty()) {
        return "No hay programas disponibles actualmente.";
      }

      StringBuilder contexto = new StringBuilder();
      contexto.append("=== PROGRAMAS DISPONIBLES ===\n\n");

      for (Map<String, Object> programa : programas) {
        Integer idProgramaAprobado = getInteger(programa, "id_aca_programa_aprobado");
        Integer diasRestantes = getInteger(programa, "dias_restantes");

        // Aranceles y requisitos
        List<Map<String, Object>> aranceles = finArancelRepository.obtenerArancelesPrograma(idProgramaAprobado);
        List<Map<String, Object>> requisitos = acaPerfilRepository.obtenerRequisitosPrograma(idProgramaAprobado);

        contexto.append(String.format("""
          📚 %s (%s) - Área: %s
          Modalidad: %s | Grupo: %s - Gestión %s
          
          📅 INSCRIPCIONES: %s
          Fecha límite: %s%s
          
          💰 ARANCELES:
          %s
          
          📋 REQUISITOS:
          %s
          
          📊 INFO: %d módulos, %d hrs | Preinscritos: %d | Matriculados: %d
          
          ---
          """,
          getString(programa, "nombre_programa"),
          getString(programa, "programa_sigla"),
          getString(programa, "nombre_area"),
          getString(programa, "nombre_modalidad"),
          getString(programa, "nombre_grupo"),
          getInteger(programa, "gestion_inicio"),
          getString(programa, "estado_inscripcion"),
          programa.get("fecha_fin_inscripcion"),
          diasRestantes > 0 ? String.format(" (%d días restantes)", diasRestantes) : "",
          formatearAranceles(aranceles),
          formatearRequisitos(requisitos),
          getInteger(programa, "total_modulos"),
          getInteger(programa, "total_horas"),
          getInteger(programa, "total_preinscritos"),
          getInteger(programa, "total_matriculados")
        ));
      }

      if (!descuentos.isEmpty()) {
        contexto.append("\n=== DESCUENTOS Y CONVENIOS VIGENTES ===\n");
        contexto.append(formatearDescuentos(descuentos));
      }

      // Estadísticas e info de contacto
      contexto.append(String.format("""
        
        === ESTADÍSTICAS ===
        Total programas: %d | Áreas: %d | Grupos activos: %d | Con inscripción abierta: %d
        Total estudiantes: %d | Docentes: %d
        
        === CONTACTO ===
        📱 WhatsApp: 591 74771457
        🔗 https://web.whatsapp.com/send?phone=59174771457
        
        ⚠️ No hay horarios en el sistema. Para horarios, contactar por WhatsApp.
        """,
        getInteger(estadisticas, "total_programas"),
        getInteger(estadisticas, "total_areas"),
        getInteger(estadisticas, "total_grupos"),
        getInteger(estadisticas, "grupos_con_inscripcion_abierta"),
        getInteger(estadisticas, "total_estudiantes"),
        getInteger(estadisticas, "total_docentes")
      ));

      return contexto.toString();

    } catch (Exception e) {
      log.error("Error al construir contexto de programas", e);
      return "Información temporalmente no disponible.";
    }
  }

  private String formatearAranceles(List<Map<String, Object>> aranceles) {
    if (aranceles == null || aranceles.isEmpty()) {
      return "No disponibles - contactar CPEyFP";
    }

    StringBuilder texto = new StringBuilder();
    Map<String, List<Map<String, Object>>> porConcepto = aranceles.stream()
      .collect(java.util.stream.Collectors.groupingBy(a -> getString(a, "concepto")));

    for (Map.Entry<String, List<Map<String, Object>>> entry : porConcepto.entrySet()) {
      texto.append(String.format("  %s:\n", entry.getKey()));
      for (Map<String, Object> arancel : entry.getValue()) {
        texto.append(String.format("    • %s: Bs. %.2f\n",
          getString(arancel, "tipo_beneficiario"),
          getDecimal(arancel, "monto")
        ));
      }
    }

    return texto.toString().trim();
  }

  private String formatearRequisitos(List<Map<String, Object>> requisitos) {
    if (requisitos == null || requisitos.isEmpty()) {
      return "No disponibles - contactar CPEyFP";
    }

    StringBuilder texto = new StringBuilder();
    String perfilActual = "";

    for (Map<String, Object> req : requisitos) {
      String perfil = getString(req, "nombre_perfil");

      if (!perfil.equals(perfilActual)) {
        if (!perfilActual.isEmpty()) texto.append("\n");
        texto.append(String.format("  %s:\n", perfil));
        perfilActual = perfil;
      }

      texto.append(String.format("    • %s", getString(req, "nombre_requisito")));
      String desc = getString(req, "descripcion_requisito");
      if (!desc.isEmpty()) {
        texto.append(String.format(" (%s)", desc));
      }
      texto.append("\n");
    }

    return texto.toString().trim();
  }

  private String formatearDescuentos(List<Map<String, Object>> descuentos) {
    if (descuentos == null || descuentos.isEmpty()) {
      return "No hay descuentos vigentes actualmente.\n";
    }

    StringBuilder texto = new StringBuilder();
    String institucionActual = "";

    for (Map<String, Object> desc : descuentos) {
      String institucion = getString(desc, "nombre_institucion");

      // Agrupar por institución
      if (!institucion.equals(institucionActual)) {
        if (!institucionActual.isEmpty()) texto.append("\n");
        texto.append(String.format("🏢 **%s** (%s):\n",
          institucion,
          getString(desc, "tipo_institucion")
        ));
        institucionActual = institucion;
      }

      // Detalle del descuento
      String alcance = getString(desc, "alcance_descuento");
      String programa = getString(desc, "nombre_programa");
      String concepto = getString(desc, "nombre_concepto");
      String descuento = getString(desc, "descuento_formato");
      String descripcion = getString(desc, "descripcion");

      texto.append(String.format("  • %s de descuento", descuento));

      if (!alcance.equals("GENERAL")) {
        texto.append(String.format(" en **%s**", programa));
        if (!concepto.equals("TODOS LOS CONCEPTOS")) {
          texto.append(String.format(" - %s", concepto));
        }
      } else {
        texto.append(" en todos los programas");
      }

      if (!descripcion.isEmpty()) {
        texto.append(String.format(" (%s)", descripcion));
      }
      texto.append("\n");
    }

    return texto.toString();
  }

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