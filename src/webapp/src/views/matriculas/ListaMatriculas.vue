<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {api} from "@/services/api.js";

const router = useRouter()

const loading = ref(false)
const busqueda = ref('')
const filtroSituacion = ref(null)
const filtroEstadoFinanciero = ref(null)

// DATOS ESTÁTICOS - TODO: Reemplazar por API
const grupoInfo = ref({
  id_ins_grupo: 1,
  nombre_grupo: 'ADMINISTRACIÓN EMPRESARIAL - GRUPO A 2024',
  nombre_programa: 'Técnico Superior en Administración Empresarial',
  modalidad: 'Presencial',
  gestion_inicio: 2024,
  fecha_inicio_inscripcion: '2024-01-15',
  fecha_fin_inscripcion: '2024-02-15'
})

const matriculados = ref([
  {
    cod_ins_matricula: 1001,
    cedula_identidad: '12345678',
    nombre_completo: 'Ana María González Pérez',
    nro_celular: '70123456',
    correo: 'ana.gonzalez@email.com',
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-01',
    modulos_cursados: 6,
    modulos_aprobados: 6,
    modulos_en_curso: 1,
    promedio_notas: 87.5,
    porcentaje_avance: 85.5,
    deuda_total: 0,
    obligaciones_pendientes: 0,
    estado_financiero: 'AL_DIA',
    situacion_academica: 'REGULAR'
  },
  {
    cod_ins_matricula: 1002,
    cedula_identidad: '87654321',
    nombre_completo: 'Carlos Eduardo Mamani Quispe',
    nro_celular: '71234567',
    correo: 'carlos.mamani@email.com',
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-03',
    modulos_cursados: 5,
    modulos_aprobados: 4,
    modulos_en_curso: 1,
    promedio_notas: 72.3,
    porcentaje_avance: 65.2,
    deuda_total: 850,
    obligaciones_pendientes: 2,
    estado_financiero: 'CON_DEUDA',
    situacion_academica: 'MOROSO'
  },
  {
    cod_ins_matricula: 1003,
    cedula_identidad: '45678912',
    nombre_completo: 'María Elena Vargas Silva',
    nro_celular: '72345678',
    correo: null,
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-01-28',
    modulos_cursados: 7,
    modulos_aprobados: 7,
    modulos_en_curso: 1,
    promedio_notas: 91.2,
    porcentaje_avance: 92.8,
    deuda_total: 0,
    obligaciones_pendientes: 0,
    estado_financiero: 'AL_DIA',
    situacion_academica: 'REGULAR'
  },
  {
    cod_ins_matricula: 1004,
    cedula_identidad: '78912345',
    nombre_completo: 'José Antonio Rodríguez López',
    nro_celular: '73456789',
    correo: 'jose.rodriguez@email.com',
    estado_matricula: 'SUSPENDIDO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-05',
    modulos_cursados: 4,
    modulos_aprobados: 2,
    modulos_en_curso: 0,
    promedio_notas: 55.8,
    porcentaje_avance: 45.1,
    deuda_total: 1520,
    obligaciones_pendientes: 3,
    estado_financiero: 'CON_DEUDA',
    situacion_academica: 'SUSPENDIDO'
  },
  {
    cod_ins_matricula: 1005,
    cedula_identidad: '65432198',
    nombre_completo: 'Rosa Patricia Mendoza Torres',
    nro_celular: '74567890',
    correo: 'rosa.mendoza@email.com',
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-02',
    modulos_cursados: 6,
    modulos_aprobados: 5,
    modulos_en_curso: 1,
    promedio_notas: 83.7,
    porcentaje_avance: 78.3,
    deuda_total: 0,
    obligaciones_pendientes: 0,
    estado_financiero: 'AL_DIA',
    situacion_academica: 'REGULAR'
  },
  {
    cod_ins_matricula: 1006,
    cedula_identidad: '32165498',
    nombre_completo: 'Miguel Ángel Castillo Herrera',
    nro_celular: '75678901',
    correo: 'miguel.castillo@email.com',
    estado_matricula: 'GRADUADO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-01-30',
    modulos_cursados: 8,
    modulos_aprobados: 8,
    modulos_en_curso: 0,
    promedio_notas: 89.4,
    porcentaje_avance: 100,
    deuda_total: 0,
    obligaciones_pendientes: 0,
    estado_financiero: 'AL_DIA',
    situacion_academica: 'GRADUADO'
  },
  {
    cod_ins_matricula: 1007,
    cedula_identidad: '15975348',
    nombre_completo: 'Lucía Fernanda Paz Morales',
    nro_celular: '76789012',
    correo: 'lucia.paz@email.com',
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-04',
    modulos_cursados: 5,
    modulos_aprobados: 5,
    modulos_en_curso: 1,
    promedio_notas: 79.8,
    porcentaje_avance: 71.4,
    deuda_total: 600,
    obligaciones_pendientes: 1,
    estado_financiero: 'CON_DEUDA',
    situacion_academica: 'MOROSO'
  },
  {
    cod_ins_matricula: 1008,
    cedula_identidad: '95135748',
    nombre_completo: 'Roberto Carlos Huanca Choque',
    nro_celular: '77890123',
    correo: 'roberto.huanca@email.com',
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-06',
    modulos_cursados: 6,
    modulos_aprobados: 6,
    modulos_en_curso: 1,
    promedio_notas: 85.2,
    porcentaje_avance: 82.1,
    deuda_total: 0,
    obligaciones_pendientes: 0,
    estado_financiero: 'AL_DIA',
    situacion_academica: 'REGULAR'
  },
  {
    cod_ins_matricula: 1009,
    cedula_identidad: '35791468',
    nombre_completo: 'Sandra Elizabeth Ramos Vera',
    nro_celular: '78901234',
    correo: null,
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-01-31',
    modulos_cursados: 4,
    modulos_aprobados: 3,
    modulos_en_curso: 1,
    promedio_notas: 68.5,
    porcentaje_avance: 57.2,
    deuda_total: 1200,
    obligaciones_pendientes: 2,
    estado_financiero: 'CON_DEUDA',
    situacion_academica: 'MOROSO'
  },
  {
    cod_ins_matricula: 1010,
    cedula_identidad: '74185296',
    nombre_completo: 'Fernando Daniel Soto Villarroel',
    nro_celular: '79012345',
    correo: 'fernando.soto@email.com',
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-07',
    modulos_cursados: 6,
    modulos_aprobados: 6,
    modulos_en_curso: 1,
    promedio_notas: 88.3,
    porcentaje_avance: 85.7,
    deuda_total: 0,
    obligaciones_pendientes: 0,
    estado_financiero: 'AL_DIA',
    situacion_academica: 'REGULAR'
  },
  {
    cod_ins_matricula: 1011,
    cedula_identidad: '85296374',
    nombre_completo: 'Carmen Rosa Delgado Pinto',
    nro_celular: '70112233',
    correo: 'carmen.delgado@email.com',
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-01',
    modulos_cursados: 5,
    modulos_aprobados: 4,
    modulos_en_curso: 1,
    promedio_notas: 76.9,
    porcentaje_avance: 69.8,
    deuda_total: 0,
    obligaciones_pendientes: 0,
    estado_financiero: 'AL_DIA',
    situacion_academica: 'REGULAR'
  },
  {
    cod_ins_matricula: 1012,
    cedula_identidad: '96374185',
    nombre_completo: 'Alexander Javier Moreno Gutiérrez',
    nro_celular: '71223344',
    correo: 'alexander.moreno@email.com',
    estado_matricula: 'INACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-08',
    modulos_cursados: 3,
    modulos_aprobados: 1,
    modulos_en_curso: 0,
    promedio_notas: 48.2,
    porcentaje_avance: 28.6,
    deuda_total: 2400,
    obligaciones_pendientes: 4,
    estado_financiero: 'CON_DEUDA',
    situacion_academica: 'INACTIVO'
  },
  {
    cod_ins_matricula: 1013,
    cedula_identidad: '14725836',
    nombre_completo: 'Diana Patricia Flores Condori',
    nro_celular: '72334455',
    correo: 'diana.flores@email.com',
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-01-29',
    modulos_cursados: 7,
    modulos_aprobados: 7,
    modulos_en_curso: 1,
    promedio_notas: 92.1,
    porcentaje_avance: 95.2,
    deuda_total: 0,
    obligaciones_pendientes: 0,
    estado_financiero: 'AL_DIA',
    situacion_academica: 'REGULAR'
  },
  {
    cod_ins_matricula: 1014,
    cedula_identidad: '25836947',
    nombre_completo: 'Raúl Eduardo Limachi Apaza',
    nro_celular: '73445566',
    correo: null,
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-03',
    modulos_cursados: 4,
    modulos_aprobados: 3,
    modulos_en_curso: 1,
    promedio_notas: 65.7,
    porcentaje_avance: 52.4,
    deuda_total: 900,
    obligaciones_pendientes: 2,
    estado_financiero: 'CON_DEUDA',
    situacion_academica: 'MOROSO'
  },
  {
    cod_ins_matricula: 1015,
    cedula_identidad: '36947258',
    nombre_completo: 'Silvia Beatriz Arce Mamani',
    nro_celular: '74556677',
    correo: 'silvia.arce@email.com',
    estado_matricula: 'ACTIVO',
    tipo_matricula: 'REGULAR',
    fecha_matricula: '2024-02-09',
    modulos_cursados: 6,
    modulos_aprobados: 5,
    modulos_en_curso: 1,
    promedio_notas: 81.4,
    porcentaje_avance: 76.9,
    deuda_total: 0,
    obligaciones_pendientes: 0,
    estado_financiero: 'AL_DIA',
    situacion_academica: 'REGULAR'
  }
])

