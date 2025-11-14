package uap.edu.bo.cpeyfc.chatbot;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class HistorialConversacion {
  private String ip;
  private List<MensajeHistorial> mensajes;
  private LocalDateTime ultimaActividad;

  public HistorialConversacion(String ip) {
    this.ip = ip;
    this.mensajes = new ArrayList<>();
    this.ultimaActividad = LocalDateTime.now();
  }

  public void agregarMensaje(String rol, String contenido) {
    mensajes.add(new MensajeHistorial(rol, contenido, LocalDateTime.now()));
    this.ultimaActividad = LocalDateTime.now();

    // Mantener solo los últimos 10 mensajes para no saturar el contexto
    if (mensajes.size() > 10) {
      mensajes.remove(0);
    }
  }

  public String obtenerContextoHistorial() {
    if (mensajes.isEmpty()) {
      return "";
    }

    StringBuilder contexto = new StringBuilder();
    contexto.append("\n=== HISTORIAL DE CONVERSACIÓN ===\n");
    contexto.append("(Últimos mensajes de esta sesión para contexto)\n\n");

    for (MensajeHistorial mensaje : mensajes) {
      contexto.append(String.format("%s: %s\n",
        mensaje.getRol().equals("usuario") ? "Usuario" : "Asistente",
        mensaje.getContenido()
      ));
    }

    return contexto.toString();
  }

  @Getter
  @AllArgsConstructor
  public static class MensajeHistorial {
    private String rol;
    private String contenido;
    private LocalDateTime timestamp;
  }
}