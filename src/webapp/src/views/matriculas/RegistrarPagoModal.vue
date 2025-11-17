<script setup>
import { ref, computed, watch } from 'vue'
import { api } from '@/services/api'
import { showError, showSuccess } from '@/utils/sweetalert'

const props = defineProps({
  estudiante: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['cerrar', 'guardado'])

const obligacionesConSaldo = ref([])
const formData = ref({
  id_fin_obligacion_pago: null,
  monto_pagado: null,
  fecha_pago: new Date().toISOString().split('T')[0],
  tipo_comprobante: 'DEPOSITO_BANCARIO',
  observacion: '',
  voucherFile: null
})

const voucherFileName = ref('')
const guardando = ref(false)
const cargando = ref(false)

const tiposComprobante = [
  { value: 'DEPOSITO_BANCARIO', title: 'Depósito Bancario' },
  { value: 'TRANSFERENCIA', title: 'Transferencia' },
  { value: 'EFECTIVO', title: 'Efectivo' },
  { value: 'QR', title: 'QR' },
  { value: 'OTRO', title: 'Otro' }
]

// Calcular información de la obligación seleccionada
const obligacionSeleccionada = computed(() => {
  if (!formData.value.id_fin_obligacion_pago) return null
  return obligacionesConSaldo.value.find(
    o => o.id_fin_obligacion_pago === formData.value.id_fin_obligacion_pago
  )
})

const montoMaximo = computed(() => {
  return obligacionSeleccionada.value?.saldo_pendiente || 0
})

const esMontoValido = computed(() => {
  if (!formData.value.monto_pagado) return true
  return formData.value.monto_pagado > 0 && formData.value.monto_pagado <= montoMaximo.value
})

const puedeGuardar = computed(() => {
  return formData.value.id_fin_obligacion_pago &&
         formData.value.monto_pagado > 0 &&
         esMontoValido.value &&
         formData.value.fecha_pago &&
         formData.value.tipo_comprobante
})

const cargarObligaciones = async () => {
  cargando.value = true
  try {
    // Cargar obligaciones del estudiante que tengan saldo pendiente
    const response = await api.get(`/api/matricula/${props.estudiante.cod_ins_matricula}/obligaciones`)

    // Filtrar solo las que tienen saldo pendiente
    obligacionesConSaldo.value = response.data.filter(o => o.saldo_pendiente > 0)
  } catch (error) {
    console.error('Error al cargar obligaciones:', error)
    await showError('Error al cargar las obligaciones de pago')
  } finally {
    cargando.value = false
  }
}

const onFileChange = (event) => {
  const files = event.target.files || event.dataTransfer.files
  if (files.length > 0) {
    formData.value.voucherFile = files[0]
    voucherFileName.value = files[0].name
  }
}

const limpiarArchivo = () => {
  formData.value.voucherFile = null
  voucherFileName.value = ''
  // Limpiar el input file
  const fileInput = document.querySelector('input[type="file"]')
  if (fileInput) fileInput.value = ''
}

const setMontoCompleto = () => {
  if (obligacionSeleccionada.value) {
    formData.value.monto_pagado = obligacionSeleccionada.value.saldo_pendiente
  }
}

const guardar = async () => {
  if (!puedeGuardar.value) {
    await showError('Complete todos los campos requeridos')
    return
  }

  guardando.value = true
  try {
    // Crear FormData para enviar archivo + datos
    const datos = new FormData()

    // Agregar el voucher si existe
    if (formData.value.voucherFile) {
      datos.append('voucher', formData.value.voucherFile)
    }

    // Agregar los datos como JSON
    const payload = {
      cod_matricula: props.estudiante.cod_ins_matricula,
      id_fin_obligacion_pago: formData.value.id_fin_obligacion_pago,
      monto_pagado: formData.value.monto_pagado,
      fecha_pago: formData.value.fecha_pago,
      tipo_comprobante: formData.value.tipo_comprobante,
      observacion: formData.value.observacion || null
    }

    datos.append('datos', JSON.stringify(payload))

    const response = await api.post('/api/transaccion/registrar-pago', datos, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })

    if (response.data.success) {
      await showSuccess(response.data.mensaje || 'Pago registrado exitosamente')
      emit('guardado')
    } else {
      await showError(response.data.message || 'Error al registrar el pago')
    }
  } catch (error) {
    console.error('Error al registrar pago:', error)
    await showError(error.response?.data?.message || 'Error al registrar el pago')
  } finally {
    guardando.value = false
  }
}

const cancelar = () => {
  emit('cerrar')
}

// Cargar obligaciones cuando el modal se abre
watch(() => props.estudiante, async (nuevoEstudiante) => {
  if (nuevoEstudiante) {
    await cargarObligaciones()
  }
}, { immediate: true })
</script>

