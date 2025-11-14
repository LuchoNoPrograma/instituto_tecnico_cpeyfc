export default [
  {
    path: '/programas',
    name: 'ListaProgramas',
    component: () => import('./ListaProgramasAprobados.vue'),
    meta: {
      requiresAuth: true,
      /*requiredPermissions: ['VER_PERSONAS']*/
    }
  }
]
