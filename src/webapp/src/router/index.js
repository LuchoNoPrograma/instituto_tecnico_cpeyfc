import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { useLoadingStore } from '@/stores/loading'
import rutasPublicas from './rutasPublicas'
import rutasAuth from './rutasAutenticacion.js'
import rutasAdmin from './rutasAutenticacion.js'
import rutasPersonas from '@/views/personas/rutasPersonas.js'
import rutasProgramas from '@/views/programas-aprobados/rutasProgramas.js';
import rutasGrupos from '@/views/grupos/rutasGrupos.js';
import rutasMatriculas from '@/views/matriculas/rutasMatriculas.js';
import rutasPlanEstudio from '@/views/plan-estudio/rutasPlanEstudio.js';
import rutasDocente from '@/views/docente/rutasDocente.js';
import rutasNoticias from '@/views/noticias/rutasNoticias.js';
import rutasAranceles from '@/views/aranceles/rutasAranceles.js';
import rutasConvenios from '@/views/convenios/rutasConvenios.js';
import rutasCatalogos from '@/views/catalogos/rutasCatalogos.js';

const routes = [
  ...rutasPublicas,
  ...rutasAuth,
  ...rutasAdmin,
  ...rutasCatalogos,
  ...rutasPersonas,
  ...rutasProgramas,
  ...rutasGrupos,
  ...rutasMatriculas,
  ...rutasPlanEstudio,
  ...rutasDocente,
  ...rutasNoticias,
  ...rutasAranceles,
  ...rutasConvenios,

  // Dashboard principal
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/PanelPrincipal.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true
    }
  },

  // 404
  {
    path: '/:pathMatch(.*)*',
    name: 'NoEncontrado',
    component: () => import('@/views/NoEncontrado.vue'),
    meta: { layout: 'LayoutBlanco' }
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

// Guard de navegación
router.beforeEach((to, from, next) => {
  const { isLoggedIn, hasAnyRole, hasAnyPermission } = useAuth()
  const loadingStore = useLoadingStore()

  // Mostrar loading solo si no es la carga inicial y las rutas son diferentes
  if (from.name !== undefined && to.name !== from.name) {
    loadingStore.show('Cargando página...')
  }

  if (to.meta.requiresAuth && !isLoggedIn()) {
    loadingStore.hide()
    next({ name: 'Login', query: { redirect: to.fullPath } })
    return
  }

  if (to.meta.requiredRoles && !hasAnyRole(...to.meta.requiredRoles)) {
    loadingStore.hide()
    next({ name: 'Dashboard' })
    return
  }

  if (to.meta.requiredPermissions && !hasAnyPermission(...to.meta.requiredPermissions)) {
    loadingStore.hide()
    next({ name: 'Dashboard' })
    return
  }

  if (to.name === 'Login' && isLoggedIn()) {
    loadingStore.hide()
    next({ name: 'Dashboard' })
    return
  }

  next()
})

// Ocultar loading después de que la navegación se complete
router.afterEach(() => {
  const loadingStore = useLoadingStore()
  // Usar setTimeout para dar tiempo a que el componente se monte
  setTimeout(() => {
    loadingStore.hide()
  }, 100)
})

export default router
