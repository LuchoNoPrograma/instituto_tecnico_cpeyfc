# Frontend Changes Required for Arancel System

## Overview
The backend has been migrated from direct pricing (precio_matricula, precio_colegiatura, precio_titulacion) to a flexible arancel (fee schedule) system. The frontend needs to be updated accordingly.

## New Backend Endpoints

### Arancel Management
- `POST /api/arancel/registrar` - Register new arancel with conceptos
- `GET /api/arancel/conceptos` - Get payment concepts with calculated discounts
- `GET /api/arancel/vista/aranceles-vigentes` - List all active arancels
- `GET /api/arancel/vista/aranceles-detalle/{id}` - Get arancel details by programa
- `GET /api/arancel/vista/aranceles-programa/{nombre}` - Get arancels by program name

### Programa Management (Updated)
- `POST /api/programa-aprobado/v2` - Register programa WITHOUT pricing
- `PUT /api/programa-aprobado/v2/{id}` - Update programa WITHOUT pricing
- ~~`POST /api/programa-aprobado`~~ - **DEPRECATED** (old pricing system)
- ~~`PUT /api/programa-aprobado/{id}`~~ - **DEPRECATED** (old pricing system)

### Parametros (Clarified)
- Parametros are ONLY for metadata (URLs, texts, config values)
- DO NOT use parametros for discounts or pricing
- Use arancel system for all pricing and discounts

## Required Frontend Changes

### 1. Create Arancel Registration Form
**File:** `src/webapp/src/pages/aranceles/RegistrarArancel.vue` (NEW)

**Features:**
- Select programa aprobado (dropdown)
- Select gestion académica (dropdown)
- Select tipo estudiante (Nacional, UAP, Extranjero)
- Input nombre arancel
- Input descripción
- Date pickers for fecha_inicio_vigencia, fecha_fin_vigencia
- Dynamic table/form for conceptos (CRUD):
  - Select concepto arancel from catalog
  - Input monto
  - Input orden (display order)
  - Add/remove rows
- Submit button that calls `POST /api/arancel/registrar`

**JSON Request Format:**
```json
{
  "idProgramaAprobado": 1,
  "idGestion": 1,
  "idTipoEstudiante": 1,
  "nombreArancel": "Arancel Regular 2025",
  "descripcion": "Arancel para estudiantes regulares",
  "fechaInicioVigencia": "2025-01-01",
  "fechaFinVigencia": "2025-12-31",
  "detalles": "[{\"id_fin_concepto_arancel\": 1, \"monto\": 500, \"orden\": 1}, {\"id_fin_concepto_arancel\": 2, \"monto\": 1200, \"orden\": 2}]",
  "userReg": "user_id"
}
```

### 2. Update Programa Aprobado Registration Form
**File:** `src/webapp/src/pages/programas/RegistrarProgramaAprobado.vue` (UPDATE)

**Changes:**
- **REMOVE** all pricing fields:
  - ~~precio_matricula~~
  - ~~precio_colegiatura~~
  - ~~precio_titulacion~~
- **ADD** id_aca_nivel field (was missing)
- **ADD** sistema_programa field (REGULAR, ACELERADO, MODULAR)
- **ADD** imagen_programa_url field
- **UPDATE** endpoint from `/api/programa-aprobado` to `/api/programa-aprobado/v2`
- **ADD** message after success: "Programa registrado. Ahora configure los aranceles en la sección de Aranceles."

**JSON Request Format (NEW):**
```json
{
  "id_aca_programa": 1,
  "id_aca_nivel": 1,
  "id_aca_modalidad": 1,
  "id_aca_plan_estudio": 1,
  "id_aca_version": 1,
  "gestion": "2025",
  "cod_certificado_ceub": "ABC123",
  "fecha_inicio_vigencia": "2025-01-01",
  "fecha_fin_vigencia": "2025-12-31",
  "sistema_programa": "REGULAR",
  "imagen_programa_url": "https://example.com/image.jpg"
}
```

