<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '@/services/api'
import { showRegistrado, showError, showModificado } from '@/utils/sweetalert'

const route = useRoute()
const router = useRouter()

// Estados reactivos
const cronogramaId = ref(route.params.id)
const estudiantes = ref([])
const criterios = ref([])
const calificaciones = ref([])
const cargando = ref(true)
const guardando = ref(false)
const infoCronograma = ref({})

// Estados de notas locales
const notasLocales = ref({})

// Cargar datos iniciales
const cargarDatos = async () => {
  cargando.value = true
  try {
    const [criteriosRes, calificacionesRes] = await Promise.all([
      api.get(`/api/cronograma/${cronogramaId.value}/criterios`),
      api.get(`/api/cronograma/${cronogramaId.value}/calificaciones`)
    ])

    criterios.value = criteriosRes.data
    calificaciones.value = calificacionesRes.data

    // 👉 Construimos la lista única de estudiantes:
    const mapaEstudiantes = {}
    calificaciones.value.forEach(item => {
      const idProg = item.id_eje_programacion
      if (!mapaEstudiantes[idProg]) {
        mapaEstudiantes[idProg] = {
          id_eje_programacion: idProg,
          nombre_estudiante: item.nombre_estudiante,
          ci: item.ci,
          cod_ins_matricula: item.cod_ins_matricula,
          nombre_grupo: item.nombre_grupo,
          estado_programacion: item.estado_programacion
        }
      }
    })
    estudiantes.value = Object.values(mapaEstudiantes)

    // Módulo para el header
    if (criterios.value.length > 0) {
      infoCronograma.value = {
        modulo: criterios.value[0].nombre_modulo
      }
    }
  } catch (error) {
    showError('Error al cargar datos del cronograma')
    console.error('Error:', error)
  } finally {
    cargando.value = false
  }
}

// Obtener nota de un estudiante para un criterio
const obtenerNota = (idProgramacion, idCriterio) => {
  const key = `${idProgramacion}-${idCriterio}`
  if (notasLocales.value[key] !== undefined) {
    return notasLocales.value[key]
  }
  const calificacion = calificaciones.value.find(cal =>
    cal.id_eje_programacion === idProgramacion &&
    cal.id_eje_criterio_eval === idCriterio
  )
  return calificacion?.nota || 0
}

// Actualizar nota localmente
const actualizarNota = (idProgramacion, idCriterio, valor) => {
  const key = `${idProgramacion}-${idCriterio}`
  const nota = parseFloat(valor) || 0
  notasLocales.value[key] = Math.max(0, Math.min(100, nota))
}

// Guardar nota
const guardarNota = async (idProgramacion, idCriterio) => {
  const key = `${idProgramacion}-${idCriterio}`
  const nota = notasLocales.value[key] || obtenerNota(idProgramacion, idCriterio)

  if (nota < 0 || nota > 100) {
    showError('La nota debe estar entre 0 y 100')
    return
  }

  try {
    await api.post('/api/calificacion/registrar', {
      id_eje_programacion: idProgramacion,
      id_eje_criterio_eval: idCriterio,
      nota: nota
    })

    // Actualizar calificaciones localmente
    const existente = calificaciones.value.findIndex(cal =>
      cal.id_eje_programacion === idProgramacion &&
      cal.id_eje_criterio_eval === idCriterio
    )

    const criterio = criterios.value.find(c => c.id_eje_criterio_eval === idCriterio)
    const notaPonderada = (nota * criterio.ponderacion) / 100

    if (existente >= 0) {
      calificaciones.value[existente].nota = nota
      calificaciones.value[existente].nota_ponderada = notaPonderada
    } else {
      calificaciones.value.push({
        id_eje_programacion: idProgramacion,
        id_eje_criterio_eval: idCriterio,
        nota: nota,
        nota_ponderada: notaPonderada
      })
    }

    showModificado('Nota registrada exitosamente')
  } catch (error) {
    showError('Error al guardar la nota')
  }
}

// Obtener nota final de un estudiante
const obtenerNotaFinal = (idProgramacion) => {
  return calificaciones.value
    .filter(cal => cal.id_eje_programacion === idProgramacion)
    .reduce((sum, cal) => sum + (cal.nota_ponderada || 0), 0)
}

// Obtener color de celda según nota
const obtenerColorNota = (nota) => {
  if (nota === 0) return 'red-lighten-4'
  if (nota < 60) return 'orange-lighten-4'
  if (nota >= 70) return 'green-lighten-4'
  return 'yellow-lighten-4'
}

// Obtener color de nota final
const obtenerColorNotaFinal = (notaFinal) => {
  if (notaFinal >= 70) return 'green-lighten-3'
  if (notaFinal > 0) return 'red-lighten-3'
  return 'grey-lighten-3'
}

// Volver al dashboard
const volverDashboard = () => {
  router.push('/dashboard')
}

// Ponderación total
const ponderacionTotal = computed(() => {
  return criterios.value.reduce((sum, c) => sum + (c.ponderacion || 0), 0)
})

const ponderacionValida = computed(() => ponderacionTotal.value === 100)

onMounted(() => {
  cargarDatos()
})
</script>

