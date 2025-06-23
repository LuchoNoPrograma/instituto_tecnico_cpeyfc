<script setup>
import { ref, computed, onMounted, reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos.js'
import ExcelJS from 'exceljs'

const route = useRoute()
const router = useRouter()

// Estados
const planEstudio = ref({})
const programasAsociados = ref([])
const modulosDelPlan = ref([])
const modulosDisponibles = ref([])
const niveles = ref([])
const cargando = ref(false)
const guardando = ref(false)
const busquedaModulo = ref('')
const busqueda = ref('')
const editando = ref(false)

// Dialogs
const dialogModulo = ref(false)
const dialogNuevoModulo = ref(false)
const dialogProgramas = ref(false)

// Forms
const formularioModulo = reactive({
  id_aca_plan_modulo_detalle: null,
  id_aca_modulo: null,
  id_aca_nivel: null,
  carga_horaria: 0,
  creditos: 0,
  orden: 1,
  competencia: ''
})

const formularioNuevoModulo = reactive({
  nombre_modulo: ''
})

// DataTable headers
const headers = [
  { title: 'Nivel', key: 'nivel_nombre', sortable: true, width: '120px' },
  { title: '#', key: 'orden', sortable: true, width: '80px' },
  { title: 'Módulo', key: 'modulo_nombre', sortable: true, width: '300px' },
  { title: 'Sigla', key: 'sigla', sortable: true, width: '100px' },
  { title: 'Horas', key: 'carga_horaria', sortable: true, width: '100px' },
  { title: 'Créditos', key: 'creditos', sortable: true, width: '100px' },
  { title: 'Competencia', key: 'competencia', sortable: false, width: '300px' },
  { title: 'Acciones', key: 'acciones', sortable: false, width: '100px' }
]

// Headers programas
const headersProgramas = [
  { title: 'Programa', key: 'programa_nombre', sortable: true },
  { title: 'Modalidad', key: 'modalidad_nombre', sortable: true },
  { title: 'Gestión', key: 'gestion', sortable: true },
  { title: 'Estado', key: 'estado_programa_aprobado', sortable: true }
]

// Computed
const estadisticas = computed(() => ({
  totalModulos: modulosDelPlan.value.filter(m => m.estado === 'ACTIVO').length,
  totalHoras: modulosDelPlan.value
    .filter(m => m.estado === 'ACTIVO')
    .reduce((sum, mod) => sum + (mod.carga_horaria || 0), 0),
  totalCreditos: modulosDelPlan.value
    .filter(m => m.estado === 'ACTIVO')
    .reduce((sum, mod) => sum + parseFloat(mod.creditos || 0), 0),
  programasAsociados: programasAsociados.value.length
}))

const tarjetasEstadisticas = computed(() => [
  {
    titulo: 'Módulos',
    valor: estadisticas.value.totalModulos,
    icono: 'mdi-book-outline',
    color: 'primary'
  },
  {
    titulo: 'Horas',
    valor: estadisticas.value.totalHoras,
    icono: 'mdi-clock-outline',
    color: 'success'
  },
  {
    titulo: 'Créditos',
    valor: estadisticas.value.totalCreditos.toFixed(1),
    icono: 'mdi-trophy',
    color: 'info'
  },
  {
    titulo: 'Programas',
    valor: estadisticas.value.programasAsociados,
    icono: 'mdi-school',
    color: 'warning'
  }
])

const modulosFiltrados = computed(() => {
  if (!busquedaModulo.value) return modulosDisponibles.value
  return modulosDisponibles.value.filter(modulo =>
    modulo.nombre_modulo.toLowerCase().includes(busquedaModulo.value.toLowerCase())
  )
})

const modulosActivos = computed(() =>
  modulosDelPlan.value.filter(m => m.estado !== 'ELIMINADO')
)

// Funciones
const cargarDatos = async () => {
  cargando.value = true
  try {
    const [planRes, programasRes, modulosRes, nivelesRes, modulosDispRes] = await Promise.all([
      api.get(`/api/plan-estudio/${route.params.id}`),
      api.get(`/api/plan-estudio/${route.params.id}/programas-asociados`),
      api.get(`/api/plan-modulo-detalle/${route.params.id}/modulos`),
      api.get('/api/nivel/vista/niveles-activos'),
      api.get('/api/modulo/vista/modulos-activos')
    ])

    planEstudio.value = planRes.data
    programasAsociados.value = programasRes.data
    modulosDelPlan.value = modulosRes.data
    niveles.value = nivelesRes.data
    modulosDisponibles.value = modulosDispRes.data

  } catch (error) {
    console.error('Error cargando datos:', error)
  } finally {
    cargando.value = false
  }
}

const abrirDialogModulo = () => {
  const siguienteOrden = Math.max(...modulosDelPlan.value.map(m => m.orden), 0) + 1

  Object.assign(formularioModulo, {
    id_aca_plan_modulo_detalle: null,
    id_aca_modulo: null,
    id_aca_nivel: null,
    carga_horaria: 0,
    creditos: 0,
    orden: siguienteOrden,
    competencia: ''
  })

  editando.value = false
  busquedaModulo.value = ''
  dialogModulo.value = true
}

const editarModulo = (item) => {
  Object.assign(formularioModulo, {
    id_aca_plan_modulo_detalle: item.id_aca_plan_modulo_detalle,
    id_aca_modulo: item.id_aca_modulo,
    id_aca_nivel: item.id_aca_nivel,
    carga_horaria: item.carga_horaria,
    creditos: item.creditos,
    orden: item.orden,
    competencia: item.competencia || ''
  })

  // Setear el valor de búsqueda para el autocomplete
  console.log(item)
  const moduloSeleccionado = modulosDisponibles.value.find(m => m.id_aca_modulo === item.id_aca_modulo)
  if (moduloSeleccionado) {
    busquedaModulo.value = moduloSeleccionado.nombre_modulo
  }

  editando.value = true
  dialogModulo.value = true
}

const abrirCrearModulo = () => {
  formularioNuevoModulo.nombre_modulo = busquedaModulo.value
  dialogNuevoModulo.value = true
}

const crearModulo = async () => {
  try {
    guardando.value = true

    const response = await api.post('/api/modulo', {
      nombre_modulo: formularioNuevoModulo.nombre_modulo
    })

    // Recargar módulos disponibles
    const modulosRes = await api.get('/api/modulo/vista/modulos-activos')
    modulosDisponibles.value = modulosRes.data

    // Auto-seleccionar el nuevo módulo basado en el mensaje de respuesta
    if (response.data && typeof response.data === 'string' && response.data.includes('ID:')) {
      const idMatch = response.data.match(/ID:\s*(\d+)/)
      if (idMatch) {
        const nuevoId = parseInt(idMatch[1])
        const moduloCreado = modulosDisponibles.value.find(m => m.id_aca_modulo === nuevoId)
        if (moduloCreado) {
          formularioModulo.id_aca_modulo = moduloCreado.id_aca_modulo
          busquedaModulo.value = moduloCreado.nombre_modulo
        }
      }
    }

    dialogNuevoModulo.value = false

  } catch (error) {
    console.error('Error creando módulo:', error)
  } finally {
    guardando.value = false
  }
}

const guardarModulo = async () => {
  try {
    guardando.value = true

    if (editando.value) {
      // Actualizar módulo existente
      await api.put('/api/plan-modulo-detalle', {
        id_aca_plan_modulo_detalle: formularioModulo.id_aca_plan_modulo_detalle,
        id_aca_plan_estudio: parseInt(route.params.id),
        id_aca_modulo: formularioModulo.id_aca_modulo,
        id_aca_nivel: formularioModulo.id_aca_nivel,
        carga_horaria: parseInt(formularioModulo.carga_horaria),
        creditos: parseFloat(formularioModulo.creditos),
        orden: parseInt(formularioModulo.orden),
        competencia: formularioModulo.competencia || '',
        estado_plan_modulo_detalle: 'ACTIVO'
      })
    } else {
      // Crear nuevo módulo
      await api.post('/api/plan-modulo-detalle', {
        id_aca_plan_estudio: parseInt(route.params.id),
        id_aca_modulo: formularioModulo.id_aca_modulo,
        id_aca_nivel: formularioModulo.id_aca_nivel,
        carga_horaria: parseInt(formularioModulo.carga_horaria),
        creditos: parseFloat(formularioModulo.creditos),
        orden: parseInt(formularioModulo.orden),
        competencia: formularioModulo.competencia || ''
      })
    }

    await cargarDatos()
    dialogModulo.value = false

  } catch (error) {
    console.error('Error guardando módulo:', error)
  } finally {
    guardando.value = false
  }
}

const obtenerColorEstado = (estado) => {
  const colores = {
    'SIN INICIAR': 'info',
    'EN EJECUCION': 'success',
    'FINALIZADO': 'warning',
    'ACTIVO': 'success',
    'INACTIVO': 'error'
  }
  return colores[estado] || 'grey'
}

const exportarExcel = async () => {
  try {
    const workbook = new ExcelJS.Workbook()
    const worksheet = workbook.addWorksheet('Plan de Estudio')

    // Configurar colores institucionales
    const colorAzul = '1976D2'
    const colorBlanco = 'FFFFFF'

    // Título principal
    worksheet.mergeCells('A1:I1')
    const tituloCell = worksheet.getCell('A1')
    tituloCell.value = `PLAN DE ESTUDIO ${planEstudio.value.anho}`
    tituloCell.font = { bold: true, size: 16, color: { argb: colorBlanco } }
    tituloCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: colorAzul } }
    tituloCell.alignment = { horizontal: 'center', vertical: 'middle' }
    worksheet.getRow(1).height = 30

    // Espaciado
    worksheet.addRow([])

    // Estadísticas
    worksheet.mergeCells('A3:I3')
    const statsCell = worksheet.getCell('A3')
    statsCell.value = 'ESTADÍSTICAS DEL PLAN'
    statsCell.font = { bold: true, size: 12, color: { argb: colorBlanco } }
    statsCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: colorAzul } }
    statsCell.alignment = { horizontal: 'center' }

    worksheet.addRow(['Total Módulos:', estadisticas.value.totalModulos])
    worksheet.addRow(['Total Horas:', estadisticas.value.totalHoras])
    worksheet.addRow(['Total Créditos:', estadisticas.value.totalCreditos])
    worksheet.addRow([])

    // Headers de la tabla
    const headerRow = worksheet.addRow(['Nivel', 'Orden', 'Módulo', 'Sigla', 'Horas', 'Créditos', 'Competencia', 'Estado'])
    headerRow.eachCell((cell) => {
      cell.font = { bold: true, color: { argb: colorBlanco } }
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: colorAzul } }
      cell.alignment = { horizontal: 'center', vertical: 'middle' }
      cell.border = {
        top: { style: 'thin' },
        left: { style: 'thin' },
        bottom: { style: 'thin' },
        right: { style: 'thin' }
      }
    })

    // Datos
    modulosActivos.value.forEach(modulo => {
      const dataRow = worksheet.addRow([
        modulo.nivel_nombre,
        modulo.orden,
        modulo.modulo_nombre,
        modulo.sigla,
        modulo.carga_horaria,
        modulo.creditos,
        modulo.competencia || '',
        modulo.estado
      ])

      dataRow.eachCell((cell) => {
        cell.border = {
          top: { style: 'thin' },
          left: { style: 'thin' },
          bottom: { style: 'thin' },
          right: { style: 'thin' }
        }
        cell.alignment = { vertical: 'top', wrapText: true }
      })
    })

    // Autofit columns
    worksheet.columns.forEach(column => {
      let maxLength = 0
      column.eachCell({ includeEmpty: false }, (cell) => {
        const columnLength = cell.value ? cell.value.toString().length : 10
        if (columnLength > maxLength) {
          maxLength = columnLength
        }
      })
      column.width = maxLength < 15 ? 15 : maxLength > 50 ? 50 : maxLength
    })

    const buffer = await workbook.xlsx.writeBuffer()
    const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `plan-estudio-${planEstudio.value.anho}.xlsx`
    link.click()
    window.URL.revokeObjectURL(url)

  } catch (error) {
    console.error('Error exportando Excel:', error)
  }
}

