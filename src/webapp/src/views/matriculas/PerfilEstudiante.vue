<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()

// Estado reactivo
const loading = ref(false)

// DATOS ESTÁTICOS - Reemplazar por API calls
const estudiante = ref({
  cod_ins_matricula: 1001,
  cedula_identidad: '12345678',
  nombre_completo: 'Ana María González Pérez',
  nro_celular: '70123456',
  correo: 'ana.gonzalez@email.com',
  fecha_nacimiento: '1995-03-15',
  fecha_matricula: '2024-02-01',
  situacion_academica: 'REGULAR',
  porcentaje_avance: 85.5,
  deuda_total: 0,
  promedio_notas: 87.5,
  modulos_cursados: 6,
  modulos_aprobados: 6,
  obligaciones_pendientes: 0,
  total_pagado: 4800,
  programa_info: {
    nombre_programa: 'Técnico Superior en Administración Empresarial',
    modalidad: 'Presencial',
    grupo: 'ADMINISTRACIÓN EMPRESARIAL - GRUPO A 2024',
    gestion: 2024
  },
  modulos_detalle: [
    {
      id: 1,
      nombre_modulo: 'Matemática Aplicada',
      sigla: 'MAT-001',
      creditos: 4,
      carga_horaria: 80,
      estado: 'APROBADO',
      nota_final: 85,
      fecha_inicio: '2024-02-01',
      fecha_fin: '2024-03-15'
    },
    {
      id: 2,
      nombre_modulo: 'Contabilidad General',
      sigla: 'CON-001',
      creditos: 5,
      carga_horaria: 100,
      estado: 'APROBADO',
      nota_final: 92,
      fecha_inicio: '2024-03-20',
      fecha_fin: '2024-05-10'
    },
    {
      id: 3,
      nombre_modulo: 'Administración de Empresas I',
      sigla: 'ADM-001',
      creditos: 6,
      carga_horaria: 120,
      estado: 'APROBADO',
      nota_final: 88,
      fecha_inicio: '2024-05-15',
      fecha_fin: '2024-07-30'
    },
    {
      id: 4,
      nombre_modulo: 'Marketing Digital',
      sigla: 'MKT-001',
      creditos: 4,
      carga_horaria: 80,
      estado: 'EN_CURSO',
      nota_final: null,
      fecha_inicio: '2024-08-01',
      fecha_fin: null
    }
  ],
  historial_pagos: [
    {
      id: 1,
      fecha: '2024-02-01',
      concepto: 'Matrícula 2024',
      monto: 800,
      estado: 'PAGADO',
      comprobante: 'MAT-001-2024'
    },
    {
      id: 2,
      fecha: '2024-03-01',
      concepto: 'Colegiatura Marzo',
      monto: 600,
      estado: 'PAGADO',
      comprobante: 'COL-003-2024'
    },
    {
      id: 3,
      fecha: '2024-04-01',
      concepto: 'Colegiatura Abril',
      monto: 600,
      estado: 'PAGADO',
      comprobante: 'COL-004-2024'
    },
    {
      id: 4,
      fecha: '2024-05-01',
      concepto: 'Colegiatura Mayo',
      monto: 600,
      estado: 'PAGADO',
      comprobante: 'COL-005-2024'
    }
  ],
  timeline: [
    {
      id: 1,
      titulo: 'Módulo Marketing Digital Iniciado',
      descripcion: 'Se inscribió en el módulo MKT-001',
      fecha: '2024-08-01',
      icon: 'mdi-book-open',
      color: 'primary'
    },
    {
      id: 2,
      titulo: 'Pago Realizado',
      descripcion: 'Colegiatura Mayo - Bs. 600',
      fecha: '2024-05-01',
      icon: 'mdi-cash',
      color: 'success'
    },
    {
      id: 3,
      titulo: 'Módulo Aprobado',
      descripcion: 'Administración de Empresas I - Nota: 88',
      fecha: '2024-07-30',
      icon: 'mdi-check-circle',
      color: 'success'
    },
    {
      id: 4,
      titulo: 'Examen Final',
      descripcion: 'Contabilidad General - Nota: 92',
      fecha: '2024-05-10',
      icon: 'mdi-file-document',
      color: 'info'
    }
  ]
})

