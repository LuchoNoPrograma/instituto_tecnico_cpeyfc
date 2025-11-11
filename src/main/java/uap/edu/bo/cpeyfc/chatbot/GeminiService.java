package uap.edu.bo.cpeyfc.chatbot;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class GeminiService {

  @Value("${gemini.api.key:}")
  private String geminiApiKey;

  @Value("${gemini.api.model:gemini-1.5-flash}")
  private String modelName;

  private final RestTemplate restTemplate = new RestTemplate();
  private final ObjectMapper objectMapper = new ObjectMapper();

  /**
   * Envía una pregunta a Gemini API con contexto de programas
   */
  public String enviarMensaje(String mensaje, String contextoProgramas) {
    if (geminiApiKey == null || geminiApiKey.isEmpty()) {
      throw new RuntimeException("API key de Gemini no configurada. Configure 'gemini.api.key' en application.properties");
    }

    try {
      // Construir el prompt con contexto
      String promptCompleto = construirPrompt(mensaje, contextoProgramas);

      // Construir el cuerpo de la petición según la API de Gemini
      Map<String, Object> requestBody = new HashMap<>();

      Map<String, Object> content = new HashMap<>();
      Map<String, String> part = new HashMap<>();
      part.put("text", promptCompleto);
      content.put("parts", List.of(part));

      requestBody.put("contents", List.of(content));

      // Configuraciones de generación (opcional)
      Map<String, Object> generationConfig = new HashMap<>();
      generationConfig.put("temperature", 0.7);
      generationConfig.put("maxOutputTokens", 1024);
      requestBody.put("generationConfig", generationConfig);

      // Configurar headers
      HttpHeaders headers = new HttpHeaders();
      headers.setContentType(MediaType.APPLICATION_JSON);

      HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

      // URL de la API de Gemini
      String url = String.format(
        "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
        modelName,
        geminiApiKey
      );

      log.info("Enviando petición a Gemini API...");

      // Hacer la petición
      ResponseEntity<String> response = restTemplate.exchange(
        url,
        HttpMethod.POST,
        entity,
        String.class
      );

      // Parsear la respuesta
      if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
        JsonNode root = objectMapper.readTree(response.getBody());
        JsonNode candidates = root.path("candidates");

        if (candidates.isArray() && candidates.size() > 0) {
          JsonNode content_response = candidates.get(0).path("content");
          JsonNode parts = content_response.path("parts");

          if (parts.isArray() && parts.size() > 0) {
            String respuesta = parts.get(0).path("text").asText();
            log.info("Respuesta recibida de Gemini");
            return respuesta;
          }
        }

        throw new RuntimeException("No se pudo extraer la respuesta de Gemini");
      } else {
        throw new RuntimeException("Error en la petición a Gemini: " + response.getStatusCode());
      }

    } catch (Exception e) {
      log.error("Error al llamar a Gemini API", e);
      throw new RuntimeException("Error al comunicarse con Gemini: " + e.getMessage(), e);
    }
  }

  /**
   * Construye el prompt con el contexto de programas
   */
  private String construirPrompt(String preguntaUsuario, String contextoProgramas) {
    return String.format("""
      Eres un asistente virtual del Instituto Técnico CPEyFC (Centro Psicopedagógico de Educación y Formación Continua) de la Universidad Amazónica de Pando (UAP).

      Tu función es ayudar a los visitantes a conocer los programas académicos ofertados y responder preguntas sobre inscripciones, modalidades, costos y requisitos.

      INFORMACIÓN DE PROGRAMAS DISPONIBLES:
      %s

      INSTRUCCIONES:
      - Responde de manera amable, profesional y concisa
      - Si te preguntan sobre un programa específico, usa la información proporcionada
      - Si te preguntan sobre costos, modalidades o fechas, refiérelos a la información específica de cada programa
      - Si no tienes información sobre algo específico, sugiere contactar directamente con la institución
      - Mantén las respuestas breves (máximo 3-4 párrafos)
      - Usa un tono motivador y positivo sobre la educación técnica
      - Si te preguntan sobre temas no relacionados con la institución, indica amablemente que solo puedes ayudar con información académica del Instituto

      PREGUNTA DEL USUARIO:
      %s

      RESPUESTA:
      """, contextoProgramas, preguntaUsuario);
  }
}
