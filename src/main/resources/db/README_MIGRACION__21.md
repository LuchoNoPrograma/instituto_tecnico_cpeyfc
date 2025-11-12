# MIGRACIÓN V026: Vistas y Funciones del Sistema Académico

## 📋 Resumen

Esta migración actualiza y crea vistas y funciones SQL para soportar las nuevas tablas y columnas de la migración V025. Se mantiene la convención de nombres sin prefijos innecesarios.

## 🎯 Cambios Principales

### **VISTAS ACTUALIZADAS (8)**

1. **vista_estudiantes_grupo**
   - ✅ Agregado: tipo_estudiante, colegio_procedencia
   - ✅ Agregado: apoderado_nombre, tipo_relacion_apoderado
   - ✅ Agregado: convenio_aplicado con detalles
   - ✅ Agregado: numero_periodo_cursando, es_estudiante_antiguo

2. **vista_cronogramas_docente**
   - ✅ Agregado: información del periodo académico
   - ✅ Agregado: datos completos del docente (contrato, CI)
   - ✅ Actualizado: conteo de estudiantes con FILTER

3. **vista_planes_estudio_activos**
   - ✅ Agregado: total_modulos, total_horas calculadas

4. **vista_programas_aprobados_detalle**
   - ✅ Agregado: sistema_programa
   - ✅ Agregado: total_certificaciones disponibles

5. **vista_estado_cuenta_estudiante**
   - ✅ Agregado: tipo_estudiante, arancel_aplicado
   - ✅ Agregado: convenio_aplicado
   - ✅ Agregado: desglose de descuentos

### **VISTAS NUEVAS (10)**

6. **vista_gestiones_periodos**
   - Gestiones con sus periodos académicos
   - Flag de periodo actual

7. **vista_periodo_actual**
   - Periodo académico vigente
   - Días restantes del periodo

8. **vista_cursos_disponibles_inscripcion**
   - Cursos disponibles para inscripción
   - Grupos con horarios, aulas y cupos
   - Estado de inscripción calculado
   - Docente asignado

9. **vista_aranceles_vigentes**
   - Aranceles con desglose de conceptos
   - Descuentos disponibles
   - Filtrado por vigencia

10. **vista_convenios_colegios**
    - Convenios asociados a colegios
    - Estado de vigencia
    - Estudiantes beneficiados

11. **vista_certificaciones_programa**
    - Certificaciones disponibles por programa
    - Requisitos de periodos/horas/créditos
    - Modalidades de graduación

12. **vista_estudiantes_aptos_certificacion**
    - Estudiantes que cumplen requisitos
    - Periodos aprobados vs requeridos
    - Validación de deuda

13. **vista_calificaciones_competencia**
    - Calificaciones con desglose por áreas
    - Comentarios por competencia
    - Notas de progress test y class performance

### **FUNCIONES NUEVAS (2)**

14. **fn_calcular_monto_matricula()**
    - Calcula monto con descuentos
    - Aplica descuento por antigüedad
    - Aplica descuento por convenio
    - Retorna desglose de conceptos

15. **fn_validar_emision_certificado()**
    - Valida requisitos de certificación
    - Verifica periodos completados
    - Verifica deuda pendiente

---

## 📊 Detalle de Vistas

### **vista_cursos_disponibles_inscripcion**

La vista más importante para el proceso de inscripción.

```sql
SELECT * FROM vista_cursos_disponibles_inscripcion
WHERE estado_inscripcion = 'ABIERTO'
```

**Campos retornados:**
- Información del programa y módulo
- Periodo académico
- Docente asignado
- Grupos con horarios y aulas
- Cupos disponibles

**Estados de inscripción:**
- `CERRADO`: No permite inscripciones
- `PROXIMAMENTE`: Antes de fecha de inicio
- `FINALIZADO`: Después de fecha de fin
- `SIN_CUPOS`: Cupo máximo alcanzado
- `ABIERTO`: Disponible para inscripción

---

### **vista_estudiantes_grupo**

Vista completa de estudiantes con toda su información.

```sql
-- Estudiantes de un grupo específico
SELECT * FROM vista_estudiantes_grupo
WHERE id_ins_grupo = 123
  AND estado_matricula = 'ACTIVO'
ORDER BY nombre_completo;
```

