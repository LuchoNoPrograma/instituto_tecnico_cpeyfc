<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const { logout, getCurrentUser, hasPermission } = useAuth()

const drawer = ref(true)
const usuario = computed(() => getCurrentUser())

const menuItems = computed(() => [
  {
    titulo: 'Panel Principal',
    icono: 'mdi-view-dashboard',
    ruta: '/dashboard',
    mostrar: true
  },
  {
    titulo: 'Personas',
    icono: 'mdi-account-group',
    ruta: '/personas',
    mostrar: hasPermission('VER_PERSONAS')
  },
  {
    titulo: 'Programas',
    icono: 'mdi-school',
    ruta: '/programas',
    mostrar: hasPermission('VER_PROGRAMAS')
  },
  {
    titulo: 'Grupos',
    icono: 'mdi-account-group',
    ruta: '/grupos',
    mostrar: hasPermission('VER_PROGRAMAS')
  },
  /*{
    titulo: 'Matrículas',
    icono: 'mdi-account-school',
    ruta: '/matriculas',
    mostrar: hasPermission('VER_MATRICULAS')
  },*/
  {
    titulo: 'Ver perfil',
    icono: 'mdi-account-school',
    ruta: '/perfil-estudiante',
    mostrar: hasPermission('VER_MATRICULAS')
  },
  /*{
    titulo: 'Ejecución Académica',
    icono: 'mdi-clipboard-play',
    ruta: '/ejecucion',
    mostrar: hasPermission('VER_EJECUCION')
  },
  {
    titulo: 'Finanzas',
    icono: 'mdi-currency-usd',
    ruta: '/finanzas',
    mostrar: hasPermission('VER_FINANZAS')
  },
  {
    titulo: 'Certificación',
    icono: 'mdi-certificate',
    ruta: '/certificados',
    mostrar: hasPermission('VER_CERTIFICADOS')
  },
  {
    titulo: 'Trabajo de Grado',
    icono: 'mdi-book-open-page-variant',
    ruta: '/trabajos-grado',
    mostrar: hasPermission('VER_TRABAJOS_GRADO')
  },
  {
    titulo: 'Administración',
    icono: 'mdi-cog',
    ruta: '/admin',
    mostrar: hasPermission('ADMIN')
  }*/
]/*.filter(item => item.mostrar)*/)

const cerrarSesion = async () => {
  logout()
  router.push('/login')
}

const irAPerfil = () => {
  router.push('/perfil')
}

const verProgramasEjecucion = () => {
  router.push('/ejecucion/cronogramas')
}
</script>

