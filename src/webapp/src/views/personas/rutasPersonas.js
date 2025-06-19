export default [
  {
    path: '/personas',
    name: 'ListaPersonas',
    component: () => import('./ListaPersonas.vue'),
    meta: {
      requiresAuth: true,
      /*requiredPermissions: ['VER_PERSONAS']*/
    }
  },
  {
    path: '/personas/nuevo',
    name: 'PersonaCreate',
    component: () => import('./FormularioPersona.vue'),
    meta: {
      requiresAuth: true,
      requiredPermissions: ['CREAR_PERSONAS']
    }
  },
  {
    path: '/personas/:id',
    name: 'PersonaDetail',
    component: () => import('./DetallePersona.vue'),
    meta: {
      requiresAuth: true,
      requiredPermissions: ['VER_PERSONAS']
    }
  }
]
