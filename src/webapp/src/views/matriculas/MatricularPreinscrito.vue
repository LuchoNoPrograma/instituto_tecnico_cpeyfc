<script setup>
import { ref, computed, onMounted, reactive, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { api } from '@/services/api'

const router = useRouter()
const route = useRoute()

// Props desde URL
/*const idProgramaAprobado = ref(parseInt(route.params.idProgramaAprobado))*/
const idProgramaAprobado = ref(1)

// Estados
const cargando = ref(false)
const matriculando = ref(false)
const currentStep = ref(1)
const maxSteps = 5

// Datos
const programaInfo = ref({})
const preinscripciones = ref([])
const grupos = ref([])
const conceptosPago = ref([])
const mensaje = ref('')
const tipoMensaje = ref('success')

// Formulario principal
const formulario = reactive({
  // Paso 1: Preinscripción
  id_ins_preinscripcion: null,
  preinscrito_seleccionado: null,

  // Paso 2: Datos persona (auto-poblados)
  persona: {
    id_prs_persona: null,
    nombre: '',
    ap_paterno: '',
    ap_materno: '',
    ci: '',
    nro_celular: '',
    correo: '',
    fecha_nacimiento: null,
    edad: 0
  },

  // Paso 3: Matrícula
  id_ins_grupo: null,
  tipo_matricula: 'REGULAR',
  observaciones_matricula: '',

  // Paso 4: Obligaciones de pago
  crear_obligacion: true,
  obligaciones: [
    {
      id_fin_concepto_pago: null,
      deuda_sin_descuento: 0,
      deuda_con_descuento: 0,
      observacion: ''
    }
  ]
})

// Validaciones por paso
const stepValidations = computed(() => ({
  1: formulario.id_ins_preinscripcion !== null,
  2: formulario.persona.nombre && formulario.persona.ap_paterno && formulario.persona.ci,
  3: formulario.id_ins_grupo !== null && formulario.tipo_matricula,
  4: !formulario.crear_obligacion || formulario.obligaciones.every(o =>
    o.id_fin_concepto_pago && o.deuda_sin_descuento > 0
  ),
  5: true
}))

const canProceed = computed(() => stepValidations.value[currentStep.value])
const canFinish = computed(() => Object.values(stepValidations.value).every(v => v))

// Opciones
const tiposMatricula = [
  { title: 'Regular', value: 'REGULAR' },
  { title: 'Convalidación', value: 'CONVALIDACION' },
  { title: 'Transferencia', value: 'TRANSFERENCIA' },
  { title: 'Especial', value: 'ESPECIAL' }
]

// Computed
const preinscriptoSeleccionado = computed(() =>
  preinscripciones.value.find(p => p.id_ins_preinscripcion === formulario.id_ins_preinscripcion)
)

const grupoSeleccionado = computed(() =>
  grupos.value.find(g => g.id_ins_grupo === formulario.id_ins_grupo)
)

const totalObligaciones = computed(() =>
  formulario.obligaciones.reduce((sum, o) => sum + Number(o.deuda_con_descuento || o.deuda_sin_descuento || 0), 0)
)

// Métodos de carga
const cargarDatos = async () => {
  cargando.value = true
  try {
    const [programaRes, preinscripcionesRes, gruposRes, conceptosRes] = await Promise.all([
      api.get(`/api/programa-aprobado/vista/programas-aprobados/${idProgramaAprobado.value}`),
      api.get(`/api/preinscripcion/pendiente/${idProgramaAprobado.value}`),
      api.get(`/api/grupo/activo-por-programa/${idProgramaAprobado.value}`),
      api.get('/api/concepto-pago/activo')
    ])

    programaInfo.value = programaRes.data
    preinscripciones.value = preinscripcionesRes.data.filter(p => p.estado_matriculacion === 'NO MATRICULADO')
    grupos.value = gruposRes.data
    conceptosPago.value = conceptosRes.data

  } catch (error) {
    console.error('Error cargando datos:', error)
    mostrarMensaje('Error cargando datos del programa', 'error')
  } finally {
    cargando.value = false
  }
}

const cargarPersonaCompleta = async (ci) => {
  try {
    const response = await api.get('/api/publico/persona/ci', { params: { ci } })
    return response.data
  } catch (error) {
    console.error('Error cargando persona completa:', error)
    return null
  }
}

// Watchers
watch(() => formulario.id_ins_preinscripcion, async (newVal) => {
  if (newVal && preinscriptoSeleccionado.value) {
    const persona = await cargarPersonaCompleta(preinscriptoSeleccionado.value.ci)
    if (persona) {
      Object.assign(formulario.persona, persona)
      formulario.preinscrito_seleccionado = preinscriptoSeleccionado.value
    }
  }
})

watch(() => formulario.crear_obligacion, (crear) => {
  if (crear && formulario.obligaciones.length === 0) {
    formulario.obligaciones.push({
      id_fin_concepto_pago: null,
      deuda_sin_descuento: programaInfo.value.precio_colegiatura || 0,
      deuda_con_descuento: programaInfo.value.precio_colegiatura || 0,
      observacion: 'Colegiatura del programa'
    })
  }
})

// Navegación del stepper
const nextStep = () => {
  if (currentStep.value < maxSteps && canProceed.value) {
    currentStep.value++
  }
}

const prevStep = () => {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

const goToStep = (step) => {
  if (step <= currentStep.value || stepValidations.value[step - 1]) {
    currentStep.value = step
  }
}

// Obligaciones de pago
const agregarObligacion = () => {
  formulario.obligaciones.push({
    id_fin_concepto_pago: null,
    deuda_sin_descuento: 0,
    deuda_con_descuento: 0,
    observacion: ''
  })
}

const removerObligacion = (index) => {
  if (formulario.obligaciones.length > 1) {
    formulario.obligaciones.splice(index, 1)
  }
}

const calcularDescuento = (obligacion) => {
  if (!obligacion.deuda_con_descuento) {
    obligacion.deuda_con_descuento = obligacion.deuda_sin_descuento
  }
}

// Matriculación
const matricular = async () => {
  if (!canFinish.value) return

  matriculando.value = true
  try {
    const datosMatricula = {
      id_ins_preinscripcion: formulario.id_ins_preinscripcion,
      id_ins_grupo: formulario.id_ins_grupo,
      ci: formulario.persona.ci,
      tipo_matricula: formulario.tipo_matricula,
      observaciones: formulario.observaciones_matricula,
      crear_obligaciones: formulario.crear_obligacion,
      obligaciones: formulario.crear_obligacion ? formulario.obligaciones : []
    }

    const response = await api.post('/api/matricula/matricular-preinscrito', datosMatricula)

    mostrarMensaje('Estudiante matriculado exitosamente', 'success')

    setTimeout(() => {
      router.push(`/grupos/${formulario.id_ins_grupo}/estudiantes`)
    }, 2000)

  } catch (error) {
    console.error('Error matriculando:', error)
    const errorMsg = error.response?.data?.message || 'Error procesando matrícula'
    mostrarMensaje(errorMsg, 'error')
  } finally {
    matriculando.value = false
  }
}

const mostrarMensaje = (texto, tipo = 'success') => {
  mensaje.value = texto
  tipoMensaje.value = tipo
  setTimeout(() => {
    mensaje.value = ''
  }, 5000)
}

const getIniciales = (nombre, apellido) => {
  return `${nombre[0] || ''}${apellido[0] || ''}`.toUpperCase()
}

const formatearMonto = (monto) => {
  return new Intl.NumberFormat('es-BO', { style: 'currency', currency: 'BOB' }).format(monto)
}

onMounted(cargarDatos)
</script>

<template>
  <v-container fluid class="pa-6">
    <!-- Header del programa -->
    <v-card class="mb-6 elevation-3">
      <v-card-title class="bg-primary text-white pa-4">
        <v-btn
          icon="mdi-arrow-left"
          color="white"
          variant="text"
          @click="router.back()"
          class="mr-3"
        />
        <div class="flex-grow-1">
          <h2 class="text-h5 font-weight-bold">Matricular Preinscrito</h2>
          <div class="text-subtitle-1">{{ programaInfo.programa_nombre }}</div>
          <div class="text-body-2">{{ programaInfo.modalidad_nombre }} • Gestión {{ programaInfo.gestion }}</div>
        </div>
        <v-chip color="white" text-color="primary" variant="elevated">
          Paso {{ currentStep }} de {{ maxSteps }}
        </v-chip>
      </v-card-title>
    </v-card>

    <!-- Mensaje de estado -->
    <v-alert
      v-if="mensaje"
      :type="tipoMensaje"
      class="mb-4"
      dismissible
      @click:close="mensaje = ''"
    >
      {{ mensaje }}
    </v-alert>

    <!-- Stepper -->
    <v-card class="mb-4">
      <v-stepper v-model="currentStep" :items="maxSteps" flat>
        <template #item.1>
          <v-stepper-item
            title="Seleccionar Preinscrito"
            subtitle="Buscar persona preinscrita"
            :complete="stepValidations[1]"
            :icon="stepValidations[1] ? 'mdi-check' : 'mdi-account-search'"
          />
        </template>

        <template #item.2>
          <v-stepper-item
            title="Datos Personales"
            subtitle="Verificar información"
            :complete="stepValidations[2]"
            :icon="stepValidations[2] ? 'mdi-check' : 'mdi-account-details'"
          />
        </template>

        <template #item.3>
          <v-stepper-item
            title="Configurar Matrícula"
            subtitle="Grupo y tipo de matrícula"
            :complete="stepValidations[3]"
            :icon="stepValidations[3] ? 'mdi-check' : 'mdi-school'"
          />
        </template>

        <template #item.4>
          <v-stepper-item
            title="Obligaciones de Pago"
            subtitle="Configurar pagos"
            :complete="stepValidations[4]"
            :icon="stepValidations[4] ? 'mdi-check' : 'mdi-cash'"
          />
        </template>

        <template #item.5>
          <v-stepper-item
            title="Confirmación"
            subtitle="Revisar y matricular"
            :complete="stepValidations[5]"
            :icon="stepValidations[5] ? 'mdi-check' : 'mdi-clipboard-check'"
          />
        </template>
      </v-stepper>
    </v-card>

    <!-- Contenido por pasos -->
    <v-card :loading="cargando">
      <!-- Paso 1: Selección de Preinscrito -->
      <div v-if="currentStep === 1">
        <v-card-title class="bg-grey-lighten-4">
          <v-icon class="mr-2" color="primary">mdi-account-search</v-icon>
          Seleccionar Preinscrito
        </v-card-title>

        <v-card-text class="pa-6">
          <v-autocomplete
            v-model="formulario.id_ins_preinscripcion"
            :items="preinscripciones"
            item-title="nombre_completo"
            item-value="id_ins_preinscripcion"
            label="Buscar Preinscrito *"
            variant="outlined"
            prepend-inner-icon="mdi-magnify"
            :loading="cargando"
            clearable
          >
            <template #item="{ props, item }">
              <v-list-item v-bind="props">
                <template #prepend>
                  <v-avatar color="primary">
                    {{ getIniciales(item.raw.nombre_completo.split(' ')[0], item.raw.nombre_completo.split(' ')[1]) }}
                  </v-avatar>
                </template>

                <template #title>{{ item.raw.nombre_completo }}</template>

                <template #subtitle>
                  <div class="text-caption">
                    <div><strong>CI:</strong> {{ item.raw.ci }} • <strong>Edad:</strong> {{ item.raw.edad }} años</div>
                    <div><strong>Cel:</strong> {{ item.raw.nro_celular }} • <strong>Email:</strong> {{ item.raw.correo || 'No registrado' }}</div>
                    <div class="text-success"><strong>Preinscrito:</strong> {{ new Date(item.raw.fecha_preinscripcion).toLocaleDateString() }}</div>
                  </div>
                </template>

                <template #append>
                  <v-chip size="small" color="warning" variant="flat">
                    {{ item.raw.estado_matriculacion }}
                  </v-chip>
                </template>
              </v-list-item>
            </template>

            <template #no-data>
              <div class="pa-8 text-center">
                <v-icon size="64" color="grey-lighten-1" class="mb-4">mdi-account-off</v-icon>
                <h3 class="text-h6 mb-2">No hay preinscripciones pendientes</h3>
                <p class="text-body-2">No se encontraron personas preinscritas sin matricular en este programa.</p>
              </div>
            </template>
          </v-autocomplete>

          <!-- Preview del seleccionado -->
          <v-card v-if="preinscriptoSeleccionado" variant="tonal" color="success" class="mt-4">
            <v-card-text class="d-flex align-center pa-4">
              <v-avatar size="56" color="success" class="mr-4">
                {{ getIniciales(preinscriptoSeleccionado.nombre_completo.split(' ')[0], preinscriptoSeleccionado.nombre_completo.split(' ')[1]) }}
              </v-avatar>

              <div class="flex-grow-1">
                <h4 class="text-h6 font-weight-bold">{{ preinscriptoSeleccionado.nombre_completo }}</h4>
                <div class="text-body-2 mt-1">
                  <v-row no-gutters>
                    <v-col cols="6">
                      <div><strong>CI:</strong> {{ preinscriptoSeleccionado.ci }}</div>
                      <div><strong>Edad:</strong> {{ preinscriptoSeleccionado.edad }} años</div>
                    </v-col>
                    <v-col cols="6">
                      <div><strong>Celular:</strong> {{ preinscriptoSeleccionado.nro_celular }}</div>
                      <div><strong>Email:</strong> {{ preinscriptoSeleccionado.correo || 'No registrado' }}</div>
                    </v-col>
                  </v-row>
                </div>
              </div>

              <div class="text-right">
                <v-chip color="success" variant="elevated" class="mb-2">
                  <v-icon start>mdi-calendar</v-icon>
                  {{ new Date(preinscriptoSeleccionado.fecha_preinscripcion).toLocaleDateString() }}
                </v-chip>
                <br>
                <v-chip color="warning" variant="flat" size="small">
                  {{ preinscriptoSeleccionado.estado_matriculacion }}
                </v-chip>
              </div>
            </v-card-text>
          </v-card>
        </v-card-text>
      </div>

      <!-- Paso 2: Datos Personales -->
      <div v-if="currentStep === 2">
        <v-card-title class="bg-grey-lighten-4">
          <v-icon class="mr-2" color="primary">mdi-account-details</v-icon>
          Datos Personales
        </v-card-title>

        <v-card-text class="pa-6">
          <v-row>
            <v-col cols="12" md="4">
              <v-text-field
                v-model="formulario.persona.nombre"
                label="Nombre *"
                variant="outlined"
                prepend-inner-icon="mdi-account"
              />
            </v-col>

            <v-col cols="12" md="4">
              <v-text-field
                v-model="formulario.persona.ap_paterno"
                label="Apellido Paterno *"
                variant="outlined"
                prepend-inner-icon="mdi-account"
              />
            </v-col>

            <v-col cols="12" md="4">
              <v-text-field
                v-model="formulario.persona.ap_materno"
                label="Apellido Materno"
                variant="outlined"
                prepend-inner-icon="mdi-account"
              />
            </v-col>

            <v-col cols="12" md="4">
              <v-text-field
                v-model="formulario.persona.ci"
                label="Cédula de Identidad *"
                variant="outlined"
                prepend-inner-icon="mdi-card-account-details"
                readonly
              />
            </v-col>

            <v-col cols="12" md="4">
              <v-text-field
                v-model="formulario.persona.nro_celular"
                label="Número de Celular *"
                variant="outlined"
                prepend-inner-icon="mdi-phone"
              />
            </v-col>

            <v-col cols="12" md="4">
              <v-text-field
                v-model="formulario.persona.correo"
                label="Correo Electrónico"
                variant="outlined"
                prepend-inner-icon="mdi-email"
                type="email"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-date-input
                readonly
                v-model="formulario.persona.fecha_nacimiento"
                label="Fecha de Nacimiento *"
                variant="outlined"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                :model-value="`${formulario.persona.edad} años`"
                label="Edad"
                variant="outlined"
                readonly
              />
            </v-col>
          </v-row>
        </v-card-text>
      </div>

      <!-- Paso 3: Configurar Matrícula -->
      <div v-if="currentStep === 3">
        <v-card-title class="bg-grey-lighten-4">
          <v-icon class="mr-2" color="primary">mdi-school</v-icon>
          Configurar Matrícula
        </v-card-title>

        <v-card-text class="pa-6">
          <v-row>
            <v-col cols="12" md="6">
              <v-select
                v-model="formulario.id_ins_grupo"
                :items="grupos"
                item-title="nombre_grupo"
                item-value="id_ins_grupo"
                label="Grupo de Matriculación *"
                variant="outlined"
                prepend-inner-icon="mdi-account-group"
              >
                <template #item="{ props, item }">
                  <v-list-item v-bind="props">
                    <template #title>{{ item.raw.nombre_grupo }}</template>
                    <template #subtitle>
                      <div class="text-caption">
                        <div>Estudiantes: {{ item.raw.total_matriculados }}</div>
                        <div>Estado: {{ item.raw.estado_inscripcion }}</div>
                      </div>
                    </template>
                    <template #append>
                      <v-chip size="small" :color="item.raw.estado_inscripcion === 'INSCRIPCIONES ABIERTAS' ? 'success' : 'warning'" variant="flat">
                        {{ item.raw.estado_inscripcion }}
                      </v-chip>
                    </template>
                  </v-list-item>
                </template>
              </v-select>
            </v-col>

            <v-col cols="12" md="6">
              <v-select
                v-model="formulario.tipo_matricula"
                :items="tiposMatricula"
                label="Tipo de Matrícula *"
                variant="outlined"
                prepend-inner-icon="mdi-card-account-details"
              />
            </v-col>

            <v-col cols="12">
              <v-textarea
                v-model="formulario.observaciones_matricula"
                label="Observaciones de Matrícula"
                variant="outlined"
                prepend-inner-icon="mdi-note-text"
                rows="3"
                placeholder="Observaciones adicionales sobre la matrícula..."
              />
            </v-col>
          </v-row>

          <!-- Info del grupo seleccionado -->
          <v-card v-if="grupoSeleccionado" variant="tonal" color="info" class="mt-4">
            <v-card-text>
              <h4 class="text-h6 mb-3">
                <v-icon class="mr-2">mdi-information</v-icon>
                Información del Grupo
              </h4>
              <v-row>
                <v-col cols="6">
                  <div><strong>Nombre:</strong> {{ grupoSeleccionado.nombre_grupo }}</div>
                  <div><strong>Estudiantes:</strong> {{ grupoSeleccionado.total_matriculados }}</div>
                </v-col>
                <v-col cols="6">
                  <div><strong>Gestión:</strong> {{ grupoSeleccionado.gestion_inicio }}</div>
                  <div><strong>Estado:</strong> {{ grupoSeleccionado.estado_inscripcion }}</div>
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>
        </v-card-text>
      </div>

      <!-- Paso 4: Obligaciones de Pago -->
      <div v-if="currentStep === 4">
        <v-card-title class="bg-grey-lighten-4">
          <v-icon class="mr-2" color="primary">mdi-cash</v-icon>
          Obligaciones de Pago
        </v-card-title>

        <v-card-text class="pa-6">
          <v-switch
            v-model="formulario.crear_obligacion"
            label="Crear obligaciones de pago automáticamente"
            color="primary"
            class="mb-4"
          />

          <div v-if="formulario.crear_obligacion">
            <div v-for="(obligacion, index) in formulario.obligaciones" :key="index" class="mb-4">
              <v-card variant="outlined">
                <v-card-title class="bg-grey-lighten-5 pa-3">
                  <div class="d-flex align-center">
                    <v-icon class="mr-2">mdi-cash</v-icon>
                    Obligación {{ index + 1 }}
                    <v-spacer />
                    <v-btn
                      v-if="formulario.obligaciones.length > 1"
                      icon="mdi-delete"
                      size="small"
                      color="error"
                      variant="text"
                      @click="removerObligacion(index)"
                    />
                  </div>
                </v-card-title>

                <v-card-text class="pa-4">
                  <v-row>
                    <v-col cols="12" md="4">
                      <v-select
                        v-model="obligacion.id_fin_concepto_pago"
                        :items="conceptosPago"
                        item-title="nombre_concepto"
                        item-value="id_fin_concepto_pago"
                        label="Concepto de Pago *"
                        variant="outlined"
                        prepend-inner-icon="mdi-tag"
                      />
                    </v-col>

                    <v-col cols="12" md="4">
                      <v-text-field
                        v-model.number="obligacion.deuda_sin_descuento"
                        label="Monto Original *"
                        variant="outlined"
                        prepend-inner-icon="mdi-currency-usd"
                        type="number"
                        step="0.01"
                        @input="calcularDescuento(obligacion)"
                      />
                    </v-col>

                    <v-col cols="12" md="4">
                      <v-text-field
                        v-model.number="obligacion.deuda_con_descuento"
                        label="Monto con Descuento"
                        variant="outlined"
                        prepend-inner-icon="mdi-currency-usd"
                        type="number"
                        step="0.01"
                      />
                    </v-col>

                    <v-col cols="12">
                      <v-text-field
                        v-model="obligacion.observacion"
                        label="Observación"
                        variant="outlined"
                        prepend-inner-icon="mdi-note"
                        placeholder="Descripción de la obligación..."
                      />
                    </v-col>
                  </v-row>
                </v-card-text>
              </v-card>
            </div>

            <v-btn
              color="primary"
              variant="outlined"
              @click="agregarObligacion"
              class="mb-4"
            >
              <v-icon start>mdi-plus</v-icon>
              Agregar Obligación
            </v-btn>

            <!-- Resumen de obligaciones -->
            <v-card variant="tonal" color="success">
              <v-card-text>
                <h4 class="text-h6 mb-2">
                  <v-icon class="mr-2">mdi-calculator</v-icon>
                  Resumen Financiero
                </h4>
                <div class="text-h5 font-weight-bold">
                  Total: {{ formatearMonto(totalObligaciones) }}
                </div>
                <div class="text-caption">
                  {{ formulario.obligaciones.length }} obligación(es) de pago
                </div>
              </v-card-text>
            </v-card>
          </div>

          <v-alert v-else type="info" class="mt-4">
            No se crearán obligaciones de pago automáticamente.
            Deberán gestionarse manualmente después de la matrícula.
          </v-alert>
        </v-card-text>
      </div>

      <!-- Paso 5: Confirmación -->
      <div v-if="currentStep === 5">
        <v-card-title class="bg-grey-lighten-4">
          <v-icon class="mr-2" color="primary">mdi-clipboard-check</v-icon>
          Confirmación de Matrícula
        </v-card-title>

        <v-card-text class="pa-6">
          <v-row>
            <!-- Datos del estudiante -->
            <v-col cols="12" md="6">
              <v-card variant="outlined">
                <v-card-title class="bg-primary text-white pa-3">
                  <v-icon class="mr-2">mdi-account</v-icon>
                  Estudiante
                </v-card-title>
                <v-card-text class="pa-4">
                  <div class="mb-2"><strong>Nombre:</strong> {{ formulario.persona.nombre }} {{ formulario.persona.ap_paterno }} {{ formulario.persona.ap_materno }}</div>
                  <div class="mb-2"><strong>CI:</strong> {{ formulario.persona.ci }}</div>
                  <div class="mb-2"><strong>Celular:</strong> {{ formulario.persona.nro_celular }}</div>
                  <div class="mb-2"><strong>Email:</strong> {{ formulario.persona.correo || 'No registrado' }}</div>
                  <div><strong>Edad:</strong> {{ formulario.persona.edad }} años</div>
                </v-card-text>
              </v-card>
            </v-col>

            <!-- Datos de matrícula -->
            <v-col cols="12" md="6">
              <v-card variant="outlined">
                <v-card-title class="bg-success text-white pa-3">
                  <v-icon class="mr-2">mdi-school</v-icon>
                  Matrícula
                </v-card-title>
                <v-card-text class="pa-4">
                  <div class="mb-2"><strong>Programa:</strong> {{ programaInfo.programa_nombre }}</div>
                  <div class="mb-2"><strong>Modalidad:</strong> {{ programaInfo.modalidad_nombre }}</div>
                  <div class="mb-2"><strong>Grupo:</strong> {{ grupoSeleccionado?.nombre_grupo }}</div>
                  <div class="mb-2"><strong>Tipo:</strong> {{ formulario.tipo_matricula }}</div>
                  <div v-if="formulario.observaciones_matricula"><strong>Observaciones:</strong> {{ formulario.observaciones_matricula }}</div>
                </v-card-text>
              </v-card>
            </v-col>

            <!-- Obligaciones de pago -->
            <v-col cols="12" v-if="formulario.crear_obligacion">
              <v-card variant="outlined">
                <v-card-title class="bg-warning text-white pa-3">
                  <v-icon class="mr-2">mdi-cash</v-icon>
                  Obligaciones de Pago ({{ formulario.obligaciones.length }})
                </v-card-title>
                <v-card-text class="pa-0">
                  <v-table>
                    <thead>
                    <tr>
                      <th>Concepto</th>
                      <th>Monto Original</th>
                      <th>Monto Final</th>
                      <th>Observación</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr v-for="(obligacion, index) in formulario.obligaciones" :key="index">
                      <td>{{ conceptosPago.find(c => c.id_fin_concepto_pago === obligacion.id_fin_concepto_pago)?.nombre_concepto }}</td>
                      <td>{{ formatearMonto(obligacion.deuda_sin_descuento) }}</td>
                      <td>{{ formatearMonto(obligacion.deuda_con_descuento) }}</td>
                      <td>{{ obligacion.observacion }}</td>
                    </tr>
                    </tbody>
                    <tfoot>
                    <tr class="font-weight-bold">
                      <td colspan="2">TOTAL</td>
                      <td>{{ formatearMonto(totalObligaciones) }}</td>
                      <td></td>
                    </tr>
                    </tfoot>
                  </v-table>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
        </v-card-text>
      </div>

      <!-- Acciones del stepper -->
      <v-divider />
      <v-card-actions class="pa-6">
        <v-btn
          v-if="currentStep > 1"
          variant="outlined"
          @click="prevStep"
          :disabled="matriculando"
        >
          <v-icon start>mdi-chevron-left</v-icon>
          Anterior
        </v-btn>

        <v-spacer />

        <v-btn
          v-if="currentStep < maxSteps"
          color="primary"
          variant="elevated"
          @click="nextStep"
          :disabled="!canProceed"
        >
          Siguiente
          <v-icon end>mdi-chevron-right</v-icon>
        </v-btn>

        <v-btn
          v-if="currentStep === maxSteps"
          color="success"
          variant="elevated"
          @click="matricular"
          :loading="matriculando"
          :disabled="!canFinish"
          size="large"
        >
          <v-icon start>mdi-check</v-icon>
          Matricular
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-container>
</template>

<style scoped>
.v-stepper :deep(.v-stepper-header) {
  box-shadow: none;
  border-bottom: 1px solid rgba(0,0,0,0.12);
}

.v-table :deep(tfoot tr) {
  background-color: #f5f5f5;
}
</style>
