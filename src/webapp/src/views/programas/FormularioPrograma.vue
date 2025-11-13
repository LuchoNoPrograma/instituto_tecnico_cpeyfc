<script setup>
import { ref, watch, computed, reactive, onMounted } from 'vue'
import { useVuelidate } from '@vuelidate/core'
import {
  esRequerido,
  longitudMinima,
  longitudMaxima,
  obtenerErroresCampo,
  validarFormulario,
  resetearValidaciones
} from '@/helpers/validations'
import { filtroLatinoFlexible } from '@/helpers/filtros'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos.js'
import { Cropper } from 'vue-advanced-cropper'
import 'vue-advanced-cropper/dist/style.css'

// Props
const props = defineProps({
  programa: {
    type: Object,
    default: null
  },
  esEdicion: {
    type: Boolean,
    default: false
  }
})

// Emits
const emit = defineEmits(['guardar', 'cancelar'])

// Estado del formulario
const formularioPrograma = reactive({
  // Paso 1: Información básica
  id_aca_programa: null,
  id_aca_modalidad: null,
  gestion: new Date().getFullYear(),

  // Paso 2: Configuración académica
  id_aca_plan_estudio: null,
  id_aca_version: null,
  estado_programa_aprobado: 'SIN INICIAR',

  // Paso 3: Imagen
  imagen_programa_url: '',

  // Vigencia
  fecha_inicio_vigencia: null,
  fecha_fin_vigencia: null,

  // Programa nuevo
  programaNuevo: {
    nombre_programa: '',
    sigla: '',
    id_aca_area: null
  },

  // Plan nuevo
  planNuevo: {
    anho: new Date().getFullYear(),
    vigente: true
  }
})

// Estados
const cargandoFormulario = ref(false)
const pasoActual = ref(1)
const totalPasos = 3
const mostrarFormularioNuevoPrograma = ref(false)
const mostrarFormularioNuevoPlan = ref(false)
const busquedaPrograma = ref('')

// Estados del cropper
const dialogCropper = ref(false)
const imagenOriginal = ref(null)
const cropperRef = ref(null)
const archivoImagen = ref(null)
const previewImagen = ref(null)

// Datos para selects
const programas = ref([])
const modalidades = ref([])
const planesEstudio = ref([])
const versiones = ref([])
const areas = ref([])

// Validaciones por paso
const esquemaReglasPaso1 = computed(() => ({
  id_aca_programa: { esRequerido },
  id_aca_modalidad: { esRequerido },
  gestion: { esRequerido }
}))

const esquemaReglasPaso2 = computed(() => ({
  estado_programa_aprobado: { esRequerido }
}))

const esquemaReglasNuevoPrograma = computed(() => ({
  programaNuevo: {
    nombre_programa: {
      esRequerido,
      longitudMinima: longitudMinima(3),
      longitudMaxima: longitudMaxima(100)
    },
    sigla: {
      longitudMaxima: longitudMaxima(15)
    },
    id_aca_area: { esRequerido }
  }
}))

// Instancias de Vuelidate
const $vPaso1 = useVuelidate(esquemaReglasPaso1, formularioPrograma)
const $vPaso2 = useVuelidate(esquemaReglasPaso2, formularioPrograma)
const $vNuevoPrograma = useVuelidate(esquemaReglasNuevoPrograma, formularioPrograma)

// Computed
const textoBoton = computed(() =>
  props.esEdicion ? 'Actualizar Programa' : 'Crear Programa'
)

const puedeAvanzar = computed(() => {
  switch (pasoActual.value) {
    case 1: return !$vPaso1.value.$invalid
    case 2: return !$vPaso2.value.$invalid
    default: return true
  }
})

const programaSeleccionado = computed(() => {
  return programas.value.find(p => p.id_aca_programa === formularioPrograma.id_aca_programa)
})

const programasFiltrados = computed(() => {
  if (!busquedaPrograma.value) return programas.value

  return programas.value.filter(programa => {
    const texto = `${programa.nombre_programa} ${programa.sigla || ''} ${programa.area_nombre || ''}`
    return filtroLatinoFlexible(texto, busquedaPrograma.value) !== -1
  })
})

