export default [
  {
    path: '/grupos',
    name: 'GestionGrupos',
    component: () => import('./ListaGrupos.vue'),
    meta: {
      requiresAuth: true,
      /*requiredPermissions: ['VER_GRUPOS']*/
    }
  },
  {
    path: '/grupos/:id',
    name: 'DetalleGrupo',
    component: () => import('./ListaGrupos.vue'),
    meta: {
      requiresAuth: true,
      /*requiredPermissions: ['VER_GRUPOS']*/
    }
  }
]
