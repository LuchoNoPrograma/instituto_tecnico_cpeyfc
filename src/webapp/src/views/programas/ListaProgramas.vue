<script setup>
import { onMounted, ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '@/services/api'
import FormularioPrograma from '@/views/programas/FormularioPrograma.vue'
import formatoFecha from '@/helpers/formatos.js'
import ExcelJS from 'exceljs'

const router = useRouter()
const programas = ref([])
const cargando = ref(false)
const busqueda = ref('')

// Estados de dialog unificado
const dialogFormulario = ref(false)
const programaSeleccionado = ref(null)
const esEdicion = computed(() => !!programaSeleccionado.value)

// Headers actualizados
const headers = [
  { title: 'Programa', key: 'programa_nombre', sortable: true, width: '25%' },
  { title: 'Plan', key: 'plan_anho', sortable: true, width: '15%' },
  { title: 'Versión', key: 'cod_version', sortable: true, width: '10%' },
  { title: 'Modalidad', key: 'modalidad_nombre', sortable: true, width: '15%' },
  { title: 'Gestión', key: 'gestion', sortable: true, width: '8%' },
  { title: 'Estado', key: 'estado_programa_aprobado', sortable: true, width: '12%' },
  { title: 'Acciones', key: 'acciones', sortable: false, width: '10%' }
]

// Computed para estadísticas calculadas desde los datos
const estadisticasCalculadas = computed(() => {
  const total = programas.value.length
  const sinIniciar = programas.value.filter(p => p.estado_programa_aprobado === 'SIN INICIAR').length
  const enEjecucion = programas.value.filter(p => p.estado_programa_aprobado === 'EN EJECUCION').length
  const finalizados = programas.value.filter(p => p.estado_programa_aprobado === 'FINALIZADO').length

  return {
    total,
    sinIniciar,
    enEjecucion,
    finalizados
  }
})

// Computed para estadísticas con colores
const tarjetasEstadisticas = computed(() => [
  {
    titulo: 'Total Programas',
    valor: estadisticasCalculadas.value.total,
    icono: 'mdi-school',
    color: 'primary',
    colorFondo: 'primary',
    descripcion: 'Programas registrados'
  },
  {
    titulo: 'Sin Iniciar',
    valor: estadisticasCalculadas.value.sinIniciar,
    icono: 'mdi-clock-outline',
    color: 'info',
    colorFondo: 'info',
    descripcion: 'Próximos a iniciar'
  },
  {
    titulo: 'En Ejecución',
    valor: estadisticasCalculadas.value.enEjecucion,
    icono: 'mdi-play-circle',
    color: 'success',
    colorFondo: 'success',
    descripcion: 'Actualmente activos'
  },
  {
    titulo: 'Finalizados',
    valor: estadisticasCalculadas.value.finalizados,
    icono: 'mdi-check-circle',
    color: 'warning',
    colorFondo: 'warning',
    descripcion: 'Completados'
  }
])

// Computed para formatear datos
const programasFormateados = computed(() => {
  return programas.value.map(programa => ({
    ...programa,
    plan_descripcion: programa.plan_anho || 'Sin plan',
    version_codigo: programa.cod_version || 'Sin versión'
  }))
})

const formatearVigencia = (inicio, fin) => {
  if (!inicio && !fin) return 'Sin definir'
  if (!fin) return `Desde ${formatoFecha.ddMMaaaa(inicio)}`
  if (!inicio) return `Hasta ${formatoFecha.ddMMaaaa(fin)}`
  return `${formatoFecha.ddMMaaaa(inicio)} - ${formatoFecha.ddMMaaaa(fin)}`
}

const obtenerProgramas = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/programas-aprobados/vista/programas-aprobados')
    programas.value = response.data
    // Ya no necesitamos obtenerEstadisticas() porque se calculan automáticamente
  } catch (error) {
    console.error('Error al obtener programas:', error)
  } finally {
    cargando.value = false
  }
}

const obtenerColorEstado = (estado) => {
  const colores = {
    'SIN INICIAR': 'info',
    'EN EJECUCION': 'success',
    'FINALIZADO': 'warning'
  }
  return colores[estado] || 'grey'
}

const duplicarPrograma = (programa) => {
  const programaDuplicado = {
    ...programa,
    gestion: new Date().getFullYear(),
    estado_programa_aprobado: 'SIN INICIAR'
  }
  abrirDialogEditar(programaDuplicado)
}

