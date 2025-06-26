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
  }
]