<template>
  <div class="administrar-notas">
    <!-- Header -->
    <v-card class="mb-4" elevation="2">
      <v-card-title class="d-flex align-center bg-primary text-white">
        <v-btn
          icon="mdi-arrow-left"
          variant="text"
          @click="volverDashboard"
          class="me-3"
        ></v-btn>
        <div>
          <div class="text-h6">Administrar Notas</div>
          <div class="text-subtitle-2">{{ infoCronograma.modulo }}</div>
        </div>
        <v-spacer></v-spacer>
      </v-card-title>

      <v-card-text>
        <v-alert
          type="info"
          variant="tonal"
          density="compact"
        >
          Las notas deben estar entre 0 y 100. Los cambios se guardan automáticamente.
        </v-alert>

        <!-- Alerta si ponderación no es 100% -->
        <v-alert
          v-if="!ponderacionValida && criterios.length > 0"
          type="warning"
          variant="tonal"
          class="mt-3"
        >
          <v-icon start icon="mdi-alert"></v-icon>
          La ponderación total de los criterios no suma 100%.
          Contacta al administrador para corregir los criterios de evaluación.
        </v-alert>
      </v-card-text>
    </v-card>

    <!-- Tabla de notas -->
    <v-card elevation="2">
      <v-card-text class="pa-0">
        <div class="table-container">
          <v-table class="notas-table" fixed-header height="600px">
            <thead>
            <tr>
              <th class="text-center bg-grey-lighten-4" style="position: sticky; left: 0; z-index: 10; width: 50px;">

              </th>
              <th class="text-left bg-grey-lighten-4" style="position: sticky; left: 50px; z-index: 10; min-width: 300px;">
                Estudiante
              </th>
              <th
                v-for="criterio in criterios"
                :key="criterio.id_eje_criterio_eval"
                class="text-center bg-blue-lighten-4"
                style="min-width: 120px;"
              >
                <div class="criterio-header">
                  <div class="font-weight-bold">{{ criterio.nombre_crit }}</div>
                  <div class="text-caption">({{ criterio.ponderacion }}%)</div>
                </div>
              </th>
              <th class="text-center bg-green-lighten-4" style="min-width: 100px;">
                Nota Final
              </th>
              <th class="text-center bg-grey-lighten-4" style="min-width: 120px;">
                Estado
              </th>
            </tr>
            </thead>
            <tbody>
            <tr v-for="(estudiante, index) in estudiantes" :key="estudiante.id_eje_programacion">
              <!-- Numeración -->
              <td class="text-center" style="position: sticky; left: 0; background: white; z-index: 5;">
                {{ index + 1 }}
              </td>

              <!-- Nombre -->
              <td class="text-left" style="position: sticky; left: 50px; background: white; z-index: 5;">
                {{ estudiante.nombre_estudiante }}
              </td>

              <!-- Notas por criterio -->
              <td
                v-for="criterio in criterios"
                :key="criterio.id_eje_criterio_eval"
                :class="obtenerColorNota(obtenerNota(estudiante.id_eje_programacion, criterio.id_eje_criterio_eval))"
                class="text-center nota-cell pa-1"
              >
                <v-text-field
                  :model-value="obtenerNota(estudiante.id_eje_programacion, criterio.id_eje_criterio_eval)"
                  @update:model-value="(value) => actualizarNota(estudiante.id_eje_programacion, criterio.id_eje_criterio_eval, value)"
                  @blur="guardarNota(estudiante.id_eje_programacion, criterio.id_eje_criterio_eval)"
                  type="text"
                  density="compact"
                  variant="outlined"
                  hide-details
                  class="nota-input"
                ></v-text-field>
              </td>

              <!-- Nota Final -->
              <td
                :class="obtenerColorNotaFinal(obtenerNotaFinal(estudiante.id_eje_programacion))"
                class="text-center font-weight-bold"
              >
                {{ Math.round(obtenerNotaFinal(estudiante.id_eje_programacion)) }}
              </td>

              <!-- Estado -->
              <td class="text-center">
                <v-chip
                  size="small"
                  :color="estudiante.estado_programacion === 'ACTIVO' ? 'success' : 'warning'"
                >
                  {{ estudiante.estado_programacion }}
                </v-chip>
              </td>
            </tr>
            </tbody>
          </v-table>
        </div>
      </v-card-text>
    </v-card>

    <!-- Loading overlay -->
    <v-overlay
      :model-value="cargando || guardando"
      class="align-center justify-center"
    >
      <div class="text-center">
        <v-progress-circular
          color="primary"
          indeterminate
          size="64"
        ></v-progress-circular>
        <div class="mt-3 text-h6">
          {{ cargando ? 'Cargando...' : 'Guardando...' }}
        </div>
      </div>
    </v-overlay>
  </div>
</template>

<style lang="scss" scoped>
.administrar-notas {
  padding: 1rem;

  .table-container {
    overflow-x: auto;
    max-width: 100%;
  }

  .notas-table {
    .criterio-header {
      text-align: center;
      line-height: 1.2;
    }

    .nota-cell {
      padding: 4px !important;
      min-width: 80px;
    }

    .nota-input {
      width: 100%;

      :deep(.v-field__input) {
        text-align: center;
        padding: 0;
      }

      :deep(.v-field) {
        border-radius: 0;
        box-shadow: none;
      }

      :deep(.v-field__outline) {
        --v-field-border-opacity: 0.2;
      }
    }

    th {
      font-weight: 600 !important;
      border-bottom: 2px solid #ddd !important;
    }

    td {
      border-bottom: 1px solid #eee !important;
      padding: 8px !important;
    }
  }
}
</style>
