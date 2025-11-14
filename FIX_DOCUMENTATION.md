# 🔧 FIX: Usuario Duplicado en Matrícula

## 📌 Problema Identificado

### Error Original
```
org.springframework.dao.DataIntegrityViolationException:
JDBC exception executing SQL [SELECT * FROM fn_activar_usuario_matricula(?, ?)]
[ERROR: llave duplicada viola restricción de unicidad «pk_seg_ocupa»
  Detail: Ya existe la llave (id_seg_rol, id_seg_usuario)=(5, 16).
```

### Causa Raíz

La función `fn_matricular_preinscrito_completo_v2()` **creaba usuarios duplicados** porque:

1. **Búsqueda incorrecta**: Buscaba usuario existente por `nombre_usuario = CI`
   ```sql
   -- ❌ INCORRECTO (código anterior)
   SELECT id_seg_usuario INTO v_id_usuario
   FROM seg_usuario
   WHERE nombre_usuario = v_ci
     AND estado_usuario != 'ELIMINADO';
   ```

2. **Problema**: Si una persona se matriculaba en un segundo programa:
   - La búsqueda por CI podría fallar (si el usuario se creó con otro formato)
   - Se creaba un **nuevo usuario** para la misma persona
   - Se intentaba asignar rol ESTUDIANTE
   - El usuario anterior **YA tenía** ese rol
   - **ERROR**: Violación de PK compuesta `(id_seg_rol, id_seg_usuario)`

3. **Consecuencia**: Una persona con múltiples matrículas tenía múltiples usuarios

---

## ✅ Solución Implementada

### Cambio Principal: Búsqueda por Relación Persona → Matrícula

```sql
-- ✅ CORRECTO (código nuevo)
SELECT m.id_seg_usuario INTO v_id_usuario
FROM ins_matricula m
  INNER JOIN seg_usuario u ON m.id_seg_usuario = u.id_seg_usuario
WHERE m.id_prs_persona = v_id_persona
  AND m.estado_matricula != 'ELIMINADO'
  AND u.estado_usuario != 'ELIMINADO'
LIMIT 1;
```

**¿Por qué funciona?**
- La tabla `ins_matricula` vincula `id_prs_persona` → `id_seg_usuario`
- Si una persona ya tiene matrículas, su usuario está ahí
- **Reutilizamos** ese mismo usuario para nuevas matrículas
- **UN solo usuario por persona** (como debe ser)

---

## 🔄 Flujo Corregido

### Cuando se matricula una persona:

#### **Caso 1: Primera matrícula**
```
1. Buscar usuario por id_prs_persona en ins_matricula
2. NO existe → Crear usuario nuevo
3. Asignar rol ESTUDIANTE
4. Crear matrícula
5. Generar obligaciones de pago
```

#### **Caso 2: Segunda+ matrícula (RE-MATRÍCULA)**
```
1. Buscar usuario por id_prs_persona en ins_matricula
2. SÍ existe → REUTILIZAR ese usuario ✅
3. Asegurar que está ACTIVO
4. Asegurar que tiene rol ESTUDIANTE activo (ON CONFLICT DO UPDATE)
5. Crear nueva matrícula CON EL MISMO USUARIO
6. Generar obligaciones de pago
```

---

## 📝 Archivos Modificados

### 1. **Migración de Flyway**
- **Archivo**: `V20__fix_matriculacion_usuario_duplicado.sql`
- **Ubicación**: `src/main/resources/db/migration/`
- **Contenido**:
  - ✅ `fn_matricular_preinscrito_completo_v2()` corregida
  - ✅ `fn_activar_usuario_matricula()` con `ON CONFLICT DO UPDATE`
  - ✅ `fn_activar_usuario_docente()` con `ON CONFLICT DO UPDATE`
  - ✅ Índice optimizado `idx_matricula_persona_usuario`

### 2. **Script Diagnóstico/Limpieza**
- **Archivo**: `FIX_MATRICULACION_USUARIO_DUPLICADO.sql` (raíz del proyecto)
- **Funciones adicionales**:
  - `fn_diagnostico_usuarios_duplicados()` - Detecta duplicados existentes
  - `fn_consolidar_usuarios_duplicados(id_persona)` - Limpia duplicados

---

## 🚀 Pasos de Implementación

### Paso 1: Aplicar Migración Automática (Flyway)

```bash
# Reiniciar Spring Boot - Flyway ejecutará V20 automáticamente
./mvnw spring-boot:run
```

**¿Qué hace?**
- Ejecuta `V20__fix_matriculacion_usuario_duplicado.sql`
- Reemplaza funciones SQL con versiones corregidas
- Crea índice de optimización

---

### Paso 2: Diagnosticar Datos Existentes

Ejecutar en PostgreSQL:

```sql
-- Ver si hay personas con múltiples usuarios
SELECT * FROM fn_diagnostico_usuarios_duplicados();
```

**Resultado esperado:**
- Si retorna filas → Hay duplicados que limpiar
- Si retorna vacío → No hay duplicados ✅

---

### Paso 3: Limpiar Duplicados (SI EXISTEN)

