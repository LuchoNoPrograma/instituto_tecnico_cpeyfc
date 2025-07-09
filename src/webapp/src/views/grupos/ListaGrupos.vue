<script setup>
import { ref, computed, onMounted, reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos.js'
import ExcelJS from 'exceljs'
import FormularioPersona from '@/views/personas/FormularioPersona.vue'
import { showRegistrado, showModificado } from '@/utils/sweetalert'

const route = useRoute()
const router = useRouter()

// Estados principales
const cronogramas = ref([])
const programasAprobados = ref([])
const personas = ref([])
const estadisticas = ref({})
const cargando = ref(false)
const guardando = ref(false)
const groupHeaders = ref({})

// Configuración tabla
const groupBy = ref([{key: 'id_ins_grupo', order: 'asc'}])
const busqueda = ref('')

// Filtros
const programaSeleccionado = ref(null)

// Dialogs
const dialogFormulario = ref(false)
const dialogInscripciones = ref(false)
const dialogCronograma = ref(false)
const dialogFormularioPersona = ref(false)
const editando = ref(false)

// Formularios
const formularioGrupo = reactive({
  id_ins_grupo: null,
  id_aca_programa_aprobado: null,
  nombre_grupo: '',
  fecha_inicio_inscripcion: null,
  fecha_fin_inscripcion: null,
  gestion_inicio: new Date().getFullYear(),
  estado_grupo: 'PROGRAMADO'
})

const cronogramaSeleccionado = ref({})
const grupoSeleccionado = ref(null)
const busquedaPersona = ref('')

// Headers tabla
const headers = [
  { title: 'Módulo', key: 'nombre_modulo', sortable: true, width: '25%' },
  { title: 'Nivel', key: 'nombre_nivel', sortable: true, width: '10%' },
  { title: 'Sigla', key: 'sigla', sortable: true, width: '10%' },
  { title: 'Horas', key: 'carga_horaria', sortable: true, width: '8%' },
  { title: 'Créditos', key: 'creditos', sortable: true, width: '8%' },
  { title: 'Docente', key: 'docente_nombre_completo', sortable: true, width: '20%' },
  { title: 'Periodo', key: 'periodo_modulo', sortable: false, width: '15%' },
  { title: 'Estado', key: 'estado_cronograma_modulo', sortable: true, width: '10%' },
  { title: 'Acciones', key: 'acciones', sortable: false, width: '12%' }
]

// Computed
const estadisticasTarjetas = computed(() => [
  {
    titulo: 'Total Grupos',
    valor: estadisticas.value.total || 0,
    icono: 'mdi-account-group',
    color: 'primary',
    descripcion: 'Grupos registrados'
  },
  {
    titulo: 'En Oferta',
    valor: estadisticas.value.en_oferta || 0,
    icono: 'mdi-bullhorn',
    color: 'info',
    descripcion: 'Recibiendo inscripciones'
  },
  {
    titulo: 'En Ejecución',
    valor: estadisticas.value.en_ejecucion || 0,
    icono: 'mdi-play-circle',
    color: 'success',
    descripcion: 'Con estudiantes activos'
  },
  {
    titulo: 'Finalizados',
    valor: estadisticas.value.finalizados || 0,
    icono: 'mdi-check-circle',
    color: 'warning',
    descripcion: 'Grupos completados'
  }
])

const programasFiltro = computed(() =>
  programasAprobados.value.map(p => ({
    ...p,
    title: `${p.programa_nombre} - ${p.modalidad_nombre} (${p.gestion})`
  }))
)

const cronogramasFormateados = computed(() => {
  return cronogramas.value.map(cronograma => ({
    ...cronograma,
    periodo_modulo: formatearPeriodoModulo(cronograma.fecha_inicio, cronograma.fecha_fin),
    docente_nombre_completo: cronograma.docente_nombre_completo?.trim()
  }))
})

// Funciones utilitarias
const formatearPeriodoModulo = (inicio, fin) => {
  if (!inicio && !fin) return 'No programado'
  if (!fin) return `Inicio: ${formatoFecha.ddMMaaaa(inicio)}`
  return `${formatoFecha.ddMMaaaa(inicio)} - ${formatoFecha.ddMMaaaa(fin)}`
}

const obtenerColorEstado = (estado) => {
  const colores = {
    'PROGRAMADO': 'info',
    'EN OFERTA': 'primary',
    'EN EJECUCION': 'success',
    'FINALIZADO': 'warning'
  }
  return colores[estado] || 'grey'
}

const limpiarFormularioGrupo = () => {
  Object.assign(formularioGrupo, {
    id_ins_grupo: null,
    id_aca_programa_aprobado: programaSeleccionado.value,
    nombre_grupo: '',
    fecha_inicio_inscripcion: null,
    fecha_fin_inscripcion: null,
    gestion_inicio: new Date().getFullYear(),
    estado_grupo: 'PROGRAMADO'
  })
}

// Funciones de carga
const cargarDatos = async () => {
  cargando.value = true
  try {
    // Configurar endpoint según filtro
    let endpoint = '/api/grupos/vista/grupos-cronogramas'
    if (route.query.programa) {
      endpoint += `?programa=${route.query.programa}`
      programaSeleccionado.value = parseInt(route.query.programa)
    }

    // Cargar datos en paralelo
    const [cronogramasRes, programasRes, statsRes] = await Promise.all([
      api.get(endpoint),
      api.get('/api/programa-aprobado/vista/programas-aprobados'),
      api.get('/api/grupos/estadisticas')
    ])

    cronogramas.value = cronogramasRes.data
    programasAprobados.value = programasRes.data
    estadisticas.value = statsRes.data

    nextTick(() => {
      autoExpandirGrupos()
    })
  } catch (error) {
    console.error('Error cargando datos:', error)
  } finally {
    cargando.value = false
  }
}

const cargarPersonas = async () => {
  try {
    const response = await api.get('/api/persona/vista/personas-activas')
    personas.value = response.data.map(p => ({
      ...p,
      nombre_completo: `${p.nombre} ${p.ap_paterno} ${p.ap_materno || ''}`.trim()
    }))
  } catch (error) {
    console.error('Error cargando personas:', error)
  }
}

// Funciones de filtrado
const filtrarPorPrograma = async () => {
  const query = programaSeleccionado.value ? { programa: programaSeleccionado.value } : {}
  await router.push({ query })
  await cargarDatos()
}

const limpiarFiltro = async () => {
  programaSeleccionado.value = null
  await router.push({ query: {} })
  await cargarDatos()
}

// Funciones de formulario grupo
const abrirDialogNuevo = () => {
  limpiarFormularioGrupo()
  editando.value = false
  dialogFormulario.value = true
}

const autoExpandirGrupos = () => {
  setTimeout(() => {
    Object.values(groupHeaders.value).forEach(groupData => {
      if (groupData?.toggleGroup && groupData?.isGroupOpen && groupData?.item) {
        if (!groupData.isGroupOpen(groupData.item)) {
          groupData.toggleGroup(groupData.item)
        }
      }
    })
  }, 100)
}

const abrirDialogEditar = (grupo) => {
  Object.assign(formularioGrupo, {
    id_ins_grupo: grupo.id_ins_grupo,
    id_aca_programa_aprobado: grupo.id_aca_programa_aprobado,
    nombre_grupo: grupo.nombre_grupo,
    fecha_inicio_inscripcion: grupo.fecha_inicio_inscripcion,
    fecha_fin_inscripcion: grupo.fecha_fin_inscripcion,
    gestion_inicio: grupo.gestion_inicio,
    estado_grupo: grupo.estado_grupo
  })
  editando.value = true
  dialogFormulario.value = true
}

const guardarGrupo = async () => {
  try {
    guardando.value = true

    const payload = {
      id_ins_grupo: formularioGrupo.id_ins_grupo,
      id_aca_programa_aprobado: formularioGrupo.id_aca_programa_aprobado,
      nombre_grupo: formularioGrupo.nombre_grupo,
      fecha_inicio_inscripcion: formularioGrupo.fecha_inicio_inscripcion,
      fecha_fin_inscripcion: formularioGrupo.fecha_fin_inscripcion,
      gestion_inicio: formularioGrupo.gestion_inicio,
      estado_grupo: formularioGrupo.estado_grupo
    }

    if (editando.value) {
      await api.put('/api/grupos', payload)
      showModificado('Grupo actualizado correctamente')
    } else {
      await api.post('/api/grupos', payload)
      showRegistrado('Grupo creado exitosamente')
    }

    await cargarDatos()
    dialogFormulario.value = false
  } catch (error) {
    console.error('Error guardando grupo:', error)
  } finally {
    guardando.value = false
  }
}

// Funciones de cronograma
const abrirDialogCronograma = async (cronograma) => {
  cronogramaSeleccionado.value = { ...cronograma }
  await cargarPersonas()
  dialogCronograma.value = true
}

const guardarCronograma = async () => {
  try {
    await api.put('/api/cronograma-modulo', {
      id_eje_cronograma_modulo: cronogramaSeleccionado.value.id_eje_cronograma_modulo,
      id_prs_persona: cronogramaSeleccionado.value.id_prs_persona,
      fecha_inicio: cronogramaSeleccionado.value.fecha_inicio,
      fecha_fin: cronogramaSeleccionado.value.fecha_fin
    })

    showModificado('Cronograma actualizado correctamente')
    await cargarDatos()
    dialogCronograma.value = false
  } catch (error) {
    console.error('Error guardando cronograma:', error)
  }
}


// Funciones de persona
const abrirFormularioNuevaPersona = () => {
  dialogFormularioPersona.value = true
}

const guardarPersona = async (datosPersona) => {
  try {
    const response = await api.post('/api/persona', datosPersona, {
      responseType: 'text'
    })

    // Extraer ID de la respuesta
    const match = response.data.match(/ID:\s*(\d+)/)
    const idPersonaCreada = match ? parseInt(match[1]) : null

    showRegistrado('Persona registrada exitosamente')
    await cargarPersonas()

    if (idPersonaCreada) {
      cronogramaSeleccionado.value.id_prs_persona = idPersonaCreada
    }

    dialogFormularioPersona.value = false
  } catch (error) {
    console.error('Error guardando persona:', error)
    throw error
  }
}

const cancelarFormularioPersona = () => {
  dialogFormularioPersona.value = false
}

// Función de exportación
const exportarExcel = async () => {
  try {
    const workbook = new ExcelJS.Workbook()
    const worksheet = workbook.addWorksheet('Grupos y Cronogramas')

    const colorAzul = '1976D2'
    const colorBlanco = 'FFFFFF'

    // Título
    worksheet.mergeCells('A1:I1')
    const tituloCell = worksheet.getCell('A1')
    tituloCell.value = 'GESTIÓN DE GRUPOS Y CRONOGRAMAS'
    tituloCell.font = { bold: true, size: 16, color: { argb: colorBlanco } }
    tituloCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: colorAzul } }
    tituloCell.alignment = { horizontal: 'center', vertical: 'middle' }
    worksheet.getRow(1).height = 30

    worksheet.addRow([])

    // Headers
    const headerRow = worksheet.addRow(['Grupo', 'Programa', 'Módulo', 'Nivel', 'Sigla', 'Horas', 'Créditos', 'Docente', 'Fechas', 'Estado'])
    headerRow.eachCell((cell) => {
      cell.font = { bold: true, color: { argb: colorBlanco } }
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: colorAzul } }
      cell.alignment = { horizontal: 'center', vertical: 'middle' }
      cell.border = {
        top: { style: 'thin' }, left: { style: 'thin' },
        bottom: { style: 'thin' }, right: { style: 'thin' }
      }
    })

    // Datos agrupados por ID
    const gruposMap = new Map()
    cronogramasFormateados.value.forEach(cronograma => {
      if (!gruposMap.has(cronograma.id_ins_grupo)) {
        gruposMap.set(cronograma.id_ins_grupo, [])
      }
      gruposMap.get(cronograma.id_ins_grupo).push(cronograma)
    })

    gruposMap.forEach(cronogramasGrupo => {
      cronogramasGrupo.forEach((cronograma, index) => {
        const dataRow = worksheet.addRow([
          index === 0 ? cronograma.nombre_grupo : '',
          index === 0 ? cronograma.nombre_programa : '',
          cronograma.nombre_modulo,
          cronograma.nombre_nivel,
          cronograma.sigla,
          cronograma.carga_horaria,
          cronograma.creditos,
          cronograma.docente_nombre_completo,
          cronograma.periodo_modulo,
          cronograma.estado_cronograma_modulo
        ])

        dataRow.eachCell((cell) => {
          cell.border = {
            top: { style: 'thin' }, left: { style: 'thin' },
            bottom: { style: 'thin' }, right: { style: 'thin' }
          }
          cell.alignment = { vertical: 'middle' }
        })
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
    link.download = `grupos-cronogramas-${formatoFecha.ahora('YYYY-MM-DD')}.xlsx`
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
    <!-- Estadísticas -->
    <v-row class="mb-6">
      <v-col v-for="tarjeta in estadisticasTarjetas" :key="tarjeta.titulo" cols="12" sm="6" md="3">
        <v-card class="rounded-lg" height="120" :color="tarjeta.color">
          <v-card-text class="d-flex align-center pa-4 white--text">
            <div class="flex-grow-1">
              <div class="text-h4 font-weight-bold mb-1 text-white">{{ tarjeta.valor }}</div>
              <div class="text-subtitle-2 font-weight-medium mb-1 text-white">{{ tarjeta.titulo }}</div>
              <div class="text-caption text-white" style="opacity: 0.9;">{{ tarjeta.descripcion }}</div>
            </div>
            <v-avatar color="white" size="48" class="ml-3">
              <v-icon :icon="tarjeta.icono" size="24" :color="tarjeta.color"></v-icon>
            </v-avatar>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- Filtros -->
    <v-card class="mb-4 rounded-lg">
      <v-card-text class="pa-4">
        <v-row align="center">
          <v-col cols="12" md="6">
            <v-select
              v-model="programaSeleccionado"
              :items="programasFiltro"
              :item-title="item => `${item.programa_nombre}, Plan ${item.plan_anho}, Versión ${item.cod_version}, ${item.modalidad_nombre}`"
              item-value="id_aca_programa_aprobado"
              label="Filtrar por Programa"
              variant="outlined"
              prepend-inner-icon="mdi-filter"
              clearable
              @update:model-value="filtrarPorPrograma"
            />
          </v-col>
          <v-col cols="12" md="6">
            <div class="d-flex ga-2">
              <v-btn
                color="primary"
                variant="elevated"
                @click="limpiarFiltro"
                :disabled="!programaSeleccionado"
              >
                <v-icon start>mdi-filter-remove</v-icon>
                Limpiar Filtro
              </v-btn>
            </div>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>

    <!-- Tabla con row grouping -->
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headers"
        :items="cronogramasFormateados"
        :loading="cargando"
        :search="busqueda"
        density="compact"
        loading-text="Cargando grupos y cronogramas..."
        no-data-text="No hay cronogramas registrados"
        class="rounded-lg"
        :group-by="groupBy"
      >
        <template #top>
          <v-toolbar flat class="rounded-t-lg pa-4">
            <v-toolbar-title class="text-h6 font-weight-bold d-flex align-center">
              <v-icon class="mr-2" color="primary">mdi-account-group</v-icon>
              Adm. Grupos con módulos
            </v-toolbar-title>

            <v-spacer></v-spacer>

            <div class="d-flex align-center ga-3 flex-wrap">
              <v-text-field
                v-model="busqueda"
                append-inner-icon="mdi-magnify"
                label="Buscar..."
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
                :disabled="cargando"
              >
                <v-icon start>mdi-file-excel</v-icon>
                Exportar
              </v-btn>

              <v-btn
                color="primary"
                variant="elevated"
                class="btn-nuevo"
                @click="abrirDialogNuevo"
              >
                <v-icon start>mdi-plus</v-icon>
                Nuevo Grupo
              </v-btn>
            </div>
          </v-toolbar>
        </template>

        <!-- Header de grupo -->
        <template #group-header="{ item, columns, toggleGroup, isGroupOpen }">
          <template :ref="(el) => { groupHeaders[item.value] = { item, toggleGroup, isGroupOpen } }" />

          <tr class="grupo-header-row">
            <td :colspan="columns.length" class="pa-3">
              <div class="d-flex align-center">
                <v-btn
                  icon
                  variant="elevated"
                  size="small"
                  color="primary"
                  @click="toggleGroup(item)"
                  class="mr-2"
                >
                  <v-icon :icon="isGroupOpen(item) ? 'mdi-chevron-up' : 'mdi-chevron-right'"></v-icon>
                </v-btn>

                <v-icon color="primary" class="mr-2">mdi-account-group</v-icon>

                <div class="flex-grow-1">
                  <div class="text-h6 font-weight-bold">
                    {{ item.items[0]?.raw?.nombre_grupo }}
                  </div>
                  <div class="text-caption">{{ item.items.length }} módulos programados</div>
                </div>

                <v-chip
                  :color="obtenerColorEstado(item.items[0]?.raw?.estado_grupo)"
                  size="small"
                  variant="flat"
                  class="mr-3"
                >
                  {{ item.items[0]?.raw?.estado_grupo }}
                </v-chip>

                <div class="d-flex ga-1">
                  <v-btn
                    icon="mdi-account-multiple"
                    size="small"
                    color="info"
                    variant="elevated"
                    @click="router.push(`/matriculas?grupo=${item.items[0]?.raw?.id_ins_grupo}`)"
                  >
                    <v-icon>mdi-account-multiple</v-icon>
                    <v-tooltip activator="parent" location="top">Ver estudiantes</v-tooltip>
                  </v-btn>

                  <v-btn
                    icon="mdi-pencil"
                    size="small"
                    color="primary"
                    variant="elevated"
                    @click="abrirDialogEditar(item.items[0].raw)"
                  >
                    <v-icon>mdi-pencil</v-icon>
                    <v-tooltip activator="parent" location="top">Editar grupo</v-tooltip>
                  </v-btn>

                  <v-btn
                    icon="mdi-account-plus"
                    size="small"
                    color="success"
                    variant="elevated"
                    :to="`/inscripciones?programa=${item.items[0].raw.id_aca_programa_aprobado}`"
                  >
                    <v-icon>mdi-account-plus</v-icon>
                    <v-tooltip activator="parent" location="top">Gestionar inscripciones</v-tooltip>
                  </v-btn>
                </div>
              </div>
            </td>
          </tr>
        </template>

        <!-- Nivel -->
        <template #item.nombre_nivel="{ item }">
          <v-chip size="small" color="info" variant="flat">
            {{ item.nombre_nivel }}
          </v-chip>
        </template>

        <!-- Docente -->
        <template #item.docente_nombre_completo="{ item }">
          <div>
            <div class="text-body-2">{{ item.docente_nombre_completo }}</div>
            <v-chip
              v-if="!item.id_eje_docente"
              color="warning"
              size="small"
              variant="flat"
            >
              SIN DOCENTE ASIGNADO
            </v-chip>
          </div>
        </template>

        <!-- Estado -->
        <template #item.estado_cronograma_modulo="{ item }">
          <v-chip
            :color="obtenerColorEstado(item.estado_cronograma_modulo)"
            size="small"
            variant="flat"
          >
            {{ item.estado_cronograma_modulo }}
          </v-chip>
        </template>

        <!-- Acciones cronograma -->
        <template #item.acciones="{ item }">
          <v-btn
            icon="mdi-calendar-edit"
            size="small"
            color="primary"
            variant="elevated"
            @click="abrirDialogCronograma(item)"
          >
            <v-icon icon="mdi-calendar-edit"></v-icon>
            <v-tooltip activator="parent" location="top">Gestionar cronograma</v-tooltip>
          </v-btn>
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog Formulario Grupo -->
    <v-dialog v-model="dialogFormulario" max-width="600px" persistent>
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary text-white">
          <v-icon start>{{ editando ? 'mdi-pencil' : 'mdi-plus' }}</v-icon>
          {{ editando ? 'Editar Grupo' : 'Nuevo Grupo' }}
        </v-card-title>

        <v-card-text class="pa-6">
          <v-row>
            <v-col cols="12" v-if="!editando">
              <v-select
                v-model="formularioGrupo.id_aca_programa_aprobado"
                :items="programasFiltro"
                item-title="title"
                item-value="id_aca_programa_aprobado"
                label="Programa Aprobado *"
                variant="outlined"
                prepend-inner-icon="mdi-school"
              />
            </v-col>

            <v-col cols="12">
              <v-text-field
                v-model="formularioGrupo.nombre_grupo"
                label="Nombre del Grupo *"
                variant="outlined"
                prepend-inner-icon="mdi-account-group"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-date-input
                v-model="formularioGrupo.fecha_inicio_inscripcion"
                label="Inicio Inscripción *"
                variant="outlined"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-date-input
                v-model="formularioGrupo.fecha_fin_inscripcion"
                label="Fin Inscripción"
                variant="outlined"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model.number="formularioGrupo.gestion_inicio"
                label="Gestión de Inicio *"
                variant="outlined"
                type="number"
                prepend-inner-icon="mdi-calendar"
                :disabled="editando"
              />
            </v-col>

            <v-col cols="12" md="6" v-if="editando">
              <v-select
                v-model="formularioGrupo.estado_grupo"
                :items="['PROGRAMADO', 'EN OFERTA', 'EN EJECUCION', 'FINALIZADO']"
                label="Estado"
                variant="outlined"
                prepend-inner-icon="mdi-state-machine"
              />
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="pa-6 pt-0">
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="dialogFormulario = false" :disabled="guardando">
            Cancelar
          </v-btn>
          <v-btn
            color="primary"
            variant="elevated"
            @click="guardarGrupo"
            :loading="guardando"
            :disabled="!formularioGrupo.nombre_grupo || (!editando && !formularioGrupo.id_aca_programa_aprobado)"
          >
            <v-icon start>mdi-content-save</v-icon>
            {{ editando ? 'Actualizar' : 'Guardar' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog Gestionar Cronograma -->
    <v-dialog v-model="dialogCronograma" max-width="800px" persistent>
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary text-white">
          <v-icon start>mdi-calendar-edit</v-icon>
          Gestionar Cronograma - {{ cronogramaSeleccionado?.nombre_modulo }}
        </v-card-title>

        <v-card-text class="pa-6">
          <v-row>
            <!-- Información del contexto (readonly) -->
            <v-col cols="12" md="12">
              <v-text-field
                :model-value="cronogramaSeleccionado?.nombre_programa"
                label="Programa"
                variant="outlined"
                prepend-inner-icon="mdi-school"
                readonly
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                :model-value="cronogramaSeleccionado?.nombre_grupo"
                label="Grupo"
                variant="outlined"
                prepend-inner-icon="mdi-account-group"
                readonly
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                :model-value="cronogramaSeleccionado?.nombre_modulo"
                label="Módulo"
                variant="outlined"
                prepend-inner-icon="mdi-book"
                readonly
              />
            </v-col>

            <!-- Campos editables -->
            <v-col cols="12">
              <v-autocomplete
                v-model="cronogramaSeleccionado.id_prs_persona"
                v-model:search="busquedaPersona"
                :items="personas"
                item-title="nombre_completo"
                item-value="id_prs_persona"
                label="Persona para Docente *"
                variant="outlined"
                prepend-inner-icon="mdi-account"
                clearable
              >
                <template #item="{ props, item }">
                  <v-list-item v-bind="props">
                    <template #title>{{ item.raw.nombre_completo }}</template>
                    <template #subtitle>
                      CI: {{ item.raw.ci }} | Cel: {{ item.raw.nro_celular }}
                    </template>
                  </v-list-item>
                </template>

                <template #no-data>
                  <div class="pa-4 text-center">
                    <p class="text-body-2 mb-3">
                      {{ busquedaPersona ?
                      `No se encontró la persona "${busquedaPersona}"` :
                      'Escriba para buscar personas' }}
                    </p>
                    <v-btn
                      v-if="busquedaPersona && busquedaPersona.length > 2"
                      color="primary"
                      variant="elevated"
                      size="small"
                      @click="abrirFormularioNuevaPersona"
                    >
                      <v-icon start>mdi-plus</v-icon>
                      Registrar nueva persona
                    </v-btn>
                  </div>
                </template>
              </v-autocomplete>
            </v-col>

            <v-col cols="12" md="6">
              <v-date-input
                v-model="cronogramaSeleccionado.fecha_inicio"
                label="Fecha Inicio"
                variant="outlined"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-date-input
                v-model="cronogramaSeleccionado.fecha_fin"
                label="Fecha Fin"
                variant="outlined"
              />
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="pa-6 pt-0">
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="dialogCronograma = false">Cancelar</v-btn>
          <v-btn color="primary" variant="elevated" @click="guardarCronograma">
            <v-icon start>mdi-content-save</v-icon>
            Guardar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog Registrar Persona -->
    <v-dialog v-model="dialogFormularioPersona" max-width="800px" persistent>
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary text-white">
          <v-icon start>mdi-account-plus</v-icon>
          Registrar Nueva Persona
        </v-card-title>

        <FormularioPersona
          :persona="null"
          :es-edicion="false"
          @guardar="guardarPersona"
          @cancelar="cancelarFormularioPersona"
        />
      </v-card>
    </v-dialog>
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

.grupo-header-row {
  background-color: #f5f5f5 !important;
  border-bottom: 2px solid #1976d2 !important;
}

:deep(.v-data-table__tr--group-header) {
  background-color: #f5f5f5 !important;
}
</style>
