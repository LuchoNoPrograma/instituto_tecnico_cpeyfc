export default [
  {
    path: '/catalogos/programas',
    name: 'CatalogosProgramas',
    component: () => import('@/views/catalogos/programas/ListaProgramas.vue'),
    meta: { requiresAuth: true }
  }
]
