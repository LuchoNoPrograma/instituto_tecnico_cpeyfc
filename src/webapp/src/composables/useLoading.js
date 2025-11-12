import { useLoadingStore } from '@/stores/loading'

/**
 * Composable para manejar el loading global
 *
 * @example
 * // En cualquier componente:
 * import { useLoading } from '@/composables/useLoading'
 *
 * const { show, hide, withLoading } = useLoading()
 *
 * // Uso básico
 * show('Cargando datos...')
 * await fetchData()
 * hide()
 *
 * // Uso con wrapper (recomendado)
 * await withLoading(fetchData(), 'Cargando datos...')
 */
export function useLoading() {
  const loadingStore = useLoadingStore()

  return {
    /**
     * Muestra el loading con un mensaje opcional
     * @param {string} message - Mensaje a mostrar
     * @param {number} minDuration - Duración mínima en ms (default: 300)
     */
    show: (message = 'Cargando...', minDuration = 300) => {
      loadingStore.show(message, minDuration)
    },

    /**
     * Oculta el loading
     */
    hide: () => {
      loadingStore.hide()
    },

    /**
     * Cambia el mensaje del loading actual
     * @param {string} message - Nuevo mensaje
     */
    setMessage: (message) => {
      loadingStore.setMessage(message)
    },

    /**
     * Envuelve una promesa con loading automático
     * @param {Promise} promise - Promesa a ejecutar
     * @param {string} message - Mensaje a mostrar
     * @returns {Promise} - Resultado de la promesa
     */
    withLoading: (promise, message = 'Cargando...') => {
      return loadingStore.withLoading(promise, message)
    },

    /**
     * Estado reactivo del loading
     */
    isLoading: loadingStore.isLoading,

    /**
     * Mensaje actual del loading
     */
    message: loadingStore.message
  }
}
