<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuth } from '@/composables/useAuth'
import { api } from '@/services/api'

const { getCurrentUser, hasPermission } = useAuth()
const usuario = computed(() => getCurrentUser())

// Estados reactivos
const estadisticas = ref({
  totalPersonas: 0,
  matriculasActivas: 0,
  programasVigentes: 0,
  pendientesPago: 0
})

const actividades = ref([])
const notificaciones = ref([])
const cargando = ref(true)

// Tarjetas de estadísticas
const tarjetasEstadisticas = computed(() => [
  {
    titulo: 'Total Personas',
    valor: estadisticas.value.totalPersonas,
    icono: 'mdi-account-group',
    color: 'primary',
    ruta: '/personas',
    permiso: 'VER_PERSONAS'
  },
  {
    titulo: 'Matrículas Activas',
    valor: estadisticas.value.matriculasActivas,
    icono: 'mdi-account-school',
    color: 'success',
    ruta: '/matriculas',
    permiso: 'VER_MATRICULAS'
  },
  {
    titulo: 'Programas Vigentes',
    valor: estadisticas.value.programasVigentes,
    icono: 'mdi-school',
    color: 'info',
    ruta: '/programas',
    permiso: 'VER_PROGRAMAS'
  },
  {
    titulo: 'Pendientes de Pago',
    valor: estadisticas.value.pendientesPago,
    icono: 'mdi-currency-usd',
    color: 'warning',
    ruta: '/finanzas',
    permiso: 'VER_FINANZAS'
  }
].filter(tarjeta => hasPermission(tarjeta.permiso)))

// Accesos rápidos actualizados
const accesosRapidos = computed(() => [
  {
    titulo: 'Ver Programas en Ejecución',
    descripcion: 'Revisar cronogramas y programación actual',
    icono: 'mdi-clipboard-play',
    color: 'primary',
    ruta: '/ejecucion/cronogramas',
    permiso: 'VER_EJECUCION'
  },
  {
    titulo: 'Nueva Matrícula',
    descripcion: 'Registrar nueva matrícula',
    icono: 'mdi-school-plus',
    color: 'success',
    ruta: '/matriculas/nuevo',
    permiso: 'CREAR_MATRICULAS'
  },
  {
    titulo: 'Registrar Pago',
    descripcion: 'Procesar nuevo pago',
    icono: 'mdi-cash-register',
    color: 'info',
    ruta: '/finanzas/pagos/nuevo',
    permiso: 'REGISTRAR_PAGOS'
  },
  {
    titulo: 'Emitir Certificado',
    descripcion: 'Generar nuevo certificado',
    icono: 'mdi-certificate',
    color: 'warning',
    ruta: '/certificados/nuevo',
    permiso: 'EMITIR_CERTIFICADOS'
  }
]/*.filter(acceso => hasPermission(acceso.permiso))*/)

// Cargar datos del dashboard
const cargarDashboard = async () => {
  cargando.value = true
  try {
    const [statsResponse, actividadesResponse, notificacionesResponse] = await Promise.all([
      api.get('/dashboard/estadisticas'),
      api.get('/dashboard/actividades'),
      api.get('/dashboard/notificaciones')
    ])

    estadisticas.value = statsResponse.data
    actividades.value = actividadesResponse.data
    notificaciones.value = notificacionesResponse.data
  } catch (error) {
    console.error('Error al cargar dashboard:', error)
  } finally {
    cargando.value = false
  }
}

onMounted(() => {
  cargarDashboard()
})
</script>

