import { watch } from 'vue'

/**
 * Hook de debounce para búsquedas
 */
export function useDebounceBusqueda(value, callback, delay = 500) {
  let timeout = null

  watch(value, (newValue) => {
    if (timeout) clearTimeout(timeout)

    timeout = setTimeout(() => {
      callback(newValue)
    }, delay)
  })
}
