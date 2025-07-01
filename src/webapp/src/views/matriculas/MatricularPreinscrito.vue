<script setup>
import { ref, computed, onMounted, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { api } from '@/services/api'
import { showRegistrado } from "@/utils/sweetalert.js"

const router = useRouter()
const route = useRoute()
const idProgramaAprobado = computed(() => parseInt(route.query.programa))

// Estados
const cargando = ref(false)
const matriculando = ref(false)
const currentStep = ref(1)

// Datos
const programaInfo = ref({})
const preinscripciones = ref([])
const grupos = ref([])
const parametros = ref([])
const conceptosPago = ref([])
const cargandoConceptos = ref(false)

// Formulario
const formulario = reactive({
  id_ins_preinscripcion: null,
  id_ins_grupo: null,
  descuento_seleccionado: null
})

// Conceptos que permiten descuento (matrícula y colegiatura)
const CONCEPTOS_CON_DESCUENTO = [1, 2] // Ajustar según tus IDs reales
const CONCEPTOS_GRATUITOS = [3] // Certificado gratuito para regulares

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

const step1Complete = computed(() =>
  formulario.id_ins_preinscripcion && formulario.id_ins_grupo
)

const conceptosConDescuento = computed(() => {
  if (!conceptosPago.value.length) return []

  return conceptosPago.value.map(concepto => {
    const esGratuito = CONCEPTOS_GRATUITOS.includes(concepto.id_fin_concepto_pago)
    const permiteDescuento = CONCEPTOS_CON_DESCUENTO.includes(concepto.id_fin_concepto_pago)

    let montoFinal = concepto.monto_aplicar
    let descuentoAplicado = 0
    let observacion = ''

    if (esGratuito) {
      // Certificado es gratuito para estudiantes regulares
      montoFinal = 0
      observacion = 'Primera impresión gratuita - Estudiante Regular'
    } else if (permiteDescuento && descuentoSeleccionado.value) {
      // Solo aplicar descuento a matrícula/colegiatura
      const porcentaje = parseFloat(descuentoSeleccionado.value.valor.replace('%', ''))
      descuentoAplicado = (concepto.monto_aplicar * porcentaje / 100)
      montoFinal = concepto.monto_aplicar - descuentoAplicado
      observacion = `Descuento aplicado: ${descuentoSeleccionado.value.nombre_param}`
    }

    return {
      ...concepto,
      monto_original: concepto.monto_aplicar,
      descuento_aplicado: descuentoAplicado,
      monto_final: montoFinal,
      es_gratuito: esGratuito,
      permite_descuento: permiteDescuento,
      observacion
    }
  })
})

const totalOriginal = computed(() =>
  conceptosPago.value
    .filter(c => !CONCEPTOS_GRATUITOS.includes(c.id_fin_concepto_pago))
    .reduce((sum, c) => sum + c.monto_aplicar, 0)
)

const totalDescuentos = computed(() =>
  conceptosConDescuento.value
    .filter(c => !c.es_gratuito)
    .reduce((sum, c) => sum + c.descuento_aplicado, 0)
)

const totalFinal = computed(() =>
  conceptosConDescuento.value
    .filter(c => !c.es_gratuito)
    .reduce((sum, c) => sum + c.monto_final, 0)
)

const totalGratuitos = computed(() =>
  conceptosConDescuento.value
    .filter(c => c.es_gratuito)
    .reduce((sum, c) => sum + c.monto_original, 0)
)

// Cargar conceptos cuando cambie el programa
const cargarConceptosPago = async () => {
  if (!idProgramaAprobado.value) return

  cargandoConceptos.value = true
  try {
    const response = await api.get(`/api/concepto-pago/programa-aprobado/${idProgramaAprobado.value}`)
    conceptosPago.value = response.data
  } catch (error) {
    console.error('Error cargando conceptos:', error)
  } finally {
    cargandoConceptos.value = false
  }
}

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
    preinscripciones.value = preinscripcionesRes.data.filter(p => p.estado_matriculacion === 'NO MATRICULADO')
    grupos.value = gruposRes.data
    parametros.value = parametrosRes.data.filter(p => p.nombre_param.includes('DESCUENTO'))

    await cargarConceptosPago()

  } catch (error) {
    console.error('Error cargando datos:', error)
  } finally {
    cargando.value = false
  }
}

