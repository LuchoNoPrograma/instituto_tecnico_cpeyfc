<script setup>
import { ref, watch, computed, reactive } from 'vue'
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
  validarFormulario,
  resetearValidaciones
} from '@/helpers/validations'

// Props
const props = defineProps({
  persona: {
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
const formularioPersona = reactive({
  nombre: '',
  ap_paterno: '',
  ap_materno: '',
  ci: '',
  nro_celular: '',
  correo: '',
  fecha_nacimiento: null
})

const cargandoFormulario = ref(false)

const esquemaReglas = computed(() => ({
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
  ci: {
    esRequerido,
    longitudMinima: longitudMinima(5),
    longitudMaxima: longitudMaxima(20),
    ciBoliviano
  },
  nro_celular: {
    esRequerido,
    longitudMinima: longitudMinima(7),
    longitudMaxima: longitudMaxima(20),
    celularBoliviano
  },
  correo: {
    esEmail,
    longitudMaxima: longitudMaxima(55)
  },
  fecha_nacimiento: {
    esRequerido,
    edadMinima: edadMinima(4),
    noFuturo
  }
}))

// Instancia de Vuelidate
const $v = useVuelidate(esquemaReglas, formularioPersona)

// Computed para títulos y botones dinámicos
const textoBoton = computed(() =>
  props.esEdicion ? 'Actualizar' : 'Guardar'
)

const iconoBoton = computed(() =>
  props.esEdicion ? 'mdi-account-edit' : 'mdi-account-plus'
)

// Funciones
const limpiarFormulario = () => {
  Object.assign(formularioPersona, {
    nombre: '',
    ap_paterno: '',
    ap_materno: '',
    ci: '',
    nro_celular: '',
    correo: '',
    fecha_nacimiento: null
  })
  resetearValidaciones($v.value)
}

const cargarDatosPersona = () => {
  if (props.persona) {
    Object.assign(formularioPersona, {
      nombre: props.persona.nombre || '',
      ap_paterno: props.persona.ap_paterno || '',
      ap_materno: props.persona.ap_materno || '',
      ci: props.persona.ci || '',
      nro_celular: props.persona.nro_celular || '',
      correo: props.persona.correo || '',
      fecha_nacimiento: props.persona.fecha_nacimiento || null
    })
  } else {
    limpiarFormulario()
  }
  resetearValidaciones($v.value)
}

const guardar = async () => {
  const esValido = await validarFormulario($v.value)
  if (!esValido) return

  cargandoFormulario.value = true

  try {
    const datos = { ...formularioPersona }
    await emit('guardar', datos)
    limpiarFormulario()
  } catch (error) {
    console.error('Error al guardar:', error)
  } finally {
    cargandoFormulario.value = false
  }
}

const cancelar = () => {
  limpiarFormulario()
  emit('cancelar')
}

// Watchers
watch(() => props.persona, () => {
  cargarDatosPersona()
}, { immediate: true, deep: true })

// Cargar datos iniciales
cargarDatosPersona()
</script>

<template>
  <div class="formulario-persona">
    <v-card-text class="pa-6">
      <v-form @submit.prevent="guardar" novalidate>
        <v-row>
          <v-col cols="12" md="6">
            <v-text-field
              v-model="formularioPersona.nombre"
              :error-messages="obtenerErroresCampo($v.nombre)"
              label="Nombre *"
              variant="outlined"
              prepend-inner-icon="mdi-account"
              :disabled="cargandoFormulario"
              @blur="$v.nombre.$touch"
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="6">
            <v-text-field
              v-model="formularioPersona.ap_paterno"
              :error-messages="obtenerErroresCampo($v.ap_paterno)"
              label="Apellido Paterno *"
              variant="outlined"
              :disabled="cargandoFormulario"
              @blur="$v.ap_paterno.$touch"
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="6">
            <v-text-field
              v-model="formularioPersona.ap_materno"
              :error-messages="obtenerErroresCampo($v.ap_materno)"
              label="Apellido Materno"
              variant="outlined"
              :disabled="cargandoFormulario"
              @blur="$v.ap_materno.$touch"
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="6">
            <v-text-field
              v-model="formularioPersona.ci"
              :error-messages="obtenerErroresCampo($v.ci)"
              label="Carnet de Identidad *"
              variant="outlined"
              prepend-inner-icon="mdi-card-account-details"
              :disabled="cargandoFormulario"
              placeholder="1234567"
              @blur="$v.ci.$touch"
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="6">
            <v-text-field
              v-model="formularioPersona.nro_celular"
              :error-messages="obtenerErroresCampo($v.nro_celular)"
              label="Número de Celular *"
              variant="outlined"
              prepend-inner-icon="mdi-cellphone"
              :disabled="cargandoFormulario"
              placeholder="7xxxxxxx"
              @blur="$v.nro_celular.$touch"
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="6">
            <v-text-field
              v-model="formularioPersona.correo"
              :error-messages="obtenerErroresCampo($v.correo)"
              label="Correo Electrónico"
              variant="outlined"
              prepend-inner-icon="mdi-email"
              :disabled="cargandoFormulario"
              type="email"
              placeholder="usuario@ejemplo.com"
              @blur="$v.correo.$touch"
            ></v-text-field>
          </v-col>

          <v-col cols="12">
            <v-date-input
              v-model="formularioPersona.fecha_nacimiento"
              :error-messages="obtenerErroresCampo($v.fecha_nacimiento)"
              label="Fecha de Nacimiento *"
              variant="outlined"
              :disabled="cargandoFormulario"
              :max="new Date().toISOString().split('T')[0]"
              @blur="$v.fecha_nacimiento.$touch"
            ></v-date-input>
          </v-col>
        </v-row>

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
      </v-form>
    </v-card-text>

    <v-card-actions class="pa-2">
      <v-spacer></v-spacer>
      <v-btn
        variant="text"
        @click="cancelar"
        :disabled="cargandoFormulario"
      >
        <v-icon start>mdi-close</v-icon>
        Cancelar
      </v-btn>

      <v-btn
        color="primary"
        variant="elevated"
        :loading="cargandoFormulario"
        :disabled="$v.$invalid"
        @click="guardar"
      >
        <v-icon start>{{ iconoBoton }}</v-icon>
        {{ textoBoton }}
      </v-btn>
    </v-card-actions>
  </div>
</template>

<style lang="scss" scoped>
.formulario-persona {
  .v-alert {
    border-radius: 8px;
  }

  .v-card-actions {
    background-color: #FAFAFA;
    border-top: 1px solid rgba(0, 0, 0, 0.08);
  }
}

// Responsive
@media (max-width: 600px) {
  .formulario-persona {
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
