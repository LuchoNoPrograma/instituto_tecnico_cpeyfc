import moment from 'moment'
import 'moment/locale/es'

// Configurar locale español por defecto
moment.locale('es')

/**
 * Formateador de fechas con moment.js
 */
export const formatoFecha = {
  /**
   * Formato dd/MM/yyyy
   * @param {string|Date|moment} fecha - Fecha a formatear
   * @returns {string} Fecha formateada
   */
  ddMMaaaa: (fecha ) => {
    if (!fecha) return 'Sin fecha'
    return moment(fecha).format('DD/MM/YYYY')
  },

  /**
   * Formato dd/MM/yyyy HH:mm
   * @param {string|Date|moment} fecha - Fecha a formatear
   * @returns {string} Fecha y hora formateada
   */
  ddMMaaaaHHmm: (fecha) => {
    if (!fecha) return ''
    return moment(fecha).format('DD/MM/YYYY HH:mm')
  },

  /**
   * Formato completo: Lunes, 15 de enero de 2024
   * @param {string|Date|moment} fecha - Fecha a formatear
   * @returns {string} Fecha formateada completa
   */
  completo: (fecha) => {
    if (!fecha) return ''
    return moment(fecha).format('dddd, DD [de] MMMM [de] YYYY')
  },

  /**
   * Formato corto: 15 ene 2024
   * @param {string|Date|moment} fecha - Fecha a formatear
   * @returns {string} Fecha formateada corta
   */
  corto: (fecha) => {
    if (!fecha) return ''
    return moment(fecha).format('DD MMM YYYY')
  },

  /**
   * Formato relativo: hace 2 días, en 3 horas, etc.
   * @param {string|Date|moment} fecha - Fecha a formatear
   * @returns {string} Fecha relativa
   */
  relativo: (fecha) => {
    if (!fecha) return ''
    return moment(fecha).fromNow()
  },

  /**
   * Solo fecha ISO para inputs date
   * @param {string|Date|moment} fecha - Fecha a formatear
   * @returns {string} Fecha en formato YYYY-MM-DD
   */
  inputDate: (fecha) => {
    if (!fecha) return ''
    return moment(fecha).format('YYYY-MM-DD')
  },

  /**
   * Validar si una fecha es válida
   * @param {string|Date|moment} fecha - Fecha a validar
   * @returns {boolean} True si es válida
   */
  esValida: (fecha) => {
    return moment(fecha).isValid()
  },

  /**
   * Obtener fecha actual formateada
   * @param {string} formato - Formato deseado (opcional, default: DD/MM/YYYY)
   * @returns {string} Fecha actual formateada
   */
  ahora: (formato = 'DD/MM/YYYY') => {
    return moment().format(formato)
  },

  /**
   * Calcular diferencia entre fechas
   * @param {string|Date|moment} fechaInicio - Fecha de inicio
   * @param {string|Date|moment} fechaFin - Fecha de fin
   * @param {string} unidad - Unidad de diferencia (days, months, years, etc.)
   * @returns {number} Diferencia en la unidad especificada
   */
  diferencia: (fechaInicio, fechaFin, unidad = 'days') => {
    return moment(fechaFin).diff(moment(fechaInicio), unidad)
  },

  /**
   * Agregar tiempo a una fecha
   * @param {string|Date|moment} fecha - Fecha base
   * @param {number} cantidad - Cantidad a agregar
   * @param {string} unidad - Unidad (days, months, years, etc.)
   * @returns {string} Fecha resultante en formato DD/MM/YYYY
   */
  agregar: (fecha, cantidad, unidad) => {
    return moment(fecha).add(cantidad, unidad).format('DD/MM/YYYY')
  },

  /**
   * Restar tiempo a una fecha
   * @param {string|Date|moment} fecha - Fecha base
   * @param {number} cantidad - Cantidad a restar
   * @param {string} unidad - Unidad (days, months, years, etc.)
   * @returns {string} Fecha resultante en formato DD/MM/YYYY
   */
  restar: (fecha, cantidad, unidad) => {
    return moment(fecha).subtract(cantidad, unidad).format('DD/MM/YYYY')
  }
}

/**
 * Instancia de moment configurada
 */
export const momentoEs = moment

/**
 * Función directa para formatear con dd/MM/yyyy
 * @param {string|Date|moment} fecha - Fecha a formatear
 * @returns {string} Fecha formateada
 */
export const formatearFecha = (fecha) => formatoFecha.ddMMaaaa(fecha)

// Export por defecto
export default formatoFecha
