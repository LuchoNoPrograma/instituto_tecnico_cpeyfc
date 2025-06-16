package uap.edu.bo.cpeyfc.crud;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.lang.reflect.Field;
import java.util.*;

/**
 * Repositorio genérico con validación type-safe usando @FieldNameConstants
 *
 * Uso: repositorio.buscarPorCampo(Usuario.class, Usuario.Fields.email, "test@email.com")
 */
@Repository
@Transactional
public class RepositorioGenericoCrud {

  @PersistenceContext
  private EntityManager entityManager;

  // =================== OPERACIONES CRUD BÁSICAS ===================

  public <T> T guardar(T entidad) {
    if (entityManager.contains(entidad)) {
      return entityManager.merge(entidad);
    } else {
      entityManager.persist(entidad);
      return entidad;
    }
  }

  public <T> Optional<T> buscarPorId(Class<T> claseEntidad, Object id) {
    return Optional.ofNullable(entityManager.find(claseEntidad, id));
  }

  public <T> List<T> buscarTodos(Class<T> claseEntidad) {
    String jpql = "SELECT e FROM " + claseEntidad.getSimpleName() + " e";
    TypedQuery<T> query = entityManager.createQuery(jpql, claseEntidad);
    return query.getResultList();
  }

  public <T> void eliminar(T entidad) {
    entityManager.remove(entidad);
  }

  public <T> boolean eliminarPorId(Class<T> claseEntidad, Object id) {
    String jpql = "DELETE FROM " + claseEntidad.getSimpleName() + " e WHERE e.id = :id";
    Query query = entityManager.createQuery(jpql);
    query.setParameter("id", id);
    return query.executeUpdate() > 0;
  }

  public <T> boolean existe(Class<T> claseEntidad, Object id) {
    String jpql = "SELECT COUNT(e) FROM " + claseEntidad.getSimpleName() + " e WHERE e.id = :id";
    TypedQuery<Long> query = entityManager.createQuery(jpql, Long.class);
    query.setParameter("id", id);
    return query.getSingleResult() > 0;
  }

  public <T> long contar(Class<T> claseEntidad) {
    String jpql = "SELECT COUNT(e) FROM " + claseEntidad.getSimpleName() + " e";
    TypedQuery<Long> query = entityManager.createQuery(jpql, Long.class);
    return query.getSingleResult();
  }

  // =================== BÚSQUEDAS CON VALIDACIÓN TYPE-SAFE ===================

  public <T> boolean existePorCampo(Class<T> claseEntidad, String campo, Object valor) {
    validarCampoExiste(claseEntidad, campo);

    String jpql = "SELECT COUNT(e) FROM " + claseEntidad.getSimpleName() +
                  " e WHERE e." + campo + " = :valor";

    TypedQuery<Long> query = entityManager.createQuery(jpql, Long.class);
    query.setParameter("valor", valor);

    return query.getSingleResult() > 0;
  }

  public <T> List<T> buscarPorCampo(Class<T> claseEntidad, String campo, Object valor) {
    validarCampoExiste(claseEntidad, campo);

    String jpql = "SELECT e FROM " + claseEntidad.getSimpleName() +
                  " e WHERE e." + campo + " = :valor";

    TypedQuery<T> query = entityManager.createQuery(jpql, claseEntidad);
    query.setParameter("valor", valor);

    return query.getResultList();
  }

  public <T> Optional<T> buscarPrimeroPorCampo(Class<T> claseEntidad, String campo, Object valor) {
    List<T> resultados = buscarPorCampo(claseEntidad, campo, valor);
    return resultados.isEmpty() ? Optional.empty() : Optional.of(resultados.get(0));
  }

  public <T> List<T> buscarPorTexto(Class<T> claseEntidad, String campo, String texto) {
    validarCampoExiste(claseEntidad, campo);

    String jpql = "SELECT e FROM " + claseEntidad.getSimpleName() +
                  " e WHERE UPPER(e." + campo + ") LIKE UPPER(:texto)";

    TypedQuery<T> query = entityManager.createQuery(jpql, claseEntidad);
    query.setParameter("texto", "%" + texto + "%");

    return query.getResultList();
  }

