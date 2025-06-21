// helpers/validations.js
import {
  required,
  minLength,
  maxLength,
  email,
  helpers
} from '@vuelidate/validators'

// Validadores en español con mensajes integrados
export const esRequerido = helpers.withMessage('Este campo es requerido', required)

export const longitudMinima = (min) => helpers.withMessage(
  `Mínimo ${min} caracteres`,
  minLength(min)
)

export const longitudMaxima = (max) => helpers.withMessage(
  `Máximo ${max} caracteres`,
  maxLength(max)
)

export const esEmail = helpers.withMessage(
  'Formato de correo inválido',
  email
)

export const soloLetras = helpers.withMessage(
  'Solo se permiten letras y espacios',
  helpers.regex(/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/)
)

export const soloNumeros = helpers.withMessage(
  'Solo se permiten números',
  helpers.regex(/^[0-9]+$/)
)

export const ciBoliviano = helpers.withMessage(
  'Formato de CI boliviano inválido',
  (value) => {
    if (!value) return true
    return /^[0-9]{5,9}(-?[0-9A-Za-z]{1,3})?$/.test(value)
  }
)

export const celularBoliviano = helpers.withMessage(
  'Formato de celular boliviano inválido',
  (value) => {
    if (!value) return true
    return /^(\+?591)?[67][0-9]{7}$/.test(value.replace(/\s|-/g, ''))
  }
)

export const edadMinima = (minima) => helpers.withMessage(
  `Debe ser mayor de ${minima} años`,
  (value) => {
    if (!value) return true
    const hoy = new Date()
    const fechaNacimiento = new Date(value)
    const edad = hoy.getFullYear() - fechaNacimiento.getFullYear()
    return edad >= minima
  }
)

export const noFuturo = helpers.withMessage(
  'La fecha no puede ser futura',
  (value) => {
    if (!value) return true
    return new Date(value) <= new Date()
  }
)

// Helper para obtener errores de un campo
export const obtenerErroresCampo = (campo) => {
  if (!campo.$error || !campo.$errors.length) return []
  return campo.$errors.map(error => error.$message)
}

// Helper para validar formulario completo
export const validarFormulario = async (validador) => {
  const esValido = await validador.$validate()
  if (!esValido) {
    console.warn('Formulario inválido')
  }
  return esValido
}

// Helper para resetear validaciones
export const resetearValidaciones = (validador) => {
  validador.$reset()
}

export default {
  esRequerido,
  longitudMinima,
  longitudMaxima,
  esEmail,
  soloLetras,
  soloNumeros,
  ciBoliviano,
  celularBoliviano,
  edadMinima,
  noFuturo,
  obtenerErroresCampo,
  validarFormulario,
  resetearValidaciones
}
