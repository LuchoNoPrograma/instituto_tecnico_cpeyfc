<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos.js'
import { useVuelidate } from '@vuelidate/core'
import {
  esRequerido,
  longitudMinima,
  longitudMaxima,
  esEmail,
  soloLetras,
  ciBoliviano,
  celularBoliviano,
  edadMinima,
  noFuturo,
  obtenerErroresCampo,
  validarFormulario as validarFormularioHelper
} from '@/helpers/validations'

const route = useRoute()
const router = useRouter()

const programa = ref(null)
const planEstudios = ref([])
const cargandoPlan = ref(false)
const cargando = ref(false)
const mostrarFormulario = ref(false)
const pasoFormulario = ref(1)
const formularioInscripcion = ref({
  ci: '',
  nombre: '',
  ap_paterno: '',
  ap_materno: '',
  fecha_nacimiento: '',
  celular: '',
  correo: '',
})

const reglasValidacion = computed(() => ({
  ci: {
    esRequerido,
    longitudMinima: longitudMinima(5),
    longitudMaxima: longitudMaxima(20),
    ciBoliviano
  },
  nombre: {
    esRequerido,
    longitudMinima: longitudMinima(2),
    longitudMaxima: longitudMaxima(35),
    soloLetras
  },
  ap_paterno: {
    esRequerido,
    longitudMinima: longitudMinima(2),
    longitudMaxima: longitudMaxima(55),
    soloLetras
  },
  ap_materno: {
    longitudMaxima: longitudMaxima(55),
    soloLetras
  },
  fecha_nacimiento: {
    esRequerido,
    edadMinima: edadMinima(4),
    noFuturo
  },
  celular: {
    esRequerido,
    celularBoliviano
  },
  correo: {
    esEmail,
    longitudMaxima: longitudMaxima(55)
  }
}))

const $v = useVuelidate(reglasValidacion, formularioInscripcion)
const enviandoFormulario = ref(false)

const programaId = computed(() => route.query.programa)

const requisitosPrograma = ref([
  {
    icono: 'mdi-file-document',
    texto: 'Boletas originales de depósito bancario de matrícula y cuota inicial'
  },
  {
    icono: 'mdi-camera',
    texto: '2 fotografías 4x4 fondo rojo'
  },
  {
    icono: 'mdi-school',
    texto: 'Hoja de Inscripción debidamente llenados'
  },
  {
    icono: 'mdi-card-account-details',
    texto: 'Dos fotocopias simples de Cédula de Identidad'
  }
])

const competenciasPrograma = ref([
  'Gestión Documental',
  'Herramientas Digitales',
  'Administración',
  'Archivo Digital',
  'Atención al Cliente'
])

const headersModulos = [
  { title: '#', key: 'orden', width: '80px', sortable: false },
  { title: 'Sigla', key: 'sigla', width: '120px', sortable: false },
  { title: 'Nombre del Módulo', key: 'nombre_modulo', sortable: false },
  { title: 'Horas', key: 'carga_horaria', width: '100px', sortable: false },
  { title: 'Créditos', key: 'creditos', width: '100px', sortable: false },
  { title: 'Competencia', key: 'competencia', sortable: false }
]

const obtenerDetallePrograma = async () => {
  if (!programaId.value) return

  cargando.value = true
  try {
    const response = await api.get(`/api/publico/programas-ofertados`)
    const programas = response.data
    programa.value = programas.find(p => p.id_aca_programa_aprobado == programaId.value)

    if (!programa.value) {
      router.push('/')
    } else {
      await obtenerPlanEstudios()
    }
  } catch (error) {
    console.error('Error al obtener programa:', error)
    router.push('/')
  } finally {
    cargando.value = false
  }
}

const obtenerPlanEstudios = async () => {
  if (!programaId.value) return

  cargandoPlan.value = true
  try {
    const response = await api.get(`/api/programa-aprobado/plan-estudio/${programaId.value}`)
    planEstudios.value = response.data
  } catch (error) {
    console.error('Error al obtener plan de estudios:', error)
    planEstudios.value = []
  } finally {
    cargandoPlan.value = false
  }
}

