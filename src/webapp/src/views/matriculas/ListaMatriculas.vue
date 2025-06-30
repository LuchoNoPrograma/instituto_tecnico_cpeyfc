<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { api } from "@/services/api.js"

const router = useRouter()
const route = useRoute()

const idGrupo = computed(() => parseInt(route.query.grupo))

const loading = ref(false)
const busqueda = ref('')
const filtroEstadoMatricula = ref(null)
const filtroEstadoFinanciero = ref(null)

const grupoInfo = ref({})
const matriculados = ref([])

// Opciones para filtros
const opcionesEstadoMatricula = [
  { title: 'En Ejecución', value: 'EN EJECUCION' },
  { title: 'Egresado', value: 'EGRESADO' },
  { title: 'Suspendido', value: 'SUSPENDIDO' }
]

const opcionesEstadoFinanciero = [
  { title: 'Al día', value: 'AL_DIA' },
  { title: 'Moroso', value: 'MOROSO' }
]

// Headers de la tabla
const headers = [
  { title: 'Estudiante', key: 'estudiante', sortable: true, width: '250px' },
  { title: 'Estado', key: 'estado_matricula', sortable: true },
  { title: 'Situación Financiera', key: 'estado_financiero', sortable: true },
  { title: 'Deuda', key: 'deuda_total', sortable: true },
  { title: 'Contacto', key: 'contacto', sortable: false },
  { title: 'Acciones', key: 'acciones', sortable: false, width: '120px' }
]

// Computed properties
const matriculadosFiltrados = computed(() => {
  let resultado = matriculados.value

  if (filtroEstadoMatricula.value) {
    resultado = resultado.filter(m => m.estado_matricula === filtroEstadoMatricula.value)
  }

  if (filtroEstadoFinanciero.value) {
    resultado = resultado.filter(m => m.estado_financiero === filtroEstadoFinanciero.value)
  }

  return resultado
})

const metricas = computed(() => {
  const total = matriculados.value.length
  const enEjecucion = matriculados.value.filter(m => m.estado_matricula === 'EN EJECUCION').length
  const egresados = matriculados.value.filter(m => m.estado_matricula === 'EGRESADO').length
  const suspendidos = matriculados.value.filter(m => m.estado_matricula === 'SUSPENDIDO').length
  const morosos = matriculados.value.filter(m => m.estado_financiero === 'MOROSO').length
  const totalDeuda = matriculados.value.reduce((sum, m) => sum + m.deuda_total, 0)

  return {
    total_estudiantes: total,
    estudiantes_en_ejecucion: enEjecucion,
    estudiantes_egresados: egresados,
    estudiantes_suspendidos: suspendidos,
    estudiantes_morosos: morosos,
    total_deuda: totalDeuda
  }
})

// Métodos de utilidad
const getIniciales = (nombre) => {
  return nombre.split(' ')
    .map(n => n[0])
    .join('')
    .substring(0, 2)
    .toUpperCase()
}

const getColorEstadoMatricula = (estado) => {
  const colores = {
    'EN EJECUCION': 'success',
    'EGRESADO': 'info',
    'SUSPENDIDO': 'error'
  }
  return colores[estado] || 'grey'
}

const getColorEstadoFinanciero = (estado) => {
  const colores = {
    'AL_DIA': 'success',
    'MOROSO': 'error'
  }
  return colores[estado] || 'grey'
}

const formatearMonto = (monto) => {
  return new Intl.NumberFormat('es-BO').format(monto)
}

const limpiarFiltros = () => {
  busqueda.value = ''
  filtroEstadoMatricula.value = null
  filtroEstadoFinanciero.value = null
}

// Acciones
const verPerfil = (estudiante) => {
  router.push(`/estudiantes/${estudiante.cod_ins_matricula}`)
}

const contactar = (estudiante) => {
  window.open(`tel:${estudiante.nro_celular}`)
}

const verPagos = (estudiante) => {
  router.push(`/estudiantes/${estudiante.cod_ins_matricula}/pagos`)
}