### 3. Update Programa Aprobado Edit Form
**File:** `src/webapp/src/pages/programas/EditarProgramaAprobado.vue` (UPDATE)

**Changes:**
- **REMOVE** all pricing fields (same as registration)
- **UPDATE** endpoint from `/api/programa-aprobado/{id}` to `/api/programa-aprobado/v2/{id}`
- **ADD** link/button to manage arancels for this programa

### 4. Create Arancel List/Management View
**File:** `src/webapp/src/pages/aranceles/ListaAranceles.vue` (NEW)

**Features:**
- Data table showing all arancels with columns:
  - Programa
  - Nivel
  - Modalidad
  - Tipo Estudiante
  - Nombre Arancel
  - Monto Total
  - Vigencia (dates)
  - Estado
  - Actions (View Details, Edit, Inactivate)
- Filters:
  - By programa
  - By tipo estudiante
  - By vigencia (Vigente, Futuro, Vencido)
- "Nuevo Arancel" button (navigates to RegistrarArancel.vue)
- Use endpoint: `GET /api/arancel/vista/aranceles-vigentes`

### 5. Update Programa Aprobado List View
**File:** `src/webapp/src/pages/programas/ListaProgramasAprobados.vue` (UPDATE)

**Changes:**
- **REMOVE** precio columns from table (precio_matricula_deprecated, precio_colegiatura_deprecated, precio_titulacion_deprecated)
- **ADD** "Gestionar Aranceles" action button (navigates to arancel management for that programa)
- **UPDATE** any views that display pricing to show message: "Consulte aranceles para información de precios"

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
- Displays results table:
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

### New Catalogs to Load
Your frontend should load these catalogs via APIs:

1. **Conceptos de Arancel** - `GET /api/concepto-arancel/vista/conceptos-activos`
   - Used in arancel registration form dropdown
   - Fields: id_fin_concepto_arancel, nombre_concepto, descripcion

2. **Tipos de Estudiante** - `GET /api/tipo-estudiante/vista/tipos-activos`
   - Used in arancel registration and calculator
   - Fields: id_aca_tipo_estudiante, nombre_tipo, descripcion

3. **Gestiones Académicas** - `GET /api/periodo/vista/gestiones-periodos`
   - Used in arancel registration
   - Fields: id_aca_gestion, gestion, anio, fecha_inicio, fecha_fin

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
- descripcion: optional, max 1000 characters
- fechaInicioVigencia: required, valid date
- fechaFinVigencia: optional, must be after fechaInicioVigencia
- detalles: required, at least 1 concepto
  - Each concepto: monto > 0, orden >= 1

### Programa Aprobado Registration (Updated)
- Remove all precio validations
- Add sistema_programa: required, must be one of ['REGULAR', 'ACELERADO', 'MODULAR']
- Add imagen_programa_url: optional, valid URL format

## Testing Checklist

- [ ] Can register programa aprobado without pricing
- [ ] Can register arancel with multiple conceptos
- [ ] Calculator shows correct pricing with discounts
- [ ] Calculator works with and without convenio
- [ ] Arancel list displays all active arancels correctly
- [ ] Can edit programa without affecting arancels
- [ ] Deprecated endpoints show warning in console
- [ ] Enrollment forms use new arancel-based pricing
- [ ] No references to precio_matricula/colegiatura/titulacion remain
- [ ] Parametros are only used for metadata (no pricing/discounts)

## Migration Notes

**For Existing Data:**
- Old programas with precio_matricula/colegiatura/titulacion will continue to work (backward compatible)
- Views will show these as *_deprecated fields
- Frontend should display migration message: "Este programa usa el sistema de precios antiguo. Cree aranceles para migrar al nuevo sistema."

**For New Data:**
- All new programas must use the arancel system
- Precios directos are no longer supported in new registrations
