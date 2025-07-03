<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useAuth } from '@/composables/useAuth'
import { api } from '@/services/api'
import { useRouter } from 'vue-router'
import { showRegistrado, showError, showConfirmar } from '@/utils/sweetalert'
import jsPDF from "jspdf";
import autoTable from 'jspdf-autotable'

const { getCurrentUser } = useAuth()
const router = useRouter()
const usuario = computed(() => getCurrentUser())

// Estados reactivos
const cronogramasDocente = ref([])
const cargando = ref(true)
const dialogCriterios = ref(false)
const cronogramaSeleccionado = ref(null)
const criterios = ref([])
const estudiantesPreview = ref([])
const cargandoCriterios = ref(false)

// Criterios predefinidos comunes
const criteriosPredefinidos = [
  { nombre_crit: 'PRIMER PARCIAL', ponderacion: 30 },
  { nombre_crit: 'SEGUNDO PARCIAL', ponderacion: 30 },
  { nombre_crit: 'TERCER PARCIAL', ponderacion: 40 }
]

// Validaciones
const ponderacionTotal = computed(() => {
  return criterios.value.reduce((sum, c) => sum + (c.ponderacion || 0), 0)
})

const esValido = computed(() => {
  return criterios.value.length > 0 &&
    ponderacionTotal.value === 100 &&
    criterios.value.every(c => c.nombre_crit && c.ponderacion > 0)
})

const estudiantesParaPreview = computed(() => {
  if (estudiantesPreview.value.length > 0) {
    return estudiantesPreview.value
  }

  // Estudiantes por defecto
  return Array.from({ length: 5 }, (_, i) => ({
    cod_ins_matricula: i + 1,
    nombre: `Estudiante ${i + 1}`,
    ap_paterno: 'Paterno',
    ap_materno: 'Materno'
  }))
})

const coloresEstado = {
  'EN_EJECUCION': 'success',
  'PROGRAMADO': 'info',
  'FINALIZADO': 'warning',
  'SIN_CRITERIOS': 'error',
  'PENDIENTE_INICIO': 'grey'
}

// Iconos para estados
const iconosEstado = {
  'EN_EJECUCION': 'mdi-play-circle',
  'PROGRAMADO': 'mdi-calendar-clock',
  'FINALIZADO': 'mdi-check-circle',
  'SIN_CRITERIOS': 'mdi-alert-circle',
  'PENDIENTE_INICIO': 'mdi-pause-circle'
}

// Formatear fecha
const formatearFecha = (fecha) => {
  if (!fecha) return 'No definida'
  return new Date(fecha).toLocaleDateString('es-BO')
}

// Cargar cronogramas del docente
const cargarCronogramasDocente = async () => {
  try {
    const response = await api.get(`/api/docente/cronogramas/${usuario.value.userId}`)
    cronogramasDocente.value = response.data
  } catch (error) {
    console.error('Error al cargar cronogramas:', error)
  }
}

// Cargar dashboard
const cargarDashboard = async () => {
  cargando.value = true
  try {
    await cargarCronogramasDocente()
  } catch (error) {
    console.error('Error al cargar dashboard:', error)
  } finally {
    cargando.value = false
  }
}

