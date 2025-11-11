package uap.edu.bo.cpeyfc.chatbot;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Slf4j
public class ChatbotApi {

  private final ChatbotService chatbotService;

  /**
   * Endpoint público para el chatbot
   * No requiere autenticación
   */
  @PostMapping("/api/publico/chatbot")
  public ResponseEntity<ChatbotResponse> chatbot(@RequestBody ChatbotRequest request) {
    log.info("Recibida consulta del chatbot: {}", request.getMensaje());

    // Validar que el mensaje no esté vacío
    if (request.getMensaje() == null || request.getMensaje().trim().isEmpty()) {
      return ResponseEntity.badRequest()
        .body(ChatbotResponse.error("El mensaje no puede estar vacío"));
    }

    // Procesar el mensaje
    ChatbotResponse response = chatbotService.procesarMensaje(request);

    return ResponseEntity.ok(response);
  }

  /**
   * Endpoint de healthcheck para verificar que el servicio está disponible
   */
  @GetMapping("/api/publico/chatbot/health")
  public ResponseEntity<String> health() {
    return ResponseEntity.ok("Chatbot service is running");
  }
}
