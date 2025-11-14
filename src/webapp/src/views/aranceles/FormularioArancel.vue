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
  arancel: {
    type: Object,
    default: null
  },
  esEdicion: {
    type: Boolean,
    default: false
  },
  tiposBeneficiario: {
    type: Array,
    default: () => []
  },
  conceptosPago: {
    type: Array,
    default: () => []
  },
  programasAprobados: {
    type: Array,
    default: () => []
  }
})

// Emits
const emit = defineEmits(['guardar', 'cancelar'])

// Estado del formulario
const formularioArancel = reactive({
  id_fin_concepto_pago: null,
  id_programa_aprobado: null,
  id_tipo_beneficiario: null,
  monto_base: null,
  fecha_inicio_vigencia: null,
  fecha_fin_vigencia: null,
  descripcion: ''
})

const cargandoFormulario = ref(false)

// Validaciones
const esquemaReglas = computed(() => ({
  id_fin_concepto_pago: { esRequerido },
  id_tipo_beneficiario: { esRequerido },
  monto_base: { esRequerido },
  fecha_inicio_vigencia: { esRequerido }
}))

const $v = useVuelidate(esquemaReglas, formularioArancel)

// Computed
const textoBoton = computed(() =>
  props.esEdicion ? 'Actualizar Arancel' : 'Crear Arancel'
)

// Funciones
const guardar = async () => {
  const esValido = await validarFormulario($v.value)
  if (!esValido) return

  cargandoFormulario.value = true

  try {
    const datos = { ...formularioArancel }
    await emit('guardar', datos)
    limpiarFormulario()
  } catch (error) {
    console.error('Error al guardar:', error)
  } finally {
    cargandoFormulario.value = false
  }
}

const limpiarFormulario = () => {
  Object.assign(formularioArancel, {
    id_fin_concepto_pago: null,
    id_programa_aprobado: null,
    id_tipo_beneficiario: null,
    monto_base: null,
    fecha_inicio_vigencia: null,
    fecha_fin_vigencia: null,
    descripcion: ''
  })
  $v.value.$reset()
}

const cancelar = () => {
  limpiarFormulario()
  emit('cancelar')
}

const cargarDatosArancel = (arancel) => {
  if (!arancel) return

  formularioArancel.id_fin_concepto_pago = arancel.id_fin_concepto_pago
  formularioArancel.id_programa_aprobado = arancel.id_aca_programa_aprobado || null
  formularioArancel.id_tipo_beneficiario = arancel.id_tipo_beneficiario
  formularioArancel.monto_base = parseFloat(arancel.monto_base)
  formularioArancel.fecha_inicio_vigencia = arancel.fecha_inicio_vigencia
  formularioArancel.fecha_fin_vigencia = arancel.fecha_fin_vigencia
  formularioArancel.descripcion = arancel.descripcion_arancel || ''
}

// Watchers
watch(() => props.arancel, (arancel) => {
  if (arancel && props.esEdicion) {
    cargarDatosArancel(arancel)
  }
}, { immediate: true })
</script>

<template>
  <div class="formulario-arancel">
    <v-card-text class="pa-6">
      <v-form>
        <v-row>
          <v-col cols="12" md="6">
            <v-select
              v-model="formularioArancel.id_fin_concepto_pago"
              :items="conceptosPago"
              :error-messages="obtenerErroresCampo($v.id_fin_concepto_pago)"
              item-title="nombre_concepto"
              item-value="id_fin_concepto_pago"
              label="Concepto de Pago *"
              variant="outlined"
              prepend-inner-icon="mdi-cash"
              :disabled="cargandoFormulario"
              hint="Tipo de concepto a cobrar"
              persistent-hint
            />
          </v-col>

          <v-col cols="12" md="6">
            <v-select
              v-model="formularioArancel.id_tipo_beneficiario"
              :items="tiposBeneficiario"
              :error-messages="obtenerErroresCampo($v.id_tipo_beneficiario)"
              item-title="nombre_tipo"
              item-value="id_tipo_beneficiario"
              label="Tipo Beneficiario *"
              variant="outlined"
              prepend-inner-icon="mdi-account-group"
              :disabled="cargandoFormulario"
              hint="Categoría del beneficiario"
              persistent-hint
            />
          </v-col>

          <v-col cols="12">
            <v-select
              v-model="formularioArancel.id_programa_aprobado"
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
            <v-text-field
              v-model.number="formularioArancel.monto_base"
              :error-messages="obtenerErroresCampo($v.monto_base)"
              label="Monto Base (Bs.) *"
              type="number"
              variant="outlined"
              prepend-inner-icon="mdi-cash-multiple"
              prefix="Bs."
              :disabled="cargandoFormulario"
              min="0"
              step="0.01"
              hint="Monto base del arancel"
              persistent-hint
            />
          </v-col>

          <v-col cols="12" md="6">
            <v-date-input
              v-model="formularioArancel.fecha_inicio_vigencia"
              :error-messages="obtenerErroresCampo($v.fecha_inicio_vigencia)"
              label="Fecha Inicio Vigencia *"
              variant="outlined"
              :disabled="cargandoFormulario"
              hint="Fecha desde la cual aplica el arancel"
              persistent-hint
            />
          </v-col>

          <v-col cols="12" md="6">
            <v-date-input
              v-model="formularioArancel.fecha_fin_vigencia"
              label="Fecha Fin Vigencia"
              :disabled="cargandoFormulario"
              clearable
              hint="Dejar vacío si no tiene fecha de término"
              persistent-hint
            />
          </v-col>

          <v-col cols="12">
            <v-textarea
              v-model="formularioArancel.descripcion"
              label="Descripción"
              prepend-inner-icon="mdi-text"
              :disabled="cargandoFormulario"
              rows="3"
              hint="Información adicional sobre el arancel"
              persistent-hint
            />
          </v-col>
        </v-row>

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
            <strong>Importante:</strong> Los campos marcados con (*) son obligatorios.
            El arancel se aplicará según el programa y tipo de beneficiario seleccionados.
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
        color="primary"
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
// Responsive
@media (max-width: 600px) {
  .formulario-arancel {
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
