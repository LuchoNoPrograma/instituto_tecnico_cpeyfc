export default [
  {
    path: '/convenios',
    name: 'Convenios',
    component: () => import('@/views/convenios/ListaConvenios.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true,
      roles: ['ADMIN', 'ADMINISTRATIVO']
    }
  }
]