// Cargar datos
const cargarDatos = async () => {
  if (!idGrupo.value) {
    console.error('ID de grupo no encontrado en la URL')
    return
  }

  loading.value = true
  try {
    const [grupoRes, estudiantesRes] = await Promise.all([
      api.get('/api/grupos/vista/grupos-completos', { params: { idGrupo: idGrupo.value } }),
      api.get('/api/matricula/vista/estudiantes-grupo', { params: { idGrupo: idGrupo.value } })
    ])

    grupoInfo.value = grupoRes.data[0] || {}
    matriculados.value = estudiantesRes.data
  } catch (error) {
    console.error('Error cargando datos:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  cargarDatos()
})
</script>

<template>
  <v-container fluid class="pa-6">
    <!-- Header del Grupo -->
    <v-card class="mb-6 elevation-2">
      <v-card-title class="d-flex align-center">
        <v-icon left color="primary">mdi-account-group</v-icon>
        <div>
          <h2 class="text-h5 font-weight-bold">{{ grupoInfo.nombre_grupo }}</h2>
          <div class="text-subtitle-1 text-medium-emphasis">
            {{ grupoInfo.nombre_programa }} - {{ grupoInfo.nombre_modalidad }}
          </div>
        </div>
        <v-spacer></v-spacer>
        <v-chip color="primary" variant="elevated" size="large">
          Gestión {{ grupoInfo.gestion_inicio }}
        </v-chip>
      </v-card-title>

      <!-- Métricas del Grupo -->
      <v-card-text>
        <v-row>
          <v-col cols="12" sm="6" md="2">
            <v-card variant="tonal" color="primary">
              <v-card-text class="text-center pa-3">
                <div class="text-h4 font-weight-bold">{{ metricas.total_estudiantes }}</div>
                <div class="text-caption">Total</div>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6" md="2">
            <v-card variant="tonal" color="success">
              <v-card-text class="text-center pa-3">
                <div class="text-h4 font-weight-bold">{{ metricas.estudiantes_en_ejecucion }}</div>
                <div class="text-caption">En Ejecución</div>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6" md="2">
            <v-card variant="tonal" color="info">
              <v-card-text class="text-center pa-3">
                <div class="text-h4 font-weight-bold">{{ metricas.estudiantes_egresados }}</div>
                <div class="text-caption">Egresados</div>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6" md="2">
            <v-card variant="tonal" color="error">
              <v-card-text class="text-center pa-3">
                <div class="text-h4 font-weight-bold">{{ metricas.estudiantes_suspendidos }}</div>
                <div class="text-caption">Suspendidos</div>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6" md="2">
            <v-card variant="tonal" color="warning">
              <v-card-text class="text-center pa-3">
                <div class="text-h4 font-weight-bold">{{ metricas.estudiantes_morosos }}</div>
                <div class="text-caption">Morosos</div>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6" md="2">
            <v-card variant="tonal" color="secondary">
              <v-card-text class="text-center pa-3">
                <div class="text-h5 font-weight-bold">{{ formatearMonto(metricas.total_deuda) }}</div>
                <div class="text-caption">Deuda Total</div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>

    <!-- Filtros -->
    <v-card class="mb-4">
      <v-card-text>
        <v-row align="center">
          <v-col cols="12" md="4">
            <v-text-field
              v-model="busqueda"
              prepend-inner-icon="mdi-magnify"
              label="Buscar estudiante"
              clearable
              variant="outlined"
              density="compact"
            />
          </v-col>
          <v-col cols="12" md="2">
            <v-select
              v-model="filtroEstadoMatricula"
              :items="opcionesEstadoMatricula"
              label="Estado Matrícula"
              clearable
              variant="outlined"
              density="compact"
            />
          </v-col>
          <v-col cols="12" md="2">
            <v-select
              v-model="filtroEstadoFinanciero"
              :items="opcionesEstadoFinanciero"
              label="Estado Financiero"
              clearable
              variant="outlined"
              density="compact"
            />
          </v-col>
          <v-col cols="12" md="4">
            <v-btn
              @click="limpiarFiltros"
              variant="outlined"
              prepend-icon="mdi-filter-off"
            >
              Limpiar
            </v-btn>
            <v-btn
              color="success"
              variant="elevated"
              @click="router.push(`/matriculas/preinscrito?programa=${grupoInfo.id_aca_programa_aprobado}`)"
            >
              <v-icon start>mdi-account-plus</v-icon>
              Matricular
            </v-btn>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>

    <!-- Tabla de Matriculados -->
    <v-card>
      <v-data-table
        :headers="headers"
        :items="matriculadosFiltrados"
        :loading="loading"
        :search="busqueda"
        class="elevation-1"
        :items-per-page="15"
        item-value="cod_ins_matricula"
      >
        <!-- Estudiante -->
        <template v-slot:item.estudiante="{ item }">
          <div class="d-flex align-center py-2">
            <v-avatar size="40" color="primary" class="mr-3">
              <span class="white--text font-weight-bold">
                {{ getIniciales(item.nombre_completo) }}
              </span>
            </v-avatar>
            <div>
              <div class="font-weight-bold">{{ item.nombre_completo }}</div>
              <div class="text-caption text-medium-emphasis">CI: {{ item.ci }}</div>
            </div>
          </div>
        </template>

        <!-- Estado Matrícula -->
        <template v-slot:item.estado_matricula="{ item }">
          <v-chip
            :color="getColorEstadoMatricula(item.estado_matricula)"
            variant="flat"
            size="small"
          >
            {{ item.estado_matricula }}
          </v-chip>
        </template>

        <!-- Estado Financiero -->
        <template v-slot:item.estado_financiero="{ item }">
          <v-chip
            :color="getColorEstadoFinanciero(item.estado_financiero)"
            variant="flat"
            size="small"
          >
            {{ item.estado_financiero }}
          </v-chip>
        </template>

        <!-- Deuda -->
        <template v-slot:item.deuda_total="{ item }">
          <div class="text-right">
            <span :class="item.deuda_total > 0 ? 'text-error font-weight-bold' : 'text-success'">
              Bs. {{ formatearMonto(item.deuda_total) }}
            </span>
            <div v-if="item.obligaciones_pendientes > 0" class="text-caption text-error">
              {{ item.obligaciones_pendientes }} pendientes
            </div>
          </div>
        </template>

        <!-- Contacto -->
        <template v-slot:item.contacto="{ item }">
          <div class="text-caption">
            <div>{{ item.nro_celular }}</div>
            <div class="text-truncate contact-email">
              {{ item.correo || 'Sin correo' }}
            </div>
          </div>
        </template>

        <!-- Acciones -->
        <template v-slot:item.acciones="{ item }">
          <div class="d-flex ga-1">
            <v-tooltip text="Ver perfil completo">
              <template v-slot:activator="{ props }">
                <v-btn
                  v-bind="props"
                  @click="verPerfil(item)"
                  icon="mdi-account-details"
                  size="small"
                  variant="elevated"
                  color="primary"
                />
              </template>
            </v-tooltip>
            <v-tooltip text="Contactar">
              <template v-slot:activator="{ props }">
                <v-btn
                  v-bind="props"
                  @click="contactar(item)"
                  icon="mdi-phone"
                  size="small"
                  variant="elevated"
                  color="success"
                />
              </template>
            </v-tooltip>
            <v-tooltip text="Ver pagos">
              <template v-slot:activator="{ props }">
                <v-btn
                  v-bind="props"
                  @click="verPagos(item)"
                  icon="mdi-cash"
                  size="small"
                  variant="elevated"
                  color="warning"
                />
              </template>
            </v-tooltip>
          </div>
        </template>
      </v-data-table>
    </v-card>
  </v-container>
</template>

<style scoped>
.text-truncate {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.contact-email {
  max-width: 120px;
}
</style>