const mostrarOpcionNuevoPrograma = computed(() => {
  return busquedaPrograma.value && busquedaPrograma.value.length > 2
})

const siglaPrograma = computed(() => {
  return programaSeleccionado.value?.sigla || ''
})

const tieneImagen = computed(() => previewImagen.value !== null && previewImagen.value !== '')

// Computed para datos de confirmación
const datosConfirmacion = computed(() => {
  const programa = programaSeleccionado.value
  const modalidad = modalidades.value.find(m => m.id_aca_modalidad === formularioPrograma.id_aca_modalidad)
  const planEstudio = planesEstudio.value.find(p => p.id_aca_plan_estudio === formularioPrograma.id_aca_plan_estudio)
  const version = versiones.value.find(v => v.id_aca_version === formularioPrograma.id_aca_version)
  const area = areas.value.find(a => a.id_aca_area === programa?.id_aca_area)

  return {
    programa: programa?.nombre_programa || 'No seleccionado',
    sigla: programa?.sigla || 'Sin sigla',
    area: area?.nombre_area || 'No definida',
    modalidad: modalidad?.nombre_modalidad || 'No seleccionada',
    gestion: formularioPrograma.gestion,
    estado: formularioPrograma.estado_programa_aprobado,
    planEstudio: planEstudio?.anho || 'No seleccionado',
    version: version?.cod_version || 'No seleccionada',
    fechaInicioVigencia: formularioPrograma.fecha_inicio_vigencia,
    fechaFinVigencia: formularioPrograma.fecha_fin_vigencia,
    tieneImagen: tieneImagen.value
  }
})

// Funciones de navegación
const siguientePaso = async () => {
  if (pasoActual.value < totalPasos && puedeAvanzar.value) {
    pasoActual.value++
  }
}

const pasoAnterior = () => {
  if (pasoActual.value > 1) {
    pasoActual.value--
  }
}

// Cargar datos
const cargarDatos = async () => {
  try {
    const [programasRes, modalidadesRes, versionesRes, areasRes, planesRes] = await Promise.all([
      api.get('/api/programa/vista/programas-activos'),
      api.get('/api/modalidad/vista/modalidades-activas'),
      api.get('/api/version/vista/versiones-activas'),
      api.get('/api/area/vista/areas-activas'),
      api.get('/api/plan-estudio/vista/planes_con_contexto')
    ])

    programas.value = programasRes.data
    modalidades.value = modalidadesRes.data
    versiones.value = versionesRes.data
    areas.value = areasRes.data
    planesEstudio.value = planesRes.data
  } catch (error) {
    console.error('Error al cargar datos:', error)
  }
}

const cargarPlanesEstudio = async () => {
  try {
    const response = await api.get('/api/plan-estudio/vista/planes_con_contexto')
    planesEstudio.value = response.data
  } catch (error) {
    console.error('Error al cargar planes de estudio:', error)
  }
}

// Manejo de programas
const abrirFormularioNuevoPrograma = () => {
  formularioPrograma.programaNuevo.nombre_programa = busquedaPrograma.value
  mostrarFormularioNuevoPrograma.value = true
}

const crearNuevoPrograma = async () => {
  const esValido = await validarFormulario($vNuevoPrograma.value.programaNuevo)
  if (!esValido) return

  try {
    const response = await api.post('/api/programa', formularioPrograma.programaNuevo)

    const mensaje = response.data
    const idMatch = mensaje.match(/ID:\s*(\d+)/)
    const nuevoId = idMatch ? parseInt(idMatch[1]) : null

    await cargarDatos()

    if (nuevoId) {
      formularioPrograma.id_aca_programa = nuevoId
      const programa = programas.value.find(p => p.id_aca_programa === nuevoId)
      if (programa) {
        busquedaPrograma.value = programa.nombre_programa
      }
    }

    mostrarFormularioNuevoPrograma.value = false
    Object.assign(formularioPrograma.programaNuevo, {
      nombre_programa: '',
      sigla: '',
      id_aca_area: null
    })

    await cargarPlanesEstudio()
  } catch (error) {
    console.error('Error al crear programa:', error)
  }
}

