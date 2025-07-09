export default [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/public/Inicio.vue')
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
  }
]
