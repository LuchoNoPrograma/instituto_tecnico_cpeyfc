import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useLoadingStore = defineStore('loading', () => {
  // State
  const isLoading = ref(false)
  const message = ref('')
  const loadingTimeout = ref(null)

  // Actions
  const show = (msg = 'Cargando...', minDuration = 300) => {
    // Limpiar timeout previo si existe
    if (loadingTimeout.value) {
      clearTimeout(loadingTimeout.value)
      loadingTimeout.value = null
    }

    message.value = msg
    isLoading.value = true

    // Establecer duración mínima para evitar flashes
    loadingTimeout.value = setTimeout(() => {
      loadingTimeout.value = null
    }, minDuration)
  }

  const hide = () => {
    // Si hay un timeout activo, esperar a que termine antes de ocultar
    if (loadingTimeout.value) {
      setTimeout(() => {
        isLoading.value = false
        message.value = ''
      }, 300) // Tiempo para respetar la duración mínima
    } else {
      isLoading.value = false
      message.value = ''
    }
  }

  const setMessage = (msg) => {
    message.value = msg
  }

  // Método helper para envolver promesas con loading
  const withLoading = async (promise, msg = 'Cargando...') => {
    show(msg)
    try {
      const result = await promise
      return result
    } finally {
      hide()
    }
  }

  return {
    // State
    isLoading,
    message,
    // Actions
    show,
    hide,
    setMessage,
    withLoading
  }
})