// Headers para tablas
const headersModulos = [
  { title: 'Módulo', key: 'nombre_modulo' },
  { title: 'Sigla', key: 'sigla' },
  { title: 'Créditos', key: 'creditos' },
  { title: 'Horas', key: 'carga_horaria' },
  { title: 'Estado', key: 'estado' },
  { title: 'Nota Final', key: 'nota_final' }
]

const headersPagos = [
  { title: 'Fecha', key: 'fecha' },
  { title: 'Concepto', key: 'concepto' },
  { title: 'Monto', key: 'monto' },
  { title: 'Estado', key: 'estado' },
  { title: 'Acciones', key: 'acciones', width: '80px' }
]

// Métodos
const getColorSituacion = (situacion) => {
  const colores = {
    'REGULAR': 'success',
    'MOROSO': 'warning',
    'SUSPENDIDO': 'error',
    'GRADUADO': 'info'
  }
  return colores[situacion] || 'grey'
}

const getColorProgreso = (porcentaje) => {
  if (porcentaje >= 80) return 'success'
  if (porcentaje >= 60) return 'warning'
  return 'error'
}

const getColorEstadoModulo = (estado) => {
  const colores = {
    'APROBADO': 'success',
    'EN_CURSO': 'primary',
    'REPROBADO': 'error',
    'ABANDONADO': 'grey'
  }
  return colores[estado] || 'grey'
}

const getColorNota = (nota) => {
  if (!nota) return 'grey'
  if (nota >= 80) return 'success'
  if (nota >= 70) return 'warning'
  return 'error'
}

const getColorEstadoPago = (estado) => {
  const colores = {
    'PAGADO': 'success',
    'PENDIENTE': 'warning',
    'VENCIDO': 'error'
  }
  return colores[estado] || 'grey'
}