**Nuevos campos:**
- `tipo_estudiante`: Nacional, UAP, Extranjero
- `colegio_procedencia`: Colegio del que proviene
- `apoderado_nombre`: Nombre completo del apoderado
- `tipo_relacion_apoderado`: PADRE, MADRE, TUTOR, etc.
- `telefono_apoderado`: Contacto de emergencia
- `nombre_convenio`: Convenio aplicado
- `monto_descuento`: Descuento del convenio
- `numero_periodo_cursando`: Periodo actual
- `es_estudiante_antiguo`: Boolean

---

### **vista_aranceles_vigentes**

Aranceles con desglose completo.

```sql
-- Arancel para un programa específico
SELECT 
  nombre_arancel,
  tipo_estudiante,
  nombre_concepto,
  monto_concepto,
  monto_total
FROM vista_aranceles_vigentes
WHERE nombre_programa = 'Inglés Regular'
  AND tipo_estudiante = 'Nacional'
ORDER BY orden_aplicacion;
```

**Uso:**
- Ver desglose de conceptos (inscripción, colegiatura, etc.)
- Calcular montos antes de inscripción
- Validar aranceles vigentes

---

### **vista_convenios_colegios**

Convenios activos con colegios.

```sql
-- Ver estudiantes beneficiados por convenio
SELECT 
  nombre_convenio,
  nombre_colegio,
  tipo_descuento,
  monto_descuento,
  estudiantes_beneficiados,
  estado_vigencia
FROM vista_convenios_colegios
WHERE estado_vigencia = 'VIGENTE'
ORDER BY estudiantes_beneficiados DESC;
```

**Estados de vigencia:**
- `PROXIMO`: Aún no inicia
- `VIGENTE`: Activo y aplicable
- `VENCIDO`: Fecha de vigencia expirada
- `SUSPENDIDO`: Suspendido temporalmente

---

### **vista_certificaciones_programa**

Certificaciones disponibles.

```sql
-- Ver requisitos de certificación
SELECT 
  nombre_programa,
  nombre_certificacion,
  tipo_certificacion_programa,
  nombre_titulo,
  periodos_requeridos,
  horas_academicas_requeridas,
  modalidades_disponibles
FROM vista_certificaciones_programa
WHERE nombre_programa = 'Inglés Regular'
ORDER BY orden_secuencial;
```

**Resultado esperado:**
```
| nombre_certificacion        | tipo  | periodos | horas | modalidades               |
|----------------------------|-------|----------|-------|---------------------------|
| Técnico Medio en Inglés    | INTER | 2        | 1200  | Graduación Directa        |
| Técnico Superior en Inglés | TERM  | 6        | 3600  | Examen de Grado, Proyecto |
```

---

### **vista_estudiantes_aptos_certificacion**

Estudiantes que pueden certificarse.

```sql
-- Estudiantes aptos para TUS
SELECT 
  nombre_completo,
  ci,
  nombre_certificacion,
  periodos_requeridos,
  periodos_aprobados,
  deuda_pendiente,
  apto_para_certificar
FROM vista_estudiantes_aptos_certificacion
WHERE tipo_certificacion_programa = 'TERMINAL'
  AND apto_para_certificar = true;
```

---

### **vista_calificaciones_competencia**

Calificaciones con desglose por competencias.

```sql
-- Calificaciones de un estudiante
SELECT 
  nombre_estudiante,
  nombre_modulo,
  nombre_area,
  nota_progress_test,
  nota_class_performance,
  nota_final_area,
  comentario_docente
FROM vista_calificaciones_competencia
WHERE cod_ins_matricula = 'MAT-2025-001'
ORDER BY area_orden;
```

**Resultado esperado:**
```
| area       | progress_test | class_perf | final | comentario              |
|------------|---------------|------------|-------|-------------------------|
| Listening  | 90            | 88         | 89    | Excelente comprensión   |
| Speaking   | 85            | 86         | 85.5  | Buena fluidez           |
| Reading    | 92            | 90         | 91    | Comprensión destacada   |
```

---

## 🔧 Funciones

### **fn_calcular_monto_matricula()**

Calcula el monto final con todos los descuentos.

```sql
-- Calcular monto para estudiante nuevo nacional sin convenio
SELECT * FROM fn_calcular_monto_matricula(
  5,    -- id_programa_aprobado (Inglés)
  1,    -- id_tipo_estudiante (Nacional)
  1,    -- numero_periodo (primer periodo)
  NULL  -- sin convenio
);

-- Resultado:
-- monto_base: 450.00
-- descuento_arancel: 0.00 (sin antigüedad)
-- descuento_convenio: 0.00
-- monto_final: 450.00
```

