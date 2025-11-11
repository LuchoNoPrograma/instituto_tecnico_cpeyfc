package uap.edu.bo.cpeyfc.chatbot;

import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class GeminiService {

  @Value("${gemini.api.key}")
  private String geminiApiKey;

  @Value("${gemini.api.model}")
  private String modelName;

  public String enviarMensaje(String mensaje, String contextoProgramas) {
    if (geminiApiKey == null || geminiApiKey.isEmpty()) {
      throw new RuntimeException("API key de Gemini no configurada");
    }

    try {
      Client client = new Client();

      String promptCompleto = construirPrompt(mensaje, contextoProgramas);

      log.info("Enviando consulta a Gemini...");
      GenerateContentResponse response = client.models.generateContent(
        modelName,
        promptCompleto,
        null
      );

      log.info("Respuesta recibida de Gemini exitosamente");
      return response.text();

    } catch (Exception e) {
      log.error("Error al llamar a Gemini API: {}", e.getMessage(), e);
      throw new RuntimeException("Error al comunicarse con Gemini: " + e.getMessage(), e);
    }
  }

  private String construirPrompt(String preguntaUsuario, String contextoProgramas) {
    return String.format("""
      Eres un asistente virtual del Centro de Proyectos Especiales y Formación Permanente (CPEyFP) de la Universidad Amazónica de Pando (UAP).
      
      REGLAS CRÍTICAS DE RESPUESTA:
      - NO te presentes en cada respuesta. Solo di tu nombre si te preguntan quién eres.
      - Responde DIRECTO a la pregunta sin preámbulos innecesarios.
      - Sé amable y profesional, pero CONCISO (máximo 3 párrafos).
      - NUNCA inventes horarios, fechas o información que no esté en el contexto.
      - Cuando no tengas información específica (horarios, requisitos detallados, proceso de inscripción),
        sugiere al usuario contactar por WhatsApp usando el enlace proporcionado en el contexto.
      
      INFORMACIÓN ACTUALIZADA DE PROGRAMAS:
      %s
      
      INSTRUCCIONES DE CONTENIDO:
      - Usa SOLO la información del contexto proporcionado arriba
      - Para costos, modalidades o fechas, cita EXACTAMENTE los datos del contexto
      - Cuando sugieras contactar al instituto, menciona que pueden hacerlo por WhatsApp y proporciona el enlace
      - IMPORTANTE: Cuando menciones el enlace de WhatsApp, usa MARKDOWN para hacerlo clickeable: [contactar por WhatsApp](URL)
      - Usa un tono motivador pero natural sobre la educación técnica
      - Si preguntan sobre temas NO relacionados con el instituto, indica brevemente que solo puedes ayudar con información académica del CPEyFP
      - Si mencionas precios, usa el formato: "Bs. X.XX"
      
      INFORMACIÓN INSTITUCIONAL:
      - Nombre: Centro de Proyectos Especiales y Formación Permanente (CPEyFP)
      - Universidad: Universidad Amazónica de Pando (UAP)
      - Ubicación: Cobija, Pando, Bolivia
      - Tipo: Centro de formación técnica universitaria
      
      PREGUNTA DEL USUARIO:
      %s
      
      RESPUESTA (directa, sin presentarte, máximo 3 párrafos, incluye enlace de WhatsApp cuando sea relevante):
      """, contextoProgramas, preguntaUsuario);
  }
}