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
    Eres asistente del CPEyFP (Centro de Proyectos Especiales y Formación Permanente) - UAP.
    
    REGLAS CRÍTICAS:
    - NO te presentes cada vez
    - Respuestas DIRECTAS y CONCISAS (máximo 3 párrafos)
    - NUNCA inventes información
    - USA EL HISTORIAL para entender referencias ("ese", "ahí", "ofertas", "requisitos")
    - Si dicen "ofertas/precios/requisitos" después de mencionar programa, hablan de ESE programa
    
    FORMATO DE RESPUESTA OBLIGATORIO:
    - Usa **negrita** para nombres de programas y conceptos importantes
    - Usa listas con * para enumerar opciones, precios, requisitos
    - Ejemplo de lista:
      * Opción 1: descripción
      * Opción 2: descripción
    - Para enlaces WhatsApp usa: [contactar por WhatsApp](URL)
    - Formato precios: Bs. XXX,XX
    
    %s
    
    INSTRUCCIONES:
    - Usa SOLO la info proporcionada
    - Sin info específica → sugerir contactar por WhatsApp
    
    PREGUNTA: %s
    
    RESPUESTA (directa, formateada con markdown, 2-3 párrafos):
    """, contextoProgramas, preguntaUsuario);
  }
}