const agruparPorNivel = (modulos) => {
  return modulos.reduce((grupos, modulo) => {
    const nivel = modulo.nivel
    if (!grupos[nivel]) {
      grupos[nivel] = []
    }
    grupos[nivel].push(modulo)
    return grupos
  }, {})
}

const abrirFormulario = () => {
  mostrarFormulario.value = true
  pasoFormulario.value = 1
}

const buscandoPersona = ref(false)
const continuarConDatos = async () => {
  $v.value.ci.$touch()

  if ($v.value.ci.$invalid) {
    return
  }

  buscandoPersona.value = true

  try {
    const response = await api.get(`/api/publico/persona/ci?ci=${formularioInscripcion.value.ci}`)

    if (response.data && Object.keys(response.data).length > 0) {
      // Poblar formulario...
      formularioInscripcion.value.nombre = response.data.nombre || ''
      formularioInscripcion.value.ap_paterno = response.data.ap_paterno || ''
      formularioInscripcion.value.ap_materno = response.data.ap_materno || ''
      formularioInscripcion.value.celular = response.data.nro_celular || ''
      formularioInscripcion.value.correo = response.data.correo || ''
      formularioInscripcion.value.fecha_nacimiento = response.data.fecha_nacimiento || ''

      $v.value.$reset()
      $v.value.ci.$touch()
    }
  } catch (error) {
    console.log('Error al buscar persona:', error)
  } finally {
    buscandoPersona.value = false
  }

  pasoFormulario.value = 2
}

const enviarInscripcion = async () => {
  // Validar todo el formulario con Vuelidate
  const esValido = await validarFormularioHelper($v.value)
  if (!esValido) return

  enviandoFormulario.value = true
  try {
    const datosInscripcion = {
      ...formularioInscripcion.value,
      id_aca_programa_aprobado: programaId.value
    }

    const response = await api.post('/api/publico/preinscripcion', datosInscripcion)
    alert('¡Preinscripción exitosa! Te contactaremos pronto.')
    mostrarFormulario.value = false
    limpiarFormulario()

  } catch (error) {
    console.error('Error en inscripción:', error)
    alert('Error en la inscripción. Por favor intenta nuevamente.')
  } finally {
    enviandoFormulario.value = false
  }
}

const limpiarFormulario = () => {
  Object.assign(formularioInscripcion.value, {
    ci: '',
    nombre: '',
    ap_paterno: '',
    ap_materno: '',
    fecha_nacimiento: '',
    celular: '',
    correo: '',
  })
  $v.value.$reset()
}

const abrirWhatsApp = () => {
  const numeroWhatsApp = '+591'
  const mensaje = `Hola, me interesa información sobre ${programa.value?.nombre_programa}`
  const url = `https://wa.me/${numeroWhatsApp}?text=${encodeURIComponent(mensaje)}`
  window.open(url, '_blank')
}

const obtenerColorEstado = (estado) => {
  const colores = {
    'INSCRIPCIONES ABIERTAS': 'success',
    'PROXIMAMENTE': 'info',
    'INSCRIPCIONES CERRADAS': 'error'
  }
  return colores[estado] || 'info'
}

onMounted(() => {
  obtenerDetallePrograma()
})
</script>

