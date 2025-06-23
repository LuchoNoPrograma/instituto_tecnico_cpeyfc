// helpers/filtros.js
import { deburr } from 'lodash'

// Normaliza sin acentos y mayúsculas
function normalize(str) {
  return deburr(String(str || '')).toUpperCase()
}

// Normaliza sin espacios
function normalizeSinEspacios(str) {
  return normalize(str).replace(/\s+/g, '')
}

// Genera mapa de índices sin espacios → original
function buildIndexMap(original) {
  const map = []
  for (let i = 0; i < original.length; i++) {
    if (original[i] !== ' ') map.push(i)
  }
  return map
}

// Encuentra índices de coincidencias de palabra
function findWordIndices(original, palabra) {
  const normOriginal = normalize(original)
  const normPalabra = normalize(palabra)

  const indices = []
  let idx = normOriginal.indexOf(normPalabra)

  while (idx !== -1) {
    indices.push([idx, idx + normPalabra.length])
    idx = normOriginal.indexOf(normPalabra, idx + normPalabra.length)
  }
  return indices
}

/**
 * Filtro latino básico compatible con Vuetify
 */
export const filtroLatino = (value, query, item) => {
  if (value == null || query == null) return -1

  const original = String(value)
  const normValue = normalizeSinEspacios(original)
  const normQuery = normalizeSinEspacios(String(query))

  if (!normQuery.length) return 0

  const indexMap = buildIndexMap(original.toUpperCase())
  const idxs = []

  let idx = normValue.indexOf(normQuery)
  while (idx > -1) {
    const start = indexMap[idx]
    const end = indexMap[idx + normQuery.length - 1] + 1
    idxs.push([start, end])
    idx = normValue.indexOf(normQuery, idx + normQuery.length)
  }

  return idxs.length ? idxs : -1
}

/**
 * Filtro flexible que permite buscar palabras en cualquier orden
 */
export const filtroLatinoFlexible = (value, query) => {
  if (!value || !query) return -1

  const original = String(value)
  const palabras = normalize(query).split(/\s+/).filter(Boolean)

  let allMatches = []

  for (const palabra of palabras) {
    const indices = findWordIndices(original, palabra)
    if (!indices.length) return -1 // Si una palabra no se encuentra, no hay match
    allMatches = allMatches.concat(indices)
  }

  // Elimina rangos superpuestos
  allMatches.sort((a, b) => a[0] - b[0])
  const merged = []

  for (const [start, end] of allMatches) {
    if (!merged.length || merged[merged.length - 1][1] <= start) {
      merged.push([start, end])
    } else {
      merged[merged.length - 1][1] = Math.max(merged[merged.length - 1][1], end)
    }
  }

  return merged
}

/**
 * Filtro para programas con opciones de crear nuevo
 */
export const filtroProgramas = (items, query) => {
  if (!query) return items

  const resultados = items.filter(item => {
    const texto = `${item.nombre_programa} ${item.sigla || ''} ${item.area_nombre || ''}`
    return filtroLatinoFlexible(texto, query) !== -1
  })

  // Si no hay resultados, agregar opción para crear nuevo
  if (resultados.length === 0) {
    resultados.push({
      id: 'nuevo',
      nombre_programa: `Crear nuevo programa: "${query}"`,
      sigla: '',
      area_nombre: '',
      esNuevo: true,
      textoOriginal: query
    })
  }

  return resultados
}

/**
 * Helper para destacar texto coincidente
 */
export const destacarCoincidencias = (texto, query) => {
  if (!query) return texto

  const coincidencias = filtroLatinoFlexible(texto, query)
  if (coincidencias === -1) return texto

  let resultado = ''
  let ultimoIndice = 0

  for (const [inicio, fin] of coincidencias) {
    resultado += texto.slice(ultimoIndice, inicio)
    resultado += `<mark class="bg-yellow-200">${texto.slice(inicio, fin)}</mark>`
    ultimoIndice = fin
  }

  resultado += texto.slice(ultimoIndice)
  return resultado
}

export default {
  filtroLatino,
  filtroLatinoFlexible,
  filtroProgramas,
  destacarCoincidencias
}
