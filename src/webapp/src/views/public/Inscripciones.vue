<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos.js'

const route = useRoute()
const router = useRouter()

const programa = ref(null)
const cargando = ref(false)
const mostrarFormulario = ref(false)
const pasoFormulario = ref(1)
const formularioInscripcion = ref({
  ci: '',
  expedido: 'LP',
  nombre: '',
  ap_paterno: '',
  ap_materno: '',
  genero: '',
  fecha_nacimiento: '',
  celular: '',
  correo: '',
  direccion: '',
  ciudad: ''
})

const validationErrors = ref({})
const enviandoFormulario = ref(false)

const programaId = computed(() => route.query.programa)

const requisitosPrograma = ref([
  {
    icono: 'mdi-file-document',
    texto: 'Boletas originales de depósito bancario de matrícula y cuota inicial'
  },
  {
    icono: 'mdi-camera',
    texto: '4 fotografías 4x4 fondo azul y 4 fotografías 2.5x2.5 fondo plomo'
  },
  {
    icono: 'mdi-school',
    texto: 'Hoja de Inscripción y Formulario de Matriculación debidamente llenados'
  },
  {
    icono: 'mdi-card-account-details',
    texto: 'Dos fotocopias simples de Cédula de Identidad'
  },
  {
    icono: 'mdi-certificate',
    texto: 'Fotocopia legalizada de Título Académico o en Provisión Nacional'
  },
  {
    icono: 'mdi-file-outline',
    texto: 'Hoja de vida profesional'
  }
])

const competenciasPrograma = ref([
  'Gestión Documental',
  'Herramientas Digitales',
  'Administración',
  'Archivo Digital',
  'Atención al Cliente'
])

const expedidoOpciones = [
  { value: 'LP', title: 'La Paz' },
  { value: 'CB', title: 'Cochabamba' },
  { value: 'SC', title: 'Santa Cruz' },
  { value: 'OR', title: 'Oruro' },
  { value: 'PT', title: 'Potosí' },
  { value: 'TJ', title: 'Tarija' },
  { value: 'CH', title: 'Chuquisaca' },
  { value: 'BE', title: 'Beni' },
  { value: 'PD', title: 'Pando' }
]

const generoOpciones = [
  { value: 'M', title: 'Masculino' },
  { value: 'F', title: 'Femenino' }
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
    }
  } catch (error) {
    console.error('Error al obtener programa:', error)
    router.push('/')
  } finally {
    cargando.value = false
  }
}

const abrirFormulario = () => {
  mostrarFormulario.value = true
  pasoFormulario.value = 1
}

const continuarConDatos = () => {
  if (!formularioInscripcion.value.ci) {
    validationErrors.value.ci = 'El número de cédula es requerido'
    return
  }

  pasoFormulario.value = 2
  validationErrors.value = {}
}

const enviarInscripcion = async () => {
  if (!validarFormulario()) return

  enviandoFormulario.value = true
  try {
    const datosInscripcion = {
      ...formularioInscripcion.value,
      id_aca_programa_aprobado: programaId.value
    }

    const response = await api.post('/api/publico/preinscripciones', datosInscripcion)
    alert('¡Preinscripción exitosa! Te contactaremos pronto.')
    mostrarFormulario.value = false

  } catch (error) {
    console.error('Error en inscripción:', error)
    alert('Error en la inscripción. Por favor intenta nuevamente.')
  } finally {
    enviandoFormulario.value = false
  }
}