```sql
-- Estudiante antiguo (3er semestre) con convenio
SELECT * FROM fn_calcular_monto_matricula(
  5,    -- Inglés Regular
  1,    -- Nacional
  3,    -- tercer periodo
  2     -- id_convenio (PRIMER CONVENIO)
);

-- Resultado:
-- monto_base: 450.00
-- descuento_arancel: 180.00 (40% por antigüedad)
-- descuento_convenio: 100.00 (convenio colegio)
-- monto_final: 170.00
```

**Parámetros:**
- `p_id_programa_aprobado`: ID del programa
- `p_id_tipo_estudiante`: Tipo (Nacional/UAP/Extranjero)
- `p_numero_periodo`: Periodo que está cursando
- `p_id_fin_convenio`: ID del convenio (NULL si no aplica)

**Retorna:**
- `monto_base`: Suma de conceptos del arancel
- `descuento_arancel`: Descuento por antigüedad
- `descuento_convenio`: Descuento por convenio
- `monto_final`: Total a pagar
- `conceptos`: JSON con desglose

---

### **fn_validar_emision_certificado()**

Valida si un estudiante puede obtener un certificado.

```sql
-- Validar si puede obtener TUM
SELECT * FROM fn_validar_emision_certificado(
  123,  -- id_prs_persona
  1     -- id_certificacion_programa (TUM Inglés)
);

-- Resultado SI CUMPLE:
-- puede_certificar: true
-- mensaje: 'El estudiante cumple todos los requisitos'
-- periodos_requeridos: 2
-- periodos_aprobados: 2
-- deuda_pendiente: 0.00

-- Resultado SI NO CUMPLE:
-- puede_certificar: false
-- mensaje: 'Faltan 1 periodo(s) por aprobar. Deuda pendiente: Bs. 350. '
-- periodos_requeridos: 2
-- periodos_aprobados: 1
-- deuda_pendiente: 350.00
```

---

## 🚀 Casos de Uso

### **Caso 1: Inscribir Estudiante Nuevo**

```sql
-- 1. Ver cursos disponibles
SELECT * FROM vista_cursos_disponibles_inscripcion
WHERE estado_inscripcion = 'ABIERTO'
  AND nivel_orden = 1; -- Solo primer nivel

-- 2. Calcular monto
SELECT * FROM fn_calcular_monto_matricula(5, 1, 1, NULL);

-- 3. Crear matrícula con los datos obtenidos
```

### **Caso 2: Validar Certificación**

```sql
-- 1. Ver certificaciones del programa
SELECT * FROM vista_certificaciones_programa
WHERE nombre_programa = 'Inglés Regular';

-- 2. Verificar si estudiante cumple requisitos
SELECT * FROM fn_validar_emision_certificado(123, 1);

-- 3. Si cumple, emitir certificado
```

### **Caso 3: Ver Estado Financiero**

```sql
-- Ver deuda completa de un estudiante
SELECT 
  nombre_completo,
  nombre_programa,
  concepto_pago,
  monto_base,
  monto_descuento_convenio,
  monto_final,
  saldo_pendiente,
  estado_financiero
FROM vista_estado_cuenta_estudiante
WHERE ci = '12345678';
```

---

## ⚠️ Consideraciones

1. **Performance**: Las vistas usan LEFT JOIN extensivamente, considerar índices en:
   - `prs_persona.id_prs_persona_apoderado`
   - `prs_persona.id_aca_colegio_procedencia`
   - `ins_matricula.id_aca_tipo_estudiante`
   - `ins_matricula.id_fin_convenio_aplicado`

2. **Funciones**: Las funciones calculan en tiempo real, no cachean resultados

3. **Vistas materializadas**: Considerar para vistas complejas con alto uso

---

## 📝 Próximos Pasos

1. Crear triggers para:
   - Validar cupos en grupos
   - Aplicar descuentos automáticos
   - Actualizar estado de periodo

2. Crear más funciones para:
   - Generar certificados PDF
   - Calcular promedios por competencia
   - Reportes financieros

---

**Versión**: V026  
**Fecha**: 2025-01-XX  
**Autor**: CPEyFP Dev Team