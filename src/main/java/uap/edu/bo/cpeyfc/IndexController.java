package uap.edu.bo.cpeyfc;

import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import uap.edu.bo.cpeyfc.security.SecurityService;

@Controller
@RequiredArgsConstructor
@Log4j2
public class IndexController {
  private final SecurityService securityService;

  @GetMapping("/")
  public String index() {
    return "index";
  }

  @GetMapping("/login")
  public String login(@RequestParam(value = "error", required = false) String error, Model model) {
    if (error != null) {
      model.addAttribute("error", "Credenciales inválidas");
    }
    return "login";
  }

  @GetMapping("/dashboard")
  public String dashboard(Model model) {
    // Para JWT, la verificación se hace en el frontend
    // Aquí solo verificamos si el usuario está autenticado en el contexto actual
    try {
      Integer userId = securityService.getCurrentUserId();
      if (userId != null) {
        // Usuario autenticado, agregar información al modelo
        model.addAttribute("userRoles", securityService.getCurrentUserRoles());
        model.addAttribute("userTareas", securityService.getCurrentUserTareas());
        model.addAttribute("userId", userId);

        log.info("Usuario {} accedió al dashboard", userId);
      } else {
        log.warn("Intento de acceso al dashboard sin autenticación");
      }
    } catch (Exception e) {
      log.error("Error al obtener información del usuario: {}", e.getMessage());
    }

    // Siempre devolvemos la vista del dashboard
    // El JavaScript del frontend se encargará de verificar el token
    return "dashboard";
  }

  @GetMapping("/admin")
  public String admin() {
    return "redirect:/dashboard";
  }

  @GetMapping("/admin/**")
  public String adminPages() {
    return "redirect:/dashboard";
  }

  @PostMapping("/logout")
  public String logout(RedirectAttributes redirectAttributes) {
    redirectAttributes.addFlashAttribute("message", "Sesión cerrada exitosamente");
    return "redirect:/";
  }

  // Endpoint para verificar si el usuario está autenticado
  @ResponseBody
  @GetMapping("/api/auth/check")
  public String checkAuth() {
    Integer userId = securityService.getCurrentUserId();
    if (userId != null) {
      return "authenticated";
    }
    return "not-authenticated";
  }
}