const imprimirActa = async cronograma => {
  try {
    const { data: acta } = await api.get(`/api/acta-regular/${cronograma.id_eje_cronograma_modulo}`)
    if (!acta.length) return showError('Sin datos para el acta')
    const meta = acta[0]
    const doc = new jsPDF()

    // Encabezado
    doc.setFontSize(14)
    doc.text('ESCUELA TÉCNICA CPEYFC UAP', doc.internal.pageSize.getWidth()/2, 15, { align: 'center' })
    doc.setFontSize(12)
    doc.text('ACTA DE CALIFICACIONES', doc.internal.pageSize.getWidth()/2, 22, { align: 'center' })

    // Metadata con bordes y encabezado coloreado
    autoTable(doc, {
      startY: 28,
      theme: 'grid',
      body: [
        ['PROGRAMA', meta.programa, 'MODALIDAD', meta.modalidad],
        ['PLAN / VERSIÓN', `${meta.plan} / ${meta.version}`, 'GESTIÓN', meta.gestion_programa],
        ['GRUPO', meta.grupo, 'GESTIÓN GRUPO', meta.gestion_grupo],
        ['DOCENTE', meta.docente, '', '']
      ],
      styles: { fontSize: 10, cellPadding: 2 },
      columnStyles: { 0: { cellWidth: 40 }, 1: { cellWidth: 60 }, 2: { cellWidth: 40 }, 3: { cellWidth: 60 } },
      didParseCell: function(data) {
        // Color header-like cells in metadata (first and third columns) background and white text
        if (data.section === 'body' && (data.column.index === 0 || data.column.index === 2)) {
          data.cell.styles.fillColor = [47,66,140];
          data.cell.styles.textColor = 255;
        }
      }
    })



    // Detalle de alumnos
    autoTable(doc, {
      startY: doc.lastAutoTable.finalY + 10,
      head: [['N°', 'CI', 'APELLIDOS Y NOMBRES', 'NOTA FINAL', 'ESTADO']],
      body: acta.map((row, i) => [
        i+1,
        row.ci,
        row.nombre_completo,
        row.nota_final,
        row.estado_nota
      ]),
      theme: 'grid',
      styles: { fontSize: 9, cellPadding: 2 },
      headStyles: { fillColor: [47,66,140] }
    })

    doc.save(`Acta_${meta.sigla || cronograma.sigla}.pdf`)
  } catch (e) {
    console.error(e)
    showError('Error al generar PDF')
  }
}


// Ir a definir criterios
const definirCriterios = (cronograma) => {
  cronogramaSeleccionado.value = cronograma
  dialogCriterios.value = true
}

// Agregar criterio
const agregarCriterio = () => {
  criterios.value.push({
    nombre_crit: '',
    descripcion: '',
    ponderacion: 0,
    orden: criterios.value.length + 1
  })
}

// Eliminar criterio
const eliminarCriterio = (index) => {
  criterios.value.splice(index, 1)
  criterios.value.forEach((c, i) => c.orden = i + 1)
}

// Aplicar predefinidos
const aplicarPredefinidos = () => {
  criterios.value = criteriosPredefinidos.map((c, index) => ({
    nombre_crit: c.nombre_crit,
    descripcion: '',
    ponderacion: c.ponderacion,
    orden: index + 1
  }))
}

// Cargar estudiantes para preview
const cargarEstudiantesPreview = async () => {
  try {
    const response = await api.get(`/api/cronograma/${cronogramaSeleccionado.value.id_eje_cronograma_modulo}/estudiantes`)
    estudiantesPreview.value = response.data
  } catch (error) {
    console.error('Error al cargar estudiantes:', error)
  }
}

// Guardar criterios
const guardarCriterios = async () => {
  if (!esValido.value) return

  const resultado = await showConfirmar({
    mensaje: '¿Confirmas la creación de estos criterios de evaluación?',
    titulo: 'Confirmar Criterios',
    tipo: 'save'
  })

  if (!resultado.isConfirmed) return

  cargandoCriterios.value = true
  try {
    // Obtener ID del docente desde el cronograma
    const idDocente = cronogramaSeleccionado.value.id_eje_docente

    // Crear criterios uno por uno
    for (const criterio of criterios.value) {
      await api.post('/api/criterio-evaluacion', {
        id_cronograma: cronogramaSeleccionado.value.id_eje_cronograma_modulo,
        nombre_crit: criterio.nombre_crit,
        descripcion: criterio.descripcion,
        ponderacion: criterio.ponderacion,
        orden: criterio.orden
      })
    }

    showRegistrado('Criterios de evaluación creados exitosamente')
    cargarCronogramasDocente()
    dialogCriterios.value = false
  } catch (error) {
    showError('Error al guardar criterios')
  } finally {
    cargandoCriterios.value = false
  }
}

