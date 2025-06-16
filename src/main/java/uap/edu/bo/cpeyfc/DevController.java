package uap.edu.bo.cpeyfc;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import uap.edu.bo.cpeyfc.domain.aca_programa.AcaProgramaService;
import uap.edu.bo.cpeyfc.domain.ins_matricula.InsMatriculaService;
import uap.edu.bo.cpeyfc.domain.prs_persona.PrsPersonaService;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * ✨ CONTROLADOR DE PRÁCTICA
 *
 * Este controlador está diseñado para que practiques:
 * - Manejo de rutas (@GetMapping, @PostMapping)
 * - Inyección de dependencias con @RequiredArgsConstructor
 * - Trabajo con Model y vistas
 * - Manejo de formularios
 * - Redirecciones y mensajes flash
 */
@Controller
@RequestMapping("/dev")
@RequiredArgsConstructor
public class DevController {

  // 📋 SERVICIOS DISPONIBLES PARA PRACTICAR
  // Descomenta los que necesites usar

  private final PrsPersonaService personaService;
  private final AcaProgramaService programaService;
  private final InsMatriculaService matriculaService;

  @GetMapping
  public String index(Model model) {
    // 💡 PRACTICA AQUÍ: Agrega datos al modelo
    model.addAttribute("titulo", "Zona de Desarrollo");
    model.addAttribute("fechaActual", LocalDateTime.now());
    model.addAttribute("desarrollador", "Texto plano");

    return "admin/dev/index";
  }

  @GetMapping("/stats")
  public String estadisticas(Model model) {
    Map<String, Object> estadisticas = new HashMap<>();
    estadisticas.put("mensaje", "Estadisticas reales");
    estadisticas.put("estudiantes", 0);
    estadisticas.put("programas", 0);
    estadisticas.put("matriculas", 0);

    model.addAttribute("stats", estadisticas);
    model.addAttribute("titulo", "Estadísticas de Desarrollo");

    return "admin/dev/stats";
  }

  @GetMapping("/form")
  public String mostrarFormulario(Model model) {
    model.addAttribute("titulo", "Formulario de Práctica");

    // 🎯 EJERCICIO: Agrega listas para select/dropdown
    // model.addAttribute("programas", programaService.findAll());

    return "admin/dev/form";
  }

  @PostMapping("/form")
  public String procesarFormulario(
    @RequestParam String nombre,
    @RequestParam String email,
    @RequestParam(required = false) String programa,
    RedirectAttributes redirectAttributes) {


    return "redirect:/admin/dev/form";
  }

  @GetMapping("/api/test")
  @ResponseBody
  public Map<String, Object> apiTest() {
    Map<String, Object> response = new HashMap<>();

    response.put("mensaje", "¡API REST!");
    response.put("timestamp", LocalDateTime.now());
    response.put("desarrollador", "Texto plano");

    return response;
  }


  @GetMapping("/playground")
  public String playground(Model model) {
    model.addAttribute("titulo", "Zona de Experimentos");
    model.addAttribute("mensaje", "Texto plano");
    return "admin/dev/playground";
  }
}