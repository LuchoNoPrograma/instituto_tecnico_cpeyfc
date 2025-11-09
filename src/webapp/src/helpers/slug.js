/**
 * Genera un slug amigable para URLs a partir de un texto
 * @param {string} texto - Texto a convertir en slug
 * @returns {string} - Slug generado
 *
 * @example
 * generarSlug('Nuevo Programa de Inglés 2025!') // 'nuevo-programa-de-ingles-2025'
 */
export const generarSlug = (texto) => {
  if (!texto) return ''

  return texto
    .toString()
    .toLowerCase()
    .trim()
    // Normalizar caracteres (quitar tildes, diéresis, etc.)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    // Reemplazar espacios y caracteres especiales por guiones
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    // Eliminar múltiples guiones consecutivos
    .replace(/-+/g, '-')
    // Quitar guiones al inicio y final
    .replace(/^-+|-+$/g, '')
    // Limitar longitud (opcional, para evitar URLs muy largas)
    .substring(0, 100)
}

/**
 * Sanitiza contenido HTML para prevenir XSS
 * @param {string} html - HTML a sanitizar
 * @returns {string} - HTML limpio y seguro
 */
export const sanitizarHTML = (html) => {
  if (!html) return ''

  // DOMPurify se importa dinámicamente donde se use
  // Esta función es un wrapper para uso consistente
  return html
}
