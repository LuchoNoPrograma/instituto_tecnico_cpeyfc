package uap.edu.bo.cpeyfc.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.domain.seg_designa.SegDesignaRepository;
import uap.edu.bo.cpeyfc.domain.seg_ocupa.SegOcupaRepository;

import java.util.List;


@Service
@Slf4j
public class SecurityService {

  private final SegOcupaRepository segOcupaRepository;
  private final SegDesignaRepository segDesignaRepository;

  public SecurityService(final SegOcupaRepository segOcupaRepository, final SegDesignaRepository segDesignaRepository) {
    this.segOcupaRepository = segOcupaRepository;
    this.segDesignaRepository = segDesignaRepository;
  }

  /**
   * Obtiene el ID del usuario actual autenticado
   */
  public Integer getCurrentUserId() {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    if (authentication != null && authentication.getPrincipal() instanceof JwtSecurityConfigUserDetails userDetails) {
      return userDetails.getIdSegUsuario();
    }
    return null;
  }

  /**
   * Obtiene los roles del usuario actual
   */
  public List<String> getCurrentUserRoles() {
    Integer userId = getCurrentUserId();
    if (userId != null) {
      return segOcupaRepository.findRolesByUsuarioId(userId);
    }
    return List.of();
  }

  /**
   * Obtiene todas las tareas del usuario actual
   */
  public List<String> getCurrentUserTareas() {
    Integer userId = getCurrentUserId();
    if (userId != null) {
      return segDesignaRepository.findAllTareasForUsuario(userId);
    }
    return List.of();
  }

  /**
   * Verifica si el usuario actual tiene un rol específico
   */
  public boolean hasRole(String roleName) {
    Integer userId = getCurrentUserId();
    if (userId != null) {
      return segOcupaRepository.hasRole(userId, roleName);
    }
    return false;
  }

  /**
   * Verifica si el usuario actual tiene una tarea específica
   */
  public boolean hasTarea(String tareaName) {
    Integer userId = getCurrentUserId();
    if (userId != null) {
      return segDesignaRepository.hasTarea(userId, tareaName);
    }
    return false;
  }

  /**
   * Verifica si el usuario actual tiene al menos uno de los roles especificados
   */
  public boolean hasAnyRole(String... roleNames) {
    for (String roleName : roleNames) {
      if (hasRole(roleName)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Verifica si el usuario actual tiene al menos una de las tareas especificadas
   */
  public boolean hasAnyTarea(String... tareaNames) {
    for (String tareaName : tareaNames) {
      if (hasTarea(tareaName)) {
        return true;
      }
    }
    return false;
  }
}