// Opciones para filtros
const opcionesSituacion = [
  { title: 'Regular', value: 'REGULAR' },
  { title: 'Moroso', value: 'MOROSO' },
  { title: 'Suspendido', value: 'SUSPENDIDO' },
  { title: 'Graduado', value: 'GRADUADO' },
  { title: 'Inactivo', value: 'INACTIVO' }
]

const opcionesEstadoFinanciero = [
  { title: 'Al día', value: 'AL_DIA' },
  { title: 'Con deuda', value: 'CON_DEUDA' }
]

// Headers de la tabla
const headers = [
  { title: 'Estudiante', key: 'estudiante', sortable: true, width: '250px' },
  { title: 'Situación', key: 'situacion_academica', sortable: true },
  { title: 'Progreso', key: 'porcentaje_avance', sortable: true },
  { title: 'Promedio', key: 'promedio_notas', sortable: true },
  { title: 'Módulos', key: 'modulos_info', sortable: false },
  { title: 'Deuda', key: 'deuda_total', sortable: true },
  { title: 'Contacto', key: 'contacto', sortable: false },
  { title: 'Acciones', key: 'acciones', sortable: false, width: '120px' }
]

// Computed properties
const matriculadosFiltrados = computed(() => {
  let resultado = matriculados.value

  if (filtroSituacion.value) {
    resultado = resultado.filter(m => m.situacion_academica === filtroSituacion.value)
  }

  if (filtroEstadoFinanciero.value) {
    resultado = resultado.filter(m => m.estado_financiero === filtroEstadoFinanciero.value)
  }

  return resultado
})