const cancelarNuevoPrograma = () => {
  mostrarFormularioNuevoPrograma.value = false
  Object.assign(formularioPrograma.programaNuevo, {
    nombre_programa: '',
    sigla: '',
    id_aca_area: null
  })
}

// Manejo de planes de estudio
const abrirFormularioNuevoPlan = () => {
  formularioPrograma.planNuevo.anho = new Date().getFullYear()
  formularioPrograma.planNuevo.vigente = false
  mostrarFormularioNuevoPlan.value = true
}

const crearNuevoPlan = async () => {
  try {
    const response = await api.post('/api/plan-estudio', formularioPrograma.planNuevo)

    await cargarPlanesEstudio()
    mostrarFormularioNuevoPlan.value = false

    const nuevoPlan = planesEstudio.value.find(p => p.anho === formularioPrograma.planNuevo.anho)
    if (nuevoPlan) {
      formularioPrograma.id_aca_plan_estudio = nuevoPlan.id_aca_plan_estudio
    }
  } catch (error) {
    console.error('Error al crear plan de estudio:', error)
  }
}

const cancelarNuevoPlan = () => {
  mostrarFormularioNuevoPlan.value = false
  Object.assign(formularioPrograma.planNuevo, {
    anho: new Date().getFullYear(),
    vigente: false
  })
}

// Manejo de imágenes con cropper
const onArchivoSeleccionado = (file) => {
  if (!file) return

  if (!(file instanceof File)) {
    console.error('No es un archivo válido')
    return
  }

  const maxSize = 10 * 1024 * 1024
  if (file.size > maxSize) {
    alert('La imagen es muy grande. Máximo: 10MB')
    return
  }

  if (!file.type.startsWith('image/')) {
    alert('Solo se permiten imágenes')
    return
  }

  const reader = new FileReader()
  reader.onload = (e) => {
    imagenOriginal.value = e.target.result
    dialogCropper.value = true
  }
  reader.readAsDataURL(file)
}

const confirmarRecorte = async () => {
  const { canvas } = cropperRef.value.getResult()

  if (canvas) {
    canvas.toBlob((blob) => {
      const archivoRecortado = new File([blob], 'programa.jpg', { type: 'image/jpeg' })
      archivoImagen.value = archivoRecortado

      const urlPreview = canvas.toDataURL('image/jpeg', 0.9)
      previewImagen.value = urlPreview

      dialogCropper.value = false
    }, 'image/jpeg', 0.9)
  }
}

const cancelarRecorte = () => {
  dialogCropper.value = false
  imagenOriginal.value = null
}

const editarImagen = () => {
  document.getElementById('file-input-programa').click()
}

// Preparar datos para envío
const guardar = async () => {
  cargandoFormulario.value = true

  try {
    const datos = { ...formularioPrograma }
    delete datos.programaNuevo
    delete datos.planNuevo

    if (archivoImagen.value) {
      const formData = new FormData()
      formData.append('file', archivoImagen.value)
      formData.append('datos', JSON.stringify(datos))

      if (props.esEdicion && props.programa?.imagen_programa_url) {
        formData.append('imagen_url_antigua', props.programa.imagen_programa_url)
      }

      await emit('guardar', formData)
    } else {
      await emit('guardar', datos)
    }

    limpiarFormulario()
  } catch (error) {
    console.error('Error al guardar:', error)
  } finally {
    cargandoFormulario.value = false
  }
}

const limpiarFormulario = () => {
  Object.assign(formularioPrograma, {
    id_aca_programa: null,
    id_aca_modalidad: null,
    gestion: new Date().getFullYear(),
    id_aca_plan_estudio: null,
    id_aca_version: null,
    estado_programa_aprobado: 'SIN INICIAR',
    imagen_programa_url: '',
    fecha_inicio_vigencia: null,
    fecha_fin_vigencia: null,
    programaNuevo: {
      nombre_programa: '',
      sigla: '',
      id_aca_area: null
    },
    planNuevo: {
      anho: new Date().getFullYear(),
      vigente: true
    }
  })
  pasoActual.value = 1
  mostrarFormularioNuevoPrograma.value = false
  busquedaPrograma.value = ''
  archivoImagen.value = null
  previewImagen.value = null
}

