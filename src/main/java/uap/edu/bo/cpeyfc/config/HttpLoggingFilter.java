package uap.edu.bo.cpeyfc.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerExecutionChain;
import org.springframework.web.servlet.mvc.method.RequestMappingInfo;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;

import java.io.IOException;
import java.util.Map;

@Slf4j
@Component
public class HttpLoggingFilter extends OncePerRequestFilter {

  private final RequestMappingHandlerMapping handlerMapping;

  public HttpLoggingFilter(@Qualifier("requestMappingHandlerMapping") RequestMappingHandlerMapping handlerMapping) {
    this.handlerMapping = handlerMapping;
  }

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                  FilterChain filterChain) throws ServletException, IOException {

    long startTime = System.currentTimeMillis();

    // Log REQUEST
    logRequest(request);

    // Procesar
    filterChain.doFilter(request, response);

    // Log RESPONSE
    logResponse(response, System.currentTimeMillis() - startTime);
  }

  private void logRequest(HttpServletRequest request) {
    String query = request.getQueryString() != null ? "?" + request.getQueryString() : "";
    String accept = request.getHeader("Accept");
    String referer = request.getHeader("Referer");

    String controllerName = getControllerName(request);

    log.info("{} [{}] {} {} | Accept: {} | Referer: {}",
      controllerName,
      request.getMethod(),
      request.getRequestURI(),
      query,
      accept != null ? accept : "N/A",
      referer != null ? referer : "N/A");
  }

  private String getControllerName(HttpServletRequest request) {
    // Estrategia 1: Intentar obtener el handler normal
    try {
      HandlerExecutionChain handler = handlerMapping.getHandler(request);
      if (handler != null && handler.getHandler() instanceof HandlerMethod handlerMethod) {
        return handlerMethod.getBeanType().getSimpleName();
      }
    } catch (Exception e) {
      // Continuar a la estrategia 2
      log.trace("Handler normal no disponible: {}", e.getMessage());
    }

    // Estrategia 2: Buscar en los mappings registrados (ignorando métdo HTTP)
    try {
      Map<RequestMappingInfo, HandlerMethod> handlerMethods = handlerMapping.getHandlerMethods();
      String requestPath = request.getRequestURI();

      for (Map.Entry<RequestMappingInfo, HandlerMethod> entry : handlerMethods.entrySet()) {
        RequestMappingInfo mappingInfo = entry.getKey();

        // Verificar si el path coincide (ignorando el métdo HTTP)
        if (mappingInfo.getPathPatternsCondition() != null) {
          boolean matches = mappingInfo.getPathPatternsCondition().getPatterns()
            .stream()
            .anyMatch(pattern -> pattern.matches(org.springframework.web.util.ServletRequestPathUtils.getParsedRequestPath(request)));

          if (matches) {
            return entry.getValue().getBeanType().getSimpleName();
          }
        }
      }
    } catch (Exception e) {
      log.trace("No se pudo buscar en mappings: {}", e.getMessage());
    }

    return "Unknown";
  }

  private void logResponse(HttpServletResponse response, long duration) {
    String emoji = response.getStatus() < 400 ? "✅" : "❌";
    log.info("{} Status: {} | {}ms", emoji, response.getStatus(), duration);
  }

  @Override
  protected boolean shouldNotFilter(HttpServletRequest request) {
    String path = request.getRequestURI();
    return path.startsWith("/static") ||
           path.startsWith("/css") ||
           path.startsWith("/js");
  }
}