const metricas = computed(() => {
  const total = matriculados.value.length
  const regulares = matriculados.value.filter(m => m.situacion_academica === 'REGULAR').length
  const morosos = matriculados.value.filter(m => m.situacion_academica === 'MOROSO').length
  const suspendidos = matriculados.value.filter(m => m.situacion_academica === 'SUSPENDIDO').length
  const graduados = matriculados.value.filter(m => m.situacion_academica === 'GRADUADO').length

  const promedioAvance = matriculados.value.length > 0
    ? Math.round(matriculados.value.reduce((sum, m) => sum + m.porcentaje_avance, 0) / matriculados.value.length)
    : 0

  const promedioNotas = matriculados.value.length > 0
    ? Math.round(matriculados.value.reduce((sum, m) => sum + m.promedio_notas, 0) / matriculados.value.length * 10) / 10
    : 0

  const totalDeuda = matriculados.value.reduce((sum, m) => sum + m.deuda_total, 0)

  return {
    total_estudiantes: total,
    estudiantes_regulares: regulares,
    estudiantes_morosos: morosos,
    estudiantes_suspendidos: suspendidos,
    estudiantes_graduados: graduados,
    promedio_avance: promedioAvance,
    promedio_notas: promedioNotas,
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

const getColorSituacion = (situacion) => {
  const colores = {
    'REGULAR': 'success',
    'MOROSO': 'warning',
    'SUSPENDIDO': 'error',
    'GRADUADO': 'info',
    'INACTIVO': 'grey'
  }
  return colores[situacion] || 'grey'
}

const getColorProgreso = (porcentaje) => {
  if (porcentaje >= 80) return 'success'
  if (porcentaje >= 60) return 'warning'
  return 'error'
}

const getColorPromedio = (promedio) => {
  if (promedio >= 80) return 'success'
  if (promedio >= 70) return 'warning'
  return 'error'
}

const formatearMonto = (monto) => {
  return new Intl.NumberFormat('es-BO').format(monto)
}

const limpiarFiltros = () => {
  busqueda.value = ''
  filtroSituacion.value = null
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

// Cargar datos - TODO: Implementar API
const cargarDatos = async () => {
  loading.value = true
  try {
    // const response = await api.get(`/grupos/${props.grupoId}/matriculados`)
    // matriculados.value = response.data.matriculados
    // grupoInfo.value = response.data.grupo_info

    const [grupoInfo] = await Promise.all([
      api.get('/')
    ])

    await new Promise(resolve => setTimeout(resolve, 1000))
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
            {{ grupoInfo.nombre_programa }} - {{ grupoInfo.modalidad }}
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
                <div class="text-h4 font-weight-bold">{{ metricas.estudiantes_regulares }}</div>
                <div class="text-caption">Regulares</div>
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
            <v-card variant="tonal" color="info">
              <v-card-text class="text-center pa-3">
                <div class="text-h4 font-weight-bold">{{ metricas.promedio_avance }}%</div>
                <div class="text-caption">Avance</div>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6" md="2">
            <v-card variant="tonal" color="secondary">
              <v-card-text class="text-center pa-3">
                <div class="text-h4 font-weight-bold">{{ metricas.promedio_notas }}</div>
                <div class="text-caption">Promedio</div>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6" md="2">
            <v-card variant="tonal" color="error">
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
              v-model="filtroSituacion"
              :items="opcionesSituacion"
              label="Situación Académica"
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
              @click="router.push('/matriculas/preinscrito')"
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
              <div class="text-caption text-medium-emphasis">CI: {{ item.cedula_identidad }}</div>
            </div>
          </div>
        </template>

        <!-- Situación académica -->
        <template v-slot:item.situacion_academica="{ item }">
          <v-chip
            :color="getColorSituacion(item.situacion_academica)"
            variant="flat"
            size="small"
          >
            {{ item.situacion_academica }}
          </v-chip>
        </template>

        <!-- Progreso -->
        <template v-slot:item.porcentaje_avance="{ item }">
          <div class="d-flex align-center">
            <v-progress-linear
              :model-value="item.porcentaje_avance"
              :color="getColorProgreso(item.porcentaje_avance)"
              height="6"
              rounded
              class="mr-2"
              style="min-width: 80px"
            />
            <span class="text-caption">{{ item.porcentaje_avance }}%</span>
          </div>
        </template>

        <!-- Promedio -->
        <template v-slot:item.promedio_notas="{ item }">
          <v-chip
            :color="getColorPromedio(item.promedio_notas)"
            variant="flat"
            size="small"
          >
            {{ item.promedio_notas }}
          </v-chip>
        </template>

        <!-- Módulos -->
        <template v-slot:item.modulos_info="{ item }">
          <div class="text-caption">
            <div>Aprobados: {{ item.modulos_aprobados }}</div>
            <div>Cursados: {{ item.modulos_cursados }}</div>
            <div>En curso: {{ item.modulos_en_curso }}</div>
          </div>
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
                  variant="text"
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
                  variant="text"
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
                  variant="text"
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
