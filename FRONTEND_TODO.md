# Frontend Changes Required for Arancel System

## ⚠️ IMPORTANTE: Usar Columnas Reales

Este documento ha sido corregido para usar SOLO las columnas que EXISTEN en las tablas SQL reales del proyecto.

## Overview

El backend ha sido migrado para deprecar precios directos y usar el sistema de aranceles (fin_arancel). Las funciones legacy siguen funcionando para compatibilidad, pero se recomienda migrar gradualmente al nuevo sistema.

## Columnas REALES de las Tablas

### aca_programa_aprobado
- gestion (INTEGER, no varchar)
- imagen_programa_url (SÍ existe)
- **NO existe**: id_aca_nivel (se obtiene por join)
- **NO existe**: sistema_programa

### fin_arancel
- id_aca_periodo (NO id_aca_gestion directamente)
- nro_resolucion (SÍ existe)
- fecha_aprobacion (SÍ existe)
- **NO existe**: descripcion

### fin_detalle_arancel
- monto_concepto (NO "monto")
- orden_aplicacion (NO "orden")
- **NO existe**: estado_detalle_arancel

### fin_descuento_arancel
- porcentaje_descuento
- monto_descuento
- aplica_desde_periodo (NO "numero_periodo")
- estado_descuento (NO "estado_descuento_arancel")

### fin_concepto_arancel
- estado_concepto (NO "estado_concepto_arancel")

## Endpoints Disponibles

### Arancel Management
- `POST /api/arancel/registrar` - Register new arancel with conceptos
- `GET /api/arancel/conceptos` - Get payment concepts with calculated discounts
- `GET /api/arancel/vista/aranceles-vigentes` - List all active arancels
- `GET /api/arancel/vista/aranceles-detalle` - Get all arancel details
- `GET /api/arancel/vista/aranceles-detalle/{id}` - Get arancel details by programa

### Programa Management (Existing - Mantener)
- `POST /api/programa-aprobado` - Register programa (precio fields optional/nullable)
- `PUT /api/programa-aprobado/{id}` - Update programa (precio fields optional/nullable)

**NOTA**: NO hay endpoints v2. Se mantienen los existentes pero los precios ahora son opcionales.

## Required Frontend Changes

### 1. Create Arancel Registration Form
**File:** `src/webapp/src/pages/aranceles/RegistrarArancel.vue` (NEW)

**Features:**
- Select programa aprobado (dropdown)
- Select periodo académico (dropdown) - OPCIONAL
- Select tipo estudiante (Nacional, UAP, Extranjero)
- Input nombre_arancel
- Input nro_resolucion (opcional)
- Date picker fecha_aprobacion (opcional)
- Date pickers for fecha_inicio_vigencia, fecha_fin_vigencia
- Dynamic table/form for conceptos (CRUD):
  - Select concepto arancel from catalog
  - Input **monto_concepto** (not "monto")
  - Input **orden_aplicacion** (not "orden")
  - Add/remove rows
- Submit button that calls `POST /api/arancel/registrar`

**JSON Request Format (Columnas REALES):**
```json
{
  "idProgramaAprobado": 1,
  "idPeriodo": 1,
  "idTipoEstudiante": 1,
  "nombreArancel": "Arancel Regular 2025",
  "nroResolucion": "RES-001-2025",
  "fechaAprobacion": "2025-01-15",
  "fechaInicioVigencia": "2025-01-01",
  "fechaFinVigencia": "2025-12-31",
  "detalles": "[{\"id_fin_concepto_arancel\": 1, \"monto_concepto\": 500, \"orden_aplicacion\": 1}, {\"id_fin_concepto_arancel\": 2, \"monto_concepto\": 1200, \"orden_aplicacion\": 2}]",
  "userReg": 1
}
```

### 2. Update Programa Aprobado Registration Form
**File:** `src/webapp/src/pages/programas/RegistrarProgramaAprobado.vue` (UPDATE)

**Changes:**
- **Hacer OPCIONALES** los campos de precio (permitir null o 0):
  - precio_matricula (opcional)
  - precio_colegiatura (opcional)
  - precio_titulacion (opcional)
- **NO agregar** id_aca_nivel (no existe en la tabla)
- **NO agregar** sistema_programa (no existe en la tabla)
- **Mantener** imagen_programa_url (ya existe)
- **MENSAJE** después de registro exitoso: "Programa registrado. Configure los aranceles en /aranceles para pricing diferenciado."

**JSON Request Format (Mantener estructura actual):**
```json
{
  "id_aca_programa": 1,
  "id_aca_modalidad": 1,
  "id_aca_plan_estudio": 1,
  "id_aca_version": 1,
  "gestion": 2025,
  "estado_programa_aprobado": "SIN INICIAR",
  "cod_certificado_ceub": "ABC123",
  "precio_matricula": 0,
  "precio_colegiatura": 0,
  "precio_titulacion": null,
  "fecha_inicio_vigencia": "2025-01-01",
  "fecha_fin_vigencia": "2025-12-31"
}
```

### 3. Update Programa Aprobado Edit Form
**File:** `src/webapp/src/pages/programas/EditarProgramaAprobado.vue` (UPDATE)

**Changes:**
- Mantener estructura actual
- Hacer campos precio_* opcionales
- Agregar enlace/botón "Gestionar Aranceles" → navega a lista de aranceles filtrada por ese programa

### 4. Create Arancel List/Management View
**File:** `src/webapp/src/pages/aranceles/ListaAranceles.vue` (NEW)

