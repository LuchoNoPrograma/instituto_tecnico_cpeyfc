package uap.edu.bo.cpeyfc.chatbot;

import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

@Service
@Slf4j
public class ChatbotHistorialService {

  // Mapa para almacenar historial por IP
  private final Map<String, HistorialConversacion> historialPorIp = new ConcurrentHashMap<>();

  // Tiempo de expiración: 30 minutos sin actividad
  private static final int MINUTOS_EXPIRACION = 30;

  /**
   * Obtiene o crea el historial para una IP
   */
  public HistorialConversacion obtenerHistorial(String ip) {
    return historialPorIp.computeIfAbsent(ip, HistorialConversacion::new);
  }

  /**
   * Agrega un mensaje al historial de una IP
   */
  public void agregarMensaje(String ip, String rol, String contenido) {
    HistorialConversacion historial = obtenerHistorial(ip);
    historial.agregarMensaje(rol, contenido);
  }

  /**
   * Obtiene el contexto del historial para una IP
   */
  public String obtenerContextoHistorial(String ip) {
    HistorialConversacion historial = historialPorIp.get(ip);
    if (historial == null) {
      return "";
    }
    return historial.obtenerContextoHistorial();
  }

  /**
   * Limpia el historial de una IP específica
   */
  public void limpiarHistorial(String ip) {
    historialPorIp.remove(ip);
    log.info("Historial limpiado para IP: {}", ip);
  }

  /**
   * Tarea programada que limpia conversaciones inactivas cada 15 minutos
   */
  @Scheduled(fixedRate = 900000) // 15 minutos
  public void limpiarConversacionesInactivas() {
    LocalDateTime tiempoExpiracion = LocalDateTime.now().minusMinutes(MINUTOS_EXPIRACION);
    AtomicInteger eliminados = new AtomicInteger(0);

    historialPorIp.entrySet().removeIf(entry -> {
      if (entry.getValue().getUltimaActividad().isBefore(tiempoExpiracion)) {
        eliminados.incrementAndGet();
        return true;
      }
      return false;
    });

    if (eliminados.get() > 0) { // 👈 Cambio aquí
      log.info("Limpieza automática: {} conversaciones inactivas eliminadas", eliminados.get());
    }
  }

  /**
   * Obtiene estadísticas del caché
   */
  public Map<String, Object> obtenerEstadisticas() {
    return Map.of(
      "conversaciones_activas", historialPorIp.size(),
      "ultima_limpieza", LocalDateTime.now()
    );
  }
}