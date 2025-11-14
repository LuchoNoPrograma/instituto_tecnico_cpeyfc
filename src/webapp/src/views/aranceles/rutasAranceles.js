export default [
  {
    path: '/aranceles',
    name: 'Aranceles',
    component: () => import('@/views/aranceles/ListaAranceles.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true,
      roles: ['ADMIN', 'ADMINISTRATIVO']
    }
  }
]
