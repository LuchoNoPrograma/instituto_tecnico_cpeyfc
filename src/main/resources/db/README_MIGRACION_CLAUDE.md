# 📚 README MASTER - SISTEMA ACADÉMICO CPEyFP

## 🎯 PROPÓSITO DE ESTE DOCUMENTO

Este documento es la **BIBLIA** del proyecto para **Claude Code**. Contiene:
- ✅ Estructura ANTES de las migraciones
- ✅ Estructura DESPUÉS de las migraciones
- ✅ Mapeo completo de cambios
- ✅ Instrucciones para refactorización

**AUDIENCIA**: Claude Code (AI Assistant para refactorización de código)

---

## 📖 ÍNDICE

1. [Contexto del Proyecto](#contexto)
2. [Stack Tecnológico](#stack)
3. [ANTES: Modelo Antiguo](#antes)
4. [DESPUÉS: Modelo Nuevo](#despues)
5. [Mapeo de Cambios](#mapeo)
6. [Convenciones del Proyecto](#convenciones)
7. [Instrucciones para Refactorización](#refactorizacion)

---

## <a name="contexto"></a>🏫 1. CONTEXTO DEL PROYECTO

### Institución
**Universidad Amazónica de Pando - Centro de Proyectos Especiales y Formación Permanente (CPEyFP)**

### Objetivo
Sistema integral de gestión académica para programas de idiomas y cursos técnicos que incluye:
- 📝 Inscripciones y matrículas
- 👨‍🏫 Gestión de docentes y cronogramas
- 📊 Calificaciones por competencias
- 💰 Aranceles diferenciados y convenios
- 🎓 Certificaciones intermedias y terminales
- 📄 Gestión de periodos académicos

### Programas Principales
1. **Inglés Regular** (Sistema REGULAR - 6 semestres)
    - Salida intermedia: TUM (2 semestres)
    - Salida terminal: TUS (6 semestres)

2. **Inglés Acelerado** (Sistema ACELERADO - 4 semestres)

3. **Inglés Modular** (Sistema MODULAR - módulos independientes)

4. **Otros idiomas y cursos técnicos**

---

## <a name="stack"></a>⚙️ 2. STACK TECNOLÓGICO

### Backend
- **Framework**: Spring Boot 3.x
- **ORM**: JPA/Hibernate
- **Database**: PostgreSQL 16+
- **Migraciones**: Flyway
- **Seguridad**: JWT + Spring Security
- **Logging**: SLF4J + Logback

### Frontend
- **Framework**: Vue.js 3
- **UI Library**: Vuetify 3.10.8
- **State Management**: Pinia
- **HTTP Client**: Axios
- **Router**: Vue Router 4

### Base de Datos
- **Tipo**: Relacional (PostgreSQL)
- **Esquema**: public
- **Convenciones**:
    - SQL: `snake_case`
    - Java: `camelCase`
    - Vistas: `vista_tabla` (sin prefijos `vw_`)
    - Funciones: `fn_nombre` (sin prefijos `sp_`)

---

## <a name="antes"></a>📋 3. ANTES: MODELO ANTIGUO

### 3.1. Tablas Principales (ANTES)

#### **aca_programa**
```sql
CREATE TABLE aca_programa (
  id_aca_programa SERIAL PRIMARY KEY,
  id_aca_area INTEGER NOT NULL,
  nombre_programa VARCHAR(100),
  sigla VARCHAR(15),
  estado_programa VARCHAR(35)
  -- NO tenía sistema_programa
);
```

#### **aca_programa_aprobado**
```sql
CREATE TABLE aca_programa_aprobado (
  id_aca_programa_aprobado SERIAL PRIMARY KEY,
  id_aca_programa INTEGER NOT NULL,
  id_aca_plan_estudio INTEGER,
  id_aca_modalidad INTEGER NOT NULL,
  gestion INTEGER,
  precio_matricula NUMERIC(8,2),
  precio_colegiatura NUMERIC(8,2),
  precio_titulacion NUMERIC(8,2)
  -- NO tenía sistema_programa
  -- Precios fijos sin diferenciación
);
```

#### **ins_grupo**
```sql
CREATE TABLE ins_grupo (
  id_ins_grupo SERIAL PRIMARY KEY,
  id_aca_programa_aprobado INTEGER NOT NULL,
  nombre_grupo VARCHAR(100),
  fecha_inicio_inscripcion DATE,
  fecha_fin_inscripcion DATE,
  gestion_inicio INTEGER
  -- NO tenía: horario, aula, codigo_paralelo
);
```

#### **ins_matricula**
```sql
CREATE TABLE ins_matricula (
  cod_ins_matricula SERIAL PRIMARY KEY,
  id_ins_grupo INTEGER NOT NULL,
  id_prs_persona INTEGER NOT NULL,
  id_seg_usuario INTEGER NOT NULL,
  estado_matricula VARCHAR(35),
  tipo_matricula VARCHAR(35)
  -- NO tenía: tipo_estudiante, arancel, convenio
  -- NO diferenciaba: periodo cursando, antigüedad
);
```

#### **eje_cronograma_modulo**
```sql
CREATE TABLE eje_cronograma_modulo (
  id_eje_cronograma_modulo SERIAL PRIMARY KEY,
  id_ins_grupo INTEGER NOT NULL,
  id_aca_plan_modulo_detalle INTEGER,
  fecha_inicio DATE,
  fecha_fin DATE
  -- NO tenía: id_eje_docente, id_aca_periodo
  -- NO tenía: fechas de inscripción, permite_inscripciones
);
```

#### **eje_programacion**
```sql
CREATE TABLE eje_programacion (
  id_eje_programacion SERIAL PRIMARY KEY,
  cod_ins_matricula INTEGER NOT NULL,
  id_eje_cronograma_modulo INTEGER,
  nota_final INTEGER,
  observacion VARCHAR(255)
  -- Nota simple, sin desglose
);
```

#### **eje_calificacion**
```sql
CREATE TABLE eje_calificacion (
  id_eje_calificacion SERIAL PRIMARY KEY,
  id_eje_programacion INTEGER NOT NULL,
  id_eje_criterio_eval INTEGER NOT NULL,
  nota NUMERIC(5,2),
  nota_ponderada NUMERIC(5,2)
  -- NO tenía: comentarios, faltas, repetir
  -- NO había desglose por competencias
);
```

#### **prs_persona**
```sql
CREATE TABLE prs_persona (
  id_prs_persona SERIAL PRIMARY KEY,
  ci VARCHAR(20),
  nombre VARCHAR(100),
  ap_paterno VARCHAR(100),
  ap_materno VARCHAR(100),
  fecha_nacimiento DATE,
  sexo VARCHAR(20)
  -- NO tenía: apoderado, colegio de procedencia
);
```

#### **fin_obligacion_pago**
```sql
CREATE TABLE fin_obligacion_pago (
  id_fin_obligacion_pago SERIAL PRIMARY KEY,
  cod_ins_matricula INTEGER,
  id_fin_concepto_pago INTEGER,
  deuda_con_descuento NUMERIC(10,2),
  saldo_pendiente NUMERIC(10,2)
  -- NO tenía: desglose de descuentos
  -- NO diferenciaba: tipo de descuento aplicado
);
```

### 3.2. Limitaciones del Modelo Antiguo

❌ **SIN gestión de periodos académicos**
- No había tabla `aca_gestion` ni `aca_periodo`
- No se podía relacionar cronogramas con semestres/trimestres

❌ **SIN diferenciación de sistemas de programa**
- Todos los programas se trataban igual
- No se distinguía: REGULAR, ACELERADO, MODULAR

❌ **SIN aranceles diferenciados**
- Precio fijo para todos los estudiantes
- No había concepto de "tipo de estudiante"
- No había: Nacional, UAP, Extranjero

❌ **SIN convenios institucionales**
- No existían descuentos por colegios
- No se registraba colegio de procedencia

❌ **SIN calificaciones por competencias**
- Solo nota final del módulo
- No había desglose: Listening, Speaking, etc.

❌ **SIN certificaciones programadas**
- No había tabla `aca_certificacion_programa`
- No se definían salidas intermedias (TUM) vs terminales (TUS)

❌ **SIN información de apoderados**
- No se registraba apoderado/tutor
- No había contacto de emergencia

❌ **SIN gestión de docentes mejorada**
- No se registraba: contrato, nivel académico
- No había relación directa docente → cronograma

---

## <a name="despues"></a>🎉 4. DESPUÉS: MODELO NUEVO

### 4.1. Tablas NUEVAS Agregadas

Baste en la migracion 20

### 4.2. Modificaciones a Tablas Existentes

Basate en la migracion 20

---

## <a name="mapeo"></a>🔄 5. MAPEO DE CAMBIOS

### 5.1. Flujo de Matriculacion

#### ANTES:
```
Estudiante → ins_matricula (precio fijo del programa)
             ↓
          ins_grupo → aca_programa_aprobado
```

#### DESPUÉS:
```
Estudiante (con colegio y apoderado)
    ↓
Determinar tipo_estudiante (Nacional/UAP/Extranjero)
    ↓
Buscar arancel aplicable
    ↓
Verificar convenio del colegio
    ↓
Calcular descuentos (antigüedad + convenio)
    ↓
ins_matricula (con arancel y convenio aplicados)
    ↓
fin_obligacion_pago (con desglose de descuentos)
```

### 5.2. Flujo de Calificaciones

#### ANTES:
```
eje_programacion.nota_final (simple)
    ↓
eje_calificacion (por criterio)
```

#### DESPUÉS:
```
eje_programacion.nota_final (consolidado)
    ↓
eje_calificacion (por criterio con comentarios)
    ↓
eje_detalle_calificacion (por competencia)
    ├─ Listening
    ├─ Speaking
    ├─ Reading
    ├─ Writing
    ├─ Vocabulary
    └─ Grammar
```

### 5.3. Flujo de Certificación

#### ANTES:
```
❌ NO EXISTÍA
```

#### DESPUÉS:
```
Estudiante completa periodos requeridos
    ↓
Sistema valida:
    ├─ Periodos completados (aca_certificacion_programa)
    ├─ Deuda pendiente = 0
    └─ Programa correcto
    ↓
Si cumple → aca_certificado_emitido
    ├─ numero_certificado único
    ├─ archivo_pdf_uri
    └─ hash_verificacion
```

---

## <a name="convenciones"></a>📐 6. CONVENCIONES DEL PROYECTO

### 6.1. Naming Conventions

#### SQL (snake_case)
```sql
-- Tablas
aca_programa_aprobado
ins_matricula
fin_obligacion_pago

-- Columnas
id_aca_programa_aprobado
numero_periodo_cursando
fecha_inicio_inscripciones

-- Vistas (sin prefijos)
vista_estudiantes_grupo
vista_aranceles_vigentes

-- Funciones (sin prefijos)
fn_calcular_monto_matricula
fn_validar_emision_certificado

-- Triggers
trg_crear_cronogramas_grupo
```

#### Java (camelCase)
```java
// Entities
@Entity
@Table(name = "aca_programa_aprobado")
public class ProgramaAprobado {
    @Id
    @Column(name = "id_aca_programa_aprobado")
    private Integer idProgramaAprobado;
    
    @Column(name = "sistema_programa")
    private String sistemaPrograma;
}

// Repositories
public interface ProgramaAprobadoRepository extends JpaRepository<ProgramaAprobado, Integer> {
    @Query(value = "SELECT * FROM vista_programas_aprobados_detalle", nativeQuery = true)
    List<Map<String, Object>> obtenerProgramasDetalle();
}

// Methods (sin @Param)
@Query(value = "SELECT fn_calcular_monto_matricula(:idPrograma, :idTipo, :periodo, :convenio)", 
       nativeQuery = true)
Map<String, Object> calcularMontoMatricula(Integer idPrograma, 
                                          Integer idTipo, 
                                          Integer periodo, 
                                          Integer convenio);
```

### 6.2. Estados

#### Estados Estándar
```sql
-- Entidades principales
'ACTIVO', 'INACTIVO', 'ELIMINADO'

-- Grupos
'EN OFERTA', 'EN EJECUCION', 'PROGRAMADO', 'FINALIZADO', 'ELIMINADO'

-- Matrículas
'ACTIVO', 'RETIRADO', 'EGRESADO', 'ELIMINADO'

-- Pagos
'PENDIENTE', 'PAGO_PARCIAL', 'PAGADO', 'ANULADO', 'ELIMINADO'

-- Inscripciones (calculado)
'ABIERTO', 'CERRADO', 'PROXIMAMENTE', 'FINALIZADO'
```

### 6.3. Filtros

```sql
-- SIEMPRE filtrar por estado != 'ELIMINADO'
WHERE estado_tabla != 'ELIMINADO'

-- NUNCA usar = 'ACTIVO' a menos que sea necesario
-- Usar != 'ELIMINADO' para incluir ACTIVO e INACTIVO
```

### 6.4. Campos de Auditoría

Todas las tablas tienen:
```sql
fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
fecha_mod TIMESTAMP,
user_reg INTEGER NOT NULL,
user_mod INTEGER
```

---

## <a name="refactorizacion"></a>🔨 7. INSTRUCCIONES PARA REFACTORIZACIÓN

### 7.1. Orden de Refactorización

1. **Entities** (actualizar con nuevos campos)
2. **Repositories** (agregar consultas para vistas nuevas)
3. **Wrappers** (para funciones nuevas)
4. **Services** (lógica de negocio)
5. **Controllers** (endpoints)
6. **DTOs** (transferencia de datos)
7. **Frontend** (componentes Vue)

### 7.2. Entities a Actualizar

#### ProgramaAprobado.java
```java
@Entity
@Table(name = "aca_programa_aprobado")
public class ProgramaAprobado {
    // ... campos existentes ...
    
    // AGREGAR:
    @Column(name = "sistema_programa")
    private String sistemaPrograma;  // REGULAR, ACELERADO, MODULAR
}
```

#### Persona.java
```java
@Entity
@Table(name = "prs_persona")
public class Persona {
    // ... campos existentes ...
    
    // AGREGAR:
    @ManyToOne
    @JoinColumn(name = "id_aca_colegio_procedencia")
    private Colegio colegioProcedencia;
    
    @ManyToOne
    @JoinColumn(name = "id_prs_persona_apoderado")
    private Persona apoderado;
    
    @Column(name = "tipo_relacion_apoderado")
    private String tipoRelacionApoderado;
    
    @Column(name = "telefono_apoderado")
    private String telefonoApoderado;
    
    @Column(name = "email_apoderado")
    private String emailApoderado;
}
```

#### Docente.java
```java
@Entity
@Table(name = "eje_docente")
public class Docente {
    // ... campos existentes ...
    
    // AGREGAR:
    @Column(name = "numero_contrato")
    private String numeroContrato;
    
    @Column(name = "fecha_inicio_contrato")
    private LocalDate fechaInicioContrato;
    
    @Column(name = "fecha_fin_contrato")
    private LocalDate fechaFinContrato;
    
    @Column(name = "nivel_academico")
    private String nivelAcademico;
    
    @Column(name = "especialidad")
    private String especialidad;
    
    @Column(name = "hoja_vida_uri")
    private String hojaVidaUri;
}
```

#### CronogramaModulo.java
```java
@Entity
@Table(name = "eje_cronograma_modulo")
public class CronogramaModulo {
    // ... campos existentes ...
    
    // AGREGAR:
    @ManyToOne
    @JoinColumn(name = "id_aca_periodo")
    private Periodo periodo;
    
    @ManyToOne
    @JoinColumn(name = "id_eje_docente")
    private Docente docente;
    
    @Column(name = "fecha_inicio_inscripciones")
    private LocalDate fechaInicioInscripciones;
    
    @Column(name = "fecha_fin_inscripciones")
    private LocalDate fechaFinInscripciones;
    
    @Column(name = "permite_inscripciones")
    private Boolean permiteInscripciones;
}
```

#### Grupo.java
```java
@Entity
@Table(name = "ins_grupo")
public class Grupo {
    // ... campos existentes ...
    
    // AGREGAR:
    @Column(name = "codigo_paralelo")
    private String codigoParalelo;
    
    @Column(name = "horario")
    private String horario;
    
    @Column(name = "aula")
    private String aula;
    
    @Column(name = "fecha_inicio")
    private LocalDate fechaInicio;
    
    @Column(name = "fecha_fin")
    private LocalDate fechaFin;
    
    // NO AGREGAR cupo_maximo
}
```

#### Matricula.java
```java
@Entity
@Table(name = "ins_matricula")
public class Matricula {
    // ... campos existentes ...
    
    // AGREGAR:
    @ManyToOne
    @JoinColumn(name = "id_aca_tipo_estudiante")
    private TipoEstudiante tipoEstudiante;
    
    @ManyToOne
    @JoinColumn(name = "id_fin_arancel_aplicado")
    private Arancel arancelAplicado;
    
    @ManyToOne
    @JoinColumn(name = "id_fin_convenio_aplicado")
    private Convenio convenioAplicado;
    
    @Column(name = "numero_periodo_cursando")
    private Integer numeroPeriodoCursando;
    
    @Column(name = "es_estudiante_antiguo")
    private Boolean esEstudianteAntiguo;
}
```

#### ObligacionPago.java
```java
@Entity
@Table(name = "fin_obligacion_pago")
public class ObligacionPago {
    // ... campos existentes ...
    
    // AGREGAR:
    @Column(name = "metodo_pago")
    private String metodoPago;
    
    @Column(name = "monto_base")
    private BigDecimal montoBase;
    
    @Column(name = "monto_descuento_arancel")
    private BigDecimal montoDescuentoArancel;
    
    @Column(name = "monto_descuento_convenio")
    private BigDecimal montoDescuentoConvenio;
    
    @Column(name = "monto_final")
    private BigDecimal montoFinal;
    
    @Column(name = "comprobante_pago_uri")
    private String comprobantePagoUri;
    
    @Column(name = "observaciones_pago")
    private String observacionesPago;
}
```

#### Calificacion.java
```java
@Entity
@Table(name = "eje_calificacion")
public class Calificacion {
    // ... campos existentes ...
    
    // AGREGAR:
    @Column(name = "comentario_general")
    private String comentarioGeneral;
    
    @Column(name = "total_faltas")
    private Integer totalFaltas;
    
    @Column(name = "debe_repetir")
    private Boolean debeRepetir;
    
    @ManyToOne
    @JoinColumn(name = "pasa_a_modulo")
    private Modulo pasaAModulo;
}
```

### 7.3. Entities NUEVAS a Crear

Crear estas entidades desde cero:

1. **AcaGestion.java** → aca_gestion
2. **AcaPeriodo.java** → aca_periodo
3. **AcaModalidadGraduacion.java** → aca_modalidad_graduacion
4. **AcaTituloCertificado.java** → aca_titulo_certificado
5. **AcaCertificacionPrograma.java** → aca_certificacion_programa
6. **AcaProgramaModalidadGraduacion.java** → aca_programa_modalidad_graduacion
7. **AcaCertificadoEmitido.java** → aca_certificado_emitido
8. **AcaColegio.java** → aca_colegio
9. **AcaTipoEstudiante.java** → aca_tipo_estudiante
10. **FinConvenio.java** → fin_convenio
11. **FinColegioConvenio.java** → fin_colegio_convenio
12. **FinConceptoArancel.java** → fin_concepto_arancel
13. **FinArancel.java** → fin_arancel
14. **FinDetalleArancel.java** → fin_detalle_arancel
15. **FinDescuentoArancel.java** → fin_descuento_arancel
16. **EjeAreaEvaluacion.java** → eje_area_evaluacion
17. **EjeDetalleCalificacion.java** → eje_detalle_calificacion

### 7.4. Repositories NUEVOS

#### Vistas
```java
public interface VistaRepository {
    // Cursos disponibles
    @Query(value = "SELECT * FROM vista_cursos_disponibles_inscripcion", nativeQuery = true)
    List<Map<String, Object>> cursosDisponiblesInscripcion();
    
    // Estado de cuenta
    @Query(value = "SELECT * FROM vista_estado_cuenta_estudiante WHERE ci = :ci", nativeQuery = true)
    List<Map<String, Object>> estadoCuentaPorCi(String ci);
    
    // Estudiantes aptos para certificar
    @Query(value = "SELECT * FROM vista_estudiantes_aptos_certificacion WHERE apto_para_certificar = true", 
           nativeQuery = true)
    List<Map<String, Object>> estudiantesAptosCertificacion();
    
    // Aranceles vigentes
    @Query(value = "SELECT * FROM vista_aranceles_vigentes WHERE nombre_programa = :programa", 
           nativeQuery = true)
    List<Map<String, Object>> arancelesVigentesPorPrograma(String programa);
    
    // Convenios con colegios
    @Query(value = "SELECT * FROM vista_convenios_colegios WHERE estado_vigencia = 'VIGENTE'", 
           nativeQuery = true)
    List<Map<String, Object>> conveniosVigentes();
    
    // Calificaciones por competencia
    @Query(value = "SELECT * FROM vista_calificaciones_competencia WHERE cod_ins_matricula = :codMatricula", 
           nativeQuery = true)
    List<Map<String, Object>> calificacionesCompetencia(Integer codMatricula);
}
```

#### Funciones (Wrappers)
```java
public interface FuncionesRepository {
    // Calcular monto de matrícula
    @Query(value = """
        SELECT * FROM fn_calcular_monto_matricula(
            :idPrograma, 
            :idTipoEstudiante, 
            :numeroPeriodo, 
            :idConvenio
        )
        """, nativeQuery = true)
    Map<String, Object> calcularMontoMatricula(Integer idPrograma,
                                               Integer idTipoEstudiante,
                                               Integer numeroPeriodo,
                                               Integer idConvenio);
    
    // Validar emisión de certificado
    @Query(value = """
        SELECT * FROM fn_validar_emision_certificado(
            :idPersona, 
            :idCertificacion
        )
        """, nativeQuery = true)
    Map<String, Object> validarEmisionCertificado(Integer idPersona,
                                                  Integer idCertificacion);
}
```

### 7.5. Services

#### ArancelService.java (NUEVO)
```java
@Service
public class ArancelService {
    public MontoMatriculaDTO calcularMonto(Integer idPrograma, 
                                           Integer idTipoEstudiante,
                                           Integer numeroPeriodo,
                                           Integer idConvenio) {
        Map<String, Object> resultado = funcionesRepository.calcularMontoMatricula(
            idPrograma, idTipoEstudiante, numeroPeriodo, idConvenio
        );
        return mapToDTO(resultado);
    }
}
```

#### CertificacionService.java (NUEVO)
```java
@Service
public class CertificacionService {
    public ValidacionCertificadoDTO validarEmision(Integer idPersona, 
                                                   Integer idCertificacion) {
        Map<String, Object> resultado = funcionesRepository.validarEmisionCertificado(
            idPersona, idCertificacion
        );
        return mapToDTO(resultado);
    }
    
    public List<EstudianteAptoCertificacionDTO> obtenerAptos() {
        return vistaRepository.estudiantesAptosCertificacion()
            .stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
    }
}
```

### 7.6. Controllers

#### ArancelController.java (NUEVO)
```java
@RestController
@RequestMapping("/api/aranceles")
public class ArancelController {
    
    @PostMapping("/calcular-monto")
    public ResponseEntity<?> calcularMonto(@RequestBody CalculoMontoRequest request) {
        MontoMatriculaDTO resultado = arancelService.calcularMonto(
            request.getIdPrograma(),
            request.getIdTipoEstudiante(),
            request.getNumeroPeriodo(),
            request.getIdConvenio()
        );
        return ResponseEntity.ok(resultado);
    }
    
    @GetMapping("/vigentes/{programa}")
    public ResponseEntity<?> arancelesVigentes(@PathVariable String programa) {
        List<ArancelDTO> aranceles = vistaRepository.arancelesVigentesPorPrograma(programa)
            .stream()
            .map(this::mapToDTO)
            .collect(Collectors.toList());
        return ResponseEntity.ok(aranceles);
    }
}
```

#### CertificacionController.java (NUEVO)
```java
@RestController
@RequestMapping("/api/certificaciones")
public class CertificacionController {
    
    @GetMapping("/validar/{idPersona}/{idCertificacion}")
    public ResponseEntity<?> validarEmision(@PathVariable Integer idPersona,
                                           @PathVariable Integer idCertificacion) {
        ValidacionCertificadoDTO resultado = certificacionService.validarEmision(
            idPersona, idCertificacion
        );
        return ResponseEntity.ok(resultado);
    }
    
    @GetMapping("/aptos")
    public ResponseEntity<?> estudiantesAptos() {
        List<EstudianteAptoCertificacionDTO> aptos = certificacionService.obtenerAptos();
        return ResponseEntity.ok(aptos);
    }
}
```

### 7.7. DTOs a Crear

```java
// MontoMatriculaDTO.java
public record MontoMatriculaDTO(
    BigDecimal montoBase,
    BigDecimal descuentoArancel,
    BigDecimal descuentoConvenio,
    BigDecimal montoFinal,
    String conceptos  // JSON
) {}

// ValidacionCertificadoDTO.java
public record ValidacionCertificadoDTO(
    Boolean puedeCertificar,
    String mensaje,
    Integer periodosRequeridos,
    Integer periodosAprobados,
    BigDecimal deudaPendiente
) {}

// EstudianteAptoCertificacionDTO.java
public record EstudianteAptoCertificacionDTO(
    Integer codMatricula,
    String nombreCompleto,
    String ci,
    String nombreCertificacion,
    Integer periodosRequeridos,
    Integer periodosAprobados,
    BigDecimal deudaPendiente,
    Boolean aptoParaCertificar
) {}
```

### 7.8. Frontend (Vue.js)

---

## 📋 CHECKLIST DE REFACTORIZACIÓN

### Backend
- [ ] Actualizar entities existentes con nuevos campos
- [ ] Crear 17 entities nuevas
- [ ] Crear repositories para vistas
- [ ] Crear wrappers para funciones
- [ ] Crear services de negocio
- [ ] Crear controllers REST
- [ ] Crear DTOs

### Frontend --Seguir el patron que está en ListaProgramas, con sweetalert, formularios
- [ ] Crear componentes para gestión de periodos
- [ ] Crear componentes para certificaciones
- [ ] Crear componentes para convenios
- [ ] Actualizar formulario de inscripción con listado de precio por programa
- [ ] Actualizar formularios existentes de aquellas tablas que fueron modificadas

### Base de Datos
- [x] Ejecutar V020 (tablas)
- [x] Ejecutar V021 (vistas y funciones)
- [ ] Crear V022 (triggers)
- [ ] Ejecutar V022 (triggers)

---

**Fecha de creación**: 2025-01-12  
**Versión**: 1.0  
**Para**: Claude Code  
**Estado**: ✅ READY FOR REFACTORING

¡TODO LISTO PARA REFACTORIZAR! 🚀