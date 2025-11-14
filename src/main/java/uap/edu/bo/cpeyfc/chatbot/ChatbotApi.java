package uap.edu.bo.cpeyfc.chatbot;

import jakarta.servlet.http.HttpServletRequest;
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
  public ResponseEntity<ChatbotResponse> chatbot(
    @RequestBody ChatbotRequest request,
    HttpServletRequest httpRequest
  ) {
    String ip = obtenerIpCliente(httpRequest);
    log.info("Recibida consulta del chatbot desde IP: {} - Mensaje: {}", ip, request.getMensaje());

    // Validar que el mensaje no esté vacío
    if (request.getMensaje() == null || request.getMensaje().trim().isEmpty()) {
      return ResponseEntity.badRequest()
        .body(ChatbotResponse.error("El mensaje no puede estar vacío"));
    }

    // Procesar el mensaje con contexto de IP
    ChatbotResponse response = chatbotService.procesarMensaje(request, ip);

    return ResponseEntity.ok(response);
  }

  /**
   * Endpoint para limpiar el historial de conversación
   */
  @DeleteMapping("/api/publico/chatbot/limpiar")
  public ResponseEntity<String> limpiarHistorial(HttpServletRequest httpRequest) {
    String ip = obtenerIpCliente(httpRequest);
    log.info("Limpiando historial para IP: {}", ip);
    chatbotService.limpiarHistorial(ip);
    return ResponseEntity.ok("Historial limpiado exitosamente");
  }

  /**
   * Endpoint de healthcheck para verificar que el servicio está disponible
   */
  @GetMapping("/api/publico/chatbot/health")
  public ResponseEntity<String> health() {
    return ResponseEntity.ok("Chatbot service is running");
  }

  /**
   * Obtiene la IP real del cliente considerando proxies
   */
  private String obtenerIpCliente(HttpServletRequest request) {
    String ip = request.getHeader("X-Forwarded-For");

    if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getHeader("X-Real-IP");
    }

    if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getHeader("Proxy-Client-IP");
    }

    if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getHeader("WL-Proxy-Client-IP");
    }

    if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getRemoteAddr();
    }

    // Si hay múltiples IPs (proxy chain), tomar la primera
    if (ip != null && ip.contains(",")) {
      ip = ip.split(",")[0].trim();
    }

    return ip != null ? ip : "unknown";
  }
}