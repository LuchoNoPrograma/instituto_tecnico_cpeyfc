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

// Estados para dialog de parámetros
const dialogParametros = ref(false)
const parametrosPrograma = ref([])
const cargandoParametros = ref(false)
const dialogFormularioParametro = ref(false)
const parametroSeleccionado = ref(null)
const esEdicionParametro = computed(() => !!parametroSeleccionado.value)

// Formulario de parámetro
const formularioParametro = ref({
  nombre_param: '',
  valor: '',
  fecha_inicio_vigencia: null,
  fecha_fin_vigencia: null,
  orden: 1
})

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

// Headers para tabla de parámetros
const headersParametros = [
  { title: 'Parámetro', key: 'nombre_param', sortable: true },
  { title: 'Valor', key: 'valor', sortable: false },
  { title: 'Tipo', key: 'tipo_dato_param', sortable: true },
  { title: 'Vigencia', key: 'vigencia', sortable: false },
  { title: 'Estado', key: 'vigente', sortable: true },
  { title: 'Acciones', key: 'acciones', sortable: false }
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

// Computed para formatear parámetros
const parametrosFormateados = computed(() => {
  return parametrosPrograma.value.map(param => ({
    ...param,
    vigencia: formatearVigencia(param.fecha_inicio_vigencia, param.fecha_fin_vigencia),
    valor_display: formatearValor(param.valor, param.tipo_dato_param)
  }))
})

const formatearVigencia = (inicio, fin) => {
  if (!inicio && !fin) return 'Sin definir'
  if (!fin) return `Desde ${formatoFecha.ddMMaaaa(inicio)}`
  if (!inicio) return `Hasta ${formatoFecha.ddMMaaaa(fin)}`
  return `${formatoFecha.ddMMaaaa(inicio)} - ${formatoFecha.ddMMaaaa(fin)}`
}

const formatearValor = (valor, tipo) => {
  if (tipo === 'DECIMAL' && !isNaN(valor)) {
    return parseFloat(valor) + '%'
  }
  if (tipo === 'BOOLEAN') {
    return valor === 'true' ? 'Sí' : 'No'
  }
  return valor
}

const obtenerProgramas = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/programa-aprobado/vista/programas-aprobados')
    programas.value = response.data
  } catch (error) {
    console.error('Error al obtener programas:', error)
  } finally {
    cargando.value = false
  }
}