const cancelar = () => {
  limpiarFormulario()
  emit('cancelar')
}

const cargarDatosPrograma = (programa) => {
  if (!programa) return

  formularioPrograma.id_aca_programa = programa.id_aca_programa
  formularioPrograma.id_aca_modalidad = programa.id_aca_modalidad
  formularioPrograma.gestion = programa.gestion
  formularioPrograma.id_aca_plan_estudio = programa.id_aca_plan_estudio
  formularioPrograma.id_aca_version = programa.id_aca_version
  formularioPrograma.estado_programa_aprobado = programa.estado_programa_aprobado
  formularioPrograma.fecha_inicio_vigencia = programa.fecha_inicio_vigencia
  formularioPrograma.fecha_fin_vigencia = programa.fecha_fin_vigencia

  if (programa.imagen_programa_url) {
    previewImagen.value = programa.imagen_programa_url
  }

  busquedaPrograma.value = programa.programa_nombre || ''
}

// Watchers
watch(() => formularioPrograma.id_aca_programa, cargarPlanesEstudio)

watch(() => props.programa, (programa) => {
  if (programa && props.esEdicion) {
    cargarDatosPrograma(programa)
  }
}, { immediate: true })

onMounted(() => {
  cargarDatos()
})
</script>

<template>
  <div class="formulario-programa">
    <v-card-text class="pa-6">
      <!-- Progress Stepper -->
      <v-stepper v-model="pasoActual" class="mb-6" elevation="0">
        <v-stepper-header>
          <v-stepper-item
            :complete="pasoActual > 1"
            :value="1"
            title="Información Básica"
            subtitle="Programa y modalidad"
          ></v-stepper-item>

          <v-divider></v-divider>

          <v-stepper-item
            :complete="pasoActual > 2"
            :value="2"
            title="Configuración"
            subtitle="Académica y vigencia"
          ></v-stepper-item>

          <v-divider></v-divider>

          <v-stepper-item
            :value="3"
            title="Confirmación"
            subtitle="Revisar datos"
          ></v-stepper-item>
        </v-stepper-header>
      </v-stepper>

      <!-- Paso 1: Información Básica -->
      <div v-if="pasoActual === 1">
        <h3 class="text-h6 mb-4">Información Básica</h3>

        <v-row>
          <v-col cols="12">
            <v-autocomplete
              v-model="formularioPrograma.id_aca_programa"
              v-model:search="busquedaPrograma"
              :custom-filter="filtroLatinoFlexible"
              :items="programasFiltrados"
              :error-messages="obtenerErroresCampo($vPaso1.id_aca_programa)"
              item-title="nombre_programa"
              item-value="id_aca_programa"
              label="Programa Académico *"
              variant="outlined"
              prepend-inner-icon="mdi-school"
              :disabled="cargandoFormulario"
              no-filter
            >
              <template #item="{ props, item }">
                <v-list-item v-bind="props">
                  <template #title>{{ item.raw.nombre_programa }}</template>
                  <template #subtitle>
                    {{ item.raw.sigla }} - {{ item.raw.area_nombre }}
                  </template>
                </v-list-item>
              </template>

              <template #no-data>
                <div class="pa-4 text-center">
                  <p class="text-body-2 mb-3">
                    {{ busquedaPrograma ?
                    `No se encontró el programa "${busquedaPrograma}"` :
                    'Escriba para buscar programas' }}
                  </p>
                  <v-btn
                    v-if="busquedaPrograma && busquedaPrograma.length > 2"
                    color="primary"
                    variant="elevated"
                    size="small"
                    @click="abrirFormularioNuevoPrograma"
                  >
                    <v-icon start>mdi-plus</v-icon>
                    Crear nuevo programa
                  </v-btn>
                </div>
              </template>
            </v-autocomplete>
          </v-col>

          <v-col cols="12" md="6">
            <v-text-field
              :model-value="siglaPrograma"
              label="Sigla del Programa"
              variant="outlined"
              prepend-inner-icon="mdi-tag"
              readonly
              :disabled="cargandoFormulario"
              hint="Se genera automáticamente del programa seleccionado"
              persistent-hint
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="6">
            <v-select
              v-model="formularioPrograma.id_aca_modalidad"
              :items="modalidades"
              :error-messages="obtenerErroresCampo($vPaso1.id_aca_modalidad)"
              item-title="nombre_modalidad"
              item-value="id_aca_modalidad"
              label="Modalidad *"
              variant="outlined"
              prepend-inner-icon="mdi-format-list-bulleted"
              :disabled="cargandoFormulario"
            ></v-select>
          </v-col>

          <v-col cols="12">
            <v-text-field
              v-model.number="formularioPrograma.gestion"
              :error-messages="obtenerErroresCampo($vPaso1.gestion)"
              label="Gestión *"
              variant="outlined"
              prepend-inner-icon="mdi-calendar"
              type="number"
              :min="2020"
              :max="2030"
              :disabled="cargandoFormulario"
            ></v-text-field>
          </v-col>
        </v-row>
      </div>

      <!-- Paso 2: Configuración Académica -->
      <div v-if="pasoActual === 2">
        <h3 class="text-h6 mb-4">Configuración Académica e Imagen</h3>

        <v-row>
          <v-col cols="12" md="6">
            <v-select
              v-model="formularioPrograma.id_aca_plan_estudio"
              :items="planesEstudio"
              item-title="descripcion_plan"
              item-value="id_aca_plan_estudio"
              label="Plan de Estudio"
              variant="outlined"
              prepend-inner-icon="mdi-book-outline"
              :disabled="cargandoFormulario"
            >
              <template #item="{ props, item }">
                <v-list-item v-bind="props">
                  <template #title>
                    <div class="d-flex align-center">
                      <span class="font-weight-bold">Plan {{ item.raw.anho }}</span>
                      <v-chip
                        v-if="item.raw.vigente"
                        color="success"
                        size="small"
                        class="ml-2"
                      >
                        Vigente
                      </v-chip>
                    </div>
                  </template>
                </v-list-item>
              </template>

              <template #append-item>
                <v-divider></v-divider>
                <v-list-item @click="abrirFormularioNuevoPlan">
                  <template #prepend>
                    <v-icon color="success">mdi-plus</v-icon>
                  </template>
                  <v-list-item-title>Crear nuevo plan</v-list-item-title>
                </v-list-item>
              </template>
            </v-select>
          </v-col>

          <v-col cols="12" md="6">
            <v-select
              v-model="formularioPrograma.estado_programa_aprobado"
              :disabled="cargandoFormulario"
              :items="['SIN INICIAR', 'EN EJECUCION', 'FINALIZADO']"
              :error-messages="obtenerErroresCampo($vPaso2.estado_programa_aprobado)"
              label="Estado del Programa *"
              prepend-inner-icon="mdi-flag"
              variant="outlined"
            ></v-select>
          </v-col>

          <v-col cols="12" md="6">
            <v-select
              v-model="formularioPrograma.id_aca_version"
              :items="versiones"
              clearable
              item-title="cod_version"
              item-value="id_aca_version"
              label="Versión CEUB"
              persistent-clear
              variant="outlined"
              prepend-inner-icon="mdi-tag"
              :disabled="cargandoFormulario"
            ></v-select>
          </v-col>

          <v-col cols="12" md="6"></v-col>

          <v-col cols="12" md="6">
            <v-date-input
              v-model="formularioPrograma.fecha_inicio_vigencia"
              label="Fecha Inicio Vigencia"
              variant="outlined"
              :disabled="cargandoFormulario"
            ></v-date-input>
          </v-col>

          <v-col cols="12" md="6">
            <v-date-input
              v-model="formularioPrograma.fecha_fin_vigencia"
              label="Fecha Fin Vigencia"
              variant="outlined"
              :disabled="cargandoFormulario"
            ></v-date-input>
          </v-col>

          <!-- Imagen del Programa -->
          <v-col cols="12" class="mt-4">
            <label class="text-subtitle-2 text-medium-emphasis mb-2 d-block">
              <v-icon size="small" class="mr-1">mdi-image</v-icon>
              Imagen Destacada (16:9)
            </label>

            <!-- Preview Grande (solo si hay imagen) -->
            <div v-if="tieneImagen" class="imagen-preview-container">
              <v-img
                :src="previewImagen"
                aspect-ratio="16/9"
                cover
                class="imagen-preview"
              >
                <template #error>
                  <div class="error-fallback">
                    <v-btn
                      @click="editarImagen"
                      :disabled="cargandoFormulario"
                      color="primary"
                    >
                      Error al cargar - Selecciona otra
                    </v-btn>
                  </div>
                </template>
              </v-img>

              <!-- Overlay con botón editar -->
              <div class="imagen-overlay">
                <v-btn
                  icon="mdi-pencil"
                  color="white"
                  size="large"
                  @click="editarImagen"
                  :disabled="cargandoFormulario"
                >
                  <v-icon>mdi-pencil</v-icon>
                  <v-tooltip activator="parent" location="bottom">Cambiar imagen</v-tooltip>
                </v-btn>
              </div>
            </div>

            <!-- File Upload visible cuando NO hay imagen -->
            <v-file-upload
              v-else
              v-model="archivoImagen"
              label="Seleccionar imagen del programa"
              variant="outlined"
              prepend-icon="mdi-image-plus"
              accept="image/*"
              :disabled="cargandoFormulario"
              show-size
              chips
              @update:model-value="onArchivoSeleccionado"
            >
              <template #hint>
                <div class="text-center mt-2">
                  PNG, JPG, WEBP • Máximo 10MB • Se recortará a 16:9
                </div>
              </template>
            </v-file-upload>

            <input
              id="file-input-programa"
              type="file"
              accept="image/*"
              style="display: none"
              @change="(e) => onArchivoSeleccionado(e.target.files[0])"
            >
          </v-col>
        </v-row>
      </div>

      <!-- Paso 3: Confirmación -->
      <div v-if="pasoActual === 3">
        <h3 class="text-h6 mb-6">Confirmar Información del Programa</h3>

        <v-row>
          <!-- Programa + Imagen -->
          <v-col cols="12" lg="6">
            <v-card variant="outlined" class="h-100">
              <div v-if="datosConfirmacion.tieneImagen" class="card-image-wrapper">
                <v-img
                  :src="previewImagen"
                  aspect-ratio="16/9"
                  cover
                  class="rounded-t"
                ></v-img>
              </div>

              <v-card-text class="pa-6">
                <div class="mb-4">
                  <h4 class="text-h4 font-weight-bold text-primary mb-2">
                    {{ datosConfirmacion.programa }}
                  </h4>
                  <div class="d-flex gap-2 mb-3">
                    <v-chip color="info" size="small">
                      {{ datosConfirmacion.sigla }}
                    </v-chip>
                    <v-chip color="success" size="small">
                      {{ datosConfirmacion.area }}
                    </v-chip>
                  </div>
                </div>

                <v-divider class="my-4"></v-divider>

                <div class="info-grid">
                  <div class="info-item">
                    <span class="label">Modalidad</span>
                    <span class="value">{{ datosConfirmacion.modalidad }}</span>
                  </div>
                  <div class="info-item">
                    <span class="label">Gestión</span>
                    <span class="value">{{ datosConfirmacion.gestion }}</span>
                  </div>
                </div>
              </v-card-text>
            </v-card>
          </v-col>

          <!-- Configuración Académica -->
          <v-col cols="12" lg="6">
            <v-card variant="outlined" class="h-100">
              <v-card-title class="bg-info text-white pa-4">
                <v-icon start>mdi-cog</v-icon>
                Configuración Académica
              </v-card-title>

              <v-card-text class="pa-6">
                <div class="info-list">
                  <div class="info-row">
                    <span class="label">Plan de Estudio</span>
                    <span class="value">{{ datosConfirmacion.planEstudio }}</span>
                  </div>

                  <div class="info-row">
                    <span class="label">Versión CEUB</span>
                    <span class="value">{{ datosConfirmacion.version }}</span>
                  </div>

                  <div class="info-row">
                    <span class="label">Estado</span>
                    <v-chip
                      :color="datosConfirmacion.estado === 'SIN INICIAR' ? 'warning' :
                               datosConfirmacion.estado === 'EN EJECUCION' ? 'success' : 'info'"
                      size="small"
                    >
                      {{ datosConfirmacion.estado }}
                    </v-chip>
                  </div>

                  <v-divider class="my-4"></v-divider>

                  <div class="info-row">
                    <span class="label">Vigencia</span>
                  </div>

                  <div class="info-row">
                    <span class="text-caption text-medium-emphasis">Inicio:</span>
                    <span class="value">
                      {{ datosConfirmacion.fechaInicioVigencia ?
                      formatoFecha.ddMMaaaa(datosConfirmacion.fechaInicioVigencia) :
                      'Sin definir' }}
                    </span>
                  </div>

                  <div class="info-row">
                    <span class="text-caption text-medium-emphasis">Fin:</span>
                    <span class="value">
                      {{ datosConfirmacion.fechaFinVigencia ?
                      formatoFecha.ddMMaaaa(datosConfirmacion.fechaFinVigencia) :
                      'Sin definir' }}
                    </span>
                  </div>
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

        <v-alert
          color="success"
          variant="tonal"
          class="mt-6"
          icon="mdi-checkbox-marked-circle"
        >
          Verifica que todos los datos sean correctos antes de guardar. Los aranceles de pago se configuran después.
        </v-alert>
      </div>
    </v-card-text>

    <!-- Acciones -->
    <v-card-actions class="pa-6 pt-0">
      <v-btn
        v-if="pasoActual > 1"
        variant="text"
        @click="pasoAnterior"
        :disabled="cargandoFormulario"
      >
        <v-icon start>mdi-arrow-left</v-icon>
        Anterior
      </v-btn>

      <v-spacer></v-spacer>

      <v-btn
        variant="text"
        @click="cancelar"
        :disabled="cargandoFormulario"
      >
        Cancelar
      </v-btn>

      <v-btn
        v-if="pasoActual < totalPasos"
        color="primary"
        variant="elevated"
        :disabled="!puedeAvanzar"
        @click="siguientePaso"
      >
        Siguiente
        <v-icon end>mdi-arrow-right</v-icon>
      </v-btn>

      <v-btn
        v-if="pasoActual === totalPasos"
        color="primary"
        variant="elevated"
        :loading="cargandoFormulario"
        @click="guardar"
      >
        <v-icon start>mdi-content-save</v-icon>
        {{ textoBoton }}
      </v-btn>
    </v-card-actions>

    <!-- Dialog para nuevo programa -->
    <v-dialog v-model="mostrarFormularioNuevoPrograma" max-width="500px" persistent>
      <v-card>
        <v-card-title class="bg-primary text-white">
          <v-icon start>mdi-plus</v-icon>
          Crear Nuevo Programa
        </v-card-title>

        <v-card-text class="pa-6">
          <v-row>
            <v-col cols="12">
              <v-text-field
                v-model="formularioPrograma.programaNuevo.nombre_programa"
                :error-messages="obtenerErroresCampo($vNuevoPrograma.programaNuevo.nombre_programa)"
                label="Nombre del Programa *"
                variant="outlined"
                prepend-inner-icon="mdi-school"
              ></v-text-field>
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioPrograma.programaNuevo.sigla"
                :error-messages="obtenerErroresCampo($vNuevoPrograma.programaNuevo.sigla)"
                label="Sigla"
                variant="outlined"
                prepend-inner-icon="mdi-tag"
                hint="Ej: DES, NDH, TIC"
                persistent-hint
              ></v-text-field>
            </v-col>

            <v-col cols="12" md="6">
              <v-select
                v-model="formularioPrograma.programaNuevo.id_aca_area"
                :items="areas"
                :error-messages="obtenerErroresCampo($vNuevoPrograma.programaNuevo.id_aca_area)"
                item-title="nombre_area"
                item-value="id_aca_area"
                label="Área Académica *"
                variant="outlined"
                prepend-inner-icon="mdi-domain"
              ></v-select>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="pa-6 pt-0">
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="cancelarNuevoPrograma">Cancelar</v-btn>
          <v-btn color="primary" variant="elevated" @click="crearNuevoPrograma">
            <v-icon start>mdi-content-save</v-icon>
            Crear Programa
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog para nuevo plan de estudio -->
    <v-dialog v-model="mostrarFormularioNuevoPlan" max-width="400px" persistent>
      <v-card>
        <v-card-title class="bg-primary text-white">
          <v-icon start>mdi-plus</v-icon>
          Crear Nuevo Plan de Estudio
        </v-card-title>

        <v-card-text class="pa-6">
          <v-row>
            <v-col cols="12">
              <v-text-field
                v-model.number="formularioPrograma.planNuevo.anho"
                label="Año del Plan *"
                variant="outlined"
                prepend-inner-icon="mdi-calendar"
                type="number"
                :min="2020"
                :max="2030"
              ></v-text-field>
            </v-col>

            <v-col cols="12">
              <v-switch
                v-model="formularioPrograma.planNuevo.vigente"
                label="Marcar como vigente"
                color="success"
                inset
              >
                <template #append>
                  <v-tooltip location="top">
                    <template #activator="{ props }">
                      <v-icon v-bind="props" size="small">mdi-help-circle</v-icon>
                    </template>
                    Si se marca como vigente, será el plan por defecto
                  </v-tooltip>
                </template>
              </v-switch>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="pa-6 pt-0">
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="cancelarNuevoPlan">Cancelar</v-btn>
          <v-btn color="primary" variant="elevated" @click="crearNuevoPlan">
            <v-icon start>mdi-content-save</v-icon>
            Crear Plan
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog del Cropper -->
    <v-dialog
      v-model="dialogCropper"
      max-width="900px"
      persistent
    >
      <v-card>
        <v-card-title class="bg-primary text-white pa-4">
          <v-icon start>mdi-crop</v-icon>
          Ajustar Imagen (Formato 16:9)
        </v-card-title>

        <v-card-text class="pa-6">
          <div class="cropper-container">
            <Cropper
              ref="cropperRef"
              class="cropper"
              :src="imagenOriginal"
              :stencil-props="{
                aspectRatio: 16/9
              }"
            />
          </div>
          <div class="text-caption text-center text-medium-emphasis mt-4">
            Ajusta la imagen para que se vea perfecta en 16:9
          </div>
        </v-card-text>

        <v-card-actions class="pa-4">
          <v-spacer></v-spacer>
          <v-btn
            variant="text"
            @click="cancelarRecorte"
          >
            Cancelar
          </v-btn>
          <v-btn
            color="primary"
            variant="elevated"
            @click="confirmarRecorte"
          >
            <v-icon start>mdi-check</v-icon>
            Confirmar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<style lang="scss" scoped>
