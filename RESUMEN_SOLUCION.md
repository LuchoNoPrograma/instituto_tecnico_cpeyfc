# 🎯 RESUMEN DE LA SOLUCIÓN

## 📋 Problema Original

```
ERROR: llave duplicada viola restricción de unicidad «pk_seg_ocupa»
Detail: Ya existe la llave (id_seg_rol, id_seg_usuario)=(5, 16).
```

**Causa**: Al re-matricular una persona, se creaba un **usuario nuevo** en lugar de reutilizar el existente.

---

## ✅ Solución Implementada

### Cambios Realizados

#### 1. **Migración V20: Sistema de Aranceles**
- **Archivo**: `V20__migracion_sistema_aranceles.sql`
- **Contenido**:
  - ✅ `fn_calcular_arancel_con_descuento()` - Calcula aranceles con descuentos de convenio
  - ✅ `fn_obtener_conceptos_pago_con_aranceles()` - Obtiene conceptos por tipo de beneficiario
  - ✅ `fn_generar_obligaciones_pago_matricula_regular_v2()` - Genera obligaciones con aranceles
  - ✅ Índices de optimización
  - ✅ Datos iniciales de tipos de beneficiario

#### 2. **Migración V21: Fix Usuario Duplicado**
- **Archivo**: `V21__fix_matriculacion_usuario_duplicado.sql`
- **Contenido**:
  - ✅ `fn_matricular_preinscrito_completo_v2()` **CORREGIDA**
    - Busca usuario por relación `persona → matrícula` (NO por CI)
    - Reutiliza usuario existente
    - Asigna rol con `ON CONFLICT DO UPDATE`
  - ✅ `fn_activar_usuario_matricula()` con manejo de conflictos
  - ✅ `fn_activar_usuario_docente()` con manejo de conflictos
  - ✅ Índice de optimización

#### 3. **Documentación Completa**
- **FIX_DOCUMENTATION.md**: Guía detallada del problema y solución
- **FIX_MATRICULACION_USUARIO_DUPLICADO.sql**: Script con funciones de diagnóstico

---

## 🔍 Cambio Clave

### ANTES (❌ INCORRECTO)
```sql
-- Buscaba usuario por CI
SELECT id_seg_usuario INTO v_id_usuario
FROM seg_usuario
WHERE nombre_usuario = v_ci
  AND estado_usuario != 'ELIMINADO';

-- Si no encontraba, creaba NUEVO usuario
-- Resultado: Múltiples usuarios para la misma persona
```

### DESPUÉS (✅ CORRECTO)
```sql
-- Busca usuario por matrículas anteriores de esta PERSONA
SELECT m.id_seg_usuario INTO v_id_usuario
FROM ins_matricula m
  INNER JOIN seg_usuario u ON m.id_seg_usuario = u.id_seg_usuario
WHERE m.id_prs_persona = v_id_persona
  AND m.estado_matricula != 'ELIMINADO'
  AND u.estado_usuario != 'ELIMINADO'
LIMIT 1;

-- Si encuentra, REUTILIZA ese usuario
-- Resultado: UN solo usuario por persona ✅
```

---

## 📦 Archivos Creados/Modificados

```
instituto_tecnico_cpeyfc/
├── src/main/resources/db/migration/
│   ├── V20__migracion_sistema_aranceles.sql       ← NUEVO (funciones SQL aranceles)
│   └── V21__fix_matriculacion_usuario_duplicado.sql ← NUEVO (fix usuario duplicado)
│
├── FIX_MATRICULACION_USUARIO_DUPLICADO.sql        ← NUEVO (diagnóstico/limpieza)
├── FIX_DOCUMENTATION.md                           ← NUEVO (documentación completa)
└── RESUMEN_SOLUCION.md                            ← ESTE ARCHIVO
```

---

## 🚀 Pasos de Implementación

### 1. Aplicar Migraciones Automáticamente
```bash
# Flyway ejecutará V20 y V21 automáticamente al iniciar
./mvnw clean package
./mvnw spring-boot:run
```

### 2. Verificar Migraciones Aplicadas
```sql
-- En PostgreSQL
SELECT version, description, success, installed_on
FROM flyway_schema_history
WHERE version IN ('20', '21')
ORDER BY installed_rank;

-- Resultado esperado:
-- 20 | migracion sistema aranceles        | true | 2025-01-14 ...
-- 21 | fix matriculacion usuario duplicado | true | 2025-01-14 ...
```

### 3. Diagnosticar Duplicados Existentes
```sql
-- Ejecutar en PostgreSQL
SELECT * FROM fn_diagnostico_usuarios_duplicados();

-- Si retorna filas: Hay duplicados
-- Si retorna vacío: No hay duplicados ✅
```

### 4. Limpiar Duplicados (SI EXISTEN)
```sql
-- Para cada persona con duplicados
SELECT * FROM fn_consolidar_usuarios_duplicados(10); -- Reemplazar 10 con id_prs_persona
```

