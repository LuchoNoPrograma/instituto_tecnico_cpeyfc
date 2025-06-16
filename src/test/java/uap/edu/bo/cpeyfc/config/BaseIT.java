package uap.edu.bo.cpeyfc.config;

import io.restassured.RestAssured;
import jakarta.annotation.PostConstruct;
import lombok.SneakyThrows;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.util.StreamUtils;
import org.testcontainers.containers.PostgreSQLContainer;
import uap.edu.bo.cpeyfc.CpeyfcApplication;
import uap.edu.bo.cpeyfc.domain.aca_area.AcaAreaRepository;
import uap.edu.bo.cpeyfc.domain.aca_modalidad.AcaModalidadRepository;
import uap.edu.bo.cpeyfc.domain.aca_modulo.AcaModuloRepository;
import uap.edu.bo.cpeyfc.domain.aca_nivel.AcaNivelRepository;
import uap.edu.bo.cpeyfc.domain.aca_parametro_programa.AcaParametroProgramaRepository;
import uap.edu.bo.cpeyfc.domain.aca_plan_estudio.AcaPlanEstudioRepository;
import uap.edu.bo.cpeyfc.domain.aca_plan_modulo_detalle.AcaPlanModuloDetalleRepository;
import uap.edu.bo.cpeyfc.domain.aca_programa.AcaProgramaRepository;
import uap.edu.bo.cpeyfc.domain.aca_programa_aprobado.AcaProgramaAprobadoRepository;
import uap.edu.bo.cpeyfc.domain.aca_version.AcaVersionRepository;
import uap.edu.bo.cpeyfc.domain.cer_certificado.CerCertificadoRepository;
import uap.edu.bo.cpeyfc.domain.cer_impresion.CerImpresionRepository;
import uap.edu.bo.cpeyfc.domain.cer_titulacion.CerTitulacionRepository;
import uap.edu.bo.cpeyfc.domain.eje_administrativo.EjeAdministrativoRepository;
import uap.edu.bo.cpeyfc.domain.eje_calificacion.EjeCalificacionRepository;
import uap.edu.bo.cpeyfc.domain.eje_criterio_eval.EjeCriterioEvalRepository;
import uap.edu.bo.cpeyfc.domain.eje_cronograma_modulo.EjeCronogramaModuloRepository;
import uap.edu.bo.cpeyfc.domain.eje_docente.EjeDocenteRepository;
import uap.edu.bo.cpeyfc.domain.eje_programacion.EjeProgramacionRepository;
import uap.edu.bo.cpeyfc.domain.fin_concepto_pago.FinConceptoPagoRepository;
import uap.edu.bo.cpeyfc.domain.fin_detalle_pago.FinDetallePagoRepository;
import uap.edu.bo.cpeyfc.domain.fin_obligacion_pago.FinObligacionPagoRepository;
import uap.edu.bo.cpeyfc.domain.fin_transaccion.FinTransaccionRepository;
import uap.edu.bo.cpeyfc.domain.ins_grupo.InsGrupoRepository;
import uap.edu.bo.cpeyfc.domain.ins_matricula.InsMatriculaRepository;
import uap.edu.bo.cpeyfc.domain.ins_preinscripcion.InsPreinscripcionRepository;
import uap.edu.bo.cpeyfc.domain.prs_persona.PrsPersonaRepository;
import uap.edu.bo.cpeyfc.domain.seg_designa.SegDesignaRepository;
import uap.edu.bo.cpeyfc.domain.seg_ocupa.SegOcupaRepository;
import uap.edu.bo.cpeyfc.domain.seg_rol.SegRolRepository;
import uap.edu.bo.cpeyfc.domain.seg_tarea.SegTareaRepository;
import uap.edu.bo.cpeyfc.domain.seg_usuario.SegUsuarioRepository;
import uap.edu.bo.cpeyfc.domain.tgr_monografia.TgrMonografiaRepository;
import uap.edu.bo.cpeyfc.domain.tgr_observacion_monografia.TgrObservacionMonografiaRepository;
import uap.edu.bo.cpeyfc.domain.tgr_revision_monografia.TgrRevisionMonografiaRepository;

import java.nio.charset.StandardCharsets;


/**
 * Abstract base class to be extended by every IT test. Starts the Spring Boot context with a
 * Datasource connected to the Testcontainers Docker instance. The instance is reused for all tests,
 * with all data wiped out before each test.
 */
@SpringBootTest(
        classes = CpeyfcApplication.class,
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT
)
@ActiveProfiles("it")
@Sql({"/data/clearAll.sql", "/data/segUsuarioData.sql"})
@SqlMergeMode(SqlMergeMode.MergeMode.MERGE)
public abstract class BaseIT {

    @ServiceConnection
    private static final PostgreSQLContainer<?> postgreSQLContainer = new PostgreSQLContainer<>("postgres:17.5");

    static {
        postgreSQLContainer.withReuse(true)
                .start();
    }

    @LocalServerPort
    public int serverPort;

    @Autowired
    public AcaParametroProgramaRepository acaParametroProgramaRepository;

    @Autowired
    public CerImpresionRepository cerImpresionRepository;

    @Autowired
    public CerCertificadoRepository cerCertificadoRepository;

    @Autowired
    public CerTitulacionRepository cerTitulacionRepository;

    @Autowired
    public EjeAdministrativoRepository ejeAdministrativoRepository;

    @Autowired
    public EjeCalificacionRepository ejeCalificacionRepository;

