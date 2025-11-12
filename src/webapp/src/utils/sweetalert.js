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

/**
 * Muestra alerta de carga (loading) mientras se procesa una operación
 * @param {string} mensaje - Mensaje de carga (opcional)
 * @param {string} titulo - Título de la alerta (opcional)
 * @returns {Promise<void>}
 */
export const showCargando = (mensaje = 'Procesando...', titulo = 'Por favor espere') => {
  return Swal.fire({
    ...baseConfig,
    title: titulo,
    html: `
      <div style="display: flex; flex-direction: column; align-items: center; gap: 16px;">
        <div class="swal2-loader" style="border-color: #1976D2; border-top-color: transparent;"></div>
        <div style="color: #666; font-size: 14px;">${mensaje}</div>
      </div>
    `,
    allowOutsideClick: false,
    allowEscapeKey: false,
    allowEnterKey: false,
    showConfirmButton: false,
    didOpen: () => {
      Swal.showLoading()
    }
  })
}

/**
 * Cierra la alerta de carga actual
 */
export const cerrarCargando = () => {
  Swal.close()
}

/**
 * Ejecuta una operación asíncrona mostrando un indicador de carga
 * Muestra feedback de éxito o error al finalizar
 * @param {Function} operacion - Función asíncrona a ejecutar
 * @param {Object} opciones - Opciones de configuración
 * @param {string} opciones.mensajeCargando - Mensaje mientras se procesa
 * @param {string} opciones.tituloCargando - Título de la alerta de carga
 * @param {string} opciones.mensajeExito - Mensaje de éxito
 * @param {string} opciones.tituloExito - Título de éxito
 * @param {string} opciones.tipoOperacion - Tipo de operación ('registrar', 'modificar', 'eliminar')
 * @returns {Promise<any>} Resultado de la operación
 */
export const ejecutarConCarga = async (
  operacion,
  {
    mensajeCargando = 'Procesando operación...',
    tituloCargando = 'Por favor espere',
    mensajeExito = null,
    tituloExito = null,
    tipoOperacion = 'registrar'
  } = {}
) => {
  // Mostrar indicador de carga
  showCargando(mensajeCargando, tituloCargando)

  try {
    // Ejecutar la operación
    const resultado = await operacion()

    // Cerrar indicador de carga
    cerrarCargando()

    // Mostrar mensaje de éxito según el tipo de operación
    if (tipoOperacion === 'registrar') {
      await showRegistrado(mensajeExito, tituloExito)
    } else if (tipoOperacion === 'modificar') {
      await showModificado(mensajeExito, tituloExito)
    } else if (tipoOperacion === 'eliminar') {
      await showEliminado(mensajeExito, tituloExito)
    }

    return resultado
  } catch (error) {
    // Cerrar indicador de carga
    cerrarCargando()

    // Mostrar mensaje de error
    const mensajeError = error.response?.data?.message || error.message || 'Ha ocurrido un error inesperado'
    await showError(mensajeError, '¡Error!')

    // Re-lanzar el error para que el componente pueda manejarlo si es necesario
    throw error
  }
}


