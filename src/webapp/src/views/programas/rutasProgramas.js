export default [
  {
    path: '/programas',
    name: 'ListaProgramas',
    component: () => import('./ListaProgramas.vue'),
    meta: {
      requiresAuth: true,
      /*requiredPermissions: ['VER_PERSONAS']*/
    }
  }
]
