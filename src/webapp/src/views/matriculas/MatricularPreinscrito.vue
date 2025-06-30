<script setup>
import { ref, computed, onMounted, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '@/services/api'

const router = useRouter()
const idProgramaAprobado = ref(1)

// Estados
const cargando = ref(false)
const matriculando = ref(false)

// Datos
const programaInfo = ref({})
const preinscripciones = ref([])
const grupos = ref([])
const parametros = ref([])

// Formulario
const formulario = reactive({
  id_ins_preinscripcion: null,
  id_ins_grupo: null,
  descuento_seleccionado: null
})

// Computed
const preinscriptoSeleccionado = computed(() =>
  preinscripciones.value.find(p => p.id_ins_preinscripcion === formulario.id_ins_preinscripcion)
)

const grupoSeleccionado = computed(() =>
  grupos.value.find(g => g.id_ins_grupo === formulario.id_ins_grupo)
)

const descuentoSeleccionado = computed(() =>
  parametros.value.find(p => p.id_parametro === formulario.descuento_seleccionado)
)

const costoMatricula = computed(() => {
  if (!programaInfo.value.precio_matricula) return 0

  let descuento = 0
  if (descuentoSeleccionado.value) {
    const porcentaje = parseFloat(descuentoSeleccionado.value.valor.replace('%', ''))
    descuento = (programaInfo.value.precio_matricula * porcentaje / 100)
  }

  return programaInfo.value.precio_matricula - descuento
})

const costoColegiatura = computed(() => {
  if (!programaInfo.value.precio_colegiatura) return 0

  let descuento = 0
  if (descuentoSeleccionado.value) {
    const porcentaje = parseFloat(descuentoSeleccionado.value.valor.replace('%', ''))
    descuento = (programaInfo.value.precio_colegiatura * porcentaje / 100)
  }

  return programaInfo.value.precio_colegiatura - descuento
})

const descuentoMatricula = computed(() => {
  if (!descuentoSeleccionado.value || !programaInfo.value.precio_matricula) return 0
  const porcentaje = parseFloat(descuentoSeleccionado.value.valor.replace('%', ''))
  return (programaInfo.value.precio_matricula * porcentaje / 100)
})

const descuentoColegiatura = computed(() => {
  if (!descuentoSeleccionado.value || !programaInfo.value.precio_colegiatura) return 0
  const porcentaje = parseFloat(descuentoSeleccionado.value.valor.replace('%', ''))
  return (programaInfo.value.precio_colegiatura * porcentaje / 100)
})

const totalDescuentos = computed(() => descuentoMatricula.value + descuentoColegiatura.value)
const costoTotal = computed(() => costoMatricula.value + costoColegiatura.value)

const puedeMatricular = computed(() =>
  formulario.id_ins_preinscripcion && formulario.id_ins_grupo
)

// Métodos
const cargarDatos = async () => {
  cargando.value = true
  try {
    const [programaRes, preinscripcionesRes, gruposRes, parametrosRes] = await Promise.all([
      api.get(`/api/programa-aprobado/vista/programas-aprobados/${idProgramaAprobado.value}`),
      api.get(`/api/preinscripcion/pendiente/${idProgramaAprobado.value}`),
      api.get(`/api/grupo/activo-por-programa/${idProgramaAprobado.value}`),
      api.get(`/api/parametro-programa/programa/${idProgramaAprobado.value}`, {
        params: { tipoDato: 'DECIMAL', soloVigentes: true }
      })
    ])

    programaInfo.value = programaRes.data
    console.log(programaInfo.value)
    preinscripciones.value = preinscripcionesRes.data.filter(p => p.estado_matriculacion === 'NO MATRICULADO')
    grupos.value = gruposRes.data
    parametros.value = parametrosRes.data.filter(p => p.nombre_param.includes('DESCUENTO'))

  } catch (error) {
    console.error('Error cargando datos:', error)
  } finally {
    cargando.value = false
  }
}

const matricular = async () => {
  if (!puedeMatricular.value) return

  matriculando.value = true
  try {
    await api.post('/api/matricula/matricular-preinscrito', {
      id_ins_preinscripcion: formulario.id_ins_preinscripcion,
      id_ins_grupo: formulario.id_ins_grupo,
      tipo_matricula: 'REGULAR',
      user_reg: 1
    })

    router.push(`/grupos/${formulario.id_ins_grupo}/estudiantes`)

  } catch (error) {
    console.error('Error matriculando:', error)
  } finally {
    matriculando.value = false
  }
}

const formatearMonto = (monto) => {
  return new Intl.NumberFormat('es-BO', {
    style: 'currency',
    currency: 'BOB'
  }).format(monto)
}

const formatearFecha = (fecha) => {
  return new Date(fecha).toLocaleDateString('es-BO')
}

const getIniciales = (nombreCompleto) => {
  const partes = nombreCompleto.split(' ')
  return `${partes[0]?.[0] || ''}${partes[1]?.[0] || ''}`.toUpperCase()
}

const calcularEdad = (fechaNacimiento) => {
  const hoy = new Date()
  const nacimiento = new Date(fechaNacimiento)
  let edad = hoy.getFullYear() - nacimiento.getFullYear()
  const mes = hoy.getMonth() - nacimiento.getMonth()
  if (mes < 0 || (mes === 0 && hoy.getDate() < nacimiento.getDate())) {
    edad--
  }
  return edad
}

onMounted(async () => {
  await cargarDatos()
})
</script>

<template>
  <v-container fluid class="pa-6">
    <!-- Header -->
    <v-card class="mb-6 elevation-2">
      <v-card-title class="bg-primary text-white pa-4">
        <v-btn
          icon="mdi-arrow-left"
          color="white"
          variant="text"
          @click="router.back()"
          class="mr-3"
        />
        <div class="flex-grow-1">
          <h2 class="text-h5 font-weight-bold">Matriculación de Estudiantes</h2>
          <div class="text-subtitle-1">Sistema de Gestión Académica</div>
        </div>
      </v-card-title>
    </v-card>

    <v-row>
      <!-- Formulario Principal -->
      <v-col cols="12" lg="8">
        <!-- Información del Programa -->
        <v-card class="mb-6">
          <v-card-title class="bg-blue-lighten-4 pa-4">
            <v-icon class="mr-2" color="blue">mdi-school</v-icon>
            Información del Programa Académico
          </v-card-title>
          <v-card-text class="pa-6">
            <v-row>
              <v-col cols="12" md="6">
                <v-text-field
                  :model-value="programaInfo.programa_nombre"
                  label="Programa académico"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="3">
                <v-text-field
                  :model-value="programaInfo.modalidad_nombre"
                  label="Modalidad"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="3">
                <v-text-field
                  :model-value="programaInfo.gestion"
                  label="Gestión"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="4">
                <v-text-field
                  :model-value="programaInfo.area_nombre"
                  label="Área de conocimiento"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="4">
                <v-text-field
                  :model-value="programaInfo.plan_anho"
                  label="Plan de estudios"
                  variant="outlined"
                  readonly
                />
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>

        <!-- Selección de Preinscrito -->
        <v-card class="mb-6">
          <v-card-title class="bg-green-lighten-4 pa-4">
            <v-icon class="mr-2" color="green">mdi-account-search</v-icon>
            Selección de Preinscrito
          </v-card-title>
          <v-card-text class="pa-6">
            <v-row>
              <v-col cols="12">
                <v-autocomplete
                  v-model="formulario.id_ins_preinscripcion"
                  :items="preinscripciones"
                  item-title="nombre_completo"
                  item-value="id_ins_preinscripcion"
                  label="Buscar y seleccionar preinscrito *"
                  variant="outlined"
                  prepend-inner-icon="mdi-magnify"
                  :loading="cargando"
                  clearable
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #prepend>
                        <v-avatar color="green" size="36">
                          {{ getIniciales(item.raw.nombre_completo) }}
                        </v-avatar>
                      </template>
                      <template #title>{{ item.raw.nombre_completo }}</template>
                      <template #subtitle>
                        CI: {{ item.raw.ci }} • {{ item.raw.edad }} años • {{ item.raw.nro_celular }}
                      </template>
                    </v-list-item>
                  </template>
                </v-autocomplete>
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>

        <!-- Datos Personales del Preinscrito -->
        <v-card class="mb-6" v-if="preinscriptoSeleccionado">
          <v-card-title class="bg-orange-lighten-4 pa-4">
            <v-icon class="mr-2" color="orange">mdi-account-details</v-icon>
            Datos Personales del Preinscrito
          </v-card-title>
          <v-card-text class="pa-6">
            <v-row>
              <v-col cols="12" md="4">
                <v-text-field
                  :model-value="preinscriptoSeleccionado.nombre"
                  label="Nombres"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="4">
                <v-text-field
                  :model-value="preinscriptoSeleccionado.ap_paterno"
                  label="Apellido paterno"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="4">
                <v-text-field
                  :model-value="preinscriptoSeleccionado.ap_materno"
                  label="Apellido materno"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="3">
                <v-text-field
                  :model-value="preinscriptoSeleccionado.ci"
                  label="Cédula de identidad"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="3">
                <v-text-field
                  :model-value="formatearFecha(preinscriptoSeleccionado.fecha_nacimiento)"
                  label="Fecha de nacimiento"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="3">
                <v-text-field
                  :model-value="preinscriptoSeleccionado.nro_celular"
                  label="Número de celular"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="3">
                <v-text-field
                  :model-value="`${preinscriptoSeleccionado.edad} años`"
                  label="Edad"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-text-field
                  :model-value="preinscriptoSeleccionado.correo"
                  label="Correo electrónico"
                  variant="outlined"
                  readonly
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-text-field
                  :model-value="formatearFecha(preinscriptoSeleccionado.fecha_preinscripcion)"
                  label="Fecha de preinscripción"
                  variant="outlined"
                  readonly
                />
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>

        <!-- Configuración de Matrícula -->
        <v-card class="mb-6">
          <v-card-title class="bg-purple-lighten-4 pa-4">
            <v-icon class="mr-2" color="purple">mdi-clipboard-edit</v-icon>
            Configuración de Matrícula
          </v-card-title>
          <v-card-text class="pa-6">
            <v-row>
              <v-col cols="12" md="6">
                <v-select
                  v-model="formulario.id_ins_grupo"
                  :items="grupos"
                  item-title="nombre_grupo"
                  item-value="id_ins_grupo"
                  label="Seleccionar grupo académico *"
                  variant="outlined"
                  prepend-inner-icon="mdi-account-group"
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #title>{{ item.raw.nombre_grupo }}</template>
                      <template #subtitle>{{ item.raw.total_matriculados }} estudiantes matriculados</template>
                    </v-list-item>
                  </template>
                </v-select>
              </v-col>
              <v-col cols="12" md="6">
                <v-text-field
                  model-value="REGULAR"
                  label="Tipo de matrícula"
                  variant="outlined"
                  prepend-inner-icon="mdi-school"
                  readonly
                />
              </v-col>
              <v-col cols="12">
                <v-select
                  v-model="formulario.descuento_seleccionado"
                  :items="parametros"
                  item-title="nombre_param"
                  item-value="id_parametro"
                  label="Aplicar descuento (opcional)"
                  variant="outlined"
                  prepend-inner-icon="mdi-percent"
                  clearable
                >
                  <template #item="{ props, item }">
                    <v-list-item v-bind="props">
                      <template #title>{{ item.raw.nombre_param }}</template>
                      <template #subtitle>Descuento del {{ item.raw.valor }}</template>
                    </v-list-item>
                  </template>
                </v-select>
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- Resumen Financiero -->
      <v-col cols="12" lg="4">
        <v-card>
          <v-card-title class="bg-success text-white pa-4">
            <v-icon class="mr-2">mdi-calculator-variant</v-icon>
            Resumen de Costos Académicos
          </v-card-title>
          <v-card-text class="pa-6">
            <!-- Matrícula -->
            <div class="mb-6">
              <h4 class="text-subtitle-1 font-weight-bold mb-3 d-flex align-center">
                <v-icon class="mr-2" color="blue">mdi-school</v-icon>
                Matrícula Semestral
              </h4>
              <div class="mb-2">
                <div class="d-flex justify-space-between mb-1">
                  <span>Precio base:</span>
                  <span class="font-weight-medium">{{ formatearMonto(programaInfo.precio_matricula) }}</span>
                </div>
                <div v-if="descuentoMatricula > 0" class="d-flex justify-space-between mb-1 text-orange">
                  <span>Descuento ({{ descuentoSeleccionado?.valor }}):</span>
                  <span class="font-weight-medium">-{{ formatearMonto(descuentoMatricula) }}</span>
                </div>
                <v-divider class="my-2" />
                <div class="d-flex justify-space-between text-h6 font-weight-bold text-success">
                  <span>Costo final:</span>
                  <span>{{ formatearMonto(costoMatricula) }}</span>
                </div>
              </div>
            </div>

            <!-- Colegiatura -->
            <div class="mb-6">
              <h4 class="text-subtitle-1 font-weight-bold mb-3 d-flex align-center">
                <v-icon class="mr-2" color="green">mdi-cash-multiple</v-icon>
                Colegiatura Completa
              </h4>
              <div class="mb-2">
                <div class="d-flex justify-space-between mb-1">
                  <span>Precio base:</span>
                  <span class="font-weight-medium">{{ formatearMonto(programaInfo.precio_colegiatura) }}</span>
                </div>
                <div v-if="descuentoColegiatura > 0" class="d-flex justify-space-between mb-1 text-orange">
                  <span>Descuento ({{ descuentoSeleccionado?.valor }}):</span>
                  <span class="font-weight-medium">-{{ formatearMonto(descuentoColegiatura) }}</span>
                </div>
                <v-divider class="my-2" />
                <div class="d-flex justify-space-between text-h6 font-weight-bold text-success">
                  <span>Costo final:</span>
                  <span>{{ formatearMonto(costoColegiatura) }}</span>
                </div>
              </div>
            </div>

            <!-- Resumen Total -->
            <v-divider class="my-4" />

            <div v-if="totalDescuentos > 0" class="mb-3">
              <div class="d-flex justify-space-between text-orange font-weight-bold">
                <span>Total descuentos aplicados:</span>
                <span>-{{ formatearMonto(totalDescuentos) }}</span>
              </div>
            </div>

            <div class="bg-success-lighten-5 pa-4 rounded mb-4">
              <div class="d-flex justify-space-between text-h5 font-weight-bold">
                <span>TOTAL A PAGAR:</span>
                <span>{{ formatearMonto(costoTotal) }}</span>
              </div>
              <div class="text-caption text-center mt-1">
                Matrícula + Colegiatura
              </div>
            </div>

            <!-- Botón Matricular -->
            <v-btn
              @click="matricular"
              :disabled="!puedeMatricular || matriculando"
              :loading="matriculando"
              color="success"
              variant="elevated"
              size="large"
              block
              class="text-h6"
            >
              <v-icon start>mdi-check-circle</v-icon>
              Confirmar Matrícula
            </v-btn>

            <div class="text-center mt-3">
              <v-chip
                :color="puedeMatricular ? 'success' : 'warning'"
                variant="flat"
                size="small"
              >
                <v-icon start>{{ puedeMatricular ? 'mdi-check' : 'mdi-alert' }}</v-icon>
                {{ puedeMatricular ? 'Datos completos' : 'Complete los campos requeridos' }}
              </v-chip>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
