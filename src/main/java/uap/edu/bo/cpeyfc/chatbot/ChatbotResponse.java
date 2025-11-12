package uap.edu.bo.cpeyfc.chatbot;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChatbotResponse {
  private String respuesta;
  private boolean error;
  private String mensajeError;

  public static ChatbotResponse exito(String respuesta) {
    return new ChatbotResponse(respuesta, false, null);
  }

  public static ChatbotResponse error(String mensajeError) {
    return new ChatbotResponse(null, true, mensajeError);
  }
}