<template>
  <div class="detalle-programa">
    <!-- Loading State -->
    <div v-if="cargando" class="loading-container">
      <v-container>
        <div class="text-center py-16">
          <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
          <p class="mt-4 text-h6">Cargando información del programa...</p>
        </div>
      </v-container>
    </div>

    <!-- Programa No Encontrado -->
    <div v-else-if="!programa" class="no-programa">
      <v-container>
        <div class="text-center py-16">
          <v-icon size="64" color="grey">mdi-school-outline</v-icon>
          <h2 class="mt-4">Programa no encontrado</h2>
          <v-btn color="primary" @click="router.push('/')" class="mt-4">
            Volver al inicio
          </v-btn>
        </div>
      </v-container>
    </div>

    <!-- Contenido Principal -->
    <div v-else class="programa-content">
      <!-- Header del Programa -->
      <section class="programa-header">
        <v-container fluid class="pa-0">
          <v-row no-gutters>
            <v-col cols="12" md="8" class="d-flex align-center">
              <div class="programa-info pa-4 pa-md-8">
                <h1 class="programa-titulo text-center text-md-start">{{ programa.nombre_programa }}</h1>

                <div class="programa-meta text-center text-md-start">
                  <v-chip :color="obtenerColorEstado(programa.estado_inscripcion)" variant="elevated" class="me-2 mb-2">
                    <v-icon start>mdi-calendar-clock</v-icon>
                    {{ programa.estado_inscripcion }}
                  </v-chip>

                  <v-chip color="white" variant="outlined" class="me-2 mb-2 chip-blanco">
                    <v-icon start>mdi-domain</v-icon>
                    {{ programa.nombre_area }}
                  </v-chip>

                  <v-chip color="white" variant="outlined" class="me-2 mb-2 chip-blanco">
                    <v-icon start>mdi-laptop</v-icon>
                    {{ programa.nombre_modalidad }}
                  </v-chip>
                </div>

                <div class="programa-detalles mt-4 mt-md-6">
                  <v-row>
                    <v-col cols="6" v-if="programa.duracion">
                      <div class="detalle-item">
                        <v-icon color="white" size="20">mdi-clock-outline</v-icon>
                        <div class="ml-2 ml-md-3">
                          <div class="text-caption text-grey-lighten-2">Duración</div>
                          <div class="font-weight-bold text-white text-body-2">{{ programa.duracion }}</div>
                        </div>
                      </div>
                    </v-col>

                    <v-col cols="6" v-if="programa.carga_horaria">
                      <div class="detalle-item">
                        <v-icon color="white" size="20">mdi-book-open</v-icon>
                        <div class="ml-2 ml-md-3">
                          <div class="text-caption text-grey-lighten-2">Carga Horaria</div>
                          <div class="font-weight-bold text-white text-body-2">{{ programa.carga_horaria }} hrs</div>
                        </div>
                      </div>
                    </v-col>
                  </v-row>
                </div>

                <!-- Botones de Acción -->
                <div class="d-flex gap-4">
                  <v-btn
                    v-if="programa.estado_inscripcion === 'INSCRIPCIONES ABIERTAS'"
                    color="white"
                    size="large"
                    variant="elevated"
                    @click="abrirFormulario"
                    prepend-icon="mdi-account-plus"
                  >
                    Inscribirse Ahora
                  </v-btn>

                  <v-btn
                    color="success"
                    size="large"
                    variant="elevated"
                    @click="abrirWhatsApp"
                    prepend-icon="mdi-whatsapp"
                  >
                    Solicitar Información
                  </v-btn>
                </div>
              </div>
            </v-col>

            <v-col cols="12" md="4">
              <div class="programa-imagen-header">
                <v-img
                  :src="programa.imagen_url"
                  height="400"
                  cover
                  :alt="programa.nombre_programa"
                  class="d-none d-md-block"
                ></v-img>
                <v-img
                  :src="programa.imagen_url"
                  height="250"
                  cover
                  :alt="programa.nombre_programa"
                  class="d-md-none"
                ></v-img>
              </div>
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Información Detallada -->
      <section class="programa-info-detalle py-8">
        <v-container fluid>
          <v-row>
            <!-- Requisitos del Programa -->
            <v-col cols="12" lg="6">
              <v-card class="info-card h-100" elevation="3">
                <v-card-title class="bg-indigo-darken-2 text-white">
                  <v-icon start>mdi-clipboard-list</v-icon>
                  Requisitos del Curso
                </v-card-title>
                <v-card-text>
                  <v-list density="compact">
                    <v-list-item
                      v-for="(requisito, index) in requisitosPrograma"
                      :key="index"
                    >
                      <template #prepend>
                        <v-icon color="indigo" :icon="requisito.icono"></v-icon>
                      </template>
                      <v-list-item-title class="text-wrap">{{ requisito.texto }}</v-list-item-title>
                    </v-list-item>
                  </v-list>
                </v-card-text>
              </v-card>
            </v-col>

            <!-- Objetivo del Programa -->
            <v-col cols="12" lg="6">
              <v-card class="info-card h-100" elevation="3">
                <v-card-title class="bg-red-darken-1 text-white">
                  <v-icon start>mdi-target</v-icon>
                  Objetivo del Programa
                </v-card-title>
                <v-card-text>
                  <p class="objetivo-texto">
                    Actualizar conocimientos y habilidades en el área de secretariado para fortalecer las competencias
                    en el uso de herramientas digitales y ofimáticas, gestión documental y archivo digital, y
                    administración organizacional, con el propósito de garantizar un desempeño eficiente y eficaz en la
                    institución educativa.
                  </p>

                  <v-divider class="my-4"></v-divider>

                  <h4 class="mb-3">Competencias que desarrollarás:</h4>
                  <v-chip-group>
                    <v-chip
                      v-for="competencia in competenciasPrograma"
                      :key="competencia"
                      variant="outlined"
                      color="primary"
                      class="ma-1"
                    >
                      {{ competencia }}
                    </v-chip>
                  </v-chip-group>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>

          <!-- Módulos del Programa -->
          <v-row class="mt-4">
            <v-col cols="12">
              <v-card class="info-card" elevation="3">
                <v-card-title class="bg-orange-darken-2 text-white">
                  <v-icon start>mdi-book-multiple</v-icon>
                  Plan de Estudios
                </v-card-title>
                <v-card-text>

                  <!-- Loading del plan -->
                  <div v-if="cargandoPlan" class="text-center py-4">
                    <v-progress-circular indeterminate color="primary" size="40"></v-progress-circular>
                    <p class="mt-2">Cargando plan de estudios...</p>
                  </div>

                  <!-- Plan de estudios -->
                  <div v-else-if="planEstudios.length > 0">

                    <!-- Tabla de módulos -->
                    <v-data-table
                      :headers="headersModulos"
                      :items="planEstudios"
                      :group-by="[{ key: 'nivel', order: 'asc' }]"
                      class="elevation-1"
                      density="compact"
                      :items-per-page="-1"
                      hide-default-footer
                    >
                      <template v-slot:top>
                        <v-row class="bg-orange-lighten-5 ma-0 pa-0">
                          <v-col cols="4">
                            <div class="text-center">
                              <div class="text-h6 text-primary">{{ planEstudios.length }}</div>
                              <div class="text-caption">Módulos</div>
                            </div>
                          </v-col>
                          <v-col cols="4">
                            <div class="text-center">
                              <div class="text-h6 text-primary">{{ planEstudios.reduce((sum, m) => sum + m.carga_horaria, 0) }}</div>
                              <div class="text-caption">Horas Total</div>
                            </div>
                          </v-col>
                          <v-col cols="4">
                            <div class="text-center">
                              <div class="text-h6 text-primary">{{ planEstudios.reduce((sum, m) => sum + parseFloat(m.creditos), 0) }}</div>
                              <div class="text-caption">Créditos</div>
                            </div>
                          </v-col>
                        </v-row>
                      </template>
                      <!-- Header de grupo -->
                      <template v-slot:group-header="{ item, columns, toggleGroup, isGroupOpen }">
                        <tr class="grupo-nivel">
                          <td :colspan="columns.length" class="pa-3 bg-orange-lighten-5">
                            <v-btn
                              variant="elevated"
                              size="small"
                              color="orange-darken-2"
                              :icon="isGroupOpen(item) ? 'mdi-chevron-down' : 'mdi-chevron-right'"
                              @click="toggleGroup(item)"
                            ></v-btn>
                            <strong class="text-orange-darken-2 ml-4">
                              <v-icon class="me-1">mdi-book-open-page-variant</v-icon>
                              Nivel {{ item.value }} - ({{ planEstudios.filter(m => m.nivel === item.value).length }} módulos)
                            </strong>
                          </td>
                        </tr>
                      </template>

                      <!-- Columna de orden -->
                      <template v-slot:item.orden="{ item }">
                        {{ item.orden }}
                      </template>

                      <!-- Columna de sigla -->
                      <template v-slot:item.sigla="{ item }">
                        <v-chip size="small" color="orange" variant="elevated">
                          {{ item.sigla }}
                        </v-chip>
                      </template>

                      <!-- Columna de carga horaria -->
                      <template v-slot:item.carga_horaria="{ item }">
                        <span class="text-body-2">{{ item.carga_horaria }}h</span>
                      </template>

                      <!-- Columna de créditos -->
                      <template v-slot:item.creditos="{ item }">
                        <span class="text-body-2">{{ item.creditos }}</span>
                      </template>

                      <!-- Columna de competencia -->
                      <template v-slot:item.competencia="{ item }">
                        <div class="text-caption text-grey" style="max-width: 300px;">
                          {{ item.competencia || 'No especificada' }}
                        </div>
                      </template>
                    </v-data-table>
                  </div>

                  <!-- Sin plan de estudios -->
                  <div v-else class="text-center py-6">
                    <v-icon size="48" color="grey-lighten-1">mdi-book-outline</v-icon>
                    <p class="mt-2 text-grey">Plan de estudios no disponible</p>
                  </div>

                  <v-divider class="my-4"></v-divider>

                  <div class="text-center">
                    <h4 class="mb-3">🏆 Certificación</h4>
                    <p class="text-body-2 mb-3">
                      Al completar exitosamente el programa, recibirás un <strong>Diploma de Técnico Superior</strong>
                      avalado por la Universidad Amazónica de Pando, reconocido a nivel nacional.
                    </p>
                    <v-chip color="green" variant="elevated" prepend-icon="mdi-certificate">
                      Certificación Oficial UAP
                    </v-chip>
                  </div>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
        </v-container>
      </section>
    </div>

    <!-- Dialog de Formulario de Inscripción -->
    <v-dialog
      v-model="mostrarFormulario"
      max-width="1080"
      persistent
      scrollable
      class="mx-2"
    >
      <v-card class="formulario-inscripcion" :loading="buscandoPersona">
        <!-- Header del formulario -->
        <v-card-title class="bg-primary text-white d-flex align-center pa-3 pa-md-4">
          <v-icon start size="24" class="d-none d-md-inline">mdi-account-plus</v-icon>
          <span class="text-h6 text-md-h5 flex-grow-1 text-center text-md-start">Formulario de Inscripción Online</span>
          <v-btn
            icon
            variant="text"
            @click="mostrarFormulario = false"
            color="white"
            size="small"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-card-title>

        <!-- Información del programa en el formulario -->
        <v-card-subtitle class="pa-3 pa-md-4 bg-grey-lighten-5">
          <div class="d-flex align-center">
            <v-img
              :src="programa?.imagen_url"
              height="50"
              width="60"
              cover
              class="rounded me-3 d-none d-sm-block"
            ></v-img>
            <div class="text-center text-sm-start flex-grow-1">
              <h3 class="programa-form-titulo text-body-1 text-md-h6">{{ programa?.nombre_programa }}</h3>
              <div class="text-caption">
                <v-icon size="12" class="me-1">mdi-calendar</v-icon>
                Inscripción hasta: {{ programa?.fechaInscripcion }}
              </div>
            </div>
          </div>
        </v-card-subtitle>

        <!-- Stepper Compacto -->
        <div class="stepper-container pa-1 pa-md-2 bg-grey-lighten-5">
          <v-stepper
            v-model="pasoFormulario"
            alt-labels
            class="elevation-0"
            :mobile="$vuetify.display.mobile"
            mobile-breakpoint="sm"
          >
            <v-stepper-header class="px-2" style="min-height: 60px;">
              <v-stepper-item
                :complete="pasoFormulario > 1"
                :value="1"
                title="Verificación"
                subtitle="CI"
              >
                <template #icon>
                  <v-icon size="16">mdi-account-search</v-icon>
                </template>
              </v-stepper-item>

              <v-divider></v-divider>

              <v-stepper-item
                :value="2"
                title="Datos Personales"
                subtitle="Información"
              >
                <template #icon>
                  <v-icon size="16">mdi-account-edit</v-icon>
                </template>
              </v-stepper-item>
            </v-stepper-header>
          </v-stepper>
        </div>

        <v-card-text class="pa-3 pa-md-6">
          <!-- Paso 1: Verificación CI -->
          <div v-if="pasoFormulario === 1" class="paso-verificacion">
            <div class="text-center mb-4 mb-md-6">
              <v-icon size="40" color="primary" class="mb-3">mdi-card-account-details</v-icon>
              <h3 class="text-h6">Ingresa tu número de identidad</h3>
              <p class="text-grey text-body-2">En caso de ser usuario nuevo debe llenar sus datos solo por única vez</p>
            </div>

            <v-row justify="center">
              <v-col cols="12" sm="12" md="12">
                <v-text-field
                  v-model="formularioInscripcion.ci"
                  label="Cédula de Identidad *"
                  placeholder="Escriba su número de identidad"
                  variant="outlined"
                  density="comfortable"
                  :error-messages="obtenerErroresCampo($v.ci)"
                  prepend-inner-icon="mdi-card-account-details"
                  class="mb-4"
                  @blur="$v.ci.$touch"
                ></v-text-field>

                <div class="text-center mt-4 mt-md-6">
                  <v-btn
                    color="primary"
                    size="large"
                    variant="elevated"
                    @click="continuarConDatos"
                    prepend-icon="mdi-arrow-right"
                    :disabled="$v.ci.$invalid"
                    :loading="buscandoPersona"
                  >
                    {{ buscandoPersona ? 'Buscando...' : 'Continuar' }}
                  </v-btn>
                </div>
              </v-col>
            </v-row>
          </div>

          <!-- Paso 2: Datos Personales -->
          <div v-if="pasoFormulario === 2" class="paso-datos">
            <div class="mb-4">
              <h3 class="text-h6">Información Personal</h3>
              <p class="text-grey text-body-2">Registre y verifique su información personal</p>
            </div>

            <v-alert
              type="info"
              variant="tonal"
              class="mb-4"
              prepend-icon="mdi-information"
            >
              Por favor complete y verifique detalladamente sus datos personales
            </v-alert>

            <v-form @submit.prevent="enviarInscripcion">
              <!-- Cédula (readonly) -->
              <v-row>
                <v-col cols="12">
                  <v-text-field
                    :model-value="formularioInscripcion.ci"
                    label="Cédula de Identidad"
                    variant="outlined"
                    readonly
                    density="comfortable"
                    prepend-inner-icon="mdi-card-account-details"
                  ></v-text-field>
                </v-col>
              </v-row>

              <!-- Nombres y apellidos -->
              <v-row>

                <v-col cols="12" md="4">
                  <v-text-field
                    v-model="formularioInscripcion.nombre"
                    label="Nombre(s) *"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="obtenerErroresCampo($v.nombre)"
                    @blur="$v.nombre.$touch"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="4">
                  <v-text-field
                    v-model="formularioInscripcion.ap_paterno"
                    label="Apellido Paterno *"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="obtenerErroresCampo($v.ap_paterno)"
                    @blur="$v.ap_paterno.$touch"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="4">
                  <v-text-field
                    v-model="formularioInscripcion.ap_materno"
                    label="Apellido Materno"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="obtenerErroresCampo($v.ap_materno)"
                    @blur="$v.ap_materno.$touch"
                  ></v-text-field>
                </v-col>
              </v-row>

              <!-- fecha nacimiento y celular -->
              <v-row>
                <v-col cols="12" md="4">
                  <v-date-input
                    v-model="formularioInscripcion.fecha_nacimiento"
                    label="Fecha Nacimiento *"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="obtenerErroresCampo($v.fecha_nacimiento)"
                    :max="new Date().toISOString().split('T')[0]"
                    @blur="$v.fecha_nacimiento.$touch"
                  ></v-date-input>
                </v-col>

                <v-col cols="12" md="4">
                  <v-text-field
                    v-model="formularioInscripcion.celular"
                    label="Celular *"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="obtenerErroresCampo($v.celular)"
                    prepend-inner-icon="mdi-phone"
                    placeholder="7xxxxxxx"
                    @blur="$v.celular.$touch"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="4">
                  <v-text-field
                    v-model="formularioInscripcion.correo"
                    label="Correo Electrónico *"
                    type="email"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="obtenerErroresCampo($v.correo)"
                    prepend-inner-icon="mdi-email"
                    placeholder="usuario@ejemplo.com"
                    @blur="$v.correo.$touch"
                  ></v-text-field>
                </v-col>
              </v-row>
            </v-form>

            <!-- Información adicional -->
            <v-row>
              <v-col cols="12">
                <v-alert
                  type="info"
                  variant="tonal"
                  density="compact"
                  class="mb-2"
                >
                  <template #prepend>
                    <v-icon>mdi-information</v-icon>
                  </template>
                  <strong>Campos obligatorios:</strong> Los marcados con (*) son requeridos
                </v-alert>
              </v-col>
            </v-row>

            <!-- Botones en card-text -->
            <div class="d-flex flex-column flex-sm-row justify-end ga-2 mt-6">
              <v-btn
                variant="outlined"
                @click="pasoFormulario = 1"
                prepend-icon="mdi-arrow-left"
                class="order-2 order-sm-1"
                :disabled="enviandoFormulario"
              >
                Anterior
              </v-btn>

              <v-btn
                variant="outlined"
                @click="mostrarFormulario = false"
                class="order-3 order-sm-2"
                :disabled="enviandoFormulario"
              >
                Cancelar
              </v-btn>

              <v-btn
                color="primary"
                variant="elevated"
                @click="enviarInscripcion"
                :loading="enviandoFormulario"
                :disabled="$v.$invalid"
                prepend-icon="mdi-send"
                class="order-1 order-sm-3"
              >
                Enviar Inscripción
              </v-btn>
            </div>
          </div>

          <!-- Botones paso 1 -->
          <div v-if="pasoFormulario === 1" class="d-flex justify-center mt-4">
            <v-btn
              variant="outlined"
              @click="mostrarFormulario = false"
            >
              Cancelar
            </v-btn>
          </div>
        </v-card-text>
      </v-card>
    </v-dialog>

    <!-- Botón WhatsApp Flotante -->
    <v-btn
      fab
      color="#25D366"
      size="large"
      class="whatsapp-flotante"
      @click="abrirWhatsApp"
      elevation="8"
    >
      <v-icon size="32" color="white">mdi-whatsapp</v-icon>
    </v-btn>
  </div>
