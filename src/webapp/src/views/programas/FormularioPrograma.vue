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
  cod_certificado_ceub: '',

  // Paso 3: Costos del programa
  precio_matricula: 0,
  precio_colegiatura: 0,
  precio_titulacion: 0,
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
const totalPasos = 4
const mostrarFormularioNuevoPrograma = ref(false)
const mostrarFormularioNuevoPlan = ref(false)
const busquedaPrograma = ref('')

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

const esquemaReglasPaso3 = computed(() => ({
  precio_matricula: { esRequerido },
  precio_colegiatura: { esRequerido }
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
const $vPaso3 = useVuelidate(esquemaReglasPaso3, formularioPrograma)
const $vNuevoPrograma = useVuelidate(esquemaReglasNuevoPrograma, formularioPrograma)

// Computed
const textoBoton = computed(() =>
  props.esEdicion ? 'Actualizar Programa' : 'Crear Programa'
)

const puedeAvanzar = computed(() => {
  switch (pasoActual.value) {
    case 1: return !$vPaso1.value.$invalid
    case 2: return !$vPaso2.value.$invalid
    case 3: return !$vPaso3.value.$invalid
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

// Computed para sigla automática del programa
const siglaPrograma = computed(() => {
  return programaSeleccionado.value?.sigla || ''
})

// Computed para formato de certificado CEUB
const codigoCertificadoFormatted = computed({
  get() {
    return formularioPrograma.cod_certificado_ceub
  },
  set(value) {
    // Remover caracteres no numéricos excepto /
    const cleaned = value.replace(/[^\d/]/g, '')
    // Si no tiene /, agregar automáticamente año al final
    if (cleaned && !cleaned.includes('/')) {
      formularioPrograma.cod_certificado_ceub = `${cleaned}/${formularioPrograma.gestion}`
    } else {
      formularioPrograma.cod_certificado_ceub = cleaned
    }
  }
})

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
    planEstudio: planEstudio?.descripcion_plan || 'No seleccionado',
    version: version?.cod_version || 'No seleccionada',
    certificadoCeub: formularioPrograma.cod_certificado_ceub || 'No definido',
    precioMatricula: new Intl.NumberFormat('es-BO', { style: 'currency', currency: 'BOB' }).format(formularioPrograma.precio_matricula),
    precioColegiatura: new Intl.NumberFormat('es-BO', { style: 'currency', currency: 'BOB' }).format(formularioPrograma.precio_colegiatura),
    precioTitulacion: new Intl.NumberFormat('es-BO', { style: 'currency', currency: 'BOB' }).format(formularioPrograma.precio_titulacion),
    fechaInicioVigencia: formularioPrograma.fecha_inicio_vigencia,
    fechaFinVigencia: formularioPrograma.fecha_fin_vigencia
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

    // Extraer ID del mensaje de respuesta: "Programa registrado exitosamente con ID: 123"
    const mensaje = response.data
    const idMatch = mensaje.match(/ID:\s*(\d+)/)
    const nuevoId = idMatch ? parseInt(idMatch[1]) : null

    // Recargar programas
    await cargarDatos()

    // Auto-seleccionar el programa recién creado
    if (nuevoId) {
      formularioPrograma.id_aca_programa = nuevoId
      const programa = programas.value.find(p => p.id_aca_programa === nuevoId)
      if (programa) {
        busquedaPrograma.value = programa.nombre_programa
      }
    }

    // Cerrar dialog y limpiar formulario nuevo programa
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

    // Auto-seleccionar el plan recién creado
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

// Preparar datos para envío
const guardar = async () => {
  cargandoFormulario.value = true

  try {
    const datos = { ...formularioPrograma }
    delete datos.programaNuevo
    delete datos.planNuevo

    await emit('guardar', datos)
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
    cod_certificado_ceub: '',
    precio_matricula: 0,
    precio_colegiatura: 0,
    precio_titulacion: 0,
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
}

const cancelar = () => {
  limpiarFormulario()
  emit('cancelar')
}

// Cargar datos al editar
const cargarDatosPrograma = (programa) => {
  if (!programa) return

  Object.assign(formularioPrograma, programa)
  busquedaPrograma.value = programa.programa_nombre || ''
}

// Watchers
watch(() => formularioPrograma.id_aca_programa, cargarPlanesEstudio)

watch(() => props.programa, (programa) => {
  if (programa && props.esEdicion) {
    cargarDatosPrograma(programa)
  }
}, { immediate: true })

// Actualizar código certificado cuando cambie la gestión
watch(() => formularioPrograma.gestion, (newGestion) => {
  if (formularioPrograma.cod_certificado_ceub && formularioPrograma.cod_certificado_ceub.includes('/')) {
    const [numero] = formularioPrograma.cod_certificado_ceub.split('/')
    formularioPrograma.cod_certificado_ceub = `${numero}/${newGestion}`
  }
})

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
            subtitle="Académica y versión"
          ></v-stepper-item>

          <v-divider></v-divider>

          <v-stepper-item
            :complete="pasoActual > 3"
            :value="3"
            title="Costos"
            subtitle="Precios del programa"
          ></v-stepper-item>

          <v-divider></v-divider>

          <v-stepper-item
            :value="4"
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
        <h3 class="text-h6 mb-4">Configuración Académica</h3>

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
              :items="['SIN INICIAR', 'EN EJECUCION', 'FINALIZADO']"
              :error-messages="obtenerErroresCampo($vPaso2.estado_programa_aprobado)"
              label="Estado del Programa *"
              variant="outlined"
              prepend-inner-icon="mdi-flag"
              :disabled="cargandoFormulario"
            ></v-select>
          </v-col>

          <v-col cols="12" md="6">
            <v-text-field
              v-model="codigoCertificadoFormatted"
              label="Nº Certificado CEUB"
              variant="outlined"
              prepend-inner-icon="mdi-certificate"
              placeholder="123/2024"
              hint="Formato: número/año"
              persistent-hint
              :disabled="cargandoFormulario"
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="6">
            <v-select
              v-model="formularioPrograma.id_aca_version"
              :items="versiones"
              item-title="cod_version"
              item-value="id_aca_version"
              label="Versión"
              variant="outlined"
              prepend-inner-icon="mdi-tag"
              :disabled="cargandoFormulario"
            ></v-select>
          </v-col>

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
        </v-row>
      </div>

      <!-- Paso 3: Costos del Programa -->
      <div v-if="pasoActual === 3">
        <h3 class="text-h6 mb-4">Costos del Programa</h3>

        <v-row>
          <v-col cols="12" md="4">
            <v-text-field
              v-model.number="formularioPrograma.precio_matricula"
              :error-messages="obtenerErroresCampo($vPaso3.precio_matricula)"
              label="Precio Matrícula *"
              variant="outlined"
              prepend-inner-icon="mdi-currency-usd"
              type="number"
              min="0"
              step="0.01"
              :disabled="cargandoFormulario"
              hint="Costo por matrícula del programa"
              persistent-hint
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="4">
            <v-text-field
              v-model.number="formularioPrograma.precio_colegiatura"
              :error-messages="obtenerErroresCampo($vPaso3.precio_colegiatura)"
              label="Precio Colegiatura *"
              variant="outlined"
              prepend-inner-icon="mdi-currency-usd"
              type="number"
              min="0"
              step="0.01"
              :disabled="cargandoFormulario"
              hint="Costo total del programa completo"
              persistent-hint
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="4">
            <v-text-field
              v-model.number="formularioPrograma.precio_titulacion"
              label="Precio Titulación"
              variant="outlined"
              prepend-inner-icon="mdi-currency-usd"
              type="number"
              min="0"
              step="0.01"
              :disabled="cargandoFormulario"
              hint="Costo adicional por obtener el título"
              persistent-hint
            ></v-text-field>
          </v-col>

          <v-col cols="12">
            <v-alert
              color="info"
              variant="tonal"
              class="mt-2"
            >
              <template #prepend>
                <v-icon>mdi-information</v-icon>
              </template>

              <div class="text-subtitle-2 font-weight-bold mb-2">
                Configuración de Costos:
              </div>

              <div class="text-body-2">
                • <strong>Matrícula:</strong> Para programas con pago por concepto de matricula semestral o matricula o única<br>
                • <strong>Colegiatura:</strong> Para programas con pago completo al contado o parcelado<br>
                • <strong>Titulación:</strong> Costo adicional para obtener el título (opcional)
              </div>
            </v-alert>
          </v-col>
        </v-row>
      </div>

      <!-- Paso 4: Confirmación -->
      <div v-if="pasoActual === 4">
        <h3 class="text-h6 mb-4">Confirmar Información del Programa</h3>

        <v-row>
          <!-- Información del Programa -->
          <v-col cols="12">
            <v-card variant="outlined" class="mb-4">
              <v-card-title class="bg-primary text-white">
                <v-icon start>mdi-school</v-icon>
                Información del Programa
              </v-card-title>
              <v-card-text class="pa-4">
                <v-row>
                  <v-col cols="12" md="6">
                    <div class="info-item">
                      <span class="label">Programa:</span>
                      <span class="value">{{ datosConfirmacion.programa }}</span>
                    </div>
                  </v-col>
                  <v-col cols="12" md="6">
                    <div class="info-item">
                      <span class="label">Sigla:</span>
                      <span class="value">{{ datosConfirmacion.sigla }}</span>
                    </div>
                  </v-col>
                  <v-col cols="12" md="6">
                    <div class="info-item">
                      <span class="label">Área:</span>
                      <span class="value">{{ datosConfirmacion.area }}</span>
                    </div>
                  </v-col>
                  <v-col cols="12" md="6">
                    <div class="info-item">
                      <span class="label">Modalidad:</span>
                      <span class="value">{{ datosConfirmacion.modalidad }}</span>
                    </div>
                  </v-col>
                </v-row>
              </v-card-text>
            </v-card>
          </v-col>

          <!-- Configuración Académica -->
          <v-col cols="12">
            <v-card variant="outlined" class="mb-4">
              <v-card-title class="bg-info text-white">
                <v-icon start>mdi-cog</v-icon>
                Configuración Académica
              </v-card-title>
              <v-card-text class="pa-4">
                <v-row>
                  <v-col cols="12" md="6">
                    <div class="info-item">
                      <span class="label">Gestión:</span>
                      <span class="value">{{ datosConfirmacion.gestion }}</span>
                    </div>
                  </v-col>
                  <v-col cols="12" md="6">
                    <div class="info-item">
                      <span class="label">Estado:</span>
                      <v-chip
                        :color="datosConfirmacion.estado === 'SIN INICIAR' ? 'warning' :
                               datosConfirmacion.estado === 'EN EJECUCION' ? 'success' : 'info'"
                        size="small"
                      >
                        {{ datosConfirmacion.estado }}
                      </v-chip>
                    </div>
                  </v-col>
                  <v-col cols="12" md="6">
                    <div class="info-item">
                      <span class="label">Plan de Estudio:</span>
                      <span class="value">{{ datosConfirmacion.planEstudio }}</span>
                    </div>
                  </v-col>
                  <v-col cols="12" md="6">
                    <div class="info-item">
                      <span class="label">Versión CEUB:</span>
                      <span class="value">{{ datosConfirmacion.version }}</span>
                    </div>
                  </v-col>
                  <v-col cols="12">
                    <div class="info-item">
                      <span class="label">Certificado CEUB:</span>
                      <span class="value">{{ datosConfirmacion.certificadoCeub }}</span>
                    </div>
                  </v-col>
                  <v-col cols="12" md="6">
                    <div class="info-item">
                      <span class="label">Inicio Vigencia:</span>
                      <span class="value">{{ formatoFecha.ddMMaaaa(datosConfirmacion.fechaInicioVigencia) }}</span>
                    </div>
                  </v-col>
                  <v-col cols="12" md="6">
                    <div class="info-item">
                      <span class="label">Fin Vigencia:</span>
                      <span class="value">{{ formatoFecha.ddMMaaaa(datosConfirmacion.fechaFinVigencia) }}</span>
                    </div>
                  </v-col>
                </v-row>
              </v-card-text>
            </v-card>
          </v-col>

          <!-- Plan de Pago -->
          <v-col cols="12">
            <v-card variant="outlined">
              <v-card-title class="bg-warning text-white">
                <v-icon start>mdi-cash-multiple</v-icon>
                Plan de Pago
              </v-card-title>
              <v-card-text class="pa-4">
                <v-row>
                  <v-col cols="12" md="4">
                    <div class="info-item">
                      <span class="label">Precio Matrícula:</span>
                      <span class="value text-success font-weight-bold">{{ datosConfirmacion.precioMatricula }}</span>
                    </div>
                  </v-col>
                  <v-col cols="12" md="4">
                    <div class="info-item">
                      <span class="label">Precio Colegiatura:</span>
                      <span class="value text-success font-weight-bold">{{ datosConfirmacion.precioColegiatura }}</span>
                    </div>
                  </v-col>
                  <v-col cols="12" md="4">
                    <div class="info-item">
                      <span class="label">Precio Titulación:</span>
                      <span class="value text-success font-weight-bold">{{ datosConfirmacion.precioTitulacion }}</span>
                    </div>
                  </v-col>
                </v-row>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
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
                    Si se marca como vigente, será el plan por defecto para este año
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
  </div>
</template>

<style lang="scss" scoped>
.formulario-programa {
  .v-stepper {
    box-shadow: none !important;
    background: transparent !important;
  }

  .info-item {
    display: flex;
    flex-direction: column;
    margin-bottom: 16px;

    .label {
      font-size: 0.875rem;
      color: rgba(var(--v-theme-on-surface), 0.6);
      margin-bottom: 4px;
    }

    .value {
      font-weight: 500;
      color: rgba(var(--v-theme-on-surface), 0.87);
    }
  }
}

// Responsive
@media (max-width: 600px) {
  .formulario-programa {
    .v-card-text {
      padding: 16px !important;
    }

    .v-card-actions {
      padding: 16px !important;
      flex-direction: column;
      gap: 8px;

      .v-btn {
        width: 100%;
      }
    }

    .info-item {
      margin-bottom: 12px;
    }
  }
}
</style>
