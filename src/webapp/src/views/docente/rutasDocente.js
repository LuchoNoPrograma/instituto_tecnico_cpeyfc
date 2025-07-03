export default [
  {
    path: '/docente/notas/:id',
    name: 'AdministrarNotas',
    component: () => import('./AdministrarNotas.vue'),
    meta: {
      requiresAuth: true,
      /*requiredPermissions: ['VER_GRUPOS']*/
    }
  }
]
