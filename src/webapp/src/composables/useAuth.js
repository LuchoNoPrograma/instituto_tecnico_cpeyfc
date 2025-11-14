// src/composables/useAuth.js
import { ref } from 'vue'
import { api } from '../services/api.js'

const user = ref(null)

export function useAuth() {
  // --- Login con tu endpoint /authenticate ---
  const login = async ({ nombreUsuario, password }) => {
    try {
      const response = await api.post('/api/authenticate', {
        nombreUsuario,
        password
      })

      const { accessToken } = response.data
      localStorage.setItem('access_token', accessToken)
      user.value = parseJwt(accessToken)

      return response.data
    } catch (error) {
      console.error('Error en login:', error)
      throw error
    }
  }

  // --- Logout ---
  const logout = () => {
    localStorage.removeItem('access_token')
    user.value = null
  }

  // --- Verifica si está logueado ---
  const isLoggedIn = () => {
    const token = localStorage.getItem('access_token')
    if (!token) return false
    const payload = parseJwt(token)
    return payload && payload.exp > Math.floor(Date.now() / 1000)
  }

  // --- Obtiene roles del usuario (claim directo) ---
  const getRoles = () => {
    const token = localStorage.getItem('access_token')
    if (!token) return []
    const payload = parseJwt(token)
    return payload.roles || []
  }

  // --- Obtiene tareas del usuario (claim directo) ---
  const getTareas = () => {
    const token = localStorage.getItem('access_token')
    if (!token) return []
    const payload = parseJwt(token)
    return payload.tareas || []
  }

  // --- Obtiene ID del usuario ---
  const getUserId = () => {
    const token = localStorage.getItem('access_token')
    if (!token) return null
    const payload = parseJwt(token)
    return payload.userId
  }

  // --- Obtiene nombre de usuario ---
  const getUsername = () => {
    const token = localStorage.getItem('access_token')
    if (!token) return null
    const payload = parseJwt(token)
    return payload.sub
  }

  // --- Verifica si tiene un rol específico ---
  const hasRole = (roleName) => {
    const roles = getRoles()
    return roles.includes(roleName.toUpperCase())
  }

  // --- Verifica si tiene una tarea específica ---
  const hasPermission = (tareaName) => {
    const tareas = getTareas()
    return tareas.includes(tareaName.toUpperCase())
  }

  // --- Verifica si tiene al menos uno de los roles ---
  const hasAnyRole = (...roleNames) => {
    const roles = getRoles()
    return roleNames.some(role => roles.includes(role.toUpperCase()))
  }

  // --- Verifica si tiene al menos una de las tareas ---
  const hasAnyPermission = (...tareaNames) => {
    const tareas = getTareas()
    return tareaNames.some(tarea => tareas.includes(tarea.toUpperCase()))
  }

  // --- Verifica múltiples condiciones ---
  const hasRoleAndPermission = (roleName, tareaName) => {
    return hasRole(roleName) && hasPermission(tareaName)
  }

  // --- Obtiene info completa del usuario ---
  const getCurrentUser = () => {
    const token = localStorage.getItem('access_token')
    if (!token) return null
    const payload = parseJwt(token)
    return {
      username: payload.sub,
      userId: payload.userId,
      roles: payload.roles || [],
      tareas: payload.tareas || [],
      authorities: payload.authorities || [],
      exp: payload.exp,
      iat: payload.iat
    }
  }

  // --- Inicializar usuario si hay token ---
  const initializeAuth = () => {
    const token = localStorage.getItem('access_token')
    if (token && isLoggedIn()) {
      user.value = parseJwt(token)
    }
  }

  // --- Util para parsear JWT ---
  function parseJwt(token) {
    try {
      return JSON.parse(atob(token.split('.')[1]))
    } catch (e) {
      console.error('Error parsing JWT:', e)
      return null
    }
  }

  return {
    login,
    logout,
    isLoggedIn,
    getRoles,
    getTareas,
    getUserId,
    getUsername,
    hasRole,
    hasPermission,
    hasAnyRole,
    hasAnyPermission,
    hasRoleAndPermission,
    getCurrentUser,
    initializeAuth,
    user
  }
}
