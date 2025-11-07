<script setup>
import { ref, watch, computed, reactive, onMounted } from 'vue'
import { useVuelidate } from '@vuelidate/core'
import {
  esRequerido,
  longitudMinima,
  longitudMaxima,
  obtenerErroresCampo,
  validarFormulario
} from '@/helpers/validations'
import { api } from '@/services/api'

// Props
const props = defineProps({
  noticia: {
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
const formularioNoticia = reactive({
  id_aca_unidad: null,
  titulo: '',
  resumen: '',
  imagen_uri: '',
  enlace_externo: '',
  fecha_noticia: new Date(),
  es_destacada: false,
  orden_prioridad: 0
})

// Estados
const cargandoFormulario = ref(false)
const unidades = ref([])

// Validaciones
const esquemaReglas = computed(() => ({
  id_aca_unidad: { esRequerido },
  titulo: {
    esRequerido,
    longitudMinima: longitudMinima(5),
    longitudMaxima: longitudMaxima(255)
  },
  resumen: {
    esRequerido,
    longitudMinima: longitudMinima(20),
    longitudMaxima: longitudMaxima(2000)
  },
  fecha_noticia: { esRequerido }
}))

// Instancia de Vuelidate
const $v = useVuelidate(esquemaReglas, formularioNoticia)

// Computed
const textoBoton = computed(() =>
  props.esEdicion ? 'Actualizar Noticia' : 'Crear Noticia'
)

// Cargar datos
const cargarUnidades = async () => {
  try {
    const response = await api.get('/api/unidad/vista/unidades-activas')
    unidades.value = response.data
  } catch (error) {
    console.error('Error al cargar unidades:', error)
  }
}

// Preparar datos para envío
const guardar = async () => {
  const esValido = await validarFormulario($v.value)
  if (!esValido) return

  cargandoFormulario.value = true

  try {
    const datos = { ...formularioNoticia }
    await emit('guardar', datos)
    limpiarFormulario()
  } catch (error) {
    console.error('Error al guardar:', error)
  } finally {
    cargandoFormulario.value = false
  }
}

const limpiarFormulario = () => {
  Object.assign(formularioNoticia, {
    id_aca_unidad: null,
    titulo: '',
    resumen: '',
    imagen_uri: '',
    enlace_externo: '',
    fecha_noticia: new Date(),
    es_destacada: false,
    orden_prioridad: 0
  })
  $v.value.$reset()
}

const cancelar = () => {
  limpiarFormulario()
  emit('cancelar')
}

// Cargar datos al editar
const cargarDatosNoticia = (noticia) => {
  if (!noticia) return

  formularioNoticia.id_aca_unidad = noticia.id_aca_unidad
  formularioNoticia.titulo = noticia.titulo
  formularioNoticia.resumen = noticia.resumen
  formularioNoticia.imagen_uri = noticia.imagen_uri || ''
  formularioNoticia.enlace_externo = noticia.enlace_externo || ''
  formularioNoticia.fecha_noticia = noticia.fecha_noticia ? new Date(noticia.fecha_noticia) : new Date()
  formularioNoticia.es_destacada = noticia.es_destacada || false
  formularioNoticia.orden_prioridad = noticia.orden_prioridad || 0
}

// Watchers
watch(() => props.noticia, (noticia) => {
  if (noticia && props.esEdicion) {
    cargarDatosNoticia(noticia)
  }
}, { immediate: true })

onMounted(() => {
  cargarUnidades()
})
</script>

<template>
  <div class="formulario-noticia">
    <v-card-text class="pa-6">
      <v-form>
        <v-row>
          <!-- Unidad Académica -->
          <v-col cols="12">
            <v-select
              v-model="formularioNoticia.id_aca_unidad"
              :items="unidades"
              :error-messages="obtenerErroresCampo($v.id_aca_unidad)"
              item-title="nombre_unidad"
              item-value="id_aca_unidad"
              label="Unidad que publica *"
              variant="outlined"
              prepend-inner-icon="mdi-domain"
              :disabled="cargandoFormulario"
            >
              <template #item="{ props, item }">
                <v-list-item v-bind="props">
                  <template #title>{{ item.raw.nombre_unidad }}</template>
                  <template #subtitle v-if="item.raw.descripcion">
                    {{ item.raw.descripcion }}
                  </template>
                </v-list-item>
              </template>
            </v-select>
          </v-col>

          <!-- Título -->
          <v-col cols="12">
            <v-text-field
              v-model="formularioNoticia.titulo"
              :error-messages="obtenerErroresCampo($v.titulo)"
              label="Título de la noticia *"
              variant="outlined"
              prepend-inner-icon="mdi-format-title"
              :disabled="cargandoFormulario"
              counter="255"
              hint="Mínimo 5 caracteres"
              persistent-hint
            ></v-text-field>
          </v-col>

          <!-- Resumen/Descripción -->
          <v-col cols="12">
            <v-textarea
              v-model="formularioNoticia.resumen"
              :error-messages="obtenerErroresCampo($v.resumen)"
              label="Descripción de la noticia *"
              variant="outlined"
              prepend-inner-icon="mdi-text"
              :disabled="cargandoFormulario"
              counter="2000"
              rows="4"
              hint="Mínimo 20 caracteres"
              persistent-hint
            ></v-textarea>
          </v-col>

          <!-- Fecha de Noticia -->
          <v-col cols="12" md="6">
            <v-date-input
              v-model="formularioNoticia.fecha_noticia"
              :error-messages="obtenerErroresCampo($v.fecha_noticia)"
              label="Fecha de la noticia *"
              variant="outlined"
              prepend-inner-icon="mdi-calendar"
              :disabled="cargandoFormulario"
            ></v-date-input>
          </v-col>

          <!-- Orden Prioridad -->
          <v-col cols="12" md="6">
            <v-text-field
              v-model.number="formularioNoticia.orden_prioridad"
              label="Orden de prioridad"
              variant="outlined"
              prepend-inner-icon="mdi-sort-numeric-variant"
              type="number"
              min="0"
              :disabled="cargandoFormulario"
              hint="Mayor número = más prioritario (0 por defecto)"
              persistent-hint
            ></v-text-field>
          </v-col>

          <!-- Sección opcionales -->
          <v-col cols="12">
            <v-divider class="my-2"></v-divider>
            <div class="text-subtitle-2 text-medium-emphasis mb-4">Información Adicional (Opcional)</div>
          </v-col>

          <!-- Imagen URI -->
          <v-col cols="12" md="6">
            <v-text-field
              v-model="formularioNoticia.imagen_uri"
              label="URL de la imagen"
              variant="outlined"
              prepend-inner-icon="mdi-image"
              :disabled="cargandoFormulario"
              hint="URL o ruta de la imagen"
              persistent-hint
            ></v-text-field>
          </v-col>

          <!-- Enlace Externo -->
          <v-col cols="12" md="6">
            <v-text-field
              v-model="formularioNoticia.enlace_externo"
              label="Enlace externo"
              variant="outlined"
              prepend-inner-icon="mdi-link"
              :disabled="cargandoFormulario"
              hint="URL para más información"
              persistent-hint
            ></v-text-field>
          </v-col>

          <!-- Destacada -->
          <v-col cols="12">
            <v-switch
              v-model="formularioNoticia.es_destacada"
              label="Marcar como noticia destacada"
              color="warning"
              inset
              :disabled="cargandoFormulario"
              hint="Las noticias destacadas aparecen primero en el carrusel"
              persistent-hint
            >
              <template #prepend>
                <v-icon>mdi-star</v-icon>
              </template>
            </v-switch>
          </v-col>
        </v-row>
      </v-form>
    </v-card-text>

    <!-- Acciones -->
    <v-card-actions class="pa-6 pt-0">
      <v-spacer></v-spacer>

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
.formulario-noticia {
  .v-card-text {
    max-height: 70vh;
    overflow-y: auto;
  }
}

// Responsive
@media (max-width: 600px) {
  .formulario-noticia {
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