```sql
-- Consolidar usuarios de una persona específica
SELECT * FROM fn_consolidar_usuarios_duplicados(10); -- Reemplazar 10 con id_prs_persona

-- Resultado:
-- usuario_mantenido | usuarios_eliminados | matriculas_actualizadas | mensaje
-- 16                | 23, 31              | 2                       | Consolidación exitosa...
```

**¿Qué hace esta función?**
1. Encuentra el usuario más antiguo de esa persona (primer usuario creado)
2. Actualiza TODAS las matrículas para usar ese usuario
3. Marca usuarios duplicados como ELIMINADO
4. Retorna resumen de consolidación

---

### Paso 4: Probar Nueva Matrícula

#### Test 1: Re-matricular persona existente

```bash
# Endpoint: POST /api/matricula/matricular-preinscrito-v2
# Payload:
{
  "id_ins_preinscripcion": 123,
  "id_ins_grupo": 45,
  "id_tipo_beneficiario": 1,
  "id_convenio": null
}
```

**Verificación:**
1. La matrícula se crea exitosamente
2. El mensaje retorna: `"Matrícula exitosa (usuario reutilizado)..."`
3. En BD: Verificar que `ins_matricula.id_seg_usuario` es el mismo que en matrículas anteriores

```sql
-- Verificar que todas las matrículas de una persona usan el mismo usuario
SELECT
  m.cod_ins_matricula,
  m.id_prs_persona,
  m.id_seg_usuario,
  u.nombre_usuario,
  g.nombre_grupo
FROM ins_matricula m
  INNER JOIN seg_usuario u ON m.id_seg_usuario = u.id_seg_usuario
  INNER JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
WHERE m.id_prs_persona = 10  -- Reemplazar con id de persona
  AND m.estado_matricula != 'ELIMINADO'
ORDER BY m.fecha_reg;

-- RESULTADO ESPERADO: Todas las filas tienen el MISMO id_seg_usuario
```

#### Test 2: Matricular persona nueva (sin usuario previo)

```bash
# Endpoint: POST /api/matricula/matricular-preinscrito-v2
# Payload: (misma estructura)
```

**Verificación:**
1. La matrícula se crea exitosamente
2. El mensaje retorna: `"Matrícula exitosa (usuario nuevo)..."`
3. Se retorna `password_temporal` (primer nombre + CI)
4. En BD: Nuevo registro en `seg_usuario` con estado `PENDIENTE`

---

## 🔍 Queries de Verificación

### 1. Ver todas las personas y sus usuarios

```sql
SELECT
  p.id_prs_persona,
  p.nombre,
  p.ap_paterno,
  p.ci,
  COUNT(DISTINCT m.id_seg_usuario) AS cantidad_usuarios,
  COUNT(m.cod_ins_matricula) AS cantidad_matriculas,
  STRING_AGG(DISTINCT u.nombre_usuario, ', ') AS usuarios
FROM prs_persona p
  LEFT JOIN ins_matricula m ON p.id_prs_persona = m.id_prs_persona AND m.estado_matricula != 'ELIMINADO'
  LEFT JOIN seg_usuario u ON m.id_seg_usuario = u.id_seg_usuario AND u.estado_usuario != 'ELIMINADO'
WHERE p.estado_persona != 'ELIMINADO'
GROUP BY p.id_prs_persona, p.nombre, p.ap_paterno, p.ci
ORDER BY cantidad_usuarios DESC;
```

**Interpretación:**
- `cantidad_usuarios = 1` y `cantidad_matriculas >= 1` → ✅ CORRECTO
- `cantidad_usuarios > 1` → ❌ HAY DUPLICADOS (ejecutar consolidación)

---

### 2. Ver matrículas de una persona específica

```sql
SELECT
  m.cod_ins_matricula,
  m.id_seg_usuario,
  u.nombre_usuario,
  u.estado_usuario,
  g.nombre_grupo,
  m.fecha_reg AS fecha_matricula
FROM ins_matricula m
  INNER JOIN seg_usuario u ON m.id_seg_usuario = u.id_seg_usuario
  INNER JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
WHERE m.id_prs_persona = 10  -- Reemplazar
  AND m.estado_matricula != 'ELIMINADO'
ORDER BY m.fecha_reg;
```

---

### 3. Ver roles asignados a un usuario

```sql
SELECT
  u.id_seg_usuario,
  u.nombre_usuario,
  r.nombre_rol,
  o.estado_ocupa,
  o.fecha_reg
FROM seg_usuario u
  INNER JOIN seg_ocupa o ON u.id_seg_usuario = o.id_seg_usuario
  INNER JOIN seg_rol r ON o.id_seg_rol = r.id_seg_rol
WHERE u.id_seg_usuario = 16  -- Reemplazar
ORDER BY r.nombre_rol;
```

---

## 🎯 Resultados Esperados

### Antes del Fix

