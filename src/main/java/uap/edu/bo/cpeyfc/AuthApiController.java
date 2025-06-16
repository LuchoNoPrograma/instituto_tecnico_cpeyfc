package uap.edu.bo.cpeyfc;

import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import uap.edu.bo.cpeyfc.security.SecurityService;

import java.util.HashMap;
import java.util.Map;

@Log4j2
@Controller
@RequiredArgsConstructor
public class AuthApiController {
  private final SecurityService securityService;

  /**
   * Endpoint para verificar si el usuario está autenticado
   * Requiere token JWT válido
   */
  @GetMapping("/check")
  @PreAuthorize("isAuthenticated()")
  public ResponseEntity<Map<String, Object>> checkAuthentication() {
    try {
      Integer userId = securityService.getCurrentUserId();

      if (userId == null) {
        return ResponseEntity.status(401).body(Map.of(
          "authenticated", false,
          "message", "No authenticated user found"
        ));
      }

      Map<String, Object> response = new HashMap<>();
      response.put("authenticated", true);
      response.put("userId", userId);
      response.put("roles", securityService.getCurrentUserRoles());
      response.put("tareas", securityService.getCurrentUserTareas());

      log.debug("Usuario {} verificado exitosamente", userId);
      return ResponseEntity.ok(response);

    } catch (Exception e) {
      log.error("Error al verificar autenticación: {}", e.getMessage());
      return ResponseEntity.status(500).body(Map.of(
        "authenticated", false,
        "message", "Authentication verification failed"
      ));
    }
  }

  /**
   * Endpoint para obtener información detallada del usuario
   * Requiere token JWT válido
   */
  @GetMapping("/user-info")
  @PreAuthorize("isAuthenticated()")
  public ResponseEntity<Map<String, Object>> getUserInfo() {
    try {
      Integer userId = securityService.getCurrentUserId();

      if (userId == null) {
        return ResponseEntity.status(401).body(Map.of(
          "error", "Usuario no autenticado"
        ));
      }

      Map<String, Object> userInfo = new HashMap<>();
      userInfo.put("userId", userId);
      userInfo.put("roles", securityService.getCurrentUserRoles());
      userInfo.put("tareas", securityService.getCurrentUserTareas());

      return ResponseEntity.ok(userInfo);

    } catch (Exception e) {
      log.error("Error al obtener información del usuario: {}", e.getMessage());
      return ResponseEntity.status(500).body(Map.of(
        "error", "Error interno del servidor"
      ));
    }
  }
}
