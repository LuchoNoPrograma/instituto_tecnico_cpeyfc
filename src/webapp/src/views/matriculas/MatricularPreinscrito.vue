<script setup>
import { ref, computed, onMounted, reactive, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { api } from '@/services/api'
import { showRegistrado, showError, showCargando, cerrarCargando } from "@/utils/sweetalert.js"

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
const tiposBeneficiario = ref([])
const convenios = ref([])
const conceptosPago = ref([])
const cargandoConceptos = ref(false)

// Formulario
const formulario = reactive({
  id_ins_preinscripcion: null,
  id_ins_grupo: null,
  id_tipo_beneficiario: null,  // NUEVO - obligatorio
  id_convenio: null             // NUEVO - opcional
})

// Computed
const preinscriptoSeleccionado = computed(() =>
  preinscripciones.value.find(p => p.id_ins_preinscripcion === formulario.id_ins_preinscripcion)
)

const grupoSeleccionado = computed(() =>
  grupos.value.find(g => g.id_ins_grupo === formulario.id_ins_grupo)
)

const tipoBeneficiarioSeleccionado = computed(() =>
  tiposBeneficiario.value.find(t => t.id_tipo_beneficiario === formulario.id_tipo_beneficiario)
)

const convenioSeleccionado = computed(() =>
  convenios.value.find(c => c.id_convenio === formulario.id_convenio)
)

const step1Complete = computed(() =>
  formulario.id_ins_preinscripcion && formulario.id_ins_grupo && formulario.id_tipo_beneficiario
)

// Procesar conceptos con la estructura que viene del backend
const conceptosProcesados = computed(() => {
  if (!conceptosPago.value.length) return []

  return conceptosPago.value.map(concepto => ({
    ...concepto,
    es_gratuito: concepto.monto_final === 0,
    tiene_descuento: concepto.descuento_aplicado > 0
  }))
})

const totalOriginal = computed(() =>
  conceptosPago.value.reduce((sum, c) => sum + parseFloat(c.monto_base || 0), 0)
)

const totalDescuentos = computed(() =>
  conceptosPago.value.reduce((sum, c) => sum + parseFloat(c.descuento_aplicado || 0), 0)
)

const totalFinal = computed(() =>
  conceptosPago.value.reduce((sum, c) => sum + parseFloat(c.monto_final || 0), 0)
)

const totalGratuitos = computed(() => {
  const gratuitos = conceptosPago.value.filter(c => parseFloat(c.monto_final) === 0)
  return gratuitos.reduce((sum, c) => sum + parseFloat(c.monto_base || 0), 0)
})

// Cargar tipos de beneficiario
const cargarTiposBeneficiario = async () => {
  try {
    const response = await api.get('/api/tipos-beneficiario/activos')
    tiposBeneficiario.value = response.data
  } catch (error) {
    console.error('Error cargando tipos de beneficiario:', error)
  }
}

// Cargar convenios vigentes
const cargarConvenios = async () => {
  try {
    const response = await api.get('/api/convenios/vigentes')
    convenios.value = response.data
  } catch (error) {
    console.error('Error cargando convenios:', error)
  }
}

// Cargar conceptos cuando cambie tipo beneficiario o convenio
const cargarConceptosPago = async () => {
  if (!idProgramaAprobado.value || !formulario.id_tipo_beneficiario) {
    conceptosPago.value = []
    return
  }

  cargandoConceptos.value = true
  try {
    const params = {
      idTipoBeneficiario: formulario.id_tipo_beneficiario
    }

    if (formulario.id_convenio) {
      params.idConvenio = formulario.id_convenio
    }

    const response = await api.get(
      `/api/concepto-pago/con-aranceles/${idProgramaAprobado.value}`,
      { params }
    )
    conceptosPago.value = response.data
  } catch (error) {
    console.error('Error cargando conceptos:', error)
    await showError('No se pudieron cargar los conceptos de pago')
  } finally {
    cargandoConceptos.value = false
  }
}

const cargarDatos = async () => {
  cargando.value = true
  try {
    const [programaRes, preinscripcionesRes, gruposRes] = await Promise.all([
      api.get(`/api/programa-aprobado/vista/programas-aprobados/${idProgramaAprobado.value}`),
      api.get(`/api/preinscripcion/pendiente/${idProgramaAprobado.value}`),
      api.get(`/api/grupo/activo-por-programa/${idProgramaAprobado.value}`)
    ])

    programaInfo.value = programaRes.data
    preinscripciones.value = preinscripcionesRes.data.filter(p => p.estado_matriculacion === 'NO MATRICULADO')
    grupos.value = gruposRes.data

    // Cargar tipos de beneficiario y convenios
    await Promise.all([
      cargarTiposBeneficiario(),
      cargarConvenios()
    ])

  } catch (error) {
    console.error('Error cargando datos:', error)
    await showError('Error al cargar la información necesaria')
  } finally {
    cargando.value = false
  }
}

const matricular = async () => {
  if (!step1Complete.value) return

  showCargando('Matriculando estudiante...', 'Por favor espere')

  try {
    const payload = {
      id_ins_preinscripcion: formulario.id_ins_preinscripcion,
      id_ins_grupo: formulario.id_ins_grupo,
      id_tipo_beneficiario: formulario.id_tipo_beneficiario,
      id_convenio: formulario.id_convenio || null
    }

    await api.post('/api/matricula/matricular-preinscrito-v2', payload)

    cerrarCargando()
    await showRegistrado('Estudiante matriculado exitosamente', '¡Matrícula Completada!')
    router.push(`/matriculas?grupo=${formulario.id_ins_grupo}`)

  } catch (error) {
    cerrarCargando()
    console.error('Error matriculando:', error)
    await showError(error.response?.data?.mensaje || error.response?.data?.message || 'No se pudo completar la matrícula')
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

const getConceptoColor = (concepto) => {
  if (concepto.es_gratuito) return 'success'
  if (concepto.tiene_descuento) return 'orange'
  return 'grey-lighten-4'
}

const getConceptoIcon = (concepto) => {
  if (concepto.es_gratuito) return 'mdi-gift'
  if (concepto.tiene_descuento) return 'mdi-sale'
  return 'mdi-file-document-outline'
}

// Watch para recargar conceptos cuando cambie tipo beneficiario o convenio
watch([() => formulario.id_tipo_beneficiario, () => formulario.id_convenio], () => {
  if (formulario.id_tipo_beneficiario) {
    cargarConceptosPago()
  }
}, { deep: true })

onMounted(() => {
  cargarDatos()
})
</script>

<template>
  <v-container fluid class="pa-6">
    <v-card>
      <v-card-title class="bg-primary text-white pa-4">
        <v-icon start>mdi-school</v-icon>
        Matricular Preinscrito
      </v-card-title>

      <v-stepper v-model="currentStep" class="elevation-0">
        <v-stepper-header>
          <v-stepper-item
            :complete="currentStep > 1"
            :value="1"
            title="Selección"
            subtitle="Preinscrito, grupo y tipo"
          ></v-stepper-item>

          <v-divider></v-divider>

          <v-stepper-item
            :value="2"
            title="Confirmación"
            subtitle="Revisar y confirmar"
          ></v-stepper-item>
        </v-stepper-header>

        <v-stepper-window>
          <!-- PASO 1: Selección -->
          <v-stepper-window-item :value="1">
            <v-container fluid>
              <v-row>
                <!-- Info del Programa -->
                <v-col cols="12">
                  <v-alert type="info" variant="tonal" class="mb-4">
                    <template #prepend>
                      <v-icon>mdi-information</v-icon>
                    </template>
                    <strong>{{ programaInfo.nombre_programa }}</strong>
                    <div class="text-caption">{{ programaInfo.nombre_modalidad }} • Gestión {{ programaInfo.gestion }}</div>
                  </v-alert>
                </v-col>

                <!-- Selección de Preinscrito -->
                <v-col cols="12" md="6">
                  <v-select
                    v-model="formulario.id_ins_preinscripcion"
                    :items="preinscripciones"
                    item-title="nombre_completo"
                    item-value="id_ins_preinscripcion"
                    label="Seleccionar Preinscrito *"
                    variant="outlined"
                    prepend-inner-icon="mdi-account"
                    :disabled="cargando"
                  >
                    <template #item="{ props, item }">
                      <v-list-item v-bind="props">
                        <template #title>{{ item.raw.nombre_completo }}</template>
                        <template #subtitle>CI: {{ item.raw.ci }} • {{ item.raw.correo }}</template>
                      </v-list-item>
                    </template>
                  </v-select>
                </v-col>

                <!-- Selección de Grupo -->
                <v-col cols="12" md="6">
                  <v-select
                    v-model="formulario.id_ins_grupo"
                    :items="grupos"
                    item-title="nombre_grupo"
                    item-value="id_ins_grupo"
                    label="Seleccionar Grupo *"
                    variant="outlined"
                    prepend-inner-icon="mdi-account-group"
                    :disabled="cargando"
                  >
                    <template #item="{ props, item }">
                      <v-list-item v-bind="props">
                        <template #title>{{ item.raw.nombre_grupo }}</template>
                        <template #subtitle>
                          Gestión {{ item.raw.gestion_inicio }} •
                          Matriculados: {{ item.raw.total_matriculados }}
                        </template>
                      </v-list-item>
                    </template>
                  </v-select>
                </v-col>

                <!-- NUEVO: Tipo de Beneficiario -->
                <v-col cols="12" md="6">
                  <v-select
                    v-model="formulario.id_tipo_beneficiario"
                    :items="tiposBeneficiario"
                    item-title="nombre_tipo"
                    item-value="id_tipo_beneficiario"
                    label="Tipo de Beneficiario *"
                    variant="outlined"
                    prepend-inner-icon="mdi-account-star"
                    :disabled="cargando"
                    hint="Determina el arancel base a aplicar"
                    persistent-hint
                  >
                    <template #item="{ props, item }">
                      <v-list-item v-bind="props">
                        <template #title>{{ item.raw.nombre_tipo }}</template>
                        <template #subtitle v-if="item.raw.descripcion">
                          {{ item.raw.descripcion }}
                        </template>
                      </v-list-item>
                    </template>
                  </v-select>
                </v-col>

                <!-- NUEVO: Convenio Institucional (opcional) -->
                <v-col cols="12" md="6">
                  <v-select
                    v-model="formulario.id_convenio"
                    :items="convenios"
                    item-title="nombre_institucion"
                    item-value="id_convenio"
                    label="Convenio Institucional (opcional)"
                    variant="outlined"
                    prepend-inner-icon="mdi-handshake"
                    :disabled="cargando"
                    clearable
                    hint="Si aplica descuento por convenio institucional"
                    persistent-hint
                  >
                    <template #item="{ props, item }">
                      <v-list-item v-bind="props">
                        <template #title>{{ item.raw.nombre_institucion }}</template>
                        <template #subtitle>
                          {{ item.raw.tipo_institucion }}
                          <span v-if="item.raw.tiene_descuentos" class="text-success">
                            • Con descuentos
                          </span>
                        </template>
                      </v-list-item>
                    </template>
                  </v-select>
                </v-col>

                <!-- Info Cards -->
                <v-col cols="12" v-if="preinscriptoSeleccionado">
                  <v-card variant="outlined">
                    <v-card-title class="text-subtitle-1">
                      <v-icon start color="primary">mdi-account-details</v-icon>
                      Información del Preinscrito
                    </v-card-title>
                    <v-card-text>
                      <v-row dense>
                        <v-col cols="12" sm="6" md="3">
                          <div class="text-caption text-medium-emphasis">Nombre Completo</div>
                          <div class="font-weight-medium">{{ preinscriptoSeleccionado.nombre_completo }}</div>
                        </v-col>
                        <v-col cols="12" sm="6" md="3">
                          <div class="text-caption text-medium-emphasis">CI</div>
                          <div class="font-weight-medium">{{ preinscriptoSeleccionado.ci }}</div>
                        </v-col>
                        <v-col cols="12" sm="6" md="3">
                          <div class="text-caption text-medium-emphasis">Celular</div>
                          <div class="font-weight-medium">{{ preinscriptoSeleccionado.nro_celular }}</div>
                        </v-col>
                        <v-col cols="12" sm="6" md="3">
                          <div class="text-caption text-medium-emphasis">Email</div>
                          <div class="font-weight-medium text-truncate">{{ preinscriptoSeleccionado.correo }}</div>
                        </v-col>
                      </v-row>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <!-- Botón siguiente -->
              <div class="d-flex justify-end mt-4">
                <v-btn
                  @click="nextStep"
                  :disabled="!step1Complete"
                  color="primary"
                  variant="elevated"
                  size="large"
                >
                  Siguiente
                  <v-icon end>mdi-arrow-right</v-icon>
                </v-btn>
              </div>
            </v-container>
          </v-stepper-window-item>

          <!-- PASO 2: Confirmación -->
          <v-stepper-window-item :value="2">
            <v-container fluid>
              <v-row>
                <!-- Resumen de Selección -->
                <v-col cols="12" lg="8">
                  <v-card>
                    <v-card-title class="bg-info text-white pa-4">
                      <v-icon start>mdi-clipboard-list</v-icon>
                      Resumen de Matrícula
                    </v-card-title>
                    <v-card-text class="pa-6">
                      <v-row dense class="mb-4">
                        <v-col cols="12" sm="6">
                          <div class="text-caption text-medium-emphasis mb-1">Estudiante</div>
                          <div class="font-weight-bold">{{ preinscriptoSeleccionado?.nombre_completo }}</div>
                        </v-col>
                        <v-col cols="12" sm="6">
                          <div class="text-caption text-medium-emphasis mb-1">Grupo</div>
                          <div class="font-weight-bold">{{ grupoSeleccionado?.nombre_grupo }}</div>
                        </v-col>
                        <v-col cols="12" sm="6">
                          <div class="text-caption text-medium-emphasis mb-1">Tipo de Beneficiario</div>
                          <div class="font-weight-bold">
                            <v-chip size="small" color="primary">
                              {{ tipoBeneficiarioSeleccionado?.nombre_tipo }}
                            </v-chip>
                          </div>
                        </v-col>
                        <v-col cols="12" sm="6" v-if="convenioSeleccionado">
                          <div class="text-caption text-medium-emphasis mb-1">Convenio Aplicado</div>
                          <div class="font-weight-bold">
                            <v-chip size="small" color="success">
                              <v-icon start size="small">mdi-handshake</v-icon>
                              {{ convenioSeleccionado?.nombre_institucion }}
                            </v-chip>
                          </div>
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
                            v-for="concepto in conceptosProcesados"
                            :key="concepto.id_fin_concepto_pago"
                            variant="outlined"
                            :color="getConceptoColor(concepto)"
                            class="mb-3"
                          >
                            <v-card-text class="pa-4">
                              <div class="d-flex justify-space-between align-center mb-2">
                                <div class="d-flex align-center">
                                  <v-icon
                                    :color="concepto.es_gratuito ? 'success' : concepto.tiene_descuento ? 'orange' : 'grey'"
                                    class="mr-2"
                                  >
                                    {{ getConceptoIcon(concepto) }}
                                  </v-icon>
                                  <h5 class="text-subtitle-2 font-weight-bold">{{ concepto.nombre_concepto }}</h5>
                                </div>
                                <div class="d-flex align-center gap-2">
                                  <v-chip v-if="concepto.es_gratuito" size="small" color="success" variant="tonal">
                                    <v-icon start size="small">mdi-gift</v-icon>
                                    GRATUITO
                                  </v-chip>
                                  <v-chip v-else-if="concepto.tiene_descuento" size="small" color="orange" variant="tonal">
                                    <v-icon start size="small">mdi-percent</v-icon>
                                    CON DESCUENTO
                                  </v-chip>
                                </div>
                              </div>

                              <p class="text-body-2 text-medium-emphasis mb-3" v-if="concepto.descripcion">
                                {{ concepto.descripcion }}
                              </p>

                              <div v-if="concepto.detalle_descuento && concepto.tiene_descuento" class="mb-2">
                                <v-alert
                                  density="compact"
                                  color="info"
                                  variant="tonal"
                                >
                                  <v-icon start size="small">mdi-information</v-icon>
                                  {{ concepto.detalle_descuento }}
                                </v-alert>
                              </div>

                              <div class="d-flex justify-space-between">
                                <div>
                                  <div v-if="!concepto.es_gratuito" class="text-body-2">
                                    Monto base: <strong>{{ formatearMonto(concepto.monto_base) }}</strong>
                                  </div>
                                  <div v-if="concepto.tiene_descuento" class="text-body-2 text-orange">
                                    Descuento: <strong>-{{ formatearMonto(concepto.descuento_aplicado) }}</strong>
                                  </div>
                                </div>
                                <div class="text-right">
                                  <div
                                    class="text-h6 font-weight-bold"
                                    :class="concepto.es_gratuito ? 'text-success' : concepto.tiene_descuento ? 'text-orange' : 'text-primary'"
                                  >
                                    {{ concepto.es_gratuito ? 'GRATUITO' : formatearMonto(concepto.monto_final) }}
                                  </div>
                                </div>
                              </div>
                            </v-card-text>
                          </v-card>
                        </div>

                        <v-alert v-else color="info" variant="tonal">
                          <v-icon start>mdi-information</v-icon>
                          No se han configurado aranceles para este tipo de beneficiario en este programa.
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
                        :disabled="!step1Complete || matriculando || !conceptosPago.length"
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

<style scoped>
.space-y-3 > * + * {
  margin-top: 12px;
}
</style>
