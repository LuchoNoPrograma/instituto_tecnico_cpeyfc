# Sistema de Loading Global

Sistema de loading con animaciones fade in/fade out integrado con Vue Router para feedback visual en toda la aplicación.

## Características

- ✨ Animaciones suaves de fade in/fade out (300ms)
- 🎯 Integración automática con Vue Router
- 🔄 Control manual desde cualquier componente
- 📱 Diseño responsive
- 🎨 Estilos Material Design con Vuetify
- ⚡ Duración mínima configurable para evitar flashes

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

## Componentes Involucrados

- **GlobalLoading.vue** - Componente visual con animaciones
- **stores/loading.js** - Store de Pinia para estado global
- **composables/useLoading.js** - Composable para uso en componentes
- **router/index.js** - Integración con navegación
- **layouts/** - Ambos layouts incluyen el componente

## Notas Importantes

1. El loading tiene duración mínima de 300ms para evitar flashes visuales molestos
2. El componente está en z-index: 9999 para aparecer sobre todo
3. Las animaciones usan CSS3 transitions para mejor performance
4. El loading se oculta automáticamente después de cada navegación
5. Múltiples llamadas a `show()` no se acumulan (sobrescriben el anterior)

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
