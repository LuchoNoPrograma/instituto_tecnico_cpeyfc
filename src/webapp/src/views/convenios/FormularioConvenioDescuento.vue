<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { useVuelidate } from '@vuelidate/core'
import {
  esRequerido,
  obtenerErroresCampo,
  validarFormulario
} from '@/helpers/validations'

// Props
const props = defineProps({
  descuento: {
    type: Object,
    default: null
  },
  esEdicion: {
    type: Boolean,
    default: false
  },
  idConvenio: {
    type: Number,
    required: true
  },
  programasAprobados: {
    type: Array,
    default: () => []
  },
  conceptosPago: {
    type: Array,
    default: () => []
  }
})

// Emits
const emit = defineEmits(['guardar', 'cancelar'])

// Estado del formulario
const formularioDescuento = reactive({
  id_convenio: null,
  id_aca_programa_aprobado: null,
  id_fin_concepto_pago: null,
  tipo_descuento: 'PORCENTUAL',
  valor_descuento: null,
  fecha_inicio_vigencia: null,
  fecha_fin_vigencia: null,
  descripcion: '',
  estado_descuento_convenio: 'ACTIVO'
})

const cargandoFormulario = ref(false)

// Validaciones
const esquemaReglas = computed(() => ({
  tipo_descuento: { esRequerido },
  valor_descuento: { esRequerido },
  fecha_inicio_vigencia: { esRequerido }
}))

const $v = useVuelidate(esquemaReglas, formularioDescuento)

// Computed
const textoBoton = computed(() =>
  props.esEdicion ? 'Actualizar Descuento' : 'Crear Descuento'
)

const tiposDescuento = [
  { value: 'PORCENTUAL', title: 'Porcentual (%)' },
  { value: 'FIJO', title: 'Monto Fijo (Bs.)' }
]

const labelValor = computed(() => {
  return formularioDescuento.tipo_descuento === 'PORCENTUAL'
    ? 'Valor del Descuento (%) *'
    : 'Valor del Descuento (Bs.) *'
})

const suffixValor = computed(() => {
  return formularioDescuento.tipo_descuento === 'PORCENTUAL' ? '%' : 'Bs.'
})

const maxValor = computed(() => {
  return formularioDescuento.tipo_descuento === 'PORCENTUAL' ? 100 : undefined
})

// Funciones
const guardar = async () => {
  const esValido = await validarFormulario($v.value)
  if (!esValido) return

  cargandoFormulario.value = true

  try {
    const datos = {
      ...formularioDescuento,
      id_convenio: props.idConvenio
    }
    await emit('guardar', datos)
    limpiarFormulario()
  } catch (error) {
    console.error('Error al guardar:', error)
  } finally {
    cargandoFormulario.value = false
  }
}

const limpiarFormulario = () => {
  Object.assign(formularioDescuento, {
    id_convenio: props.idConvenio,
    id_aca_programa_aprobado: null,
    id_fin_concepto_pago: null,
    tipo_descuento: 'PORCENTUAL',
    valor_descuento: null,
    fecha_inicio_vigencia: null,
    fecha_fin_vigencia: null,
    descripcion: '',
    estado_descuento_convenio: 'ACTIVO'
  })
  $v.value.$reset()
}

const cancelar = () => {
  limpiarFormulario()
  emit('cancelar')
}

const cargarDatosDescuento = (descuento) => {
  if (!descuento) return

  formularioDescuento.id_convenio = props.idConvenio
  formularioDescuento.id_aca_programa_aprobado = descuento.id_aca_programa_aprobado
  formularioDescuento.id_fin_concepto_pago = descuento.id_fin_concepto_pago
  formularioDescuento.tipo_descuento = descuento.tipo_descuento
  formularioDescuento.valor_descuento = parseFloat(descuento.valor_descuento)
  formularioDescuento.fecha_inicio_vigencia = descuento.fecha_inicio_vigencia
  formularioDescuento.fecha_fin_vigencia = descuento.fecha_fin_vigencia
  formularioDescuento.descripcion = descuento.descripcion || ''
  formularioDescuento.estado_descuento_convenio = descuento.estado_descuento_convenio
}

// Watchers
watch(() => props.descuento, (descuento) => {
  if (descuento && props.esEdicion) {
    cargarDatosDescuento(descuento)
  } else {
    formularioDescuento.id_convenio = props.idConvenio
  }
}, { immediate: true })

watch(() => formularioDescuento.tipo_descuento, (nuevoTipo) => {
  // Si cambia a PORCENTUAL y el valor actual excede 100, ajustarlo
  if (nuevoTipo === 'PORCENTUAL' && formularioDescuento.valor_descuento > 100) {
    formularioDescuento.valor_descuento = 100
  }
})
</script>