// Limpiar al abrir dialog
watch(dialogCriterios, (newVal) => {
  if (newVal) {
    criterios.value = []
    cargarEstudiantesPreview()
  }
})

// Manejar actualización de criterios
const onCriteriosActualizados = () => {
  cargarCronogramasDocente()
}

// Ir a administrar notas
const administrarNotas = (cronograma) => {
  router.push(`/docente/notas/${cronograma.id_eje_cronograma_modulo}`)
}

onMounted(() => {
  cargarDashboard()
})
</script>

<template>
  <div class="panel-docente">
    <!-- Cronogramas asignados -->
    <div class="cronogramas-section">
      <h2 class="section-title">Mis Cronogramas</h2>

      <v-row v-if="cronogramasDocente.length > 0">
        <v-col
          v-for="cronograma in cronogramasDocente"
          :key="cronograma.id_eje_cronograma_modulo"
          cols="12"
          md="6"
          lg="4"
        >
          <v-card class="cronograma-card" elevation="2">
            <!-- Header del cronograma -->
            <v-card-title class="d-flex align-center pa-4">
              <v-icon
                :color="coloresEstado[cronograma.estado_cronograma]"
                size="24"
                class="me-2"
              >
                {{ iconosEstado[cronograma.estado_cronograma] }}
              </v-icon>
              <div class="flex-grow-1">
                <div class="text-h6 font-weight-medium">
                  {{ cronograma.sigla }} - {{ cronograma.nombre_modulo }}
                </div>
                <div class="text-body-2 text-medium-emphasis">
                  {{ cronograma.nombre_grupo }}
                </div>
              </div>
            </v-card-title>

            <!-- Información del cronograma -->
            <v-card-text class="pt-0">
              <v-chip
                :color="coloresEstado[cronograma.estado_cronograma]"
                variant="flat"
                size="small"
                class="mb-3"
              >
                {{ cronograma.estado_cronograma.replace('_', ' ') }}
              </v-chip>

              <div class="cronograma-info mb-3">
                <div class="info-row">
                  <v-icon size="16" class="me-2">mdi-school</v-icon>
                  <span class="text-body-2">
                    {{ cronograma.nombre_programa }}
                  </span>
                </div>

                <div class="info-row">
                  <v-icon size="16" class="me-2">mdi-bookmark</v-icon>
                  <span class="text-body-2">
                    Plan {{ cronograma.anho_plan }} - {{ cronograma.cod_version }} ({{ cronograma.nombre_modalidad }})
                  </span>
                </div>

                <div class="info-row">
                  <v-icon size="16" class="me-2">mdi-calendar</v-icon>
                  <span class="text-body-2">
                    {{ formatearFecha(cronograma.fecha_inicio) }} - {{ formatearFecha(cronograma.fecha_fin) }}
                  </span>
                </div>

                <div class="info-row">
                  <v-icon size="16" class="me-2">mdi-account-group</v-icon>
                  <span class="text-body-2">
                    {{ cronograma.total_estudiantes }} estudiantes | {{ cronograma.total_criterios }} criterios
                  </span>
                </div>
              </div>
            </v-card-text>

            <!-- Acciones -->
            <v-card-actions class="pa-4 pt-0">
              <div class="d-flex gap-2 flex-wrap">
                <v-btn
                  color="primary"
                  variant="outlined"
                  size="small"
                  @click="definirCriterios(cronograma)"
                  prepend-icon="mdi-format-list-bulleted-square"
                  class="me-2"
                >
                  Adm. Criterios
                </v-btn>
                <v-btn
                  color="success"
                  variant="flat"
                  size="small"
                  @click="administrarNotas(cronograma)"
                  prepend-icon="mdi-clipboard-edit"
                  :disabled="cronograma.total_criterios === 0"
                >
                  Adm. Notas
                </v-btn>
                <v-btn
                  color="primary"
                  variant="elevated"
                  size="small"
                  @click="imprimirActa(cronograma)"
                >
                  <v-icon start icon="mdi-printer"></v-icon>
                  Cerrar e Imprimir Acta
                </v-btn>
              </div>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>

      <!-- Sin cronogramas -->
      <v-card v-else class="text-center pa-8">
        <v-icon size="64" color="grey" class="mb-4">
          mdi-calendar-remove
        </v-icon>
        <div class="text-h6 mb-2">
          No tienes cronogramas asignados
        </div>
        <div class="text-body-1 text-medium-emphasis">
          Contacta al administrador para que te asigne cronogramas de módulos.
        </div>
      </v-card>
    </div>

    <!-- Dialog criterios -->
    <v-dialog v-model="dialogCriterios" max-width="1200px" persistent>
      <v-card>
        <v-card-title class="d-flex align-center bg-primary text-white">
          <v-icon class="me-3">mdi-format-list-bulleted-square</v-icon>
          <div>
            <div class="text-h6">Planificar Criterios de Evaluación</div>
            <div class="text-subtitle-2">
              {{ cronogramaSeleccionado?.sigla }} - {{ cronogramaSeleccionado?.nombre_modulo }}
            </div>
          </div>
          <v-spacer></v-spacer>
          <v-btn
            icon="mdi-close"
            variant="text"
            @click="dialogCriterios = false"
          ></v-btn>
        </v-card-title>

        <v-card-text class="pa-6">
          <v-row>
            <!-- Configuración de criterios -->
            <v-col cols="12" md="5">
              <div class="d-flex align-center mb-4">
                <h3 class="text-h6 me-4">Criterios de Evaluación</h3>
                <v-btn
                  color="info"
                  size="small"
                  variant="outlined"
                  @click="aplicarPredefinidos"
                  prepend-icon="mdi-auto-fix"
                >
                  Aplicar Predefinidos
                </v-btn>
              </div>

              <v-card variant="outlined" class="mb-4">
                <v-card-text>
                  <div class="d-flex align-center justify-space-between mb-2">
                    <span class="font-weight-medium">Ponderación Total:</span>
                    <v-chip
                      :color="ponderacionTotal === 100 ? 'success' : 'error'"
                      variant="flat"
                    >
                      {{ ponderacionTotal }}%
                    </v-chip>
                  </div>
                  <v-progress-linear
                    :model-value="ponderacionTotal"
                    :color="ponderacionTotal === 100 ? 'success' : 'error'"
                    height="8"
                    rounded
                  ></v-progress-linear>
                </v-card-text>
              </v-card>

              <div v-for="(criterio, index) in criterios" :key="index" class="mb-3">
                <v-card variant="outlined">
                  <v-card-text class="pb-2">
                    <div class="d-flex align-center mb-2">
                      <v-chip size="small" color="primary" class="me-2">
                        {{ index + 1 }}
                      </v-chip>
                      <v-spacer></v-spacer>
                      <v-btn
                        icon="mdi-delete"
                        size="small"
                        color="error"
                        variant="text"
                        @click="eliminarCriterio(index)"
                      ></v-btn>
                    </div>

                    <v-text-field
                      v-model="criterio.nombre_crit"
                      label="Nombre del criterio"
                      variant="outlined"
                      density="compact"
                      class="mb-2"
                    ></v-text-field>

                    <v-row>
                      <v-col cols="8">
                        <v-text-field
                          v-model="criterio.descripcion"
                          label="Descripción (opcional)"
                          variant="outlined"
                          density="compact"
                        ></v-text-field>
                      </v-col>
                      <v-col cols="4">
                        <v-text-field
                          v-model.number="criterio.ponderacion"
                          label="Ponderación %"
                          variant="outlined"
                          density="compact"
                          type="number"
                          min="1"
                          max="100"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                  </v-card-text>
                </v-card>
              </div>

              <v-btn
                @click="agregarCriterio"
                color="primary"
                variant="outlined"
                prepend-icon="mdi-plus"
                block
              >
                Agregar Criterio
              </v-btn>
            </v-col>

            <!-- Preview de acta -->
            <v-col cols="12" md="7">
              <div class="d-flex align-center mb-4">
                <h3 class="text-h6">Previsualizar Detalle de Calificaciones</h3>
                <v-spacer></v-spacer>
              </div>

              <v-card v-if="criterios.length > 0" variant="outlined">
                <v-card-title class="text-center bg-grey-lighten-4">
                  Detalle de Calificaciones - {{ cronogramaSeleccionado?.nombre_grupo }}
                </v-card-title>

                <v-card-text class="pa-2">
                  <div class="acta-preview">
                    <table class="acta-table">
                      <thead>
                      <tr>
                        <th rowspan="2">N°</th>
                        <th rowspan="2">Estudiante</th>
                        <th
                          v-for="criterio in criterios"
                          :key="criterio.nombre_crit"
                          :title="criterio.descripcion"
                        >
                          {{ criterio.nombre_crit }}
                          <br>
                          <small>({{ criterio.ponderacion }}%)</small>
                        </th>
                        <th rowspan="2">Promedio</th>
                      </tr>
                      </thead>
                      <tbody>
                      <tr
                        v-for="(estudiante, index) in estudiantesParaPreview.slice(0, 5)"
                        :key="estudiante.cod_ins_matricula"
                      >
                        <td>{{ index + 1 }}</td>
                        <td class="text-left">
                          {{ estudiante.ap_paterno }} {{ estudiante.ap_materno }}, {{ estudiante.nombre }}
                        </td>
                        <td
                          v-for="criterio in criterios"
                          :key="criterio.nombre_crit"
                          class="nota-cell"
                        >
                          -
                        </td>
                        <td class="promedio-cell">-</td>
                      </tr>
                      <tr v-if="estudiantesParaPreview.length > 5 > 5">
                        <td colspan="100%" class="text-center text-grey">
                          ... y {{ estudiantesParaPreview.length - 5 }} estudiantes más
                        </td>
                      </tr>
                      </tbody>
                    </table>
                  </div>
                </v-card-text>
              </v-card>

              <v-alert
                v-else-if="criterios.length === 0"
                type="info"
                color="primary"
                variant="tonal"
              >
                Agrega criterios para previsualizar el detalle de calificaciones
              </v-alert>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="pa-6 pt-0">
          <v-spacer></v-spacer>
          <v-btn
            @click="dialogCriterios = false"
            variant="outlined"
          >
            Cancelar
          </v-btn>
          <v-btn
            @click="guardarCriterios"
            color="primary"
            variant="elevated"
            :disabled="!esValido"
            :loading="cargandoCriterios"
          >
            <v-icon start icon="mdi-content-save"></v-icon>
            Guardar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

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
.panel-docente {
  .section-title {
    color: rgb(var(--v-theme-primary));
    font-weight: 600;
    margin-bottom: 1.5rem;
    font-size: 1.5rem;
  }

  .estadistica-card {
    transition: transform 0.2s ease, box-shadow 0.2s ease;

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 16px rgba(var(--v-theme-primary-rgb), 0.25) !important;
    }
  }

  .cronograma-card {
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    height: 100%;

    &:hover {
      transform: translateY(-2px);
    }

    .cronograma-info {
      .info-row {
        display: flex;
        align-items: center;
        margin-bottom: 0.5rem;

        &:last-child {
          margin-bottom: 0;
        }
      }
    }
  }

  .estadisticas-section {
    margin-bottom: 2rem;
  }
}

.acta-preview {
  overflow-x: auto;
  max-height: 400px;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
}

.acta-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 12px;
}

.acta-table th,
.acta-table td {
  border: 1px solid #ddd;
  padding: 4px 6px;
  text-align: center;
  white-space: nowrap;
}

.acta-table th {
  background-color: #f5f5f5;
  font-weight: bold;
  font-size: 11px;
}

.nota-cell {
  background-color: #fafafa;
  min-width: 40px;
}

.promedio-cell {
  background-color: #e3f2fd;
  font-weight: bold;
}

</style>
