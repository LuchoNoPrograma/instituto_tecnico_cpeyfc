# MIGRACIÓN V025: Sistema Académico Completo CPEyFP

## 📋 Resumen

Esta migración implementa la estructura completa del sistema académico incluyendo:
- Gestión y periodos académicos
- Modalidades de graduación y certificaciones
- Colegios, convenios y descuentos
- Aranceles diferenciados por tipo de estudiante
- Calificaciones desglosadas por competencias
- Contratos docentes
- Apoderados y colegios de procedencia

## 🎯 Objetivo

Migrar de un modelo simplificado a un sistema académico robusto que soporte:
1. Múltiples programas (Técnico Medio, Técnico Superior, Cursos Cortos)
2. Convenios institucionales con descuentos
3. Aranceles diferenciados (Nacional, UAP, Extranjero)
4. Calificaciones por competencias (Listening, Speaking, etc.)
5. Certificaciones intermedias y terminales
6. Gestión de periodos académicos

## 📊 Estructura de Tablas

### NUEVAS TABLAS CREADAS (17)

#### Gestión Académica (2)
- `aca_gestion`: Gestiones anuales (años lectivos)
- `aca_periodo`: Periodos académicos (semestres/trimestres)

#### Certificaciones (5)
- `aca_modalidad_graduacion`: Catálogo de modalidades (examen, tesis, etc.)
- `aca_titulo_certificado`: Catálogo de títulos/certificados
- `aca_certificacion_programa`: Define qué títulos emite cada programa
- `aca_programa_modalidad_graduacion`: Modalidades permitidas por programa
- `aca_certificado_emitido`: Registro de certificados emitidos

#### Colegios y Convenios (3)
- `aca_colegio`: Colegios de procedencia
- `fin_convenio`: Convenios con descuentos
- `fin_colegio_convenio`: Relación N:N colegios-convenios

#### Financiero (5)
- `aca_tipo_estudiante`: Clasificación para aranceles
- `fin_concepto_arancel`: Catálogo de conceptos (inscripción, colegiatura)
- `fin_arancel`: Aranceles oficiales
- `fin_detalle_arancel`: Desglose de conceptos
- `fin_descuento_arancel`: Descuentos por antigüedad

#### Calificaciones (2)
- `eje_area_evaluacion`: Catálogo de competencias evaluables
- `eje_detalle_calificacion`: Desglose por competencia

### TABLAS MODIFICADAS (8)

1. **aca_programa_aprobado**
   - `+ sistema_programa` (REGULAR/ACELERADO/MODULAR)

2. **prs_persona**
   - `+ id_aca_colegio_procedencia` (FK a aca_colegio)
   - `+ id_prs_persona_apoderado` (FK recursiva)
   - `+ tipo_relacion_apoderado`
   - `+ telefono_apoderado`
   - `+ email_apoderado`

3. **eje_docente**
   - `+ numero_contrato`
   - `+ fecha_inicio_contrato`
   - `+ fecha_fin_contrato`
   - `+ nivel_academico`
   - `+ especialidad`
   - `+ hoja_vida_uri`

4. **eje_cronograma_modulo**
   - `+ id_aca_periodo` (FK)
   - `+ id_eje_docente` (FK)
   - `+ fecha_inicio_inscripciones`
   - `+ fecha_fin_inscripciones`
   - `+ permite_inscripciones`

5. **ins_grupo**
   - `+ codigo_paralelo` (A, B, C)
   - `+ horario`
   - `+ aula`
   - `+ fecha_inicio`
   - `+ fecha_fin`
   - `+ cupo_maximo`

6. **ins_matricula**
   - `+ id_aca_tipo_estudiante` (FK)
   - `+ id_fin_arancel_aplicado` (FK)
   - `+ id_fin_convenio_aplicado` (FK)
   - `+ numero_periodo_cursando`
   - `+ es_estudiante_antiguo`
   - `~ id_ins_grupo` (ahora permite NULL)

7. **fin_obligacion_pago**
   - `+ metodo_pago`
   - `+ monto_base`
   - `+ monto_descuento_arancel`
   - `+ monto_descuento_convenio`
   - `+ monto_final`
   - `+ comprobante_pago_uri`
   - `+ observaciones_pago`

8. **eje_calificacion**
   - `+ comentario_general`
   - `+ total_faltas`
   - `+ debe_repetir`
   - `+ pasa_a_modulo` (FK)

## 🔄 Flujos Implementados

### Flujo de Inscripción con Descuentos

```
1. Estudiante se preinscribe
   └─> ins_matricula (id_ins_grupo = NULL)

2. Sistema determina:
   ├─> Tipo estudiante (Nacional/UAP/Extranjero)
   ├─> Arancel aplicable (id_fin_arancel_aplicado)
   ├─> Colegio de procedencia (prs_persona.id_aca_colegio_procedencia)
   └─> Convenio del colegio (fin_colegio_convenio)

3. Cálculo de pago:
   ├─> Monto base (fin_arancel)
   ├─> - Descuento arancel (antigüedad)
   ├─> - Descuento convenio (colegio)
   └─> = Monto final (fin_obligacion_pago)

4. Asignación a grupo:
   └─> ins_matricula.id_ins_grupo = [grupo seleccionado]
```

