<script setup>
import { onMounted, ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '@/services/api'

const router = useRouter()
const programas = ref([])
const cargando = ref(false)
const busqueda = ref('')
const estadisticas = ref({})

// Estados de dialog unificado
const dialogFormulario = ref(false)
const programaSeleccionado = ref(null)
const esEdicion = computed(() => !!programaSeleccionado.value)

const headers = [
  { title: 'Programa', key: 'programa_nombre', sortable: true },
  { title: 'Modalidad', key: 'modalidad_nombre', sortable: true },
  { title: 'Área', key: 'area_nombre', sortable: true },
  { title: 'Gestión', key: 'gestion', sortable: true },
  { title: 'Estado', key: 'estado_programa_aprobado', sortable: true },
  { title: 'Vigencia', key: 'vigencia' },
  { title: 'Acciones', key: 'acciones', sortable: false }
]

// Computed para estadísticas
const tarjetasEstadisticas = computed(() => [
  {
    titulo: 'Total Programas',
    valor: estadisticas.value.total || 0,
    icono: 'mdi-school',
    color: 'primary',
    descripcion: 'Programas aprobados'
  },
  {
    titulo: 'Vigentes',
    valor: estadisticas.value.vigentes || 0,
    icono: 'mdi-check-circle',
    color: 'success',
    descripcion: 'Actualmente vigentes'
  },
  {
    titulo: 'Por Vencer',
    valor: estadisticas.value.porVencer || 0,
    icono: 'mdi-clock-alert',
    color: 'warning',
    descripcion: 'Próximos a vencer'
  },
  {
    titulo: 'Vencidos',
    valor: estadisticas.value.vencidos || 0,
    icono: 'mdi-close-circle',
    color: 'error',
    descripcion: 'Fuera de vigencia'
  }
])

// Computed para formatear vigencia
const programasConVigencia = computed(() => {
  return programas.value.map(programa => ({
    ...programa,
    vigencia: formatearVigencia(programa.fecha_inicio_vigencia, programa.fecha_fin_vigencia)
  }))
})

const formatearVigencia = (inicio, fin) => {
  if (!inicio && !fin) return 'Sin definir'
  if (!fin) return `Desde ${new Date(inicio).toLocaleDateString()}`
  if (!inicio) return `Hasta ${new Date(fin).toLocaleDateString()}`

  const fechaInicio = new Date(inicio).toLocaleDateString()
  const fechaFin = new Date(fin).toLocaleDateString()
  return `${fechaInicio} - ${fechaFin}`
}

const obtenerProgramas = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/programa-aprobado/vista/programas-aprobados')
    programas.value = response.data
    await obtenerEstadisticas()
  } catch (error) {
    console.error('Error al obtener programas:', error)
  } finally {
    cargando.value = false
  }
}

const obtenerEstadisticas = async () => {
  try {
    const response = await api.get('/api/programa-aprobado/estadisticas')
    estadisticas.value = response.data
  } catch (error) {
    console.error('Error al obtener estadísticas:', error)
  }
}

const obtenerColorEstado = (estado) => {
  const colores = {
    'ACTIVO': 'success',
    'VIGENTE': 'success',
    'INACTIVO': 'error',
    'VENCIDO': 'error',
    'SUSPENDIDO': 'warning',
    'PENDIENTE': 'info'
  }
  return colores[estado] || 'grey'
}

const abrirDialogRegistrar = () => {
  programaSeleccionado.value = null
  dialogFormulario.value = true
}

const abrirDialogEditar = (programa) => {
  programaSeleccionado.value = programa
  dialogFormulario.value = true
}

const cerrarDialog = () => {
  dialogFormulario.value = false
  programaSeleccionado.value = null
}

const verDetalle = (programa) => {
  router.push(`/programas/${programa.id_aca_programa_aprobado}`)
}

onMounted(() => {
  obtenerProgramas()
})
</script>