<template>
  <v-card>
    <v-card-title class="d-flex align-center pa-4 bg-primary">
      <v-icon class="mr-2">mdi-cash-register</v-icon>
      <div>
        <div>Registrar Pago</div>
        <div class="text-subtitle-2 font-weight-regular">
          {{ estudiante?.nombre_completo }}
        </div>
      </div>
    </v-card-title>

    <v-divider></v-divider>

    <v-card-text class="pa-4">
      <v-progress-linear
        v-if="cargando"
        indeterminate
        color="primary"
        class="mb-4"
      ></v-progress-linear>

      <v-alert
        v-if="!cargando && obligacionesConSaldo.length === 0"
        type="info"
        variant="tonal"
        class="mb-4"
      >
        No hay obligaciones de pago pendientes para este estudiante
      </v-alert>

      <v-form v-if="obligacionesConSaldo.length > 0">
        <!-- Selección de obligación -->
        <v-select
          v-model="formData.id_fin_obligacion_pago"
          :items="obligacionesConSaldo"
          item-title="nombre_concepto"
          item-value="id_fin_obligacion_pago"
          label="Concepto de Pago *"
          variant="outlined"
          :disabled="cargando"
          density="comfortable"
        >
          <template #item="{ item, props }">
            <v-list-item v-bind="props">
              <template #subtitle>
                Saldo: Bs. {{ item.raw.saldo_pendiente.toFixed(2) }} de Bs. {{ item.raw.deuda_con_descuento.toFixed(2) }}
              </template>
            </v-list-item>
          </template>
        </v-select>

        <!-- Info de obligación seleccionada -->
        <v-alert
          v-if="obligacionSeleccionada"
          type="info"
          variant="tonal"
          class="mb-4"
          density="compact"
        >
          <div><strong>{{ obligacionSeleccionada.nombre_concepto }}</strong></div>
          <div class="text-caption">
            Deuda total: Bs. {{ obligacionSeleccionada.deuda_con_descuento.toFixed(2) }}
          </div>
          <div class="text-caption">
            Saldo pendiente: Bs. {{ obligacionSeleccionada.saldo_pendiente.toFixed(2) }}
          </div>
        </v-alert>

        <!-- Monto -->
        <v-text-field
          v-model.number="formData.monto_pagado"
          label="Monto Pagado *"
          type="number"
          step="0.01"
          prefix="Bs."
          variant="outlined"
          :disabled="!formData.id_fin_obligacion_pago || cargando"
          :error-messages="!esMontoValido ? `El monto debe ser entre 0.01 y ${montoMaximo.toFixed(2)}` : ''"
          density="comfortable"
        >
          <template #append-inner>
            <v-btn
              size="small"
              variant="text"
              color="primary"
              :disabled="!formData.id_fin_obligacion_pago"
              @click="setMontoCompleto"
            >
              Monto completo
            </v-btn>
          </template>
        </v-text-field>

        <!-- Fecha de pago -->
        <v-text-field
          v-model="formData.fecha_pago"
          label="Fecha de Pago *"
          type="date"
          variant="outlined"
          :disabled="cargando"
          density="comfortable"
        ></v-text-field>

        <!-- Tipo de comprobante -->
        <v-select
          v-model="formData.tipo_comprobante"
          :items="tiposComprobante"
          label="Tipo de Comprobante *"
          variant="outlined"
          :disabled="cargando"
          density="comfortable"
        ></v-select>

        <!-- Observaciones -->
        <v-textarea
          v-model="formData.observacion"
          label="Observaciones"
          variant="outlined"
          rows="2"
          :disabled="cargando"
          density="comfortable"
          counter="500"
          maxlength="500"
        ></v-textarea>

        <!-- Voucher -->
        <v-card variant="outlined" class="mb-4">
          <v-card-text>
            <div class="d-flex align-center">
              <v-icon class="mr-2" color="primary">mdi-file-upload</v-icon>
              <div class="flex-grow-1">
                <div class="text-subtitle-2">Comprobante de Pago (Opcional)</div>
                <div v-if="voucherFileName" class="text-caption text-success">
                  {{ voucherFileName }}
                </div>
                <div v-else class="text-caption text-grey">
                  JPG, PNG, PDF - Máx. 10MB
                </div>
              </div>
              <v-btn
                v-if="voucherFileName"
                icon="mdi-close"
                size="small"
                variant="text"
                @click="limpiarArchivo"
              ></v-btn>
              <v-btn
                v-else
                color="primary"
                variant="outlined"
                size="small"
                @click="() => $refs.fileInput.click()"
              >
                Seleccionar
              </v-btn>
            </div>
            <input
              ref="fileInput"
              type="file"
              accept="image/*,.pdf"
              style="display: none"
              @change="onFileChange"
            />
          </v-card-text>
        </v-card>
      </v-form>
    </v-card-text>

    <v-divider></v-divider>

    <v-card-actions class="pa-4">
      <v-spacer></v-spacer>
      <v-btn
        color="grey-darken-1"
        variant="text"
        :disabled="guardando || cargando"
        @click="cancelar"
      >
        Cancelar
      </v-btn>
      <v-btn
        color="primary"
        variant="elevated"
        :loading="guardando"
        :disabled="!puedeGuardar || cargando"
        @click="guardar"
      >
        <v-icon start>mdi-cash-check</v-icon>
        Registrar Pago
      </v-btn>
    </v-card-actions>
  </v-card>
</template>