    @Autowired
    public EjeCriterioEvalRepository ejeCriterioEvalRepository;

    @Autowired
    public EjeCronogramaModuloRepository ejeCronogramaModuloRepository;

    @Autowired
    public AcaPlanModuloDetalleRepository acaPlanModuloDetalleRepository;

    @Autowired
    public AcaPlanEstudioRepository acaPlanEstudioRepository;

    @Autowired
    public AcaNivelRepository acaNivelRepository;

    @Autowired
    public AcaModuloRepository acaModuloRepository;

    @Autowired
    public EjeDocenteRepository ejeDocenteRepository;

    @Autowired
    public EjeProgramacionRepository ejeProgramacionRepository;

    @Autowired
    public FinDetallePagoRepository finDetallePagoRepository;

    @Autowired
    public FinObligacionPagoRepository finObligacionPagoRepository;

    @Autowired
    public FinConceptoPagoRepository finConceptoPagoRepository;

    @Autowired
    public FinTransaccionRepository finTransaccionRepository;

    @Autowired
    public InsPreinscripcionRepository insPreinscripcionRepository;

    @Autowired
    public SegDesignaRepository segDesignaRepository;

    @Autowired
    public SegOcupaRepository segOcupaRepository;

    @Autowired
    public SegTareaRepository segTareaRepository;

    @Autowired
    public SegRolRepository segRolRepository;

    @Autowired
    public TgrObservacionMonografiaRepository tgrObservacionMonografiaRepository;

    @Autowired
    public TgrRevisionMonografiaRepository tgrRevisionMonografiaRepository;

    @Autowired
    public TgrMonografiaRepository tgrMonografiaRepository;

    @Autowired
    public InsMatriculaRepository insMatriculaRepository;

    @Autowired
    public PrsPersonaRepository prsPersonaRepository;

    @Autowired
    public SegUsuarioRepository segUsuarioRepository;

    @Autowired
    public InsGrupoRepository insGrupoRepository;

    @Autowired
    public AcaProgramaAprobadoRepository acaProgramaAprobadoRepository;

    @Autowired
    public AcaVersionRepository acaVersionRepository;

    @Autowired
    public AcaModalidadRepository acaModalidadRepository;

    @Autowired
    public AcaProgramaRepository acaProgramaRepository;

    @Autowired
    public AcaAreaRepository acaAreaRepository;

    @PostConstruct
    public void initRestAssured() {
        RestAssured.port = serverPort;
        RestAssured.urlEncodingEnabled = false;
        RestAssured.enableLoggingOfRequestAndResponseIfValidationFails();
    }

    @SneakyThrows
    public String readResource(final String resourceName) {
        return StreamUtils.copyToString(getClass().getResourceAsStream(resourceName), StandardCharsets.UTF_8);
    }

    public String matriculadoSecurityConfigToken() {
        // user matriculado, expires 2040-01-01
        return "Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9." +
                "eyJzdWIiOiJtYXRyaWN1bGFkbyIsInJvbGVzIjpbIk1BVFJJQ1VMQURPIl0sImlzcyI6ImJvb3RpZnkiLCJpYXQiOjE3NDk5NjY0ODUsImV4cCI6MjIwODk4ODgwMH0." +
                "0FwpHuptwgYYFV5l5OUg8mAlwa7JhT13dtTu0_7RvbFUoE5SkKmXafKEEvaT-31YJ5v8u-k8p4-I72W_ztXn8g";
    }

    public String docenteSecurityConfigToken() {
        // user docente, expires 2040-01-01
        return "Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9." +
                "eyJzdWIiOiJkb2NlbnRlIiwicm9sZXMiOlsiRE9DRU5URSJdLCJpc3MiOiJib290aWZ5IiwiaWF0IjoxNzQ5OTY2NDg1LCJleHAiOjIyMDg5ODg4MDB9." +
                "qMPQF4P6rEmVzNO_DB8ADqvF6e2OJGWPS4Yzt6Il6rKS_54JswWJ9Ikz8Gpa0cbjyao179YRdIhBFa7d7hhwJQ";
    }

    public String administrativoSecurityConfigToken() {
        // user administrativo, expires 2040-01-01
        return "Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9." +
                "eyJzdWIiOiJhZG1pbmlzdHJhdGl2byIsInJvbGVzIjpbIkFETUlOSVNUUkFUSVZPIl0sImlzcyI6ImJvb3RpZnkiLCJpYXQiOjE3NDk5NjY0ODUsImV4cCI6MjIwODk4ODgwMH0." +
                "u_6SwKwgqtIdKbxeKmQK-gzNEf7cnxytRmoJMMTG97wuB0Rs4eqseUSvxAi6RhIB1EUUBhNyu0yWTPQyjA3tkQ";
    }

    public String desarrolloSecurityConfigToken() {
        // user desarrollo, expires 2040-01-01
        return "Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9." +
                "eyJzdWIiOiJkZXNhcnJvbGxvIiwicm9sZXMiOlsiREVTQVJST0xMTyJdLCJpc3MiOiJib290aWZ5IiwiaWF0IjoxNzQ5OTY2NDg1LCJleHAiOjIyMDg5ODg4MDB9." +
                "xMCXrZ-9ncCnT5o1Psyn9zosFIh-R-NAM2O1XC2FvzvVDFZkAWohqrOpNFspWxnU95BsdGyJpM76ekaCIPeDmw";
    }

}