<template>
  <div class="pa-4">
    <!-- Cards de estadísticas -->
    <v-row class="mb-6">
      <v-col
        v-for="tarjeta in tarjetasEstadisticas"
        :key="tarjeta.titulo"
        cols="12"
        sm="6"
        md="3"
      >
        <v-card class="rounded-lg" height="120">
          <v-card-text class="d-flex align-center pa-4">
            <div class="flex-grow-1">
              <div class="text-h4 font-weight-bold mb-1" :class="`text-${tarjeta.color}`">
                {{ tarjeta.valor }}
              </div>
              <div class="text-subtitle-2 font-weight-medium mb-1">
                {{ tarjeta.titulo }}
              </div>
              <div class="text-caption text-medium-emphasis">
                {{ tarjeta.descripcion }}
              </div>
            </div>
            <v-avatar :color="tarjeta.color" size="48" class="ml-3">
              <v-icon :icon="tarjeta.icono" size="24" color="white"></v-icon>
            </v-avatar>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- Tabla de programas -->
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headers"
        :items="programasConVigencia"
        :loading="cargando"
        :search="busqueda"
        loading-text="Cargando programas..."
        no-data-text="No hay programas registrados"
        class="rounded-lg"
      >
        <template #top>
          <v-toolbar flat class="rounded-t-lg">
            <v-toolbar-title class="text-h6 font-weight-bold d-flex align-center">
              <v-icon class="mr-2" color="primary">mdi-school</v-icon>
              Gestión de Programas Aprobados
            </v-toolbar-title>

            <v-spacer></v-spacer>

            <div class="d-flex align-center ga-3">
              <v-text-field
                v-model="busqueda"
                append-inner-icon="mdi-magnify"
                label="Buscar programas..."
                single-line
                hide-details
                variant="outlined"
                density="compact"
                style="max-width: 300px;"
              ></v-text-field>

              <v-btn
                color="primary"
                variant="elevated"
                @click="abrirDialogRegistrar"
              >
                <v-icon start>mdi-plus</v-icon>
                Nuevo Programa
              </v-btn>
            </div>
          </v-toolbar>
        </template>

        <template #item.estado_programa_aprobado="{ item }">
          <v-chip
            :color="obtenerColorEstado(item.estado_programa_aprobado)"
            size="small"
            variant="flat"
          >
            {{ item.estado_programa_aprobado }}
          </v-chip>
        </template>

        <template #item.vigencia="{ item }">
          <span class="text-body-2">{{ item.vigencia }}</span>
        </template>

        <template #item.acciones="{ item }">
          <div class="d-flex ga-2">
            <v-btn
              icon="mdi-eye"
              size="small"
              color="info"
              variant="elevated"
              @click="verDetalle(item)"
            >
              <v-icon>mdi-eye</v-icon>
              <v-tooltip activator="parent" location="top">Ver detalle</v-tooltip>
            </v-btn>

            <v-btn
              icon="mdi-pencil"
              size="small"
              color="primary"
              variant="elevated"
              @click="abrirDialogEditar(item)"
            >
              <v-icon>mdi-pencil</v-icon>
              <v-tooltip activator="parent" location="top">Editar</v-tooltip>
            </v-btn>
          </div>
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog unificado para formulario -->
    <v-dialog
      v-model="dialogFormulario"
      max-width="800px"
      persistent
      class="ma-2"
    >
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary text-white d-flex align-center pa-4">
          <v-icon start>{{ esEdicion ? 'mdi-school-edit' : 'mdi-school-plus' }}</v-icon>
          {{ esEdicion ? 'Editar Programa Aprobado' : 'Nuevo Programa Aprobado' }}
        </v-card-title>

        <!-- Aquí iría el FormularioPrograma -->
        <v-card-text class="pa-6">
          <p class="text-center text-medium-emphasis">
            FormularioPrograma se implementará a continuación
          </p>
        </v-card-text>

        <v-card-actions class="pa-4">
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="cerrarDialog">Cancelar</v-btn>
          <v-btn color="primary" variant="elevated">Guardar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<style lang="scss" scoped>
// Responsive
@media (max-width: 960px) {
  .v-toolbar {
    .d-flex.align-center.ga-3 {
      flex-direction: column;
      align-items: stretch !important;
      gap: 12px !important;
    }

    .v-toolbar-title {
      text-align: center;
      margin-bottom: 8px;
    }
  }
}
</style>