  public <T> List<T> buscarTodosConFiltros(Class<T> claseEntidad, Map<String, Object> filtros) {
    return buscarTodosConFiltros(claseEntidad, filtros, null);
  }

  public <T> List<T> buscarTodosConFiltros(Class<T> claseEntidad, Map<String, Object> filtros, String ordenarPor) {
    if (filtros != null) {
      validarCamposExisten(claseEntidad, filtros.keySet().toArray(new String[0]));
    }

    if (ordenarPor != null && !ordenarPor.trim().isEmpty()) {
      String campoOrden = ordenarPor.split("\\s+")[0];
      validarCampoExiste(claseEntidad, campoOrden);
    }

    StringBuilder jpql = new StringBuilder("SELECT e FROM ")
      .append(claseEntidad.getSimpleName())
      .append(" e WHERE 1=1");

    if (filtros != null && !filtros.isEmpty()) {
      filtros.forEach((campo, valor) -> {
        if (valor != null) {
          jpql.append(" AND e.").append(campo).append(" = :param_").append(campo.replace(".", "_"));
        }
      });
    }

    if (ordenarPor != null && !ordenarPor.trim().isEmpty()) {
      jpql.append(" ORDER BY e.").append(ordenarPor);
    }

    TypedQuery<T> query = entityManager.createQuery(jpql.toString(), claseEntidad);

    if (filtros != null) {
      filtros.forEach((campo, valor) -> {
        if (valor != null) {
          query.setParameter("param_" + campo.replace(".", "_"), valor);
        }
      });
    }

    return query.getResultList();
  }

  public <T> long contarConFiltros(Class<T> claseEntidad, Map<String, Object> filtros) {
    if (filtros != null) {
      validarCamposExisten(claseEntidad, filtros.keySet().toArray(new String[0]));
    }

    StringBuilder jpql = new StringBuilder("SELECT COUNT(e) FROM ")
      .append(claseEntidad.getSimpleName())
      .append(" e WHERE 1=1");

    if (filtros != null && !filtros.isEmpty()) {
      filtros.forEach((campo, valor) -> {
        if (valor != null) {
          jpql.append(" AND e.").append(campo).append(" = :param_").append(campo.replace(".", "_"));
        }
      });
    }

    TypedQuery<Long> query = entityManager.createQuery(jpql.toString(), Long.class);

    if (filtros != null) {
      filtros.forEach((campo, valor) -> {
        if (valor != null) {
          query.setParameter("param_" + campo.replace(".", "_"), valor);
        }
      });
    }

    return query.getSingleResult();
  }

  // =================== PAGINACIÓN ===================

  public <T> Page<T> paginar(Class<T> claseEntidad, int pagina, int tamanho) {
    return paginar(claseEntidad, pagina, tamanho, null, null);
  }

  public <T> Page<T> paginar(Class<T> claseEntidad, int pagina, int tamanho, String ordenarPor) {
    return paginar(claseEntidad, pagina, tamanho, ordenarPor, null);
  }

  public <T> Page<T> paginar(Class<T> claseEntidad, int pagina, int tamanho, String ordenarPor, Map<String, Object> filtros) {
    if (filtros != null) {
      validarCamposExisten(claseEntidad, filtros.keySet().toArray(new String[0]));
    }
    if (ordenarPor != null && !ordenarPor.trim().isEmpty()) {
      String campoOrden = ordenarPor.split("\\s+")[0];
      validarCampoExiste(claseEntidad, campoOrden);
    }

    StringBuilder jpql = new StringBuilder("SELECT e FROM ")
      .append(claseEntidad.getSimpleName())
      .append(" e WHERE 1=1");

    if (filtros != null && !filtros.isEmpty()) {
      filtros.forEach((campo, valor) -> {
        if (valor != null) {
          jpql.append(" AND e.").append(campo).append(" = :param_").append(campo.replace(".", "_"));
        }
      });
    }

    if (ordenarPor != null && !ordenarPor.trim().isEmpty()) {
      jpql.append(" ORDER BY e.").append(ordenarPor);
    }

    TypedQuery<T> queryDatos = entityManager.createQuery(jpql.toString(), claseEntidad);

    String jpqlCount = jpql.toString().replaceFirst("SELECT e", "SELECT COUNT(e)");
    if (jpqlCount.contains("ORDER BY")) {
      jpqlCount = jpqlCount.substring(0, jpqlCount.indexOf("ORDER BY"));
    }
    TypedQuery<Long> queryCount = entityManager.createQuery(jpqlCount, Long.class);

    if (filtros != null) {
      filtros.forEach((campo, valor) -> {
        if (valor != null) {
          String paramName = "param_" + campo.replace(".", "_");
          queryDatos.setParameter(paramName, valor);
          queryCount.setParameter(paramName, valor);
        }
      });
    }

    queryDatos.setFirstResult(pagina * tamanho);
    queryDatos.setMaxResults(tamanho);

    List<T> contenido = queryDatos.getResultList();
    long totalElementos = queryCount.getSingleResult();

    Pageable pageable = PageRequest.of(pagina, tamanho);
    return new PageImpl<>(contenido, pageable, totalElementos);
  }

