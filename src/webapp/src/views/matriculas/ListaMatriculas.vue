<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { api } from "@/services/api.js"
import RegistrarPagoModal from './RegistrarPagoModal.vue'

const router = useRouter()
const route = useRoute()

const idGrupo = computed(() => parseInt(route.query.grupo))

const loading = ref(false)
const busqueda = ref('')
const filtroEstadoMatricula = ref(null)
const filtroEstadoFinanciero = ref(null)
const mostrarTodos = ref(false)

const grupoInfo = ref({})
const matriculados = ref([])

// Estado del modal de pago
const mostrarModalPago = ref(false)
const estudianteSeleccionado = ref(null)

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
  { title: 'Estudiante', key: 'estudiante', sortable: true, width: '280px' },
  { title: 'Estado', key: 'estado_matricula', sortable: true, width: '150px' },
  { title: 'Situación Financiera', key: 'estado_financiero', sortable: true, width: '180px' },
  { title: 'Deuda', key: 'deuda_total', sortable: true, width: '150px' },
  { title: 'Contacto', key: 'contacto', sortable: false, width: '180px' },
  { title: 'Acciones', key: 'acciones', sortable: false, width: '180px' }
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

const estudiantesRequierenAtencion = computed(() => {
  return matriculados.value
    .filter(m => m.estado_financiero === 'MOROSO' || m.estado_matricula === 'SUSPENDIDO')
    .sort((a, b) => b.deuda_total - a.deuda_total)
    .slice(0, mostrarTodos.value ? undefined : 5)
})

