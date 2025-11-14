<script setup>
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { useVuelidate } from '@vuelidate/core'
import {
  esRequerido,
  esEmail,
  longitudMinima,
  longitudMaxima,
  obtenerErroresCampo,
  validarFormulario
} from '@/helpers/validations'

// Props
const props = defineProps({
  convenio: {
    type: Object,
    default: null
  },
  esEdicion: {
    type: Boolean,
    default: false
  }
})

// Emits
const emit = defineEmits(['guardar', 'cancelar'])

// Estado del formulario
const formularioConvenio = reactive({
  nombre_institucion: '',
  tipo_institucion: '',
  nit: '',
  contacto_nombre: '',
  contacto_telefono: '',
  contacto_email: '',
  fecha_inicio_convenio: null,
  fecha_fin_convenio: null,
  observaciones: '',
  estado_convenio: 'ACTIVO'
})

const cargandoFormulario = ref(false)

// Validaciones
const esquemaReglas = computed(() => ({
  nombre_institucion: {
    esRequerido,
    longitudMinima: longitudMinima(3),
    longitudMaxima: longitudMaxima(100)
  },
  tipo_institucion: { esRequerido },
  contacto_email: {
    esEmail: esEmail
  },
  fecha_inicio_convenio: { esRequerido }
}))

const $v = useVuelidate(esquemaReglas, formularioConvenio)

// Computed
const textoBoton = computed(() =>
  props.esEdicion ? 'Actualizar Convenio' : 'Crear Convenio'
)

const tiposInstitucion = [
  'COLEGIO',
  'EMPRESA',
  'FUNDACION',
  'ONG',
  'OTRO'
]

// Funciones
const guardar = async () => {
  const esValido = await validarFormulario($v.value)
  if (!esValido) return

  cargandoFormulario.value = true

  try {
    const datos = { ...formularioConvenio }
    await emit('guardar', datos)
    limpiarFormulario()
  } catch (error) {
    console.error('Error al guardar:', error)
  } finally {
    cargandoFormulario.value = false
  }
}

const limpiarFormulario = () => {
  Object.assign(formularioConvenio, {
    nombre_institucion: '',
    tipo_institucion: '',
    nit: '',
    contacto_nombre: '',
    contacto_telefono: '',
    contacto_email: '',
    fecha_inicio_convenio: null,
    fecha_fin_convenio: null,
    observaciones: '',
    estado_convenio: 'ACTIVO'
  })
  $v.value.$reset()
}

const cancelar = () => {
  limpiarFormulario()
  emit('cancelar')
}

const cargarDatosConvenio = (convenio) => {
  if (!convenio) return

  formularioConvenio.nombre_institucion = convenio.nombre_institucion
  formularioConvenio.tipo_institucion = convenio.tipo_institucion
  formularioConvenio.nit = convenio.nit || ''
  formularioConvenio.contacto_nombre = convenio.contacto_nombre || ''
  formularioConvenio.contacto_telefono = convenio.contacto_telefono || ''
  formularioConvenio.contacto_email = convenio.contacto_email || ''
  formularioConvenio.fecha_inicio_convenio = convenio.fecha_inicio_convenio
  formularioConvenio.fecha_fin_convenio = convenio.fecha_fin_convenio
  formularioConvenio.observaciones = convenio.observaciones || ''
  formularioConvenio.estado_convenio = convenio.estado_convenio
}

// Watchers
watch(() => props.convenio, (convenio) => {
  if (convenio && props.esEdicion) {
    cargarDatosConvenio(convenio)
  }
}, { immediate: true })
</script>