const validarFormulario = () => {
  const errores = {}

  if (!formularioInscripcion.value.ci) errores.ci = 'Requerido'
  if (!formularioInscripcion.value.nombre) errores.nombre = 'Requerido'
  if (!formularioInscripcion.value.ap_paterno) errores.ap_paterno = 'Requerido'
  if (!formularioInscripcion.value.fecha_nacimiento) errores.fecha_nacimiento = 'Requerido'
  if (!formularioInscripcion.value.celular) errores.celular = 'Requerido'
  if (!formularioInscripcion.value.correo) errores.correo = 'Requerido'

  validationErrors.value = errores
  return Object.keys(errores).length === 0
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
                <div class="botones-accion mt-4 mt-md-6">
                  <v-btn
                    v-if="programa.estado_inscripcion === 'INSCRIPCIONES ABIERTAS'"
                    class="mb-2 d-block d-md-inline-block"
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
                    class="d-block d-md-inline-block ml-md-2"
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
                  Requisitos del Programa
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
                  Módulos del Programa
                </v-card-title>
                <v-card-text>
                  <v-alert type="info" variant="tonal" class="mb-4">
                    El programa está estructurado en módulos especializados que te permitirán desarrollar competencias específicas.
                  </v-alert>

                  <v-row>
                    <v-col cols="12" md="6">
                      <v-list density="compact">
                        <v-list-item>
                          <template #prepend>
                            <v-icon color="orange">mdi-numeric-1-circle</v-icon>
                          </template>
                          <v-list-item-title>Fundamentos de Administración</v-list-item-title>
                          <v-list-item-subtitle>Base teórica y práctica</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                          <template #prepend>
                            <v-icon color="orange">mdi-numeric-2-circle</v-icon>
                          </template>
                          <v-list-item-title>Herramientas Digitales Avanzadas</v-list-item-title>
                          <v-list-item-subtitle>Office, Google Workspace</v-list-item-subtitle>
                        </v-list-item>
                      </v-list>
                    </v-col>

                    <v-col cols="12" md="6">
                      <v-list density="compact">
                        <v-list-item>
                          <template #prepend>
                            <v-icon color="orange">mdi-numeric-3-circle</v-icon>
                          </template>
                          <v-list-item-title>Gestión Documental Digital</v-list-item-title>
                          <v-list-item-subtitle>Archivo y organización</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                          <template #prepend>
                            <v-icon color="orange">mdi-numeric-4-circle</v-icon>
                          </template>
                          <v-list-item-title>Atención y Servicio al Cliente</v-list-item-title>
                          <v-list-item-subtitle>Comunicación efectiva</v-list-item-subtitle>
                        </v-list-item>
                      </v-list>
                    </v-col>
                  </v-row>

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
      max-width="800"
      persistent
      scrollable
      class="mx-2"
    >
      <v-card class="formulario-inscripcion">
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
              <v-col cols="12" sm="10" md="8">
                <v-text-field
                  v-model="formularioInscripcion.ci"
                  label="Cédula de Identidad"
                  placeholder="Escriba su número de identidad"
                  variant="outlined"
                  density="comfortable"
                  :error-messages="validationErrors.ci"
                  prepend-inner-icon="mdi-card-account-details"
                  class="mb-4"
                ></v-text-field>

                <v-select
                  v-model="formularioInscripcion.expedido"
                  :items="expedidoOpciones"
                  label="Expedido en"
                  variant="outlined"
                  density="comfortable"
                  prepend-inner-icon="mdi-map-marker"
                ></v-select>

                <div class="text-center mt-4 mt-md-6">
                  <v-btn
                    color="primary"
                    size="large"
                    variant="elevated"
                    @click="continuarConDatos"
                    prepend-icon="mdi-arrow-right"
                    :disabled="!formularioInscripcion.ci"
                  >
                    Continuar
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

            <v-form>
              <!-- Cédula (readonly) -->
              <v-row>
                <v-col cols="12" md="8">
                  <v-text-field
                    :model-value="`${formularioInscripcion.ci} ${formularioInscripcion.expedido}`"
                    label="Cédula de Identidad"
                    variant="outlined"
                    readonly
                    density="comfortable"
                    prepend-inner-icon="mdi-card-account-details"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="4">
                  <v-select
                    v-model="formularioInscripcion.expedido"
                    :items="expedidoOpciones"
                    label="Expedido en"
                    variant="outlined"
                    density="comfortable"
                  ></v-select>
                </v-col>
              </v-row>

              <!-- Nombres y apellidos -->
              <v-row>
                <v-col cols="12" md="4">
                  <v-text-field
                    v-model="formularioInscripcion.ap_paterno"
                    label="Apellido Paterno *"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="validationErrors.ap_paterno"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="4">
                  <v-text-field
                    v-model="formularioInscripcion.ap_materno"
                    label="Apellido Materno"
                    variant="outlined"
                    density="comfortable"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="4">
                  <v-text-field
                    v-model="formularioInscripcion.nombre"
                    label="Nombre(s) *"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="validationErrors.nombre"
                  ></v-text-field>
                </v-col>
              </v-row>

              <!-- Género, fecha nacimiento y celular -->
              <v-row>
                <v-col cols="12" md="4">
                  <v-select
                    v-model="formularioInscripcion.genero"
                    :items="generoOpciones"
                    label="Género *"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="validationErrors.genero"
                  ></v-select>
                </v-col>

                <v-col cols="12" md="4">
                  <v-date-input
                    v-model="formularioInscripcion.fecha_nacimiento"
                    label="Fecha Nacimiento *"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="validationErrors.fecha_nacimiento"
                  ></v-date-input>
                </v-col>

                <v-col cols="12" md="4">
                  <v-text-field
                    v-model="formularioInscripcion.celular"
                    label="Celular *"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="validationErrors.celular"
                    prepend-inner-icon="mdi-phone"
                  ></v-text-field>
                </v-col>
              </v-row>

              <!-- Correo -->
              <v-row>
                <v-col cols="12">
                  <v-text-field
                    v-model="formularioInscripcion.correo"
                    label="Correo Electrónico *"
                    type="email"
                    variant="outlined"
                    density="comfortable"
                    :error-messages="validationErrors.correo"
                    prepend-inner-icon="mdi-email"
                  ></v-text-field>
                </v-col>
              </v-row>

              <!-- Dirección y ciudad -->
              <v-row>
                <v-col cols="12" md="8">
                  <v-text-field
                    v-model="formularioInscripcion.direccion"
                    label="Dirección donde vive"
                    variant="outlined"
                    density="comfortable"
                    prepend-inner-icon="mdi-map-marker"
                  ></v-text-field>
                </v-col>

                <v-col cols="12" md="4">
                  <v-text-field
                    v-model="formularioInscripcion.ciudad"
                    label="Ciudad donde vive"
                    variant="outlined"
                    density="comfortable"
                  ></v-text-field>
                </v-col>
              </v-row>
            </v-form>

            <!-- Botones en card-text -->
            <div class="d-flex flex-column flex-sm-row justify-end ga-2 mt-6">
              <v-btn
                variant="outlined"
                @click="pasoFormulario = 1"
                prepend-icon="mdi-arrow-left"
                class="order-2 order-sm-1"
              >
                Anterior
              </v-btn>

              <v-btn
                variant="outlined"
                @click="mostrarFormulario = false"
                class="order-3 order-sm-2"
              >
                Cancelar
              </v-btn>

              <v-btn
                color="primary"
                variant="elevated"
                @click="enviarInscripcion"
                :loading="enviandoFormulario"
                prepend-icon="mdi-send"
                class="order-1 order-sm-3"
              >
                Enviar
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
</style>