<template>
  <v-app>
    <!-- Menú lateral -->
    <v-navigation-drawer
      v-model="drawer"
      app
      color="primary"
      class="elevation-2"
    >
      <!-- Header del menú -->
      <v-list-item class="pa-4">
        <v-avatar color="white" size="40">
          <v-icon color="primary">mdi-school</v-icon>
        </v-avatar>
        <v-list-item-title class="text-h6 font-weight-bold text-white">
          CPEYFC
        </v-list-item-title>
        <v-list-item-subtitle class="text-caption text-white" style="opacity: 0.8;">
          {{ usuario?.username || 'Usuario' }}
        </v-list-item-subtitle>
      </v-list-item>

      <v-divider color="white" style="opacity: 0.3;"></v-divider>

      <!-- Items del menú -->
      <v-list nav density="comfortable">
        <v-list-item
          v-for="item in menuItems"
          :key="item.titulo"
          :to="item.ruta"
          :prepend-icon="item.icono"
          :title="item.titulo"
          class="menu-item"
          color="white"
        ></v-list-item>
      </v-list>

      <!-- Footer del menú -->
      <template #append>
        <v-divider color="white" style="opacity: 0.3;"></v-divider>
        <v-list density="compact">
          <v-list-item
            prepend-icon="mdi-book-open"
            title="Documentación"
            class="menu-item"
            color="white"
            @click="$router.push('/docs')"
          ></v-list-item>
        </v-list>
      </template>
    </v-navigation-drawer>

    <!-- Header superior -->
    <v-app-bar
      app
      color="secondary"
      class="elevation-2 header-bar"
    >
      <v-app-bar-nav-icon
        @click="drawer = !drawer"
        class="me-2"
        color="white"
      ></v-app-bar-nav-icon>

      <v-toolbar-title class="text-h6 font-weight-bold text-white">
        Centro Profesional de Enseñanza y Formación Continua
      </v-toolbar-title>

      <v-spacer></v-spacer>

      <!-- Acceso rápido a programas en ejecución -->
      <v-btn
        icon
        class="me-2"
        color="white"
        @click="verProgramasEjecucion"
      >
        <v-icon>mdi-clipboard-play</v-icon>
        <v-tooltip activator="parent" location="bottom">
          Ver Programas en Ejecución
        </v-tooltip>
      </v-btn>

      <!-- Notificaciones -->
      <v-btn icon class="me-2" color="white">
        <v-icon>mdi-bell-outline</v-icon>
        <v-tooltip activator="parent" location="bottom">
          Notificaciones
        </v-tooltip>
      </v-btn>

      <!-- Menú de usuario -->
      <v-menu offset-y>
        <template #activator="{ props }">
          <v-btn
            v-bind="props"
            icon
            class="user-avatar"
          >
            <v-avatar color="primary" size="36">
              <v-icon color="white">mdi-account</v-icon>
            </v-avatar>
          </v-btn>
        </template>

        <v-list min-width="200">
          <v-list-item>
            <v-list-item-title class="font-weight-bold">
              {{ usuario?.username || 'Usuario' }}
            </v-list-item-title>
            <v-list-item-subtitle>
              {{ usuario?.roles?.join(', ') || 'Sin roles' }}
            </v-list-item-subtitle>
          </v-list-item>

          <v-divider></v-divider>

          <v-list-item @click="irAPerfil">
            <v-list-item-title>
              <v-icon start>mdi-account-circle</v-icon>
              Mi Perfil
            </v-list-item-title>
          </v-list-item>

          <v-list-item @click="$router.push('/configuracion')">
            <v-list-item-title>
              <v-icon start>mdi-cog</v-icon>
              Configuración
            </v-list-item-title>
          </v-list-item>

          <v-divider></v-divider>

          <v-list-item @click="cerrarSesion">
            <v-list-item-title class="text-error">
              <v-icon start>mdi-logout</v-icon>
              Cerrar Sesión
            </v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-app-bar>

    <!-- Contenido principal -->
    <v-main class="main-content">
      <v-container fluid class="pa-4">
        <slot />
      </v-container>
    </v-main>
  </v-app>
</template>

<style lang="scss" scoped>
.header-bar {
  .v-toolbar-title {
    font-size: 1.1rem !important;
  }
}

.menu-item {
  border-radius: 0;
  margin: 0;

  &.v-list-item--active {
    background: rgba(255, 255, 255, 0.2) !important;
    color: white !important;

    .v-icon {
      color: white !important;
    }
  }

  &:hover {
    background: rgba(255, 255, 255, 0.1) !important;
    color: white !important;

    .v-icon {
      color: white !important;
    }
  }

  // Asegurar que el texto sea blanco
  .v-list-item-title {
    color: white !important;
  }

  .v-icon {
    color: rgba(255, 255, 255, 0.9) !important;
  }
}

.main-content {
  background-color: rgb(var(--v-theme-background));
}

.user-avatar {
  transition: transform 0.2s;

  &:hover {
    transform: scale(1.1);
  }
}

// Responsive
@media (max-width: 960px) {
  .header-bar .v-toolbar-title {
    font-size: 0.9rem !important;
  }
}

@media (max-width: 600px) {
  .header-bar .v-toolbar-title {
    display: none;
  }
}
</style>
