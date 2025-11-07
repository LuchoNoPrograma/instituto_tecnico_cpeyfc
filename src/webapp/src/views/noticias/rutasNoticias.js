export default [
  {
    path: '/noticias',
    name: 'ListaNoticias',
    component: () => import('./ListaNoticias.vue'),
    meta: {
      requiresAuth: true,
      /*requiredPermissions: ['VER_NOTICIAS']*/
    }
  }
]
