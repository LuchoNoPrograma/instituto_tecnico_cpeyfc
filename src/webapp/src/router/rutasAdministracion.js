// src/enrutador/rutasAdministracion.js
export default [
  {
    path: '/admin',
    name: 'AdminDashboard',
    component: () => import('@/views/admin/PanelAdministracion.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true,
      requiredRoles: ['ADMIN']
    }
  },
  /*{
    path: '/admin/usuarios',
    name: 'AdminUsuarios',
    component: () => import('@/views/admin/usuarios/ListaUsuarios.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true,
      requiredRoles: ['ADMIN'],
      requiredPermissions: ['GESTIONAR_USUARIOS']
    }
  },
  {
    path: '/admin/usuarios/nuevo',
    name: 'AdminUsuarioNuevo',
    component: () => import('@/views/admin/usuarios/FormularioUsuario.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true,
      requiredRoles: ['ADMIN'],
      requiredPermissions: ['CREAR_USUARIOS']
    }
  },
  {
    path: '/admin/usuarios/:id/editar',
    name: 'AdminUsuarioEditar',
    component: () => import('@/views/admin/usuarios/EditarUsuario.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true,
      requiredRoles: ['ADMIN'],
      requiredPermissions: ['EDITAR_USUARIOS']
    }
  },
  {
    path: '/admin/roles',
    name: 'AdminRoles',
    component: () => import('@/views/admin/roles/ListaRoles.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true,
      requiredRoles: ['ADMIN'],
      requiredPermissions: ['GESTIONAR_ROLES']
    }
  },
  {
    path: '/admin/configuracion',
    name: 'AdminConfiguracion',
    component: () => import('@/views/admin/Configuracion.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true,
      requiredRoles: ['ADMIN']
    }
  },
  {
    path: '/admin/reportes',
    name: 'AdminReportes',
    component: () => import('@/views/admin/Reportes.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true,
      requiredRoles: ['ADMIN'],
      requiredPermissions: ['VER_REPORTES']
    }
  },
  {
    path: '/admin/auditoria',
    name: 'AdminAuditoria',
    component: () => import('@/views/admin/Auditoria.vue'),
    meta: {
      layout: 'LayoutCompleto',
      requiresAuth: true,
      requiredRoles: ['ADMIN'],
      requiredPermissions: ['VER_AUDITORIA']
    }
  }*/
]