// Funciones de exportación
const exportarExcel = async () => {
  try {
    const workbook = new ExcelJS.Workbook()
    const worksheet = workbook.addWorksheet('Programas Aprobados')

    // Configurar columnas
    worksheet.columns = [
      { header: 'Programa', key: 'programa', width: 40 },
      { header: 'Modalidad', key: 'modalidad', width: 15 },
      { header: 'Área', key: 'area', width: 20 },
      { header: 'Versión', key: 'version', width: 12 },
      { header: 'Gestión', key: 'gestion', width: 10 },
      { header: 'Estado', key: 'estado', width: 15 },
      { header: 'Precio Matrícula', key: 'matricula', width: 15 },
      { header: 'Precio Colegiatura', key: 'colegiatura', width: 15 },
      { header: 'Precio Titulación', key: 'titulacion', width: 15 },
      { header: 'Fecha Inicio Vigencia', key: 'inicio', width: 18 },
      { header: 'Fecha Fin Vigencia', key: 'fin', width: 18 },
      { header: 'Certificado CEUB', key: 'certificado', width: 18 }
    ]

    // Estilo del header
    worksheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFF' } }
    worksheet.getRow(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: '1976D2' }
    }

    // Agregar datos
    programas.value.forEach(programa => {
      worksheet.addRow({
        programa: programa.programa_nombre,
        modalidad: programa.modalidad_nombre,
        area: programa.area_nombre,
        version: programa.version_codigo || 'Sin versión',
        gestion: programa.gestion,
        estado: programa.estado_programa_aprobado,
        matricula: programa.precio_matricula,
        colegiatura: programa.precio_colegiatura,
        titulacion: programa.precio_titulacion || 0,
        inicio: programa.fecha_inicio_vigencia ? formatoFecha.ddMMaaaa(programa.fecha_inicio_vigencia) : 'No definida',
        fin: programa.fecha_fin_vigencia ? formatoFecha.ddMMaaaa(programa.fecha_fin_vigencia) : 'No definida',
        certificado: programa.cod_certificado_ceub || 'No definido'
      })
    })

    // Formato de moneda para columnas de precios
    worksheet.getColumn('matricula').numFmt = '"Bs" #,##0.00'
    worksheet.getColumn('colegiatura').numFmt = '"Bs" #,##0.00'
    worksheet.getColumn('titulacion').numFmt = '"Bs" #,##0.00'

    // Autoajustar filas
    worksheet.eachRow({ includeEmpty: false }, (row) => {
      row.height = 20
    })

    // Agregar filtros
    worksheet.autoFilter = {
      from: 'A1',
      to: 'L1'
    }

    // Generar archivo
    const buffer = await workbook.xlsx.writeBuffer()
    const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `programas-aprobados-${formatoFecha.ahora('YYYY-MM-DD')}.xlsx`
    link.click()
    window.URL.revokeObjectURL(url)

  } catch (error) {
    console.error('Error al exportar Excel:', error)
  }
}

// Funciones de dialog
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

const guardarPrograma = async (datos) => {
  try {
    cargando.value = true
    datos.cod_certificado_ceub = datos.cod_certificado_ceub ? datos.cod_certificado_ceub : null
    const response = await api.post('/api/programa-aprobado', datos)
    await obtenerProgramas()
    cerrarDialog()
    console.log('Programa guardado exitosamente:', response.data)
  } catch (error) {
    console.error('Error al guardar programa:', error)
  } finally {
    cargando.value = false
  }
}

// Funciones de navegación
const verDetalle = (programa) => {
  router.push(`/programas/${programa.id_aca_programa_aprobado}`)
}

const verPlanEstudio = (programa) => {
  if (programa.id_aca_plan_estudio) {
    router.push(`/plan-estudio/${programa.id_aca_plan_estudio}`)
  }
}

const verGrupos = (programa) => {
  router.push(`/grupos?programa=${programa.id_aca_programa_aprobado}`)
}

onMounted(() => {
  obtenerProgramas()
})
</script>