const matricular = async () => {
  if (!step1Complete.value) return

  matriculando.value = true
  try {
    const payload = {
      id_ins_preinscripcion: formulario.id_ins_preinscripcion,
      id_ins_grupo: formulario.id_ins_grupo
    }

    // Solo enviar descuento si está seleccionado
    if (formulario.descuento_seleccionado) {
      payload.id_parametro_descuento = formulario.descuento_seleccionado
    }

    await api.post('/api/matricula/matricular-preinscrito', payload)

    showRegistrado('Estudiante matriculado exitosamente', '¡Matrícula Completada!')
    router.push(`/matriculas?grupo=${formulario.id_ins_grupo}`)

  } catch (error) {
    console.error('Error matriculando:', error)
  } finally {
    matriculando.value = false
  }
}

const nextStep = () => {
  if (currentStep.value < 2) currentStep.value++
}

const prevStep = () => {
  if (currentStep.value > 1) currentStep.value--
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

const getConceptoColor = (concepto) => {
  if (concepto.es_gratuito) return 'success'
  if (concepto.descuento_aplicado > 0) return 'orange'
  return 'primary'
}

const getConceptoIcon = (concepto) => {
  if (concepto.es_gratuito) return 'mdi-gift'
  if (concepto.descuento_aplicado > 0) return 'mdi-percent'
  return 'mdi-currency-usd'
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

    <!-- Stepper -->
    <v-card class="mb-6">
      <v-stepper v-model="currentStep" alt-labels>
        <v-stepper-header>
          <v-stepper-item
            :value="1"
            title="Información Académica"
            subtitle="Programa, estudiante y grupo"
          >
            <template #icon>
              <v-icon>mdi-school</v-icon>
            </template>
          </v-stepper-item>

          <v-divider />

          <v-stepper-item
            :value="2"
            title="Información Económica"
            subtitle="Costos y descuentos"
          >
            <template #icon>
              <v-icon>mdi-currency-usd</v-icon>
            </template>
          </v-stepper-item>
        </v-stepper-header>

        <v-stepper-window>
          <!-- STEP 1: Información Académica -->
          <v-stepper-window-item :value="1">
            <v-container>
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
                        :model-value="programaInfo.plan_anho"
                        label="Plan de estudios"
                        variant="outlined"
                        readonly
                      />
                    </v-col>
                    <v-col cols="12" md="3">
                      <v-text-field
                        :model-value="programaInfo.cod_version"
                        label="Versión"
                        variant="outlined"
                        readonly
                      />
                    </v-col>
                    <v-col cols="12" md="6">
                      <v-text-field
                        :model-value="programaInfo.modalidad_nombre"
                        label="Modalidad"
                        variant="outlined"
                        readonly
                      />
                    </v-col>
                    <v-col cols="12" md="6">
                      <v-text-field
                        :model-value="programaInfo.gestion"
                        label="Gestión"
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

                  <!-- Datos Personales del Preinscrito -->
                  <div v-if="preinscriptoSeleccionado">
                    <v-divider class="my-4" />
                    <h4 class="text-subtitle-1 font-weight-bold mb-3 d-flex align-center">
                      <v-icon class="mr-2" color="orange">mdi-account-details</v-icon>
                      Datos Personales del Preinscrito
                    </h4>
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
                  </div>
                </v-card-text>
              </v-card>

              <!-- Selección de Grupo -->
              <v-card class="mb-6">
                <v-card-title class="bg-purple-lighten-4 pa-4">
                  <v-icon class="mr-2" color="purple">mdi-account-group</v-icon>
                  Asignación de Grupo Académico
                </v-card-title>
                <v-card-text class="pa-6">
                  <v-row>
                    <v-col cols="12">
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
                  </v-row>
                </v-card-text>
              </v-card>

              <!-- Botones de navegación -->
              <div class="d-flex justify-end">
                <v-btn
                  @click="nextStep"
                  :disabled="!step1Complete"
                  color="primary"
                  variant="elevated"
                >
                  Continuar
                  <v-icon end>mdi-arrow-right</v-icon>
                </v-btn>
              </div>
            </v-container>
          </v-stepper-window-item>

          <!-- STEP 2: Información Económica -->
          <v-stepper-window-item :value="2">
            <v-container>
              <v-row>
                <v-col cols="12" lg="8">
                  <!-- Selección de Descuento y Previsualización -->
                  <v-card class="mb-6">
                    <v-card-title class="bg-orange-lighten-4 pa-4">
                      <v-icon class="mr-2" color="orange">mdi-percent</v-icon>
                      Descuentos y Previsualización de Obligaciones
                    </v-card-title>
                    <v-card-text class="pa-6">
                      <v-row>
                        <v-col cols="12">
                          <v-select
                            v-model="formulario.descuento_seleccionado"
                            :items="parametros"
                            item-title="nombre_param"
                            item-value="id_parametro"
                            label="Aplicar descuento a matrícula/colegiatura (opcional)"
                            variant="outlined"
                            prepend-inner-icon="mdi-percent"
                            clearable
                            hint="El descuento solo se aplica a matrícula y colegiatura, no a certificados"
                            persistent-hint
                          >
                            <template #item="{ props, item }">
                              <v-list-item v-bind="props">
                                <template #title>{{ item.raw.nombre_param }}</template>
                                <template #subtitle>Descuento del {{ item.raw.valor }} (solo matrícula/colegiatura)</template>
                              </v-list-item>
                            </template>
                          </v-select>
                        </v-col>
                      </v-row>

                      <v-divider class="my-4" />

                      <!-- Conceptos de pago -->
                      <div class="mb-4">
                        <h4 class="text-subtitle-1 font-weight-bold mb-3 d-flex align-center">
                          <v-icon class="mr-2" color="info">mdi-receipt</v-icon>
                          Conceptos de Pago que se Generarán
                        </h4>

                        <v-progress-linear v-if="cargandoConceptos" indeterminate color="primary" class="mb-4" />

                        <div v-else-if="conceptosPago.length" class="space-y-3">
                          <v-card
                            v-for="concepto in conceptosConDescuento"
                            :key="concepto.id_fin_concepto_pago"
                            variant="outlined"
                            :color="getConceptoColor(concepto)"
                            class="mb-3"
                          >
                            <v-card-text class="pa-4" color="gr">
                              <div class="d-flex justify-space-between align-center mb-2">
                                <div class="d-flex align-center">
                                  <v-icon :color="concepto.es_gratuito ? 'success' : concepto.descuento_aplicado > 0 ? 'orange' : 'grey'" class="mr-2">
                                    {{ getConceptoIcon(concepto) }}
                                  </v-icon>
                                  <h5 class="text-subtitle-2 font-weight-bold">{{ concepto.nombre_concepto }}</h5>
                                </div>
                                <div class="d-flex align-center gap-2">
                                  <v-chip v-if="concepto.es_gratuito" size="small" color="success" variant="tonal">
                                    <v-icon start size="small">mdi-gift</v-icon>
                                    GRATUITO
                                  </v-chip>
                                  <v-chip v-else-if="concepto.descuento_aplicado > 0" size="small" color="orange" variant="tonal">
                                    <v-icon start size="small">mdi-percent</v-icon>
                                    CON DESCUENTO
                                  </v-chip>
                                </div>
                              </div>

                              <p class="text-body-2 text-medium-emphasis mb-3">{{ concepto.descripcion }}</p>

                              <div v-if="concepto.observacion" class="mb-2">
                                <v-alert
                                  density="compact"
                                  :color="concepto.es_gratuito ? 'success' : 'info'"
                                  variant="tonal"
                                >
                                  <v-icon start size="small">mdi-information</v-icon>
                                  {{ concepto.observacion }}
                                </v-alert>
                              </div>

                              <div class="d-flex justify-space-between">
                                <div>
                                  <div v-if="!concepto.es_gratuito" class="text-body-2">
                                    Monto base: <strong>{{ formatearMonto(concepto.monto_original) }}</strong>
                                  </div>
                                  <div v-if="concepto.descuento_aplicado > 0" class="text-body-2 text-orange">
                                    Descuento: <strong>-{{ formatearMonto(concepto.descuento_aplicado) }}</strong>
                                  </div>
                                </div>
                                <div class="text-right">
                                  <div class="text-h6 font-weight-bold" :class="concepto.es_gratuito ? 'text-success' : concepto.descuento_aplicado > 0 ? 'text-orange' : 'text-primary'">
                                    {{ concepto.es_gratuito ? 'GRATUITO' : formatearMonto(concepto.monto_final) }}
                                  </div>
                                </div>
                              </div>
                            </v-card-text>
                          </v-card>
                        </div>

                        <v-alert v-else color="info" variant="tonal">
                          <v-icon start>mdi-information</v-icon>
                          No se han configurado precios para este programa, no se generarán obligaciones de pago.
                        </v-alert>
                      </div>
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
                      <div v-if="conceptosPago.length">
                        <!-- Total Original -->
                        <div class="d-flex justify-space-between mb-2">
                          <span>Total base:</span>
                          <span class="font-weight-medium">{{ formatearMonto(totalOriginal) }}</span>
                        </div>

                        <!-- Beneficios Gratuitos -->
                        <div v-if="totalGratuitos > 0" class="d-flex justify-space-between mb-2 text-success">
                          <span>Beneficios gratuitos:</span>
                          <span class="font-weight-medium">{{ formatearMonto(totalGratuitos) }}</span>
                        </div>

                        <!-- Descuentos -->
                        <div v-if="totalDescuentos > 0" class="d-flex justify-space-between mb-2 text-orange">
                          <span>Descuentos aplicados:</span>
                          <span class="font-weight-medium">-{{ formatearMonto(totalDescuentos) }}</span>
                        </div>

                        <v-divider class="my-3" />

                        <!-- Total Final -->
                        <div class="d-flex justify-space-between text-h5 font-weight-bold text-success mb-4">
                          <span>TOTAL A PAGAR:</span>
                          <span>{{ formatearMonto(totalFinal) }}</span>
                        </div>

                        <!-- Desglose adicional -->
                        <div v-if="totalGratuitos > 0 || totalDescuentos > 0">
                          <v-divider class="my-3" />
                          <div class="text-caption text-medium-emphasis">
                            <div>• Servicios gratuitos: {{ formatearMonto(totalGratuitos) }}</div>
                            <div v-if="totalDescuentos > 0">• Ahorro por descuentos: {{ formatearMonto(totalDescuentos) }}</div>
                          </div>
                        </div>
                      </div>

                      <v-alert v-else color="warning" variant="tonal" class="mb-4">
                        <v-icon start>mdi-alert</v-icon>
                        Sin conceptos de pago configurados
                      </v-alert>

                      <!-- Botón Matricular -->
                      <v-btn
                        @click="matricular"
                        :disabled="!step1Complete || matriculando"
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
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <!-- Botones de navegación -->
              <div class="d-flex justify-space-between mt-4">
                <v-btn
                  @click="prevStep"
                  color="primary"
                  variant="outlined"
                >
                  <v-icon start>mdi-arrow-left</v-icon>
                  Anterior
                </v-btn>
              </div>
            </v-container>
          </v-stepper-window-item>
        </v-stepper-window>
      </v-stepper>
    </v-card>
  </v-container>
</template>
