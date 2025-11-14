export default [
  {
    path: '/catalogos/programas',
    name: 'CatalogosProgramas',
    component: () => import('@/views/catalogos/programas/ListaProgramas.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/catalogos/perfiles',
    name: 'CatalogosPerfiles',
    component: () => import('@/views/catalogos/perfiles/ListaPerfiles.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/catalogos/requisitos',
    name: 'CatalogosRequisitos',
    component: () => import('@/views/catalogos/requisitos/ListaRequisitos.vue'),
    meta: { requiresAuth: true }
  }
]