<template>
  <div class="panel-principal">
    <!-- Header de bienvenida -->
    <div class="welcome-section bg-primary">
      <div class="welcome-content">
        <h1 class="welcome-title">
          ¡Bienvenido, {{ usuario?.username }}!
        </h1>
        <div class="welcome-meta">
          <v-chip
            v-for="rol in usuario?.roles"
            :key="rol"
            color="white"
            variant="outlined"
            size="small"
            class="me-2"
          >
            {{ rol }}
          </v-chip>
        </div>
      </div>
    </div>

    <!-- Estadísticas principales -->
    <div class="estadisticas-section">
      <h2 class="section-title">Resumen General</h2>

      <v-row>
        <v-col
          v-for="tarjeta in tarjetasEstadisticas"
          :key="tarjeta.titulo"
          cols="12"
          sm="6"
          md="3"
        >
          <v-card
            :color="tarjeta.color"
            variant="flat"
            class="estadistica-card text-white"
            :to="tarjeta.ruta"
            hover
          >
            <v-card-text class="d-flex align-center">
              <div class="flex-grow-1">
                <div class="text-h4 font-weight-bold mb-1">
                  {{ tarjeta.valor }}
                </div>
                <div class="text-subtitle-1">
                  {{ tarjeta.titulo }}
                </div>
              </div>
              <v-icon size="48" opacity="0.8">
                {{ tarjeta.icono }}
              </v-icon>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </div>

    <v-row>
      <!-- Accesos rápidos -->
      <v-col cols="12" md="8">
        <h2 class="section-title">Accesos Rápidos</h2>

        <v-row>
          <v-col
            v-for="acceso in accesosRapidos"
            :key="acceso.titulo"
            cols="12"
            sm="6"
          >
            <v-card
              class="acceso-card"
              :to="acceso.ruta"
              hover
            >
              <v-card-text class="d-flex align-center pa-4">
                <v-avatar
                  :color="acceso.color"
                  size="56"
                  class="me-4"
                >
                  <v-icon color="white" size="32">
                    {{ acceso.icono }}
                  </v-icon>
                </v-avatar>

                <div>
                  <div class="text-h6 font-weight-medium mb-1">
                    {{ acceso.titulo }}
                  </div>
                  <div class="text-body-2 text-medium-emphasis">
                    {{ acceso.descripcion }}
                  </div>
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-col>

      <!-- Notificaciones y actividades recientes -->
      <v-col cols="12" md="4">
        <h2 class="section-title">Actividad Reciente</h2>

        <!-- Notificaciones -->
        <v-card class="mb-4">
          <v-card-title class="d-flex align-center bg-warning text-white">
            <v-icon class="me-2">mdi-bell</v-icon>
            Notificaciones
          </v-card-title>

          <v-card-text class="pa-0">
            <v-list density="compact">
              <v-list-item
                v-for="notif in notificaciones.slice(0, 5)"
                :key="notif.id"
                class="px-4"
              >
                <v-list-item-title class="text-body-2">
                  {{ notif.mensaje }}
                </v-list-item-title>
                <v-list-item-subtitle>
                  {{ notif.fecha }}
                </v-list-item-subtitle>
              </v-list-item>

              <v-list-item v-if="notificaciones.length === 0">
                <v-list-item-title class="text-body-2 text-medium-emphasis">
                  No hay notificaciones pendientes
                </v-list-item-title>
              </v-list-item>
            </v-list>
          </v-card-text>
        </v-card>

        <!-- Actividades recientes -->
        <v-card>
          <v-card-title class="d-flex align-center bg-info text-white">
            <v-icon class="me-2">mdi-history</v-icon>
            Actividades Recientes
          </v-card-title>

          <v-card-text class="pa-0">
            <v-list density="compact">
              <v-list-item
                v-for="actividad in actividades.slice(0, 5)"
                :key="actividad.id"
                class="px-4"
              >
                <template #prepend>
                  <v-avatar size="32" :color="actividad.color">
                    <v-icon size="18" color="white">
                      {{ actividad.icono }}
                    </v-icon>
                  </v-avatar>
                </template>

                <v-list-item-title class="text-body-2">
                  {{ actividad.descripcion }}
                </v-list-item-title>
                <v-list-item-subtitle>
                  {{ actividad.fecha }}
                </v-list-item-subtitle>
              </v-list-item>

              <v-list-item v-if="actividades.length === 0">
                <v-list-item-title class="text-body-2 text-medium-emphasis">
                  No hay actividades recientes
                </v-list-item-title>
              </v-list-item>
            </v-list>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- Loading overlay -->
    <v-overlay
      :model-value="cargando"
      class="align-center justify-center"
    >
      <v-progress-circular
        color="primary"
        indeterminate
        size="64"
      ></v-progress-circular>
    </v-overlay>
  </div>
</template>

<style lang="scss" scoped>
.panel-principal {
  .welcome-section {
    color: white;
    padding: 2rem;
    border-radius: 12px;
    margin-bottom: 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;

    .welcome-title {
      font-size: 2rem;
      font-weight: 600;
      margin-bottom: 0.5rem;
    }

    .welcome-subtitle {
      font-size: 1.1rem;
      opacity: 0.9;
      margin-bottom: 1rem;
    }

    .welcome-meta {
      display: flex;
      gap: 0.5rem;
      flex-wrap: wrap;
    }
  }

  .section-title {
    color: rgb(var(--v-theme-primary));
    font-weight: 600;
    margin-bottom: 1.5rem;
    font-size: 1.5rem;
  }

  .estadistica-card {
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    cursor: pointer;

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 16px rgba(var(--v-theme-primary-rgb), 0.25) !important;
    }
  }

  .acceso-card {
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    cursor: pointer;
    border: 1px solid rgba(var(--v-theme-on-surface-rgb), 0.12);

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(var(--v-theme-primary-rgb), 0.15) !important;
      border-color: rgb(var(--v-theme-primary));
    }
  }
}

// Responsive
@media (max-width: 960px) {
  .panel-principal {
    .welcome-section {
      flex-direction: column;
      text-align: center;
      gap: 1rem;
    }
  }
}
</style>