<template>
  <div class="formulario-convenio">
    <v-card-text class="pa-6">
      <v-form>
        <!-- Sección 1: Información de la Institución -->
        <div class="mb-6">
          <h3 class="text-h6 mb-4 text-primary">
            <v-icon start color="primary">mdi-domain</v-icon>
            Información de la Institución
          </h3>

          <v-row>
            <v-col cols="12" md="8">
              <v-text-field
                v-model="formularioConvenio.nombre_institucion"
                :error-messages="obtenerErroresCampo($v.nombre_institucion)"
                label="Nombre de la Institución *"
                variant="outlined"
                prepend-inner-icon="mdi-office-building"
                :disabled="cargandoFormulario"
                hint="Nombre completo de la institución"
                persistent-hint
              />
            </v-col>

            <v-col cols="12" md="4">
              <v-select
                v-model="formularioConvenio.tipo_institucion"
                :items="tiposInstitucion"
                :error-messages="obtenerErroresCampo($v.tipo_institucion)"
                label="Tipo de Institución *"
                variant="outlined"
                prepend-inner-icon="mdi-format-list-bulleted"
                :disabled="cargandoFormulario"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioConvenio.nit"
                label="NIT"
                variant="outlined"
                prepend-inner-icon="mdi-card-account-details"
                :disabled="cargandoFormulario"
                hint="Número de Identificación Tributaria (opcional)"
                persistent-hint
              />
            </v-col>
          </v-row>
        </div>

        <v-divider class="my-6" />

        <!-- Sección 2: Datos de Contacto -->
        <div class="mb-6">
          <h3 class="text-h6 mb-4 text-primary">
            <v-icon start color="primary">mdi-account-box</v-icon>
            Datos de Contacto
          </h3>

          <v-row>
            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioConvenio.contacto_nombre"
                label="Nombre del Contacto"
                variant="outlined"
                prepend-inner-icon="mdi-account"
                :disabled="cargandoFormulario"
                hint="Persona de contacto en la institución"
                persistent-hint
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioConvenio.contacto_telefono"
                label="Teléfono"
                variant="outlined"
                prepend-inner-icon="mdi-phone"
                :disabled="cargandoFormulario"
                hint="Número de contacto principal"
                persistent-hint
              />
            </v-col>

            <v-col cols="12">
              <v-text-field
                v-model="formularioConvenio.contacto_email"
                :error-messages="obtenerErroresCampo($v.contacto_email)"
                label="Correo Electrónico"
                type="email"
                variant="outlined"
                prepend-inner-icon="mdi-email"
                :disabled="cargandoFormulario"
                hint="Email de contacto institucional"
                persistent-hint
              />
            </v-col>
          </v-row>
        </div>

        <v-divider class="my-6" />

        <!-- Sección 3: Vigencia del Convenio -->
        <div class="mb-6">
          <h3 class="text-h6 mb-4 text-primary">
            <v-icon start color="primary">mdi-calendar-clock</v-icon>
            Vigencia del Convenio
          </h3>

          <v-row>
            <v-col cols="12" md="6">
              <v-date-input
                v-model="formularioConvenio.fecha_inicio_convenio"
                :error-messages="obtenerErroresCampo($v.fecha_inicio_convenio)"
                label="Fecha Inicio Convenio *"
                variant="outlined"
                :disabled="cargandoFormulario"
                hint="Fecha de inicio del convenio"
                persistent-hint
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-date-input
                v-model="formularioConvenio.fecha_fin_convenio"
                label="Fecha Fin Convenio"
                variant="outlined"
                :disabled="cargandoFormulario"
                clearable
                hint="Dejar vacío si el convenio no tiene fecha de término"
                persistent-hint
              />
            </v-col>

            <v-col cols="12">
              <v-textarea
                v-model="formularioConvenio.observaciones"
                label="Observaciones"
                variant="outlined"
                prepend-inner-icon="mdi-text"
                :disabled="cargandoFormulario"
                rows="3"
                hint="Información adicional sobre el convenio"
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
            <strong>Importante:</strong> Los campos marcados con (*) son obligatorios.
            Asegúrate de completar toda la información antes de guardar el convenio.
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
.formulario-convenio {
  .v-divider {
    border-color: rgba(var(--v-theme-on-surface), 0.08);
  }
}

// Responsive
@media (max-width: 600px) {
  .formulario-convenio {
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