</template>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 8px;

  .v-data-table__tr:hover {
    background-color: rgba(255, 152, 0, 0.04) !important;
  }
}

.detalle-programa {
  min-height: 100vh;
  background: #f8f9fa;

  .programa-header {
    background: linear-gradient(135deg, #37474F 0%, #263238 100%);
    color: white;

    .programa-titulo {
      font-size: 2rem;
      font-weight: 700;
      line-height: 1.2;
      margin-bottom: 1rem;
      text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
      word-wrap: break-word;

      @media (min-width: 960px) {
        font-size: 2.5rem;
        margin-bottom: 1.5rem;
      }
    }

    .chip-blanco {
      border-color: rgba(255, 255, 255, 0.7);
      color: white;

      .v-icon {
        color: white;
      }
    }

    .detalle-item {
      display: flex;
      align-items: center;
      margin-bottom: 0.5rem;
    }

    .botones-accion {
      .v-btn {
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: #37474F !important;

        &:hover {
          transform: translateY(-2px);
        }
      }
    }
  }

  .info-card {
    border-radius: 12px;
    transition: transform 0.3s ease;

    &:hover {
      transform: translateY(-4px);
    }

    .objetivo-texto {
      line-height: 1.7;
      text-align: justify;
      color: #444;
    }
  }

  .formulario-inscripcion {
    border-radius: 12px;

    .programa-form-titulo {
      color: #1976D2;
      font-weight: 600;
      line-height: 1.2;
      word-wrap: break-word;
    }

    .v-alert {
      border-radius: 8px;
    }
  }

  .whatsapp-flotante {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    z-index: 1000;
    animation: pulse 2s infinite;

    &:hover {
      animation-play-state: paused;
      transform: scale(1.1);
    }
  }
}

@keyframes pulse {
  0% {
    box-shadow: 0 0 0 0 rgba(37, 211, 102, 0.7);
  }
  70% {
    box-shadow: 0 0 0 10px rgba(37, 211, 102, 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(37, 211, 102, 0);
  }
}

// Responsive
@media (max-width: 600px) {
  .formulario-inscripcion {
    .v-card-text {
      padding: 16px !important;
    }
  }
}
</style>