<template>
  <div class="formulario-descuento">
    <v-card-text class="pa-6">
      <v-form>
        <!-- Sección: Alcance del Descuento -->
        <div class="mb-6">
          <h3 class="text-h6 mb-4 text-primary">
            <v-icon start color="primary">mdi-target</v-icon>
            Alcance del Descuento
          </h3>

          <v-row>
            <v-col cols="12">
              <v-select
                v-model="formularioDescuento.id_aca_programa_aprobado"
                :items="programasAprobados"
                item-title="programa_nombre"
                item-value="id_aca_programa_aprobado"
                label="Programa"
                variant="outlined"
                prepend-inner-icon="mdi-school"
                :disabled="cargandoFormulario"
                clearable
                hint="Dejar vacío para aplicar a todos los programas"
                persistent-hint
              >
                <template #selection="{ item }">
                  <span>{{ item.raw.programa_nombre }} ({{ item.raw.gestion }})</span>
                </template>

                <template #item="{ props, item }">
                  <v-list-item v-bind="props">
                    <template #title>{{ item.raw.programa_nombre }}</template>
                    <template #subtitle>
                      {{ item.raw.modalidad_nombre }} - Gestión {{ item.raw.gestion }}
                    </template>
                  </v-list-item>
                </template>
              </v-select>
            </v-col>

            <v-col cols="12">
              <v-select
                v-model="formularioDescuento.id_fin_concepto_pago"
                :items="conceptosPago"
                item-title="nombre_concepto"
                item-value="id_fin_concepto_pago"
                label="Concepto de Pago"
                variant="outlined"
                prepend-inner-icon="mdi-cash"
                :disabled="cargandoFormulario"
                clearable
                hint="Dejar vacío para aplicar a todos los conceptos"
                persistent-hint
              />
            </v-col>
          </v-row>

        </div>

        <v-divider class="my-6" />

        <!-- Sección: Configuración del Descuento -->
        <div class="mb-6">
          <h3 class="text-h6 mb-4 text-primary">
            <v-icon start color="primary">mdi-percent</v-icon>
            Configuración del Descuento
          </h3>

          <v-row>
            <v-col cols="12" md="6">
              <v-select
                v-model="formularioDescuento.tipo_descuento"
                :items="tiposDescuento"
                :error-messages="obtenerErroresCampo($v.tipo_descuento)"
                label="Tipo de Descuento *"
                variant="outlined"
                prepend-inner-icon="mdi-tag"
                :disabled="cargandoFormulario"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-number-input
                v-model.number="formularioDescuento.valor_descuento"
                :error-messages="obtenerErroresCampo($v.valor_descuento)"
                :label="labelValor"
                variant="outlined"
                prepend-inner-icon="mdi-cash-multiple"
                :disabled="cargandoFormulario"
                :min="0"
                :precision="2"
                :max="maxValor"
                :step="1"
              >
              </v-number-input>
            </v-col>

            <v-col cols="12">
              <v-textarea
                v-model="formularioDescuento.descripcion"
                label="Descripción del Descuento"
                variant="outlined"
                prepend-inner-icon="mdi-text"
                :disabled="cargandoFormulario"
                rows="2"
                hint="Información adicional sobre este descuento"
                persistent-hint
              />
            </v-col>
          </v-row>

          <v-row>
          <v-col cols="12" md="6">
            <v-date-input
              v-model="formularioDescuento.fecha_inicio_vigencia"
              :error-messages="obtenerErroresCampo($v.fecha_inicio_vigencia)"
              label="Fecha Inicio Vigencia *"
              variant="outlined"
              :disabled="cargandoFormulario"
              hint="Fecha desde la cual aplica el descuento"
              persistent-hint
            />
          </v-col>

          <v-col cols="12" md="6">
            <v-date-input
              v-model="formularioDescuento.fecha_fin_vigencia"
              label="Fecha Fin Vigencia"
              variant="outlined"
              :disabled="cargandoFormulario"
              clearable
              hint="Dejar vacío si no tiene fecha de término"
              persistent-hint
            />
          </v-col>
          </v-row>
        </div>

        <!-- Alerta informativa -->
        <v-alert
          color="info"
          variant="tonal"
          class="mt-4"
        >
          <template #prepend>
            <v-icon>mdi-information</v-icon>
          </template>

          <div class="text-body-2">
            <strong>Nota:</strong> El descuento se aplicará automáticamente a las inscripciones
            que cumplan con los criterios definidos y que se realicen dentro del período de vigencia.
          </div>
        </v-alert>
      </v-form>
    </v-card-text>

    <!-- Acciones -->
    <v-card-actions class="pa-6 pt-0">
      <v-spacer />
      <v-btn
        variant="text"
        @click="cancelar"
        :disabled="cargandoFormulario"
      >
        Cancelar
      </v-btn>
      <v-btn
        color="success"
        variant="elevated"
        :loading="cargandoFormulario"
        @click="guardar"
      >
        <v-icon start>mdi-content-save</v-icon>
        {{ textoBoton }}
      </v-btn>
    </v-card-actions>
  </div>
</template>

<style lang="scss" scoped>
.formulario-descuento {
  .v-divider {
    border-color: rgba(var(--v-theme-on-surface), 0.08);
  }
}

// Responsive
@media (max-width: 600px) {
  .formulario-descuento {
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
  }
}
</style>