const obtenerParametros = async (idPrograma) => {
  cargandoParametros.value = true
  try {
    const response = await api.get(`/api/parametro-programa/programa/${idPrograma}`)
    parametrosPrograma.value = response.data
  } catch (error) {
    console.error('Error al obtener parámetros:', error)
    parametrosPrograma.value = []
  } finally {
    cargandoParametros.value = false
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

// Funciones de parámetros
const abrirParametros = async (programa) => {
  programaSeleccionado.value = programa
  dialogParametros.value = true
  await obtenerParametros(programa.id_aca_programa_aprobado)
}

const abrirFormularioParametro = (parametro = null) => {
  if (parametro) {
    parametroSeleccionado.value = parametro
    formularioParametro.value = {
      nombre_param: parametro.nombre_param,
      valor: parametro.valor,
      fecha_inicio_vigencia: parametro.fecha_inicio_vigencia,
      fecha_fin_vigencia: parametro.fecha_fin_vigencia,
      orden: parametro.orden
    }
  } else {
    parametroSeleccionado.value = null
    formularioParametro.value = {
      nombre_param: '',
      valor: '',
      fecha_inicio_vigencia: null,
      fecha_fin_vigencia: null,
      orden: 1
    }
  }
  dialogFormularioParametro.value = true
}

const guardarParametro = async () => {
  try {
    const datos = {
      ...formularioParametro.value,
      id_programa_aprobado: programaSeleccionado.value.id_aca_programa_aprobado
    }

    if (esEdicionParametro.value) {
      await api.put(`/api/parametro-programa/${parametroSeleccionado.value.id_parametro}`, datos)
    } else {
      await api.post('/api/parametro-programa', datos)
    }

    await obtenerParametros(programaSeleccionado.value.id_aca_programa_aprobado)
    cerrarFormularioParametro()
  } catch (error) {
    console.error('Error al guardar parámetro:', error)
  }
}

const eliminarParametro = async (parametro) => {
  if (confirm('¿Está seguro de eliminar este parámetro?')) {
    try {
      await api.delete(`/api/parametro-programa/${parametro.id_parametro}`)
      await obtenerParametros(programaSeleccionado.value.id_aca_programa_aprobado)
    } catch (error) {
      console.error('Error al eliminar parámetro:', error)
    }
  }
}

const cerrarFormularioParametro = () => {
  dialogFormularioParametro.value = false
  parametroSeleccionado.value = null
}

const cerrarParametros = () => {
  dialogParametros.value = false
  programaSeleccionado.value = null
  parametrosPrograma.value = []
}

// Funciones de exportación
const exportarExcel = async () => {
  try {
    const workbook = new ExcelJS.Workbook()
    const worksheet = workbook.addWorksheet('Programas Aprobados')

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

    worksheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFF' } }
    worksheet.getRow(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: '1976D2' }
    }

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

    worksheet.getColumn('matricula').numFmt = '"Bs" #,##0.00'
    worksheet.getColumn('colegiatura').numFmt = '"Bs" #,##0.00'
    worksheet.getColumn('titulacion').numFmt = '"Bs" #,##0.00'

    worksheet.eachRow({ includeEmpty: false }, (row) => {
      row.height = 20
    })

    worksheet.autoFilter = {
      from: 'A1',
      to: 'L1'
    }

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

                <v-list-item @click="abrirParametros(item)">
                  <template #prepend>
                    <v-icon>mdi-percent</v-icon>
                  </template>
                  <v-list-item-title>Configurar Descuentos</v-list-item-title>
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

    <!-- Dialog de parámetros/descuentos -->
    <v-dialog
      v-model="dialogParametros"
      max-width="1000px"
      persistent
      class="ma-2"
    >
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary d-flex align-center pa-4">
          <v-icon start>mdi-percent</v-icon>
          Configurar Parámetros - {{ programaSeleccionado?.programa_nombre }}
        </v-card-title>

        <v-card-text class="pa-4">
          <div class="d-flex justify-space-between align-center mb-4">
            <div class="text-h6">Lista de Parámetros</div>
            <v-btn
              color="primary"
              variant="elevated"
              @click="abrirFormularioParametro()"
            >
              <v-icon start>mdi-plus</v-icon>
              Agregar Parámetro
            </v-btn>
          </div>

          <v-data-table
            :headers="headersParametros"
            :items="parametrosFormateados"
            :loading="cargandoParametros"
            loading-text="Cargando parámetros..."
            no-data-text="No hay parámetros configurados"
            density="compact"
          >
            <template #item.valor_display="{ item }">
              <v-chip
                :color="item.tipo_dato_param === 'DECIMAL' ? 'success' : 'info'"
                size="small"
                variant="tonal"
              >
                {{ item.valor_display }}
              </v-chip>
            </template>

            <template #item.tipo_dato_param="{ item }">
              <v-chip size="x-small" variant="outlined">
                {{ item.tipo_dato_param }}
              </v-chip>
            </template>

            <template #item.vigente="{ item }">
              <v-chip
                :color="item.vigente ? 'success' : 'warning'"
                size="small"
                variant="flat"
              >
                {{ item.vigente ? 'Vigente' : 'No vigente' }}
              </v-chip>
            </template>

            <template #item.acciones="{ item }">
              <div class="d-flex ga-1">
                <v-btn
                  icon="mdi-pencil"
                  size="small"
                  color="primary"
                  variant="text"
                  @click="abrirFormularioParametro(item)"
                >
                  <v-icon>mdi-pencil</v-icon>
                  <v-tooltip activator="parent">Editar</v-tooltip>
                </v-btn>

                <v-btn
                  icon="mdi-delete"
                  size="small"
                  color="error"
                  variant="text"
                  @click="eliminarParametro(item)"
                >
                  <v-icon>mdi-delete</v-icon>
                  <v-tooltip activator="parent">Eliminar</v-tooltip>
                </v-btn>
              </div>
            </template>
          </v-data-table>
        </v-card-text>

        <v-card-actions class="pa-4">
          <v-spacer></v-spacer>
          <v-btn
            color="grey"
            variant="text"
            @click="cerrarParametros"
          >
            Cerrar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog formulario de parámetro -->
    <v-dialog
      v-model="dialogFormularioParametro"
      max-width="600px"
      persistent
    >
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary d-flex align-center pa-4">
          <v-icon start>{{ esEdicionParametro ? 'mdi-pencil' : 'mdi-plus' }}</v-icon>
          {{ esEdicionParametro ? 'Editar Parámetro' : 'Nuevo Parámetro' }}
        </v-card-title>

        <v-card-text class="pa-4">
          <v-form>
            <v-row>
              <v-col cols="12">
                <v-text-field
                  v-model="formularioParametro.nombre_param"
                  label="Nombre del Parámetro"
                  variant="outlined"
                  placeholder="Ej: DESCUENTO UNIVERSITARIO, OFERTA ESPECIAL"
                  required
                ></v-text-field>
              </v-col>

              <v-col cols="12" md="6">
                <v-text-field
                  v-model="formularioParametro.valor"
                  label="Valor"
                  variant="outlined"
                  placeholder="Ej: 20, 50%, true, Texto"
                  required
                  hint="Se detectará automáticamente el tipo de dato"
                  persistent-hint
                ></v-text-field>
              </v-col>

              <v-col cols="12" md="6">
                <v-text-field
                  v-model="formularioParametro.orden"
                  label="Orden"
                  type="number"
                  variant="outlined"
                  min="1"
                ></v-text-field>
              </v-col>

              <v-col cols="12" md="6">
                <v-date-input
                  v-model="formularioParametro.fecha_inicio_vigencia"
                  label="Fecha Inicio Vigencia"
                  variant="outlined"
                  hint="Opcional - Sin fecha = desde siempre"
                  persistent-hint
                ></v-date-input>
              </v-col>

              <v-col cols="12" md="6">
                <v-date-input
                  v-model="formularioParametro.fecha_fin_vigencia"
                  label="Fecha Fin Vigencia"
                  type="date"
                  variant="outlined"
                  hint="Opcional - Sin fecha = permanente"
                  persistent-hint
                ></v-date-input>
              </v-col>
            </v-row>
          </v-form>
        </v-card-text>

        <v-card-actions class="pa-4">
          <v-spacer></v-spacer>
          <v-btn
            color="grey"
            variant="text"
            @click="cerrarFormularioParametro"
          >
            Cancelar
          </v-btn>
          <v-btn
            color="success"
            variant="elevated"
            @click="guardarParametro"
          >
            {{ esEdicionParametro ? 'Actualizar' : 'Guardar' }}
          </v-btn>
        </v-card-actions>
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