  // =================== CONSULTAS PERSONALIZADAS ===================

  public <T> List<T> ejecutarJpql(String jpql, Class<T> claseResultado, Object... parametros) {
    TypedQuery<T> query = entityManager.createQuery(jpql, claseResultado);

    for (int i = 0; i < parametros.length; i++) {
      query.setParameter(i + 1, parametros[i]);
    }

    return query.getResultList();
  }

  public <T> List<T> ejecutarJpql(String jpql, Class<T> claseResultado, Map<String, Object> parametros) {
    TypedQuery<T> query = entityManager.createQuery(jpql, claseResultado);

    if (parametros != null) {
      parametros.forEach(query::setParameter);
    }

    return query.getResultList();
  }

  public <T> Optional<T> ejecutarJpqlUnico(String jpql, Class<T> claseResultado, Object... parametros) {
    TypedQuery<T> query = entityManager.createQuery(jpql, claseResultado);

    for (int i = 0; i < parametros.length; i++) {
      query.setParameter(i + 1, parametros[i]);
    }

    return query.getResultStream().findFirst();
  }

  public int ejecutarJpqlActualizacion(String jpql, Object... parametros) {
    Query query = entityManager.createQuery(jpql);

    for (int i = 0; i < parametros.length; i++) {
      query.setParameter(i + 1, parametros[i]);
    }

    return query.executeUpdate();
  }

  // =================== UTILIDADES ===================

  public <T> T obtenerReferencia(Class<T> claseEntidad, Object id) {
    return entityManager.getReference(claseEntidad, id);
  }

  public <T> void refrescar(T entidad) {
    entityManager.refresh(entidad);
  }

  public void sincronizar() {
    entityManager.flush();
  }

  public void limpiarContexto() {
    entityManager.clear();
  }

  // =================== VALIDACIONES TYPE-SAFE ===================

  private void validarCampoExiste(Class<?> claseEntidad, String campo) {
    Set<String> camposValidos = extraerCamposDeEntidad(claseEntidad);

    if (!camposValidos.contains(campo)) {
      throw new IllegalArgumentException(
        "Campo '" + campo + "' no existe en " + claseEntidad.getSimpleName() +
        ". Usa " + claseEntidad.getSimpleName() + ".Fields.nombreCampo"
      );
    }
  }

  private void validarCamposExisten(Class<?> claseEntidad, String... campos) {
    for (String campo : campos) {
      validarCampoExiste(claseEntidad, campo);
    }
  }

  private Set<String> extraerCamposDeEntidad(Class<?> claseEntidad) {
    Set<String> campos = new HashSet<>();

    Class<?> claseActual = claseEntidad;
    while (claseActual != null && !claseActual.equals(Object.class)) {
      Field[] camposClase = claseActual.getDeclaredFields();
      for (Field campo : camposClase) {
        if (!java.lang.reflect.Modifier.isStatic(campo.getModifiers()) &&
            !campo.getName().startsWith("$") &&
            !campo.isSynthetic()) {
          campos.add(campo.getName());
        }
      }
      claseActual = claseActual.getSuperclass();
    }

    return campos;
  }
}