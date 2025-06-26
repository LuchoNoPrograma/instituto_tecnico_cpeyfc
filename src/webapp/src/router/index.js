import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import rutasPublicas from './rutasPublicas'
import rutasAuth from './rutasAutenticacion.js'
import rutasAdmin from './rutasAutenticacion.js'
import rutasPersonas from '@/views/personas/rutasPersonas.js'
import rutasProgramas from '@/views/programas/rutasProgramas.js';
import rutasGrupos from '@/views/grupos/rutasGrupos.js';
import rutasMatriculas from '@/views/matriculas/rutasMatriculas.js';
import rutasPlanEstudio from '@/views/plan-estudio/rutasPlanEstudio.js';

const routes = [
  ...rutasPublicas,
  ...rutasAuth,
  ...rutasAdmin,
  ...rutasPersonas,
  ...rutasProgramas,
  ...rutasGrupos,
  ...rutasMatriculas,
  ...rutasPlanEstudio,

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

  if (to.meta.requiresAuth && !isLoggedIn()) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
    return
  }

  if (to.meta.requiredRoles && !hasAnyRole(...to.meta.requiredRoles)) {
    next({ name: 'Dashboard' })
    return
  }

  if (to.meta.requiredPermissions && !hasAnyPermission(...to.meta.requiredPermissions)) {
    next({ name: 'Dashboard' })
    return
  }

  if (to.name === 'Login' && isLoggedIn()) {
    next({ name: 'Dashboard' })
    return
  }

  next()
})

export default router
