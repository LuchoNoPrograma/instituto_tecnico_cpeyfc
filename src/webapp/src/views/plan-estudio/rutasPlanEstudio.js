export default [
  {
    path: '/plan-estudio/:id',
    name: 'VistaPlanEstudio',
    component: () => import('./VistaPlanEstudio.vue'),
    meta: {
      requiresAuth: true,
      /*requiredPermissions: ['VER_PERSONAS']*/
    }
  },
]
