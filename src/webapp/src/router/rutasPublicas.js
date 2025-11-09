export default [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/inicio/Inicio.vue')
  },
  {
    path: '/about',
    name: 'About',
    component: () => import('@/views/public/AcercaDe.vue')
  },
  {
    path: '/inscripciones',
    name: 'Inscripciones',
    component: () => import('@/views/public/Inscripciones.vue')
  },
  {
    path: '/noticias/:id/:slug?',
    name: 'NoticiaDetalle',
    component: () => import('@/views/noticias/NoticiaDetalle.vue')
  }
]