```
Persona 1 (id=10, ci=12345678)
  ├── Matrícula 1 (Programa A, Grupo 1) → Usuario 16 ❌
  ├── Matrícula 2 (Programa B, Grupo 5) → Usuario 23 ❌ DUPLICADO
  └── Matrícula 3 (Programa C, Grupo 8) → Usuario 31 ❌ DUPLICADO

Error: "llave duplicada pk_seg_ocupa (5, 23)"
```

### Después del Fix

```
Persona 1 (id=10, ci=12345678)
  ├── Matrícula 1 (Programa A, Grupo 1) → Usuario 16 ✅
  ├── Matrícula 2 (Programa B, Grupo 5) → Usuario 16 ✅ REUTILIZADO
  └── Matrícula 3 (Programa C, Grupo 8) → Usuario 16 ✅ REUTILIZADO

Mensaje: "Matrícula exitosa (usuario reutilizado) - Grupo: ..."
```

---

## ⚠️ Consideraciones Importantes

### 1. **Datos Históricos**
Si ya hay duplicados en la BD:
- La función `fn_consolidar_usuarios_duplicados()` los limpia
- Ejecutar **antes** de matricular nuevos estudiantes

### 2. **Password Temporal**
- Solo se genera cuando se crea usuario NUEVO
- Al reutilizar usuario, retorna `password_temporal = NULL`
- El usuario usa su contraseña anterior

### 3. **ON CONFLICT DO UPDATE**
Ahora cuando se reutiliza usuario:
```sql
INSERT INTO seg_ocupa(...) VALUES (...)
ON CONFLICT (id_seg_rol, id_seg_usuario)
  DO UPDATE SET estado_ocupa = 'ACTIVO', ...
```
- Si el rol ya existe → Lo reactiva (en lugar de fallar)
- Asegura que roles estén activos

### 4. **Índice de Optimización**
```sql
CREATE INDEX idx_matricula_persona_usuario
  ON ins_matricula(id_prs_persona, id_seg_usuario)
  WHERE estado_matricula != 'ELIMINADO';
```
- Acelera búsqueda de usuario por persona
- Filtro parcial (solo registros no eliminados)

---

## 🧪 Casos de Prueba

### Caso 1: Re-matriculación en mismo programa
```
Escenario: Estudiante se retira y vuelve a matricular en el MISMO programa
Resultado esperado:
  - Reutiliza usuario ✅
  - Reactiva rol ESTUDIANTE ✅
  - Genera nuevas obligaciones de pago ✅
```

### Caso 2: Re-matriculación en programa diferente
```
Escenario: Estudiante completa Programa A y se matricula en Programa B
Resultado esperado:
  - Reutiliza MISMO usuario ✅
  - Mantiene rol ESTUDIANTE ✅
  - Genera obligaciones del nuevo programa ✅
```

### Caso 3: Primera matrícula
```
Escenario: Persona nueva sin matrículas previas
Resultado esperado:
  - Crea usuario nuevo ✅
  - Asigna rol ESTUDIANTE ✅
  - Genera password temporal ✅
```

### Caso 4: Usuario existente inactivo
```
Escenario: Persona con usuario INACTIVO se vuelve a matricular
Resultado esperado:
  - Reutiliza usuario ✅
  - Cambia estado a ACTIVO ✅
  - Reactiva rol ✅
```

---

## 📊 Checklist de Validación

Después de aplicar el fix:

- [ ] Migración V20 ejecutada exitosamente (verificar `flyway_schema_history`)
- [ ] Función `fn_matricular_preinscrito_completo_v2` actualizada
- [ ] Funciones `fn_activar_usuario_*` con ON CONFLICT
- [ ] Índice `idx_matricula_persona_usuario` creado
- [ ] Ejecutar `fn_diagnostico_usuarios_duplicados()` - sin resultados
- [ ] Test: Re-matricular persona existente - sin error
- [ ] Test: Verificar mensaje "usuario reutilizado"
- [ ] Test: Verificar mismo id_seg_usuario en múltiples matrículas
- [ ] Test: Matricular persona nueva - genera password temporal

---

## 🐛 Troubleshooting

### Error persiste después del fix

**Posible causa**: Función no se actualizó en BD

```sql
-- Verificar versión de función
SELECT pg_get_functiondef('fn_matricular_preinscrito_completo_v2'::regproc);

-- Debe contener: "FROM ins_matricula m INNER JOIN seg_usuario u"
-- NO debe contener: "WHERE nombre_usuario = v_ci"
```

**Solución**: Ejecutar manualmente `V20__fix_matriculacion_usuario_duplicado.sql`

---

### Duplicados no se consolidan

**Verificar**:
```sql
SELECT * FROM fn_diagnostico_usuarios_duplicados();
```

**Solución manual**:
```sql
-- Para cada persona con duplicados
SELECT * FROM fn_consolidar_usuarios_duplicados(id_persona);
```

---

## 📞 Contacto

Si el error persiste:
1. Compartir resultado de `fn_diagnostico_usuarios_duplicados()`
2. Compartir logs completos del error
3. Compartir resultado de verificación de función

---

**Estado**: ✅ Fix implementado y listo para deploy
**Versión de migración**: V20
**Fecha**: 2025-01-14