### 5. Probar Matrícula
```bash
# Endpoint: POST /api/matricula/matricular-preinscrito-v2
# Payload:
{
  "id_ins_preinscripcion": 123,
  "id_ins_grupo": 45,
  "id_tipo_beneficiario": 1,
  "id_convenio": null
}

# Verificar en respuesta:
# - mensaje contiene "usuario reutilizado" (si persona ya tenía usuario)
# - password_temporal = null (si reutilizó usuario)
```

---

## ✅ Validación de la Solución

### Query de Verificación
```sql
-- Verificar que cada persona tiene UN SOLO usuario
SELECT
  p.id_prs_persona,
  CONCAT(p.nombre, ' ', p.ap_paterno) AS nombre,
  COUNT(DISTINCT m.id_seg_usuario) AS cantidad_usuarios,
  COUNT(m.cod_ins_matricula) AS cantidad_matriculas
FROM prs_persona p
  LEFT JOIN ins_matricula m ON p.id_prs_persona = m.id_prs_persona
    AND m.estado_matricula != 'ELIMINADO'
  LEFT JOIN seg_usuario u ON m.id_seg_usuario = u.id_seg_usuario
    AND u.estado_usuario != 'ELIMINADO'
WHERE p.estado_persona != 'ELIMINADO'
GROUP BY p.id_prs_persona, p.nombre, p.ap_paterno
HAVING COUNT(DISTINCT m.id_seg_usuario) > 1; -- Personas con múltiples usuarios

-- RESULTADO ESPERADO: 0 filas (no duplicados)
```

---

## 📊 Casos de Prueba

### ✅ Test 1: Re-matriculación exitosa
```
Persona: Juan Pérez (id_prs_persona = 10)
Matrícula anterior: Programa A → Usuario 16
Nueva matrícula: Programa B → Usuario 16 (REUTILIZADO)

Resultado: ✅ Sin error, mismo usuario
```

### ✅ Test 2: Primera matrícula
```
Persona: María López (id_prs_persona = 20, sin matrículas previas)
Nueva matrícula: Programa C → Usuario 45 (NUEVO)
Password temporal: "MARIA12345678"

Resultado: ✅ Usuario nuevo creado
```

### ✅ Test 3: Usuario inactivo reactivado
```
Persona: Pedro García (id_prs_persona = 30)
Usuario existente: 50 (estado = INACTIVO)
Nueva matrícula: Programa D → Usuario 50 (REACTIVADO)

Resultado: ✅ Usuario reactivado, rol asegurado
```

---

## 🎯 Beneficios de la Solución

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Usuarios por persona** | Múltiples ❌ | Uno solo ✅ |
| **Búsqueda** | Por CI (propenso a error) | Por relación persona-matrícula |
| **Manejo de duplicados** | Error fatal | ON CONFLICT (reactiva rol) |
| **Trazabilidad** | Sin mensaje claro | Indica "reutilizado" o "nuevo" |
| **Datos históricos** | Se pierden | Se consolidan |

---

## ⚠️ Notas Importantes

### 1. **Compatibilidad Backward**
- Las funciones antiguas siguen existiendo
- El sistema antiguo de parámetros sigue funcionando
- No se rompe código existente

### 2. **Datos Históricos**
- Campos deprecados NO se eliminan
- Se marcan con `COMMENT` como DEPRECADOS
- Se mantienen para auditoría

### 3. **Sistema Dual**
- **Nuevo**: `fn_matricular_preinscrito_completo_v2()` + aranceles
- **Antiguo**: `fn_matricular_preinscrito_completo()` + parámetros (DEPRECADO)

---

## 🐛 Troubleshooting

### Error persiste después de migración

**Verificar función actualizada**:
```sql
SELECT pg_get_functiondef('fn_matricular_preinscrito_completo_v2'::regproc);

-- Debe contener:
-- "FROM ins_matricula m INNER JOIN seg_usuario u"
-- NO debe contener:
-- "WHERE nombre_usuario = v_ci"
```

**Solución**: Ejecutar manualmente V21

---

### Duplicados no se limpian

**Ejecutar diagnóstico**:
```sql
SELECT * FROM fn_diagnostico_usuarios_duplicados();
```

**Limpiar manualmente**:
```sql
SELECT * FROM fn_consolidar_usuarios_duplicados(id_persona);
```

---

## 📞 Soporte

### Funciones de Diagnóstico Disponibles

1. **`fn_diagnostico_usuarios_duplicados()`**
   - Detecta personas con múltiples usuarios
   - Retorna lista de duplicados

2. **`fn_consolidar_usuarios_duplicados(id_persona)`**
   - Consolida usuarios de una persona
   - Mantiene el más antiguo
   - Actualiza todas las matrículas

---

## ✅ Checklist Final

- [ ] Migraciones V20 y V21 ejecutadas exitosamente
- [ ] Query de verificación retorna 0 duplicados
- [ ] Test de re-matriculación exitoso (sin error)
- [ ] Mensaje indica "usuario reutilizado"
- [ ] Mismo `id_seg_usuario` en múltiples matrículas de la misma persona
- [ ] Test de primera matrícula exitoso (genera password temporal)
- [ ] Roles asignados correctamente (ON CONFLICT funciona)

---

**Estado**: ✅ Solución completa e implementada
**Versiones**: V20 (aranceles) + V21 (fix usuario duplicado)
**Fecha**: 2025-01-14
