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
import {showRegistrado, showError, showCargando, cerrarCargando} from "@/utils/sweetalert.js";

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

const obtenerDetallePrograma = async () => {
  if (!programaId.value) {
    router.push('/')
    return
  }

  cargando.value = true
  try {
    const response = await api.get(`/api/publico/programas-ofertados`)
    const programas = response.data
    programa.value = programas.find(p => p.id_aca_programa_aprobado == programaId.value)

    if (programa.value) {
      await obtenerPlanEstudios()
    }
  } catch (error) {
    console.error('Error al obtener programa:', error)
    programa.value = null
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
  const esValido = await validarFormularioHelper($v.value)
  if (!esValido) return

  // Mostrar indicador de carga
  showCargando('Enviando preinscripción...', 'Por favor espere')

  try {
    const datosInscripcion = {
      ...formularioInscripcion.value,
      id_aca_programa_aprobado: programaId.value
    }

    const response = await api.post('/api/publico/preinscripcion', datosInscripcion)
    cerrarCargando()
    await showRegistrado('¡Preinscripción exitosa!', ' Te contactaremos pronto.');
    mostrarFormulario.value = false
    limpiarFormulario()

  } catch (error) {
    cerrarCargando()
    console.error('Error en inscripción:', error)
    await showError(error.response?.data?.message || 'No se pudo completar la preinscripción')
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
  <div class="programa-page">
    <!-- Overlay de carga -->
    <v-overlay
      :model-value="cargando"
      class="align-center justify-center"
      persistent
      z-index="2000"
    >
      <v-progress-circular
        color="primary"
        size="64"
        indeterminate
      ></v-progress-circular>
    </v-overlay>

    <!-- Programa No Encontrado -->
    <div v-if="!cargando && !programa" class="no-programa">
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
    <div v-if="!cargando && programa" class="programa-content">
      <!-- Breadcrumb -->
      <v-container class="py-3">
        <v-breadcrumbs
          :items="[
            { title: 'Inicio', to: '/', disabled: false },
            { title: 'Programas', disabled: true },
            { title: programa.nombre_programa, disabled: true }
          ]"
          density="compact"
          class="px-0"
        >
          <template #divider>
            <v-icon>mdi-chevron-right</v-icon>
          </template>
        </v-breadcrumbs>
      </v-container>

      <v-container class="programa-container">
        <v-row>
          <!-- Contenido Principal -->
          <v-col cols="12" lg="8" class="main-content">
            <!-- Título del programa (mobile/tablet) -->
            <h1 class="programa-titulo mb-4 d-lg-none">{{ programa.nombre_programa }}</h1>

            <!-- Competencias -->
            <v-card class="mb-4" elevation="0" variant="outlined">
              <v-card-title class="text-h6 font-weight-bold pa-4">
                <v-icon start color="primary">mdi-lightbulb-on</v-icon>
                ¿Qué aprenderás?
              </v-card-title>
              <v-card-text class="pa-4">
                <v-chip-group column>
                  <v-chip
                    v-for="competencia in competenciasPrograma"
                    :key="competencia"
                    variant="tonal"
                    color="primary"
                    prepend-icon="mdi-check-circle"
                  >
                    {{ competencia }}
                  </v-chip>
                </v-chip-group>
              </v-card-text>
            </v-card>

            <!-- Objetivo -->
            <v-card class="mb-4" elevation="0" variant="outlined">
              <v-card-title class="text-h6 font-weight-bold pa-4">
                <v-icon start color="primary">mdi-target</v-icon>
                Objetivo del Programa
              </v-card-title>
              <v-card-text class="pa-4">
                <p class="text-body-1 mb-0">
                  Actualizar conocimientos y habilidades en el área de secretariado para fortalecer las competencias
                  en el uso de herramientas digitales y ofimáticas, gestión documental y archivo digital, y
                  administración organizacional, con el propósito de garantizar un desempeño eficiente y eficaz en la
                  institución educativa.
                </p>
              </v-card-text>
            </v-card>

            <!-- Plan de Estudios -->
            <v-card class="mb-4" elevation="0" variant="outlined">
              <v-card-title class="text-h6 font-weight-bold pa-4">
                <v-icon start color="primary">mdi-book-multiple</v-icon>
                Plan de Estudios
              </v-card-title>
              <v-card-text class="pa-4">
                <!-- Estadísticas inline -->
                <div v-if="planEstudios.length > 0" class="d-flex flex-wrap ga-4 mb-4">
                  <div class="stat-inline">
                    <span class="text-h6 font-weight-bold text-primary">{{ planEstudios.length }}</span>
                    <span class="text-caption text-grey-darken-1 ml-1">Módulos</span>
                  </div>
                  <v-divider vertical></v-divider>
                  <div class="stat-inline">
                    <span class="text-h6 font-weight-bold text-primary">{{ planEstudios.reduce((sum, m) => sum + m.carga_horaria, 0) }}</span>
                    <span class="text-caption text-grey-darken-1 ml-1">Horas</span>
                  </div>
                  <v-divider vertical></v-divider>
                  <div class="stat-inline">
                    <span class="text-h6 font-weight-bold text-primary">{{ planEstudios.reduce((sum, m) => sum + parseFloat(m.creditos), 0) }}</span>
                    <span class="text-caption text-grey-darken-1 ml-1">Créditos</span>
                  </div>
                </div>

                <!-- Loading del plan -->
                <div v-if="cargandoPlan" class="text-center py-8">
                  <v-progress-circular indeterminate color="primary" size="40"></v-progress-circular>
                  <p class="mt-2">Cargando plan de estudios...</p>
                </div>

                <!-- Acordeones por nivel -->
                <v-expansion-panels v-else-if="planEstudios.length > 0" variant="accordion" class="plan-expansion" multiple>
                  <v-expansion-panel
                    v-for="nivel in [...new Set(planEstudios.map(m => m.nivel))].sort()"
                    :key="nivel"
                    elevation="0"
                  >
                    <v-expansion-panel-title class="nivel-header">
                      <div class="d-flex align-center">
                        <v-icon class="me-2" size="20">mdi-book-open-variant</v-icon>
                        <span class="font-weight-medium">Nivel {{ nivel }}</span>
                        <v-chip size="small" variant="text" color="primary" class="ml-2">
                          {{ planEstudios.filter(m => m.nivel === nivel).length }} módulos
                        </v-chip>
                      </div>
                    </v-expansion-panel-title>

                    <v-expansion-panel-text>
                      <div class="modulos-table">
                        <div
                          v-for="modulo in planEstudios.filter(m => m.nivel === nivel)"
                          :key="modulo.sigla"
                          class="modulo-row"
                        >
                          <div class="modulo-info">
                            <span class="modulo-sigla">{{ modulo.sigla }}</span>
                            <span class="modulo-nombre">{{ modulo.nombre_modulo }}</span>
                          </div>
                          <div class="modulo-stats">
                            <span class="stat-item">{{ modulo.carga_horaria }}h</span>
                            <span class="stat-divider">|</span>
                            <span class="stat-item">{{ modulo.creditos }} créditos</span>
                          </div>
                        </div>
                      </div>
                    </v-expansion-panel-text>
                  </v-expansion-panel>
                </v-expansion-panels>

                <!-- Sin plan -->
                <div v-else class="text-center py-8">
                  <v-icon size="48" color="grey-lighten-1">mdi-book-outline</v-icon>
                  <p class="mt-2 text-grey">Plan de estudios no disponible</p>
                </div>
              </v-card-text>
            </v-card>

            <!-- Requisitos -->
            <v-card class="mb-4" elevation="0" variant="outlined">
              <v-card-title class="text-h6 font-weight-bold pa-4">
                <v-icon start color="primary">mdi-clipboard-list</v-icon>
                Requisitos
              </v-card-title>
              <v-card-text class="pa-4">
                <v-list density="compact" class="requisitos-list">
                  <v-list-item
                    v-for="(requisito, index) in requisitosPrograma"
                    :key="index"
                  >
                    <template #prepend>
                      <v-icon color="success" size="20">mdi-check-circle</v-icon>
                    </template>
                    <v-list-item-title>{{ requisito.texto }}</v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-card-text>
            </v-card>

            <!-- Certificación -->
            <v-card class="mb-4" elevation="0" variant="outlined">
              <v-card-title class="text-h6 font-weight-bold pa-4">
                <v-icon start color="success">mdi-certificate</v-icon>
                Certificación
              </v-card-title>
              <v-card-text class="pa-4">
                <div class="text-center pa-4">
                  <v-icon size="64" color="success" class="mb-3">mdi-seal</v-icon>
                  <h4 class="text-h6 font-weight-bold mb-2">Diploma de Técnico Superior</h4>
                  <p class="text-body-2 mb-3">
                    Avalado por la Universidad Amazónica de Pando, con reconocimiento a nivel nacional.
                  </p>
                  <v-chip color="success" variant="elevated" prepend-icon="mdi-certificate">
                    Certificación Oficial UAP
                  </v-chip>
                </div>
              </v-card-text>
            </v-card>
          </v-col>

          <!-- Sidebar Sticky -->
          <v-col cols="12" lg="4" class="sidebar-container">
            <div class="sidebar-sticky">
              <v-card class="programa-card" elevation="2">
                <!-- Imagen -->
                <v-img
                  :src="programa.imagen_url"
                  height="250"
                  cover
                  :alt="programa.nombre_programa"
                  class="programa-img"
                ></v-img>

                <v-card-text class="pa-4">
                  <!-- Título (solo desktop) -->
                  <h2 class="text-h5 font-weight-bold mb-3 d-none d-lg-block">{{ programa.nombre_programa }}</h2>

                  <!-- Info del programa -->
                  <div class="programa-meta mb-4">
                    <!-- Estado -->
                    <div class="meta-item mb-2">
                      <v-chip
                        :color="obtenerColorEstado(programa.estado_inscripcion)"
                        variant="flat"
                        size="small"
                        class="mb-2"
                      >
                        <v-icon start size="16">mdi-calendar-clock</v-icon>
                        {{ programa.estado_inscripcion }}
                      </v-chip>
                    </div>

                    <!-- Área -->
                    <div class="meta-item d-flex align-center mb-2">
                      <v-icon size="18" color="grey-darken-1" class="mr-2">mdi-domain</v-icon>
                      <span class="text-body-2">{{ programa.nombre_area }}</span>
                    </div>

                    <!-- Modalidad -->
                    <div class="meta-item d-flex align-center mb-2">
                      <v-icon size="18" color="grey-darken-1" class="mr-2">mdi-laptop</v-icon>
                      <span class="text-body-2">{{ programa.nombre_modalidad }}</span>
                    </div>

                    <!-- Duración -->
                    <div v-if="programa.duracion" class="meta-item d-flex align-center mb-2">
                      <v-icon size="18" color="grey-darken-1" class="mr-2">mdi-clock-outline</v-icon>
                      <span class="text-body-2">{{ programa.duracion }}</span>
                    </div>

                    <!-- Carga horaria -->
                    <div v-if="programa.carga_horaria" class="meta-item d-flex align-center mb-2">
                      <v-icon size="18" color="grey-darken-1" class="mr-2">mdi-book-open</v-icon>
                      <span class="text-body-2">{{ programa.carga_horaria }} horas</span>
                    </div>
                  </div>

                  <v-divider class="my-4"></v-divider>

                  <!-- CTAs -->
                  <div class="cta-buttons">
                    <v-btn
                      v-if="programa.estado_inscripcion === 'INSCRIPCIONES ABIERTAS'"
                      color="primary"
                      size="large"
                      variant="elevated"
                      block
                      @click="abrirFormulario"
                      prepend-icon="mdi-account-plus"
                      class="mb-3"
                    >
                      Preinscríbete Ahora
                    </v-btn>

                    <v-btn
                      color="success"
                      size="large"
                      variant="outlined"
                      block
                      @click="abrirWhatsApp"
                      prepend-icon="mdi-whatsapp"
                    >
                      Solicitar Información
                    </v-btn>
                  </div>
                </v-card-text>
              </v-card>
            </div>
          </v-col>
        </v-row>
      </v-container>

    </div>

    <!-- Dialog de Formulario de Inscripción -->
    <v-dialog
      v-model="mostrarFormulario"
      max-width="900"
      persistent
      scrollable
      class="mx-2"
    >
      <v-card class="formulario-inscripcion" :loading="buscandoPersona">
        <!-- Header Compacto -->
        <v-card-title class="bg-primary text-white d-flex align-center pa-3">
          <v-icon start size="20">mdi-account-plus</v-icon>
          <span class="text-subtitle-1 text-md-h6 flex-grow-1">Preinscripción - {{ programa?.nombre_programa }}</span>
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

        <!-- Tabs Compactos -->
        <v-tabs
          v-model="pasoFormulario"
          bg-color="grey-lighten-4"
          color="primary"
          align-tabs="center"
          density="compact"
          class="stepper-tabs"
        >
          <v-tab :value="1" :disabled="pasoFormulario !== 1">
            <v-icon start size="18">mdi-card-account-details</v-icon>
            Verificar CI
          </v-tab>
          <v-tab :value="2" :disabled="pasoFormulario !== 2">
            <v-icon start size="18">mdi-account-edit</v-icon>
            Datos Personales
          </v-tab>
        </v-tabs>

        <!-- Contenido del formulario con transiciones -->
        <v-window v-model="pasoFormulario" class="formulario-window">
          <!-- Paso 1: Verificación CI -->
          <v-window-item :value="1">
            <v-card-text class="pa-4 pa-md-6">
              <div class="text-center mb-4">
                <v-icon size="48" color="primary" class="mb-2">mdi-card-account-details</v-icon>
                <h3 class="text-h6 mb-2">Ingresa tu Cédula de Identidad</h3>
                <p class="text-grey text-body-2">
                  Si eres usuario nuevo, deberás llenar tus datos solo por única vez
                </p>
              </div>

              <v-row justify="center">
                <v-col cols="12" md="10">
                  <v-text-field
                    v-model="formularioInscripcion.ci"
                    label="Cédula de Identidad *"
                    placeholder="Ej: 1234567"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="obtenerErroresCampo($v.ci)"
                    prepend-inner-icon="mdi-card-account-details"
                    @blur="$v.ci.$touch"
                    @keyup.enter="continuarConDatos"
                    autofocus
                  ></v-text-field>
                </v-col>
              </v-row>

              <div class="d-flex justify-center ga-2 mt-4">
                <v-btn
                  variant="outlined"
                  @click="mostrarFormulario = false"
                  :disabled="buscandoPersona"
                >
                  Cancelar
                </v-btn>
                <v-btn
                  color="primary"
                  size="large"
                  variant="elevated"
                  @click="continuarConDatos"
                  append-icon="mdi-arrow-right"
                  :disabled="$v.ci.$invalid"
                  :loading="buscandoPersona"
                >
                  Continuar
                </v-btn>
              </div>
            </v-card-text>
          </v-window-item>

          <!-- Paso 2: Datos Personales -->
          <v-window-item :value="2">
            <v-card-text class="pa-4 pa-md-6">
              <div class="mb-4">
                <h3 class="text-h6 mb-1">Información Personal</h3>
                <p class="text-grey text-body-2">
                  Complete y verifique sus datos personales
                </p>
              </div>

              <v-form @submit.prevent="enviarInscripcion">
                <!-- Cédula (readonly) -->
                <v-row dense>
                  <v-col cols="12">
                    <v-text-field
                      :model-value="formularioInscripcion.ci"
                      label="Cédula de Identidad"
                      variant="outlined"
                      readonly
                      density="comfortable"
                      prepend-inner-icon="mdi-card-account-details"
                      bg-color="grey-lighten-3"
                    ></v-text-field>
                  </v-col>
                </v-row>

                <!-- Nombres y apellidos -->
                <v-row dense>
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

                <!-- Fecha nacimiento y contacto -->
                <v-row dense>
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

              <!-- Info adicional -->
              <v-alert
                type="info"
                variant="tonal"
                density="compact"
                class="mt-4"
              >
                <span class="text-body-2">
                  <strong>Nota:</strong> Los campos marcados con (*) son obligatorios
                </span>
              </v-alert>

              <!-- Botones de acción -->
              <div class="d-flex justify-space-between mt-6">
                <v-btn
                  variant="outlined"
                  @click="pasoFormulario = 1"
                  prepend-icon="mdi-arrow-left"
                  :disabled="enviandoFormulario"
                >
                  Anterior
                </v-btn>

                <div class="d-flex ga-2">
                  <v-btn
                    variant="outlined"
                    @click="mostrarFormulario = false"
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
                    append-icon="mdi-send"
                  >
                    Enviar Preinscripción
                  </v-btn>
                </div>
              </div>
            </v-card-text>
          </v-window-item>
        </v-window>
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
.programa-page {
  min-height: 100vh;
  background: #f5f7fa;

  .programa-content {
    background: #f5f7fa;
  }

  .programa-container {
    max-width: 1280px;
  }

  .programa-titulo {
    font-size: 1.75rem;
    font-weight: 700;
    line-height: 1.3;
    color: #1a1a1a;

    @media (min-width: 600px) {
      font-size: 2rem;
    }
  }

  // Contenido principal
  .main-content {
    :deep(.v-card) {
      border-radius: 8px;
      border: 1px solid #e0e0e0;
    }

    :deep(.v-card-title) {
      background: transparent !important;
      color: #1a1a1a !important;
    }
  }

  // Estadísticas inline
  .stat-inline {
    display: flex;
    align-items: baseline;
  }

  // Plan de estudios
  .plan-expansion {
    :deep(.v-expansion-panel) {
      margin-bottom: 8px;
      border: 1px solid #e0e0e0;
      border-radius: 4px !important;

      &:before {
        box-shadow: none;
      }
    }

    :deep(.v-expansion-panel-title) {
      min-height: 48px;
      padding: 12px 16px;
      font-size: 0.95rem;

      &:hover {
        background-color: rgba(var(--v-theme-primary), 0.04);
      }
    }

    :deep(.v-expansion-panel-text__wrapper) {
      padding: 0;
    }
  }

  // Tabla de módulos
  .modulos-table {
    .modulo-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px 16px;
      border-bottom: 1px solid #f0f0f0;
      transition: background-color 0.2s;

      &:last-child {
        border-bottom: none;
      }

      &:hover {
        background-color: #f9f9f9;
      }

      .modulo-info {
        flex: 1;
        display: flex;
        align-items: center;
        gap: 12px;

        .modulo-sigla {
          font-weight: 600;
          color: rgb(var(--v-theme-primary));
          min-width: 60px;
          font-size: 0.85rem;
        }

        .modulo-nombre {
          font-size: 0.9rem;
          color: #1a1a1a;
        }
      }

      .modulo-stats {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 0.85rem;
        color: #666;
        white-space: nowrap;

        .stat-divider {
          color: #ccc;
        }
      }
    }
  }

  // Lista de requisitos
  .requisitos-list {
    background: transparent;

    :deep(.v-list-item) {
      padding: 8px 0;

      &:hover {
        background: transparent;
      }
    }
  }

  // Sidebar sticky
  .sidebar-container {
    @media (min-width: 1280px) {
      .sidebar-sticky {
        position: sticky;
        top: 24px;
      }
    }
  }

  .programa-card {
    border-radius: 8px;

    .programa-img {
      border-radius: 8px 8px 0 0;
    }

    .programa-meta {
      .meta-item {
        font-size: 0.9rem;
        line-height: 1.6;
      }
    }

    .cta-buttons {
      :deep(.v-btn) {
        font-weight: 600;
        text-transform: none;
        letter-spacing: 0.25px;
      }
    }
  }

  .formulario-inscripcion {
    border-radius: 12px;
    overflow: hidden;

    .stepper-tabs {
      border-bottom: 1px solid rgba(0, 0, 0, 0.12);

      :deep(.v-tab) {
        text-transform: none;
        font-weight: 500;
        letter-spacing: 0;
        min-width: 140px;

        &.v-tab--selected {
          color: rgb(var(--v-theme-primary));
          font-weight: 600;
        }

        &:disabled {
          opacity: 0.5;
        }
      }
    }

    .formulario-window {
      min-height: 400px;

      :deep(.v-window__container) {
        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      }
    }

    .v-alert {
      border-radius: 8px;
    }

    .v-row.dense {
      > .v-col {
        padding-top: 8px;
        padding-bottom: 8px;
      }
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