onMounted(cargarDatos)
</script>

<template>
  <div class="pa-4">
    <!-- Header -->
    <v-card class="mb-6 rounded-lg">
      <v-card-title class="bg-primary text-white d-flex align-center pa-4">
        <v-btn icon="mdi-arrow-left" variant="text" class="text-white mr-3" @click="router.back()" />
        <div class="flex-grow-1">
          <h2 class="text-h5 mb-1">
            <v-icon start>mdi-book-open-page-variant</v-icon>
            Plan de Estudio {{ planEstudio.anho }}
          </h2>
          <div class="text-subtitle-1 d-flex align-center ga-3">
            <v-chip :color="planEstudio.vigente ? 'success' : 'warning'" size="small" variant="flat">
              {{ planEstudio.vigente ? 'Vigente' : 'No Vigente' }}
            </v-chip>
            <span>Creado: {{ formatoFecha.ddMMaaaa(planEstudio.fecha_reg) }}</span>
          </div>
        </div>

        <div class="d-flex ga-2">
          <v-btn
            color="info"
            variant="elevated"
            @click="dialogProgramas = true"
            :disabled="!programasAsociados.length"
          >
            <v-icon start>mdi-school</v-icon>
            Programas ({{ programasAsociados.length }})
          </v-btn>
        </div>
      </v-card-title>
    </v-card>

    <!-- Estadísticas -->
    <v-row class="mb-6">
      <v-col v-for="tarjeta in tarjetasEstadisticas" :key="tarjeta.titulo" cols="12" sm="6" md="3">
        <v-card class="rounded-lg" height="100" :color="tarjeta.color">
          <v-card-text class="d-flex align-center pa-4 white--text">
            <div class="flex-grow-1">
              <div class="text-h4 font-weight-bold mb-1 text-white">{{ tarjeta.valor }}</div>
              <div class="text-subtitle-2 font-weight-medium text-white">{{ tarjeta.titulo }}</div>
            </div>
            <v-avatar color="white" size="40" class="ml-3">
              <v-icon :icon="tarjeta.icono" size="20" :color="tarjeta.color"></v-icon>
            </v-avatar>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- DataTable -->
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headers"
        :items="modulosActivos"
        :loading="cargando"
        :search="busqueda"
        density="compact"
        loading-text="Cargando módulos..."
        no-data-text="No hay módulos en este plan"
        :items-per-page="10"
        class="rounded-lg"
      >
        <template #top>
          <v-toolbar flat class="rounded-t-lg pa-4">
            <v-toolbar-title class="text-h6 font-weight-bold d-flex align-center">
              <v-icon class="mr-2" color="primary">mdi-table-edit</v-icon>
              Módulos del Plan ({{ modulosActivos.length }})
            </v-toolbar-title>

            <v-spacer></v-spacer>

            <div class="d-flex align-center ga-3 flex-wrap">
              <v-text-field
                v-model="busqueda"
                append-inner-icon="mdi-magnify"
                label="Buscar módulos..."
                single-line
                hide-details
                variant="outlined"
                density="compact"
                class="search-field"
              ></v-text-field>

              <v-btn
                color="success"
                variant="elevated"
                @click="exportarExcel"
                :disabled="cargando || !modulosDelPlan.length"
              >
                <v-icon start>mdi-file-excel</v-icon>
                Exportar
              </v-btn>

              <v-btn
                color="primary"
                variant="elevated"
                class="btn-nuevo"
                @click="abrirDialogModulo"
                :disabled="cargando"
              >
                <v-icon start>mdi-plus</v-icon>
                Agregar Módulo
              </v-btn>
            </div>
          </v-toolbar>
        </template>
        <!-- Nivel -->
        <template #item.nivel_nombre="{ item }">
          <v-chip size="small" color="info" variant="flat">
            {{ item.nivel_nombre }}
          </v-chip>
        </template>

        <!-- Competencia -->
        <template #item.competencia="{ item }">
          <div class="text-truncate" style="max-width: 300px;" :title="item.competencia">
            {{ item.competencia || 'Sin definir' }}
          </div>
        </template>

        <!-- Acciones -->
        <template #item.acciones="{ item }">
          <v-btn
            icon="mdi-pencil"
            size="small"
            color="primary"
            variant="elevated"
            @click="editarModulo(item)"
            :disabled="guardando"
          >
            <v-icon>mdi-pencil</v-icon>
          </v-btn>
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog Agregar/Editar Módulo -->
    <v-dialog v-model="dialogModulo" max-width="600px" persistent>
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary text-white">
          <v-icon start>{{ editando ? 'mdi-pencil' : 'mdi-book-plus' }}</v-icon>
          {{ editando ? 'Editar Módulo' : 'Agregar Módulo al Plan' }}
        </v-card-title>

        <v-card-text class="pa-6">
          <v-row>
            <v-col cols="12">
              <v-autocomplete
                v-model="formularioModulo.id_aca_modulo"
                v-model:search="busquedaModulo"
                :items="modulosFiltrados"
                item-title="nombre_modulo"
                item-value="id_aca_modulo"
                label="Módulo *"
                variant="outlined"
                prepend-inner-icon="mdi-book"
                no-filter
                clearable
                :disabled="editando"
              >
                <template #no-data>
                  <div class="pa-4 text-center" v-if="!editando">
                    <p class="text-body-2 mb-3">No se encontró "{{ busquedaModulo }}"</p>
                    <v-btn
                      color="primary"
                      variant="elevated"
                      size="small"
                      @click="abrirCrearModulo"
                      v-if="busquedaModulo && busquedaModulo.length > 2"
                    >
                      <v-icon start>mdi-plus</v-icon>
                      Crear "{{ busquedaModulo }}"
                    </v-btn>
                  </div>
                </template>
              </v-autocomplete>
            </v-col>

            <v-col cols="12">
              <v-select
                v-model="formularioModulo.id_aca_nivel"
                :items="niveles"
                item-title="nombre_nivel"
                item-value="id_aca_nivel"
                label="Nivel Académico *"
                variant="outlined"
                prepend-inner-icon="mdi-stairs"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model.number="formularioModulo.orden"
                label="Orden *"
                variant="outlined"
                prepend-inner-icon="mdi-sort"
                type="number"
                min="1"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model.number="formularioModulo.carga_horaria"
                label="Carga Horaria *"
                variant="outlined"
                prepend-inner-icon="mdi-clock-outline"
                type="number"
                min="0"
              />
            </v-col>

            <v-col cols="12">
              <v-text-field
                v-model.number="formularioModulo.creditos"
                label="Créditos *"
                variant="outlined"
                prepend-inner-icon="mdi-trophy"
                type="number"
                min="0"
                step="0.1"
              />
            </v-col>

            <v-col cols="12">
              <v-textarea
                v-model="formularioModulo.competencia"
                label="Competencia"
                variant="outlined"
                prepend-inner-icon="mdi-target"
                rows="3"
                counter="500"
              />
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="pa-6 pt-0">
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="dialogModulo = false" :disabled="guardando">
            Cancelar
          </v-btn>
          <v-btn
            color="primary"
            variant="elevated"
            @click="guardarModulo"
            :loading="guardando"
            :disabled="!formularioModulo.id_aca_modulo || !formularioModulo.id_aca_nivel"
          >
            <v-icon start>mdi-content-save</v-icon>
            {{ editando ? 'Actualizar' : 'Guardar' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog Crear Módulo -->
    <v-dialog v-model="dialogNuevoModulo" max-width="400px" persistent>
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary text-white">
          <v-icon start>mdi-plus</v-icon>
          Crear Nuevo Módulo
        </v-card-title>

        <v-card-text class="pa-6">
          <v-text-field
            v-model="formularioNuevoModulo.nombre_modulo"
            label="Nombre del Módulo *"
            variant="outlined"
            prepend-inner-icon="mdi-book"
            counter="100"
          />
        </v-card-text>

        <v-card-actions class="pa-6 pt-0">
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="dialogNuevoModulo = false" :disabled="guardando">
            Cancelar
          </v-btn>
          <v-btn
            color="primary"
            variant="elevated"
            @click="crearModulo"
            :loading="guardando"
            :disabled="!formularioNuevoModulo.nombre_modulo"
          >
            <v-icon start>mdi-content-save</v-icon>
            Crear
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog Programas -->
    <v-dialog v-model="dialogProgramas" max-width="800px">
      <v-card class="rounded-lg">
        <v-card-title class="bg-info text-white">
          <v-icon start>mdi-school</v-icon>
          Programas que usan este Plan
        </v-card-title>

        <v-data-table
          :headers="headersProgramas"
          :items="programasAsociados"
          density="compact"
          hide-default-footer
        >
          <template #item.programa_nombre="{ item }">
            <div>
              <div class="font-weight-medium">{{ item.programa_nombre }}</div>
              <div class="text-caption text-medium-emphasis">{{ item.area_nombre }}</div>
            </div>
          </template>

          <template #item.estado_programa_aprobado="{ item }">
            <v-chip :color="obtenerColorEstado(item.estado_programa_aprobado)" size="small" variant="flat">
              {{ item.estado_programa_aprobado }}
            </v-chip>
          </template>
        </v-data-table>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="dialogProgramas = false">Cerrar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Loading overlay -->
    <v-overlay v-model="guardando" class="align-center justify-center">
      <v-progress-circular
        color="primary"
        indeterminate
        size="64"
      ></v-progress-circular>
      <p class="text-white mt-4">Guardando cambios...</p>
    </v-overlay>
  </div>
</template>
<style lang="scss" scoped>
.search-field {
  min-width: 280px;
  max-width: 350px;
}

.btn-nuevo {
  min-width: 160px;
  flex-shrink: 0;
}
</style>
