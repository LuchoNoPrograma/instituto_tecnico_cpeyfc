export default [
  {
    path: '/perfil-estudiante',
    name: 'PerfilEstudiante',
    component: () => import('./PerfilEstudiante.vue'),
    meta: {
      requiresAuth: true,
      /*requiredPermissions: ['VER_GRUPOS']*/
    }
  },
  {
    path: '/matriculas',
    name: 'ListaMatriculas',
    component: () => import('./ListaMatriculas.vue'),
    meta: {
      requiresAuth: true,
      /*requiredPermissions: ['VER_GRUPOS']*/
    }
  },
  {
    path: '/matriculas/preinscrito',
    name: 'MatricularPreinscrito',
    component: () => import('@/views/matriculas/MatricularPreinscrito.vue'),
    meta: {
      requiresAuth: true,
    }
  },
  {
    path: '/finanzas',
    name: 'Finanzas',
    component: () => import('@/views/matriculas/Finanzas.vue'),
    meta: {
      requiresAuth: true,
    }
  },
]
