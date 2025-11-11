package uap.edu.bo.cpeyfc.chatbot;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChatbotRequest {
  private String mensaje;
  private String contexto; // Contexto adicional (opcional)
}
