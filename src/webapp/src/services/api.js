import axios from 'axios'
import { showError } from '@/utils/sweetalert'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Interceptor para agregar token
api.interceptors.request.use(config => {
  const token = localStorage.getItem('access_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Interceptor para manejar errores
api.interceptors.response.use(
  response => response,
  error => {
    console.error('🔥 Error capturado por interceptor:', error)

    // Si no hay respuesta (problemas de red)
    if (!error.response) {
      console.log('🌐 Error de red detectado')
      showError(
        'No se puede conectar al servidor. Verifica tu conexión a internet.',
        'Error de Conexión'
      )
      return Promise.reject(error)
    }

    const { status, data } = error.response
    console.log(`📊 Status: ${status}, Data:`, data)

    // Manejo específico por código de estado
    switch (status) {
      case 401:
        console.log('🔐 Error 401 - No autorizado')
        localStorage.removeItem('access_token')
        window.location.href = '/login'
        break

      case 409:
        console.log('⚠️ Error 409 - Conflicto de DB')
        if (data?.message) {
          console.log('💬 Mostrando mensaje:', data.message)
          showError(data.message, data.error || 'Error de Base de Datos')
        } else {
          showError('Ya existe un registro con estos datos.', 'Registro Duplicado')
        }
        break

      case 400:
        console.log('❌ Error 400 - Bad Request')
        if (data?.message) {
          showError(data.message, data.error || 'Error de Validación')
        } else {
          showError('Solicitud inválida. Verifica los datos enviados.', 'Error de Validación')
        }
        break

      case 403:
        console.log('🚫 Error 403 - Forbidden')
        showError('No tienes permisos para realizar esta acción.', 'Acceso Denegado')
        break

      case 404:
        console.log('🔍 Error 404 - Not Found')
        showError('El recurso solicitado no fue encontrado.', 'No Encontrado')
        break

      case 500:
        console.log('💥 Error 500 - Server Error')
        if (data?.message) {
          showError(data.message, 'Error del Servidor')
        } else {
          showError('Error interno del servidor. Contacta al administrador.', 'Error del Servidor')
        }
        break

      default:
        console.log(`❓ Error ${status} - Genérico`)
        if (data?.message) {
          showError(data.message, `Error ${status}`)
        } else {
          showError('Ha ocurrido un error inesperado. Intenta nuevamente.', 'Error Inesperado')
        }
        break
    }

    return Promise.reject(error)
  }
)

export { api }