const formatearFecha = (fecha) => {
  return new Date(fecha).toLocaleDateString('es-BO', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const contactar = () => {
  window.open(`tel:${estudiante.value.nro_celular}`)
}

const editarPerfil = () => {
  // Cambiar por ruta real
  router.push(`/estudiantes/${estudiante.value.cod_ins_matricula}/editar`)
}

const verComprobante = (pago) => {
  // Abrir comprobante en nueva ventana
  console.log('Ver comprobante:', pago.comprobante)
}

const registrarPago = () => {
  // Cambiar por ruta real
  router.push(`/estudiantes/${estudiante.value.cod_ins_matricula}/nuevo-pago`)
}

// Función para cargar datos (reemplazar por API call)
const cargarDatos = async () => {
  loading.value = true
  try {
    const matriculaId = route.params.id
    // TODO: Reemplazar por llamada a API
    // const response = await api.get(`/estudiantes/${matriculaId}`)
    // estudiante.value = response.data
    await new Promise(resolve => setTimeout(resolve, 1000)) // Simular carga
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
    <!-- Header del Estudiante -->
    <v-card class="mb-6 elevation-2">
      <v-card-text>
        <v-row align="center">
          <v-col cols="auto">
            <v-avatar size="80" color="primary">
              <span class="white--text text-h4 font-weight-bold">
                {{ estudiante.nombre_completo.split(' ').map(n => n[0]).join('').substring(0, 2) }}
              </span>
            </v-avatar>
          </v-col>
          <v-col>
            <h1 class="text-h4 font-weight-bold mb-1">{{ estudiante.nombre_completo }}</h1>
            <div class="text-h6 text-medium-emphasis mb-2">{{ estudiante.programa_info.nombre_programa }}</div>
            <div class="d-flex align-center ga-4 flex-wrap">
              <v-chip :color="getColorSituacion(estudiante.situacion_academica)" variant="flat">
                {{ estudiante.situacion_academica }}
              </v-chip>
              <span class="text-body-2">CI: {{ estudiante.cedula_identidad }}</span>
              <span class="text-body-2">Matrícula: {{ estudiante.cod_ins_matricula }}</span>
            </div>
          </v-col>
          <v-col cols="auto">
            <div class="d-flex flex-column ga-2">
              <v-btn color="primary" prepend-icon="mdi-phone" @click="contactar">
                Contactar
              </v-btn>
              <v-btn variant="outlined" prepend-icon="mdi-pencil" @click="editarPerfil">
                Editar
              </v-btn>
            </div>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>

    <v-row>
      <!-- Columna Principal -->
      <v-col cols="12" lg="8">
        <!-- Progreso Académico -->
        <v-card class="mb-6">
          <v-card-title class="d-flex align-center">
            <v-icon left color="primary">mdi-school</v-icon>
            Progreso Académico
          </v-card-title>
          <v-card-text>
            <v-row class="mb-4">
              <v-col cols="12" md="4">
                <div class="text-center">
                  <v-progress-circular
                    :model-value="estudiante.porcentaje_avance"
                    :color="getColorProgreso(estudiante.porcentaje_avance)"
                    size="80"
                    width="8"
                  >
                    {{ estudiante.porcentaje_avance }}%
                  </v-progress-circular>
                  <div class="text-subtitle-2 mt-2">Avance General</div>
                </div>
              </v-col>
              <v-col cols="12" md="8">
                <v-row>
                  <v-col cols="6">
                    <v-card variant="tonal" color="success">
                      <v-card-text class="text-center">
                        <div class="text-h5 font-weight-bold">{{ estudiante.modulos_aprobados }}</div>
                        <div class="text-caption">Módulos Aprobados</div>
                      </v-card-text>
                    </v-card>
                  </v-col>
                  <v-col cols="6">
                    <v-card variant="tonal" color="info">
                      <v-card-text class="text-center">
                        <div class="text-h5 font-weight-bold">{{ estudiante.promedio_notas }}</div>
                        <div class="text-caption">Promedio General</div>
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>
              </v-col>
            </v-row>

            <!-- Tabla de Módulos -->
            <v-data-table
              :headers="headersModulos"
              :items="estudiante.modulos_detalle"
              density="compact"
              :items-per-page="10"
            >
              <template v-slot:item.estado="{ item }">
                <v-chip :color="getColorEstadoModulo(item.estado)" variant="flat" size="small">
                  {{ item.estado }}
                </v-chip>
              </template>
              <template v-slot:item.nota_final="{ item }">
                <v-chip
                  :color="getColorNota(item.nota_final)"
                  variant="flat"
                  size="small"
                >
                  {{ item.nota_final || 'N/A' }}
                </v-chip>
              </template>
            </v-data-table>
          </v-card-text>
        </v-card>

        <!-- Historial de Pagos -->
        <v-card class="mb-6">
          <v-card-title class="d-flex align-center">
            <v-icon left color="warning">mdi-cash-multiple</v-icon>
            Historial de Pagos
          </v-card-title>
          <v-card-text>
            <v-data-table
              :headers="headersPagos"
              :items="estudiante.historial_pagos"
              density="compact"
              :items-per-page="8"
            >
              <template v-slot:item.monto="{ item }">
                <span class="font-weight-bold">Bs. {{ item.monto.toLocaleString() }}</span>
              </template>
              <template v-slot:item.estado="{ item }">
                <v-chip :color="getColorEstadoPago(item.estado)" variant="flat" size="small">
                  {{ item.estado }}
                </v-chip>
              </template>
              <template v-slot:item.acciones="{ item }">
                <v-btn icon="mdi-receipt" size="small" variant="text" @click="verComprobante(item)"></v-btn>
              </template>
            </v-data-table>
          </v-card-text>
        </v-card>

        <!-- Timeline de Actividades -->
        <v-card>
          <v-card-title class="d-flex align-center">
            <v-icon left color="info">mdi-timeline</v-icon>
            Actividades Recientes
          </v-card-title>
          <v-card-text>
            <v-timeline density="compact" side="end">
              <v-timeline-item
                v-for="actividad in estudiante.timeline"
                :key="actividad.id"
                :dot-color="actividad.color"
                size="small"
              >
                <template v-slot:icon>
                  <v-icon :icon="actividad.icon" size="16"></v-icon>
                </template>
                <div class="d-flex justify-space-between align-center">
                  <div>
                    <div class="font-weight-bold">{{ actividad.titulo }}</div>
                    <div class="text-caption text-medium-emphasis">{{ actividad.descripcion }}</div>
                  </div>
                  <div class="text-caption text-medium-emphasis">{{ actividad.fecha }}</div>
                </div>
              </v-timeline-item>
            </v-timeline>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- Sidebar -->
      <v-col cols="12" lg="4">
        <!-- Información Personal -->
        <v-card class="mb-6">
          <v-card-title class="d-flex align-center">
            <v-icon left color="primary">mdi-account-circle</v-icon>
            Información Personal
          </v-card-title>
          <v-card-text>
            <v-list density="compact">
              <v-list-item>
                <template v-slot:prepend>
                  <v-icon icon="mdi-card-account-details"></v-icon>
                </template>
                <v-list-item-title>Cédula de Identidad</v-list-item-title>
                <v-list-item-subtitle>{{ estudiante.cedula_identidad }}</v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <template v-slot:prepend>
                  <v-icon icon="mdi-phone"></v-icon>
                </template>
                <v-list-item-title>Celular</v-list-item-title>
                <v-list-item-subtitle>{{ estudiante.nro_celular }}</v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <template v-slot:prepend>
                  <v-icon icon="mdi-email"></v-icon>
                </template>
                <v-list-item-title>Correo Electrónico</v-list-item-title>
                <v-list-item-subtitle>{{ estudiante.correo || 'No registrado' }}</v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <template v-slot:prepend>
                  <v-icon icon="mdi-calendar"></v-icon>
                </template>
                <v-list-item-title>Fecha de Nacimiento</v-list-item-title>
                <v-list-item-subtitle>{{ formatearFecha(estudiante.fecha_nacimiento) }}</v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <template v-slot:prepend>
                  <v-icon icon="mdi-calendar-clock"></v-icon>
                </template>
                <v-list-item-title>Fecha de Matrícula</v-list-item-title>
                <v-list-item-subtitle>{{ formatearFecha(estudiante.fecha_matricula) }}</v-list-item-subtitle>
              </v-list-item>
            </v-list>
          </v-card-text>
        </v-card>

        <!-- Estado Financiero -->
        <v-card class="mb-6">
          <v-card-title class="d-flex align-center">
            <v-icon left color="success">mdi-currency-usd</v-icon>
            Estado Financiero
          </v-card-title>
          <v-card-text>
            <div class="text-center mb-4">
              <div class="text-h4 font-weight-bold" :class="estudiante.deuda_total > 0 ? 'text-error' : 'text-success'">
                Bs. {{ estudiante.deuda_total.toLocaleString() }}
              </div>
              <div class="text-subtitle-2">{{ estudiante.deuda_total > 0 ? 'Deuda Pendiente' : 'Al Día' }}</div>
            </div>

            <v-divider class="mb-4"></v-divider>

            <v-list density="compact">
              <v-list-item>
                <v-list-item-title>Obligaciones Pendientes</v-list-item-title>
                <template v-slot:append>
                  <v-chip color="warning" size="small">{{ estudiante.obligaciones_pendientes }}</v-chip>
                </template>
              </v-list-item>
              <v-list-item>
                <v-list-item-title>Total Pagado</v-list-item-title>
                <template v-slot:append>
                  <span class="font-weight-bold">Bs. {{ estudiante.total_pagado.toLocaleString() }}</span>
                </template>
              </v-list-item>
            </v-list>

            <v-btn
              block
              color="primary"
              variant="outlined"
              prepend-icon="mdi-plus"
              class="mt-4"
              @click="registrarPago"
            >
              Registrar Pago
            </v-btn>
          </v-card-text>
        </v-card>

        <!-- Información del Programa -->
        <v-card>
          <v-card-title class="d-flex align-center">
            <v-icon left color="info">mdi-school-outline</v-icon>
            Programa Académico
          </v-card-title>
          <v-card-text>
            <v-list density="compact">
              <v-list-item>
                <v-list-item-title>Programa</v-list-item-title>
                <v-list-item-subtitle>{{ estudiante.programa_info.nombre_programa }}</v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <v-list-item-title>Modalidad</v-list-item-title>
                <v-list-item-subtitle>{{ estudiante.programa_info.modalidad }}</v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <v-list-item-title>Grupo</v-list-item-title>
                <v-list-item-subtitle>{{ estudiante.programa_info.grupo }}</v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <v-list-item-title>Gestión</v-list-item-title>
                <v-list-item-subtitle>{{ estudiante.programa_info.gestion }}</v-list-item-subtitle>
              </v-list-item>
            </v-list>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
<style scoped>
.text-truncate {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