.formulario-programa {
  .v-stepper {
    box-shadow: none !important;
    background: transparent !important;
  }

  .imagen-preview-container {
    position: relative;
    overflow: hidden;
    border-radius: 8px;
    margin-bottom: 16px;

    .imagen-preview {
      width: 100%;
    }

    .error-fallback {
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: rgba(var(--v-theme-error), 0.1);
    }

    .imagen-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.4);
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 16px;
      opacity: 0;
      transition: opacity 0.3s ease;

      &:hover {
        opacity: 1;
      }
    }
  }

  .cropper-container {
    height: 500px;
    background: rgba(var(--v-theme-surface-variant), 1);

    .cropper {
      height: 100%;
    }
  }

  .card-image-wrapper {
    width: 100%;
    overflow: hidden;
  }

  .info-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }

  .info-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .info-item,
  .info-row {
    display: flex;
    flex-direction: column;
    gap: 4px;

    .label {
      font-size: 0.875rem;
      color: rgba(var(--v-theme-on-surface), 0.6);
      font-weight: 500;
    }

    .value {
      font-weight: 500;
      color: rgba(var(--v-theme-on-surface), 0.87);
      font-size: 1rem;
    }
  }
}

@media (max-width: 960px) {
  .formulario-programa {
    .info-grid {
      grid-template-columns: 1fr;
    }

    .cropper-container {
      height: 400px;
    }
  }
}

@media (max-width: 600px) {
  .formulario-programa {
    .v-card-actions {
      flex-direction: column;
      gap: 8px;

      .v-btn {
        width: 100%;
      }
    }

    .cropper-container {
      height: 250px;
    }
  }
}
</style>