**Features:**
- Data table showing all arancels with columns:
  - Programa
  - Modalidad
  - Periodo (si existe)
  - Tipo Estudiante
  - Nombre Arancel
  - Nro Resolución
  - Monto Total
  - Vigencia (dates)
  - Estado
  - Actions (View Details, Edit if needed, Inactivate)
- Filters:
  - By programa
  - By tipo estudiante
  - By vigencia (Vigente, Futuro, Vencido)
- "Nuevo Arancel" button (navigates to RegistrarArancel.vue)
- Use endpoint: `GET /api/arancel/vista/aranceles-vigentes`

### 5. Update Programa Aprobado List View
**File:** `src/webapp/src/pages/programas/ListaProgramasAprobados.vue` (UPDATE)

**Changes:**
- **Columnas deprecated** renombradas en vista:
  - precio_matricula_deprecated
  - precio_colegiatura_deprecated
  - precio_titulacion_deprecated
- **MOSTRAR** mensaje si los precios están deprecated: "Este programa usa precios legacy. Configure aranceles para pricing diferenciado."
- **ADD** "Gestionar Aranceles" action button (navigates to arancel management for that programa)

### 6. Create Conceptos Arancel Calculator
**File:** `src/webapp/src/components/aranceles/CalculadoraConceptos.vue` (NEW)

**Features:**
- Reusable component for enrollment/registration forms
- Inputs:
  - Programa aprobado
  - Tipo estudiante
  - Numero periodo (1, 2, 3...)
  - Convenio (optional)
- Calls `GET /api/arancel/conceptos?idProgramaAprobado=X&idTipoEstudiante=Y&numeroPeriodo=Z&idConvenio=W`
- Displays results table (usando columnas REALES):
  - Concepto
  - Descripción
  - Monto Base
  - Descuento Aplicado
  - Monto Final
  - Origen Descuento (ARANCEL, CONVENIO, ARANCEL + CONVENIO, SIN DESCUENTO)
- Shows total at bottom

### 7. Update Inscripción/Matrícula Forms
**Files:**
- `src/webapp/src/pages/inscripciones/Preinscripcion.vue` (UPDATE)
- `src/webapp/src/pages/matriculas/Matricular.vue` (UPDATE)

**Changes:**
- Replace any hardcoded pricing displays with the CalculadoraConceptos component
- Remove any references to precio_matricula/colegiatura/titulacion
- Use the new arancel-based pricing display

## Data Dependencies

### Catalogs to Load
Your frontend should load these catalogs via APIs:

1. **Conceptos de Arancel**
   - Endpoint: crear vista o query directo a fin_concepto_arancel
   - Fields: id_fin_concepto_arancel, nombre_concepto, descripcion, tipo_concepto

2. **Tipos de Estudiante**
   - Endpoint: crear vista o query directo a aca_tipo_estudiante
   - Fields: id_aca_tipo_estudiante, nombre_tipo, descripcion

3. **Periodos Académicos**
   - Endpoint: usar vista_gestiones_periodos existente
   - Fields: id_aca_periodo, codigo_periodo, nombre_periodo, numero_periodo

## Navigation/Routing Updates

Add new routes to `src/webapp/src/router/index.js`:

```javascript
{
  path: '/aranceles',
  name: 'ListaAranceles',
  component: () => import('@/pages/aranceles/ListaAranceles.vue'),
  meta: { requiresAuth: true, roles: ['ADMINISTRATIVO', 'DESARROLLO'] }
},
{
  path: '/aranceles/registrar',
  name: 'RegistrarArancel',
  component: () => import('@/pages/aranceles/RegistrarArancel.vue'),
  meta: { requiresAuth: true, roles: ['ADMINISTRATIVO', 'DESARROLLO'] }
}
```

## Sidebar/Menu Updates

Add new menu item to sidebar navigation:

```javascript
{
  title: 'Aranceles',
  icon: 'mdi-currency-usd',
  to: '/aranceles',
  roles: ['ADMINISTRATIVO', 'DESARROLLO']
}
```

## Validation Rules

### Arancel Registration
- nombreArancel: required, max 200 characters
- nroResolucion: optional, max 50 characters
- fechaAprobacion: optional, valid date
- fechaInicioVigencia: required, valid date
- fechaFinVigencia: optional, must be after fechaInicioVigencia
- detalles: required, at least 1 concepto
  - Each concepto: monto_concepto > 0, orden_aplicacion >= 1

### Programa Aprobado Registration (Updated)
- precio_* fields: opcional, puede ser null o 0
- NO validar sistema_programa (no existe)
- NO validar id_aca_nivel (no existe)

## Testing Checklist

- [ ] Can register programa aprobado with precio_* as null or 0
- [ ] Can register arancel with multiple conceptos (usando monto_concepto, orden_aplicacion)
- [ ] Calculator shows correct pricing with discounts
- [ ] Calculator works with and without convenio
- [ ] Arancel list displays all active arancels correctly
- [ ] Can edit programa without affecting aranceles
- [ ] Deprecated fields show as *_deprecated in views
- [ ] Enrollment forms use new arancel-based pricing
- [ ] Parametros are only used for metadata (no pricing/discounts)

## Migration Notes

**For Existing Data:**
- Old programas with precio_matricula/colegiatura/titulacion will continue to work
- Views will show these as *_deprecated fields
- Frontend should display migration message: "Este programa usa el sistema de precios antiguo. Cree aranceles para migrar al nuevo sistema."

**For New Data:**
- New programas can have precio_* as null or 0
- Configure aranceles separately after creating the programa
- Precios directos are deprecated but still functional for compatibility