const metricas = computed(() => {
  const total = matriculados.value.length
  const enEjecucion = matriculados.value.filter(m => m.estado_matricula === 'EN EJECUCION').length
  const egresados = matriculados.value.filter(m => m.estado_matricula === 'EGRESADO').length
  const suspendidos = matriculados.value.filter(m => m.estado_matricula === 'SUSPENDIDO').length
  const morosos = matriculados.value.filter(m => m.estado_financiero === 'MOROSO').length
  const alDia = matriculados.value.filter(m => m.estado_financiero === 'AL_DIA').length
  const totalDeuda = matriculados.value.reduce((sum, m) => sum + m.deuda_total, 0)

  return {
    total_estudiantes: total,
    estudiantes_en_ejecucion: enEjecucion,
    estudiantes_egresados: egresados,
    estudiantes_suspendidos: suspendidos,
    estudiantes_morosos: morosos,
    estudiantes_al_dia: alDia,
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

const getIconEstadoMatricula = (estado) => {
  const iconos = {
    'EN EJECUCION': 'mdi-school',
    'EGRESADO': 'mdi-account-school',
    'SUSPENDIDO': 'mdi-account-cancel'
  }
  return iconos[estado] || 'mdi-help-circle'
}

const getColorEstadoFinanciero = (estado) => {
  const colores = {
    'AL_DIA': 'success',
    'MOROSO': 'error'
  }
  return colores[estado] || 'grey'
}

const formatearMonto = (monto) => {
  return new Intl.NumberFormat('es-BO', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(monto)
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

const contactarTelefono = (estudiante) => {
  window.open(`tel:${estudiante.nro_celular}`)
}

const contactarWhatsApp = (estudiante) => {
  const mensaje = `Hola ${estudiante.nombre_completo.split(' ')[0]}, soy del ${grupoInfo.value.nombre_programa}.`
  const url = `https://wa.me/591${estudiante.nro_celular}?text=${encodeURIComponent(mensaje)}`
  window.open(url, '_blank')
}

const enviarEmail = (estudiante) => {
  if (estudiante.correo) {
    window.location.href = `mailto:${estudiante.correo}?subject=Información ${grupoInfo.value.nombre_programa}`
  }
}

const registrarPago = (estudiante) => {
  estudianteSeleccionado.value = estudiante
  mostrarModalPago.value = true
}

const cerrarModalPago = () => {
  mostrarModalPago.value = false
  estudianteSeleccionado.value = null
}

const onPagoGuardado = () => {
  cerrarModalPago()
  // Recargar datos para reflejar los cambios
  cargarDatos()
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
  <v-container fluid class="pa-4 pa-md-6">
    <!-- Header del Grupo -->
    <div class="mb-8">
      <div class="d-flex align-center mb-2">
        <v-btn
          icon="mdi-arrow-left"
          variant="text"
          size="small"
          class="mr-2"
          @click="router.back()"
        />
        <div class="flex-grow-1">
          <h1 class="text-h4 font-weight-bold mb-1">{{ grupoInfo.nombre_grupo }}</h1>
          <p class="text-subtitle-1 text-medium-emphasis mb-0">
            {{ grupoInfo.nombre_programa }} • {{ grupoInfo.nombre_modalidad }}
          </p>
        </div>
        <v-chip color="primary" variant="flat" size="large" class="px-4">
          <v-icon start>mdi-calendar</v-icon>
          Gestión {{ grupoInfo.gestion_inicio }}
        </v-chip>
      </div>
    </div>

    <!-- Métricas Principales -->
    <v-row class="mb-6">
      <v-col cols="12" sm="6" md="4">
        <v-card class="metric-card" color="primary" variant="tonal">
          <v-card-text class="pa-5">
            <div class="d-flex align-center">
              <v-avatar size="56" color="primary" variant="flat" class="mr-4">
                <v-icon size="32">mdi-account-group</v-icon>
              </v-avatar>
              <div>
                <div class="text-h3 font-weight-bold">{{ metricas.total_estudiantes }}</div>
                <div class="text-body-2 text-medium-emphasis">Total Estudiantes</div>
              </div>
            </div>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" sm="6" md="4">
        <v-card class="metric-card" :color="metricas.estudiantes_morosos > 0 ? 'error' : 'success'" variant="tonal">
          <v-card-text class="pa-5">
            <div class="d-flex align-center">
              <v-avatar size="56" :color="metricas.estudiantes_morosos > 0 ? 'error' : 'success'" variant="flat" class="mr-4">
                <v-icon size="32">{{ metricas.estudiantes_morosos > 0 ? 'mdi-alert-circle' : 'mdi-check-circle' }}</v-icon>
              </v-avatar>
              <div>
                <div class="text-h3 font-weight-bold">{{ metricas.estudiantes_morosos }}</div>
                <div class="text-body-2 text-medium-emphasis">Requieren Atención</div>
              </div>
            </div>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" sm="6" md="4">
        <v-card class="metric-card" color="secondary" variant="tonal">
          <v-card-text class="pa-5">
            <div class="d-flex align-center">
              <v-avatar size="56" color="secondary" variant="flat" class="mr-4">
                <v-icon size="32">mdi-cash-multiple</v-icon>
              </v-avatar>
              <div>
                <div class="text-h4 font-weight-bold">Bs. {{ formatearMonto(metricas.total_deuda) }}</div>
                <div class="text-body-2 text-medium-emphasis">Por Cobrar</div>
              </div>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- Estadísticas Detalladas -->
    <v-row class="mb-6">
      <v-col cols="6" sm="3">
        <v-card variant="outlined" class="text-center pa-4">
          <v-icon size="32" color="success" class="mb-2">mdi-school</v-icon>
          <div class="text-h5 font-weight-bold">{{ metricas.estudiantes_en_ejecucion }}</div>
          <div class="text-caption text-medium-emphasis">En Ejecución</div>
        </v-card>
      </v-col>
      <v-col cols="6" sm="3">
        <v-card variant="outlined" class="text-center pa-4">
          <v-icon size="32" color="success" class="mb-2">mdi-check-circle</v-icon>
          <div class="text-h5 font-weight-bold">{{ metricas.estudiantes_al_dia }}</div>
          <div class="text-caption text-medium-emphasis">Al Día</div>
        </v-card>
      </v-col>
      <v-col cols="6" sm="3">
        <v-card variant="outlined" class="text-center pa-4">
          <v-icon size="32" color="info" class="mb-2">mdi-account-school</v-icon>
          <div class="text-h5 font-weight-bold">{{ metricas.estudiantes_egresados }}</div>
          <div class="text-caption text-medium-emphasis">Egresados</div>
        </v-card>
      </v-col>
      <v-col cols="6" sm="3">
        <v-card variant="outlined" class="text-center pa-4">
          <v-icon size="32" color="error" class="mb-2">mdi-account-cancel</v-icon>
          <div class="text-h5 font-weight-bold">{{ metricas.estudiantes_suspendidos }}</div>
          <div class="text-caption text-medium-emphasis">Suspendidos</div>
        </v-card>
      </v-col>
    </v-row>

    <!-- Sección: Requieren Atención -->
    <v-card v-if="estudiantesRequierenAtencion.length > 0" class="mb-6 elevation-3">
      <v-card-title class="d-flex align-center bg-error-lighten-5 pa-4">
        <v-icon color="error" size="28" class="mr-2">mdi-alert-circle</v-icon>
        <span class="text-h6 font-weight-bold">Estudiantes que Requieren Atención</span>
        <v-spacer />
        <v-chip color="error" variant="flat">
          {{ estudiantesRequierenAtencion.length }}
        </v-chip>
      </v-card-title>

      <v-divider />

      <v-card-text class="pa-0">
        <v-list lines="two">
          <template v-for="(estudiante, index) in estudiantesRequierenAtencion" :key="estudiante.cod_ins_matricula">
            <v-list-item class="px-6 py-4">
              <template v-slot:prepend>
                <v-avatar size="48" :color="estudiante.estado_financiero === 'MOROSO' ? 'error' : 'warning'" class="mr-4">
                  <span class="text-white font-weight-bold">{{ getIniciales(estudiante.nombre_completo) }}</span>
                </v-avatar>
              </template>

              <v-list-item-title class="font-weight-bold text-h6 mb-1">
                {{ estudiante.nombre_completo }}
              </v-list-item-title>

              <v-list-item-subtitle class="d-flex align-center gap-3 mt-1">
                <span class="text-medium-emphasis">
                  <v-icon size="16" class="mr-1">mdi-card-account-details</v-icon>
                  CI: {{ estudiante.ci }}
                </span>
                <span class="text-medium-emphasis">
                  <v-icon size="16" class="mr-1">mdi-phone</v-icon>
                  {{ estudiante.nro_celular }}
                </span>
                <v-chip
                  v-if="estudiante.estado_financiero === 'MOROSO'"
                  color="error"
                  variant="flat"
                  size="small"
                  class="ml-2"
                >
                  <v-icon start size="16">mdi-currency-usd-off</v-icon>
                  Moroso - Bs. {{ formatearMonto(estudiante.deuda_total) }}
                </v-chip>
                <v-chip
                  v-if="estudiante.estado_matricula === 'SUSPENDIDO'"
                  color="warning"
                  variant="flat"
                  size="small"
                  class="ml-2"
                >
                  <v-icon start size="16">mdi-account-cancel</v-icon>
                  Suspendido
                </v-chip>
              </v-list-item-subtitle>

              <template v-slot:append>
                <div class="d-flex gap-2">
                  <v-tooltip text="Llamar">
                    <template v-slot:activator="{ props }">
                      <v-btn
                        v-bind="props"
                        icon="mdi-phone"
                        size="small"
                        color="success"
                        variant="tonal"
                        @click="contactarTelefono(estudiante)"
                      />
                    </template>
                  </v-tooltip>

                  <v-tooltip text="WhatsApp">
                    <template v-slot:activator="{ props }">
                      <v-btn
                        v-bind="props"
                        icon="mdi-whatsapp"
                        size="small"
                        color="success"
                        variant="tonal"
                        @click="contactarWhatsApp(estudiante)"
                      />
                    </template>
                  </v-tooltip>

                  <v-tooltip text="Email" v-if="estudiante.correo">
                    <template v-slot:activator="{ props }">
                      <v-btn
                        v-bind="props"
                        icon="mdi-email"
                        size="small"
                        color="primary"
                        variant="tonal"
                        @click="enviarEmail(estudiante)"
                      />
                    </template>
                  </v-tooltip>

                  <v-tooltip text="Registrar Pago">
                    <template v-slot:activator="{ props }">
                      <v-btn
                        v-bind="props"
                        icon="mdi-cash-plus"
                        size="small"
                        color="warning"
                        variant="tonal"
                        @click="registrarPago(estudiante)"
                      />
                    </template>
                  </v-tooltip>
                </div>
              </template>
            </v-list-item>

            <v-divider v-if="index < estudiantesRequierenAtencion.length - 1" />
          </template>
        </v-list>

        <v-card-actions v-if="estudiantesRequierenAtencion.length > 5 && !mostrarTodos" class="justify-center pa-4">
          <v-btn
            variant="text"
            color="primary"
            @click="mostrarTodos = true"
          >
            Ver todos los estudiantes que requieren atención
            <v-icon end>mdi-chevron-down</v-icon>
          </v-btn>
        </v-card-actions>
      </v-card-text>
    </v-card>

    <!-- Filtros y Búsqueda -->
    <v-card class="mb-4" variant="outlined">
      <v-card-text class="pa-4">
        <v-row align="center">
          <v-col cols="12" md="5">
            <v-text-field
              v-model="busqueda"
              prepend-inner-icon="mdi-magnify"
              label="Buscar estudiante por nombre, CI o celular"
              clearable
              variant="outlined"
              density="comfortable"
              hide-details
            />
          </v-col>
          <v-col cols="12" sm="6" md="2">
            <v-select
              v-model="filtroEstadoMatricula"
              :items="opcionesEstadoMatricula"
              label="Estado"
              clearable
              variant="outlined"
              density="comfortable"
              hide-details
            />
          </v-col>
          <v-col cols="12" sm="6" md="2">
            <v-select
              v-model="filtroEstadoFinanciero"
              :items="opcionesEstadoFinanciero"
              label="Situación"
              clearable
              variant="outlined"
              density="comfortable"
              hide-details
            />
          </v-col>
          <v-col cols="12" md="3" class="d-flex gap-2">
            <v-btn
              @click="limpiarFiltros"
              variant="outlined"
              prepend-icon="mdi-filter-off"
              block
            >
              Limpiar
            </v-btn>
            <v-btn
              color="primary"
              variant="flat"
              prepend-icon="mdi-account-plus"
              block
              @click="router.push(`/matriculas/preinscrito?programa=${grupoInfo.id_aca_programa_aprobado}`)"
            >
              Nueva Matrícula
            </v-btn>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>

    <!-- Tabla Completa de Estudiantes -->
    <v-card>
      <v-card-title class="d-flex align-center pa-4 bg-grey-lighten-5">
        <v-icon class="mr-2">mdi-account-group</v-icon>
        <span class="text-h6">Todos los Estudiantes</span>
        <v-spacer />
        <v-chip variant="flat" color="primary">
          {{ matriculadosFiltrados.length }} estudiantes
        </v-chip>
      </v-card-title>

      <v-divider />

      <v-data-table
        :headers="headers"
        :items="matriculadosFiltrados"
        :loading="loading"
        :search="busqueda"
        :items-per-page="15"
        item-value="cod_ins_matricula"
        class="custom-table"
      >
        <!-- Estudiante -->
        <template v-slot:item.estudiante="{ item }">
          <div class="d-flex align-center py-3">
            <v-avatar size="44" color="primary" class="mr-3">
              <span class="text-white font-weight-bold text-subtitle-1">
                {{ getIniciales(item.nombre_completo) }}
              </span>
            </v-avatar>
            <div>
              <div class="font-weight-medium text-body-1">{{ item.nombre_completo }}</div>
              <div class="text-caption text-medium-emphasis">
                <v-icon size="14" class="mr-1">mdi-card-account-details</v-icon>
                CI: {{ item.ci }}
              </div>
            </div>
          </div>
        </template>

        <!-- Estado Matrícula -->
        <template v-slot:item.estado_matricula="{ item }">
          <v-chip
            :color="getColorEstadoMatricula(item.estado_matricula)"
            :prepend-icon="getIconEstadoMatricula(item.estado_matricula)"
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
            <v-icon start size="16">
              {{ item.estado_financiero === 'AL_DIA' ? 'mdi-check-circle' : 'mdi-alert-circle' }}
            </v-icon>
            {{ item.estado_financiero === 'AL_DIA' ? 'Al día' : 'Moroso' }}
          </v-chip>
        </template>

        <!-- Deuda -->
        <template v-slot:item.deuda_total="{ item }">
          <div>
            <div :class="item.deuda_total > 0 ? 'text-error font-weight-bold' : 'text-success font-weight-medium'">
              Bs. {{ formatearMonto(item.deuda_total) }}
            </div>
            <div v-if="item.obligaciones_pendientes > 0" class="text-caption text-error">
              <v-icon size="12">mdi-alert</v-icon>
              {{ item.obligaciones_pendientes }} pendiente{{ item.obligaciones_pendientes > 1 ? 's' : '' }}
            </div>
          </div>
        </template>

        <!-- Contacto -->
        <template v-slot:item.contacto="{ item }">
          <div class="text-caption">
            <div class="mb-1">
              <v-icon size="14" class="mr-1">mdi-phone</v-icon>
              {{ item.nro_celular }}
            </div>
            <div class="text-truncate contact-email" v-if="item.correo">
              <v-icon size="14" class="mr-1">mdi-email</v-icon>
              {{ item.correo }}
            </div>
          </div>
        </template>

        <!-- Acciones -->
        <template v-slot:item.acciones="{ item }">
          <div class="d-flex gap-1">
            <v-tooltip text="Llamar">
              <template v-slot:activator="{ props }">
                <v-btn
                  v-bind="props"
                  @click="contactarTelefono(item)"
                  icon="mdi-phone"
                  size="small"
                  variant="tonal"
                  color="success"
                />
              </template>
            </v-tooltip>

            <v-tooltip text="WhatsApp">
              <template v-slot:activator="{ props }">
                <v-btn
                  v-bind="props"
                  @click="contactarWhatsApp(item)"
                  icon="mdi-whatsapp"
                  size="small"
                  variant="tonal"
                  color="success"
                />
              </template>
            </v-tooltip>

            <v-tooltip text="Email" v-if="item.correo">
              <template v-slot:activator="{ props }">
                <v-btn
                  v-bind="props"
                  @click="enviarEmail(item)"
                  icon="mdi-email"
                  size="small"
                  variant="tonal"
                  color="primary"
                />
              </template>
            </v-tooltip>
          </div>
        </template>
      </v-data-table>
    </v-card>

    <!-- Modal de Registro de Pago -->
    <v-dialog v-model="mostrarModalPago" max-width="700px" persistent>
      <RegistrarPagoModal
        v-if="estudianteSeleccionado"
        :estudiante="estudianteSeleccionado"
        @cerrar="cerrarModalPago"
        @guardado="onPagoGuardado"
      />
    </v-dialog>
  </v-container>
</template>

<style scoped>
.metric-card {
  transition: transform 0.2s, box-shadow 0.2s;
}

.metric-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1) !important;
}

.text-truncate {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.contact-email {
  max-width: 150px;
}

.custom-table :deep(.v-data-table__td) {
  padding: 12px 16px !important;
}

.custom-table :deep(.v-data-table__th) {
  font-weight: 600 !important;
  background-color: rgb(var(--v-theme-grey-lighten-5)) !important;
}

.bg-error-lighten-5 {
  background-color: rgb(var(--v-theme-error), 0.05);
}

.bg-grey-lighten-5 {
  background-color: rgb(var(--v-theme-grey-lighten-5));
}
</style>
