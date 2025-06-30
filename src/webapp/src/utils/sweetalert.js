// utils/sweetalert.js
import Swal from 'sweetalert2'

/**
 * Configuración base para Sweet Alert con tema personalizado CPEYFC
 */
const baseConfig = {
  customClass: {
    popup: 'cpeyfc-swal-popup',
    title: 'cpeyfc-swal-title',
    content: 'cpeyfc-swal-content',
    confirmButton: 'cpeyfc-swal-confirm',
    cancelButton: 'cpeyfc-swal-cancel'
  },
  buttonsStyling: false
}

/**
 * Muestra alerta de éxito para registro
 * @param {string} mensaje - Mensaje personalizado (opcional)
 * @param {string} titulo - Título personalizado (opcional)
 */
export const showRegistrado = (mensaje = 'Registro creado exitosamente', titulo = '¡Registrado!') => {
  return Swal.fire({
    ...baseConfig,
    icon: 'success',
    title: titulo,
    text: mensaje,
    confirmButtonText: 'Aceptar',
    timer: 3000,
    timerProgressBar: true,
    customClass: {
      ...baseConfig.customClass,
      confirmButton: 'cpeyfc-swal-confirm success'
    }
  })
}

/**
 * Muestra alerta de éxito para eliminación
 * @param {string} mensaje - Mensaje personalizado (opcional)
 * @param {string} titulo - Título personalizado (opcional)
 */
export const showEliminado = (mensaje = 'Registro eliminado correctamente', titulo = '¡Eliminado!') => {
  return Swal.fire({
    ...baseConfig,
    icon: 'success',
    title: titulo,
    text: mensaje,
    confirmButtonText: 'Aceptar',
    timer: 3000,
    timerProgressBar: true,
    customClass: {
      ...baseConfig.customClass,
      confirmButton: 'cpeyfc-swal-confirm warning'
    }
  })
}

/**
 * Muestra alerta de éxito para modificación
 * @param {string} mensaje - Mensaje personalizado (opcional)
 * @param {string} titulo - Título personalizado (opcional)
 */
export const showModificado = (mensaje = 'Registro actualizado exitosamente', titulo = '¡Modificado!') => {
  return Swal.fire({
    ...baseConfig,
    icon: 'success',
    title: titulo,
    text: mensaje,
    confirmButtonText: 'Aceptar',
    timer: 3000,
    timerProgressBar: true,
    customClass: {
      ...baseConfig.customClass,
      confirmButton: 'cpeyfc-swal-confirm info'
    }
  })
}

/**
 * Muestra alerta de confirmación
 * @param {Object} options - Opciones de configuración
 * @param {string} options.mensaje - Mensaje de confirmación
 * @param {string} options.titulo - Título de la alerta
 * @param {string} options.textoConfirmar - Texto del botón confirmar
 * @param {string} options.textoCancelar - Texto del botón cancelar
 * @param {string} options.tipo - Tipo de acción ('delete', 'update', 'save')
 */
export const showConfirmar = ({
                                mensaje = '¿Estás seguro de realizar esta acción?',
                                titulo = '¿Confirmar acción?',
                                textoConfirmar = 'Sí, confirmar',
                                textoCancelar = 'Cancelar',
                                tipo = 'save'
                              } = {}) => {

  const iconConfig = {
    delete: { icon: 'warning', confirmClass: 'error' },
    update: { icon: 'question', confirmClass: 'info' },
    save: { icon: 'question', confirmClass: 'success' }
  }

  const config = iconConfig[tipo] || iconConfig.save

  return Swal.fire({
    ...baseConfig,
    icon: config.icon,
    title: titulo,
    text: mensaje,
    showCancelButton: true,
    confirmButtonText: textoConfirmar,
    cancelButtonText: textoCancelar,
    reverseButtons: true,
    focusCancel: true,
    customClass: {
      ...baseConfig.customClass,
      confirmButton: `cpeyfc-swal-confirm ${config.confirmClass}`,
      cancelButton: 'cpeyfc-swal-cancel'
    }
  })
}

/**
 * Muestra alerta de error personalizada
 * @param {string} mensaje - Mensaje de error
 * @param {string} titulo - Título del error
 */
export const showError = (mensaje = 'Ha ocurrido un error inesperado', titulo = '¡Error!') => {
  return Swal.fire({
    ...baseConfig,
    icon: 'error',
    title: titulo,
    text: mensaje,
    confirmButtonText: 'Aceptar',
    customClass: {
      ...baseConfig.customClass,
      confirmButton: 'cpeyfc-swal-confirm error'
    }
  })
}

/**
 * Muestra alerta de información/advertencia
 * @param {string} mensaje - Mensaje informativo
 * @param {string} titulo - Título de la información
 */
export const showInfo = (mensaje, titulo = 'Información') => {
  return Swal.fire({
    ...baseConfig,
    icon: 'info',
    title: titulo,
    text: mensaje,
    confirmButtonText: 'Entendido',
    customClass: {
      ...baseConfig.customClass,
      confirmButton: 'cpeyfc-swal-confirm info'
    }
  })
}

/**
 * Configuración para Toast (notificaciones pequeñas)
 */
export const Toast = Swal.mixin({
  toast: true,
  position: 'top-end',
  showConfirmButton: false,
  timer: 3000,
  timerProgressBar: true,
  didOpen: (toast) => {
    toast.addEventListener('mouseenter', Swal.stopTimer)
    toast.addEventListener('mouseleave', Swal.resumeTimer)
  }
})

/**
 * Muestra toast de éxito
 * @param {string} mensaje - Mensaje del toast
 */
export const showToastSuccess = (mensaje) => {
  return Toast.fire({
    icon: 'success',
    title: mensaje
  })
}

/**
 * Muestra toast de error
 * @param {string} mensaje - Mensaje del toast
 */
export const showToastError = (mensaje) => {
  return Toast.fire({
    icon: 'error',
    title: mensaje
  })
}

/**
 * Muestra toast de información
 * @param {string} mensaje - Mensaje del toast
 */
export const showToastInfo = (mensaje) => {
  return Toast.fire({
    icon: 'info',
    title: mensaje
  })
}