<template>
  <div class="pa-4">
    <!-- Cards de estadísticas coloridas -->
    <v-row class="mb-6">
      <v-col
        v-for="tarjeta in tarjetasEstadisticas"
        :key="tarjeta.titulo"
        cols="12"
        sm="6"
        md="3"
      >
        <v-card
          class="rounded-lg"
          height="120"
          :color="tarjeta.colorFondo"
        >
          <v-card-text class="d-flex align-center pa-4 white--text">
            <div class="flex-grow-1">
              <div class="text-h4 font-weight-bold mb-1 text-white">
                {{ tarjeta.valor }}
              </div>
              <div class="text-subtitle-2 font-weight-medium mb-1 text-white">
                {{ tarjeta.titulo }}
              </div>
              <div class="text-caption text-white" style="opacity: 0.9;">
                {{ tarjeta.descripcion }}
              </div>
            </div>
            <v-avatar color="white" size="48" class="ml-3">
              <v-icon :icon="tarjeta.icono" size="24" :color="tarjeta.color"></v-icon>
            </v-avatar>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- Tabla de programas -->
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headers"
        :items="programasFormateados"
        :loading="cargando"
        :search="busqueda"
        loading-text="Cargando programas..."
        no-data-text="No hay programas registrados"
        class="rounded-lg"
        density="comfortable"
      >
        <template #top>
          <v-toolbar flat class="rounded-t-lg pa-4">
            <v-toolbar-title class="text-h6 font-weight-bold d-flex align-center">
              <v-icon class="mr-2" color="primary">mdi-school</v-icon>
              Administrar Programas
            </v-toolbar-title>

            <v-spacer></v-spacer>

            <div class="d-flex align-center ga-3 flex-wrap">
              <v-text-field
                v-model="busqueda"
                append-inner-icon="mdi-magnify"
                label="Buscar programas..."
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
                Exportar Excel
              </v-btn>

              <v-btn
                color="primary"
                variant="elevated"
                class="btn-nuevo"
                @click="abrirDialogRegistrar"
              >
                <v-icon start>mdi-plus</v-icon>
                Nuevo Programa
              </v-btn>
            </div>
          </v-toolbar>
        </template>

        <template #item.programa_nombre="{ item }">
          <div>
            <div class="text-body-1 font-weight-medium">
              {{ item.programa_nombre }}
            </div>
            <div class="text-caption text-medium-emphasis">
              <v-icon size="12" class="mr-1">mdi-domain</v-icon>
              {{ item.area_nombre }}
            </div>
          </div>
        </template>

        <template #item.plan_descripcion="{ item }">
          <span class="text-body-2">{{ item.plan_descripcion }}</span>
        </template>

        <template #item.version_codigo="{ item }">
          <span class="text-body-2">{{ item.version_codigo }}</span>
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

        <template #item.acciones="{ item }">
          <div class="d-flex ga-1">
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

            <v-menu>
              <template #activator="{ props }">
                <v-btn
                  color="primary"
                  icon="mdi-dots-vertical"
                  size="small"
                  variant="elevated"
                  v-bind="props"
                >
                  <v-icon>mdi-dots-vertical</v-icon>
                </v-btn>
              </template>

              <v-list density="compact">
                <v-list-item @click="verPlanEstudio(item)" :disabled="!item.id_aca_plan_estudio">
                  <template #prepend>
                    <v-icon>mdi-book-outline</v-icon>
                  </template>
                  <v-list-item-title>Ver Plan de Estudio</v-list-item-title>
                </v-list-item>

                <v-list-item @click="verGrupos(item)">
                  <template #prepend>
                    <v-icon>mdi-account-group</v-icon>
                  </template>
                  <v-list-item-title>Ver Grupos</v-list-item-title>
                </v-list-item>

                <v-list-item @click="duplicarPrograma(item)">
                  <template #prepend>
                    <v-icon>mdi-content-copy</v-icon>
                  </template>
                  <v-list-item-title>Duplicar Programa</v-list-item-title>
                </v-list-item>
              </v-list>
            </v-menu>
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
          <v-icon start>{{ esEdicion ? 'mdi-book-edit' : 'mdi-book-plus' }}</v-icon>
          {{ esEdicion ? 'Editar Programa' : 'Nuevo Programa' }}
        </v-card-title>

        <FormularioPrograma
          :programa="programaSeleccionado"
          :es-edicion="esEdicion"
          @cancelar="cerrarDialog"
          @guardar="guardarPrograma"
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

// Responsive
@media (max-width: 960px) {
  .v-toolbar {
    .d-flex.align-center.ga-3 {
      flex-direction: column;
      align-items: stretch !important;
      gap: 16px !important;
      width: 100%;
    }

    .v-toolbar-title {
      text-align: center;
      margin-bottom: 8px;
    }

    .search-field {
      min-width: 100%;
      max-width: 100%;
    }

    .btn-nuevo {
      min-width: 100%;
    }
  }
}

@media (max-width: 600px) {
  .v-toolbar {
    padding: 16px !important;
  }
}
</style>
