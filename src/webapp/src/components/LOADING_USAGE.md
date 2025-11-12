# Sistema de Loading Global

Sistema de loading con animaciones fade in/fade out integrado con Vue Router para feedback visual en toda la aplicación.

## Características

- ✨ Animaciones suaves de fade in/fade out (300ms)
- 🎯 Integración automática con Vue Router
- 🔄 Control manual desde cualquier componente
- 📱 Diseño responsive
- 🎨 Estilos Material Design con Vuetify
- ⚡ Duración mínima configurable para evitar flashes
- 🎭 Modo "scoped": limita el loading solo al área de contenido (sin afectar sidebar/header)

## Modos de Uso

### 1. Fullscreen (Pantalla Completa)
Por defecto, el loading cubre **toda la pantalla** con blur. Ideal para layouts públicos.

```vue
<GlobalLoading />
```

**Usado en:** `LayoutBlanco.vue` (login, 404, etc.)

### 2. Scoped (Solo Contenido)
Con la prop `scoped`, el loading solo cubre el **área de contenido** sin afectar sidebar/header/footer.

```vue
<GlobalLoading scoped />
```

**Usado en:** `LayoutCompleto.vue` (panel de administración)
- ✅ Sidebar visible durante carga
- ✅ Header visible durante carga
- ✅ Solo el contenido central tiene overlay y blur

## Uso Automático (Vue Router)

El loading se muestra automáticamente en cada cambio de ruta:

```javascript
// No requiere configuración adicional
// Ya está integrado en router/index.js
router.push('/nueva-ruta') // Loading se muestra automáticamente
```

## Uso Manual en Componentes

### Método 1: Usando el Composable (Recomendado)

```vue
<script setup>
import { useLoading } from '@/composables/useLoading'

const { show, hide, withLoading } = useLoading()

// Opción A: Control manual
const cargarDatos = async () => {
  show('Cargando datos...')
  try {
    await apiService.getData()
  } finally {
    hide()
  }
}

// Opción B: Wrapper automático (más limpio)
const cargarDatos = async () => {
  await withLoading(
    apiService.getData(),
    'Cargando datos...'
  )
}
</script>
```

### Método 2: Usando el Store Directamente

```vue
<script setup>
import { useLoadingStore } from '@/stores/loading'

const loadingStore = useLoadingStore()

const procesarFormulario = async () => {
  loadingStore.show('Procesando...')
  await submitForm()
  loadingStore.hide()
}
</script>
```

## API

### Composable `useLoading()`

```javascript
const {
  show,        // (message?: string, minDuration?: number) => void
  hide,        // () => void
  setMessage,  // (message: string) => void
  withLoading, // (promise: Promise, message?: string) => Promise
  isLoading,   // Ref<boolean>
  message      // Ref<string>
} = useLoading()
```

### Store `useLoadingStore()`

```javascript
const loadingStore = useLoadingStore()

// State
loadingStore.isLoading  // boolean
loadingStore.message    // string

// Methods
loadingStore.show(message, minDuration)
loadingStore.hide()
loadingStore.setMessage(message)
loadingStore.withLoading(promise, message)
```

## Ejemplos Avanzados

### Cambiar el Mensaje Durante la Carga

```vue
<script setup>
import { useLoading } from '@/composables/useLoading'

const { show, setMessage, hide } = useLoading()

const procesoPaso = async () => {
  show('Paso 1: Validando...')
  await validar()

  setMessage('Paso 2: Guardando...')
  await guardar()

  setMessage('Paso 3: Finalizando...')
  await finalizar()

  hide()
}
</script>
```

### Múltiples Operaciones Paralelas

```vue
<script setup>
import { useLoading } from '@/composables/useLoading'

const { withLoading } = useLoading()

const cargarTodo = async () => {
  await withLoading(
    Promise.all([
      cargarUsuarios(),
      cargarProductos(),
      cargarConfiguracion()
    ]),
    'Cargando datos...'
  )
}
</script>
```

### Control Condicional

```vue
<script setup>
import { useLoading } from '@/composables/useLoading'

const { show, hide, isLoading } = useLoading()

const guardar = async () => {
  if (isLoading.value) {
    console.log('Ya hay una operación en curso')
    return
  }

  show('Guardando cambios...')
  await saveData()
  hide()
}
</script>
```

## Personalización

### Modificar Estilos

Edita `src/components/GlobalLoading.vue`:

```scss
// Cambiar color del overlay
.loading-overlay {
  background-color: rgba(0, 0, 0, 0.7); // Más oscuro
}

// Cambiar velocidad de animación
.fade-enter-active {
  transition: opacity 0.5s ease-in; // Más lento
}
```

### Configurar Duración Mínima

```javascript
// Por defecto: 300ms
show('Cargando...', 500) // 500ms mínimo
```

### Usar en Layouts Personalizados

Si creas un layout personalizado:

**Para loading fullscreen (cubre todo):**
```vue
<template>
  <v-app>
    <GlobalLoading />
    <!-- Tu contenido -->
  </v-app>
</template>
```

**Para loading scoped (solo contenido):**
```vue
<template>
  <v-app>
    <!-- Header/Sidebar -->
    <v-main class="content-wrapper">
      <GlobalLoading scoped />
      <slot />
    </v-main>
  </v-app>
</template>

<style scoped>
.content-wrapper {
  position: relative; /* IMPORTANTE para que scoped funcione */
}
</style>
```

⚠️ **Importante:** El contenedor padre del `<GlobalLoading scoped />` debe tener `position: relative` para que funcione correctamente.

## Componentes Involucrados

- **GlobalLoading.vue** - Componente visual con animaciones
- **stores/loading.js** - Store de Pinia para estado global
- **composables/useLoading.js** - Composable para uso en componentes
- **router/index.js** - Integración con navegación
- **layouts/** - Ambos layouts incluyen el componente

## Notas Importantes

1. El loading tiene duración mínima de 300ms para evitar flashes visuales molestos
2. **Modo fullscreen:** z-index: 9999, position: fixed (cubre toda la pantalla)
3. **Modo scoped:** z-index: 100, position: absolute (solo el contenedor padre)
4. Las animaciones usan CSS3 transitions para mejor performance
5. El loading se oculta automáticamente después de cada navegación
6. Múltiples llamadas a `show()` no se acumulan (sobrescriben el anterior)
7. Para modo scoped, el contenedor padre **debe** tener `position: relative`

## Solución de Problemas

### El loading no aparece

1. Verifica que el componente esté en el layout
2. Revisa que el store esté importado correctamente
3. Comprueba la consola por errores de importación

### El loading no desaparece

1. Asegúrate de llamar a `hide()` en bloques `finally`
2. Verifica que no haya errores que interrumpan el flujo
3. Usa `withLoading()` para manejo automático

### Animaciones no funcionan

1. Verifica que el navegador soporte CSS transitions
2. Revisa que no haya conflictos de CSS
3. Comprueba el z-index del componente

### El loading scoped no se muestra o se ve raro

1. Verifica que el contenedor padre tenga `position: relative`
2. Asegúrate de que el contenedor tenga un tamaño definido (width/height)
3. Comprueba que el componente esté dentro del contenedor correcto
4. Revisa la consola por errores de importación

### El loading scoped está cubriendo sidebar/header

1. Verifica que estés usando la prop `scoped` en el componente
2. Asegúrate de que el componente esté dentro del `<v-main>`, no en `<v-app>`
3. Revisa que el `<v-main>` tenga `position: relative` en sus estilos