### Flujo de Certificación

```
1. Estudiante completa periodos requeridos

2. Sistema valida:
   ├─> ¿Cursó este programa? (ins_matricula)
   ├─> ¿Completó periodos necesarios? (aca_certificacion_programa)
   └─> ¿Existe salida para este programa?

3. Si cumple requisitos:
   └─> Genera aca_certificado_emitido
       ├─> numero_certificado único
       ├─> hash_verificacion
       └─> archivo_pdf_uri
```

### Flujo de Calificación por Competencias

```
1. Docente registra calificación principal:
   └─> eje_calificacion (nota_parcial, nota_final)

2. Docente desglosa por competencias:
   └─> eje_detalle_calificacion (múltiples registros)
       ├─> Listening: 90 pts
       ├─> Speaking: 85 pts
       ├─> Reading: 92 pts
       ├─> Writing: 88 pts
       ├─> Vocabulary: 87 pts
       └─> Grammar: 89 pts

3. Sistema calcula promedio:
   └─> eje_calificacion.nota_final = AVG(notas_areas)
```

## 🗺️ Diagrama de Relaciones Clave

```
aca_programa_aprobado
├─> aca_certificacion_programa (1:N)
│   └─> aca_titulo_certificado (N:1)
├─> fin_arancel (1:N)
│   ├─> fin_detalle_arancel (1:N)
│   └─> fin_descuento_arancel (1:N)
└─> aca_programa_modalidad_graduacion (1:N)
    └─> aca_modalidad_graduacion (N:1)

aca_colegio
├─> prs_persona.id_aca_colegio_procedencia (1:N)
└─> fin_colegio_convenio (1:N)
    └─> fin_convenio (N:1)

prs_persona (estudiante)
├─> prs_persona.id_prs_persona_apoderado (1:1 recursiva)
├─> ins_matricula (1:N)
│   ├─> id_aca_tipo_estudiante (N:1)
│   ├─> id_fin_arancel_aplicado (N:1)
│   └─> id_fin_convenio_aplicado (N:1)
└─> aca_certificado_emitido (1:N)

eje_calificacion
└─> eje_detalle_calificacion (1:N)
    └─> eje_area_evaluacion (N:1)
```

## 📝 Datos Iniciales (Seeds)

La migración incluye datos iniciales para:

1. **Modalidades de Graduación**:
   - Graduación Directa (TUM)
   - Examen de Grado (TUS)
   - Proyecto de Grado
   - Monografía
   - Certificado por Culminación
   - Certificado de Asistencia

2. **Tipos de Estudiante**:
   - Nacional
   - Estudiante UAP
   - Extranjero

3. **Conceptos de Arancel**:
   - Inscripción
   - Cédula Universitaria
   - Carpeta Única
   - Colegiatura Semestral
   - Colegiatura Trimestral
   - Certificado de Egreso
   - Título en Provisión Nacional

4. **Áreas de Evaluación (Idiomas)**:
   - Listening
   - Speaking
   - Reading
   - Writing
   - Vocabulary
   - Grammar

## ⚠️ Consideraciones Importantes

### Integridad Referencial

1. **Apoderados**: Relación recursiva en `prs_persona`
   - `id_prs_persona_apoderado` puede ser NULL (estudiantes sin apoderado)
   - Un apoderado puede tener múltiples estudiantes a cargo

2. **Convenios**: Solo se aplican si el colegio tiene convenio activo
   - Validar vigencia: `CURRENT_DATE BETWEEN fecha_inicio AND fecha_fin`

3. **Certificaciones**: Validación estricta
   - Solo puede certificarse en programas que cursó
   - Solo si completó periodos requeridos

### Validaciones de Negocio

1. **Descuentos acumulables**:
   ```
   Monto Final = Monto Base - Desc. Arancel - Desc. Convenio
   ```

2. **Fechas de inscripción**:
   ```
   eje_cronograma_modulo.permite_inscripciones = true
   AND CURRENT_DATE BETWEEN fecha_inicio_inscripciones AND fecha_fin_inscripciones
   ```

3. **Capacidad de grupos**:
   ```
   COUNT(ins_matricula) < ins_grupo.cupo_maximo
   ```

## 🚀 Próximos Pasos

Después de ejecutar esta migración, será necesario crear:

1. **Vistas SQL** (próxima migración):
   - vista_cursos_disponibles
   - vista_estudiantes_por_curso
   - vista_resumen_calificaciones
   - vista_certificaciones_pendientes

2. **Funciones SQL**:
   - fn_calcular_monto_matricula()
   - fn_validar_emision_certificado()
   - fn_obtener_siguiente_nivel()
   - fn_registrar_calificacion_completa()

3. **Triggers**:
   - trg_validar_cupo_grupo
   - trg_aplicar_descuentos_automaticos
   - trg_actualizar_estado_periodo

## 📞 Soporte

Para dudas o problemas con esta migración:
- Revisar logs de PostgreSQL
- Verificar constraints fallidos
- Consultar documentación del proyecto

---

**Versión**: V025
**Fecha**: 2025-01-XX
**Autor**: CPEyFP Dev Team