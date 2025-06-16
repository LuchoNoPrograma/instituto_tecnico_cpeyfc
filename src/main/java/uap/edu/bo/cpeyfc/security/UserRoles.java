package uap.edu.bo.cpeyfc.security;

/**
 * @deprecated Usar el sistema de roles dinámico basado en base de datos.
 * Esta clase se mantiene temporalmente para compatibilidad.
 */
@Deprecated(since = "1.0", forRemoval = true)
public class UserRoles {

    /**
     * @deprecated Usar SecurityService.hasRole("MATRICULADO") en su lugar
     */
    @Deprecated
    public static final String MATRICULADO = "MATRICULADO";

    /**
     * @deprecated Usar SecurityService.hasRole("DOCENTE") en su lugar
     */
    @Deprecated
    public static final String DOCENTE = "DOCENTE";

    /**
     * @deprecated Usar SecurityService.hasRole("ADMINISTRATIVO") en su lugar
     */
    @Deprecated
    public static final String ADMINISTRATIVO = "ADMINISTRATIVO";

    /**
     * @deprecated Usar SecurityService.hasRole("DESARROLLO") en su lugar
     */
    @Deprecated
    public static final String DESARROLLO = "DESARROLLO";

    private UserRoles() {
        // Utility class
    }
}