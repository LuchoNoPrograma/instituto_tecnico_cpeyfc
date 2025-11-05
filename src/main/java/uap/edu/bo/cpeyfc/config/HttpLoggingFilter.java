package uap.edu.bo.cpeyfc.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Slf4j
@Component
public class HttpLoggingFilter extends OncePerRequestFilter {

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

    log.info("[{}] {} {} | Accept: {} | Referer: {}",
      request.getMethod(),
      request.getRequestURI(),
      query,
      accept != null ? accept : "N/A",
      referer != null ? referer : "N/A");
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