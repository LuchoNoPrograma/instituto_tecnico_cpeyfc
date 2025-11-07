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
const subiendoImagen = ref(false)
const unidades = ref([])
const archivoImagen = ref(null)
const previewImagen = ref(null)

// Opciones de prioridad
const opcionesPrioridad = [
  { titulo: 'Baja', valor: 0, descripcion: 'Noticia normal', color: 'grey', icono: 'mdi-arrow-down' },
  { titulo: 'Media', valor: 5, descripcion: 'Noticia importante', color: 'warning', icono: 'mdi-minus' },
  { titulo: 'Alta', valor: 10, descripcion: 'Noticia prioritaria', color: 'error', icono: 'mdi-arrow-up' }
]

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

const prioridadSeleccionada = computed(() => {
  return opcionesPrioridad.find(p => p.valor === formularioNoticia.orden_prioridad) || opcionesPrioridad[0]
})

// Cargar datos
const cargarUnidades = async () => {
  try {
    const response = await api.get('/api/unidad/vista/unidades-activas')
    unidades.value = response.data
  } catch (error) {
    console.error('Error al cargar unidades:', error)
  }
}

// Manejo de imágenes
const onArchivoSeleccionado = (files) => {
  if (!files || files.length === 0) {
    archivoImagen.value = null
    previewImagen.value = null
    return
  }

  const file = files[0]
  archivoImagen.value = file

  // Generar preview
  const reader = new FileReader()
  reader.onload = (e) => {
    previewImagen.value = e.target.result
  }
  reader.readAsDataURL(file)
}

const eliminarImagen = () => {
  archivoImagen.value = null
  previewImagen.value = null
  formularioNoticia.imagen_uri = ''
}

const subirImagen = async () => {
  if (!archivoImagen.value) {
    return null
  }

  subiendoImagen.value = true

  try {
    const formData = new FormData()
    formData.append('file', archivoImagen.value)

    const response = await api.post('/api/archivo/noticia/imagen', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })

    if (response.data.success) {
      return response.data.url
    } else {
      throw new Error(response.data.message || 'Error al subir imagen')
    }
  } catch (error) {
    console.error('Error al subir imagen:', error)
    alert('Error al subir la imagen: ' + (error.response?.data?.message || error.message))
    throw error
  } finally {
    subiendoImagen.value = false
  }
}

// Preparar datos para envío
const guardar = async () => {
  const esValido = await validarFormulario($v.value)
  if (!esValido) return

  cargandoFormulario.value = true

  try {
    // Si hay una imagen nueva, subirla primero
    if (archivoImagen.value) {
      const urlImagen = await subirImagen()
      if (urlImagen) {
        formularioNoticia.imagen_uri = urlImagen
      }
    }

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
  archivoImagen.value = null
  previewImagen.value = null
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

  // Si hay imagen existente, mostrar preview
  if (noticia.imagen_uri) {
    previewImagen.value = noticia.imagen_uri
  }
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

          <!-- Prioridad Visual -->
          <v-col cols="12" md="6">
            <v-select
              v-model="formularioNoticia.orden_prioridad"
              :items="opcionesPrioridad"
              item-title="titulo"
              item-value="valor"
              label="Prioridad en el carrusel"
              variant="outlined"
              prepend-inner-icon="mdi-priority-high"
              :disabled="cargandoFormulario"
              hint="Define qué tan arriba aparecerá en el carrusel"
              persistent-hint
            >
              <template #item="{ props, item }">
                <v-list-item v-bind="props">
                  <template #prepend>
                    <v-icon :color="item.raw.color">{{ item.raw.icono }}</v-icon>
                  </template>
                  <template #title>
                    <span :class="`text-${item.raw.color}`">{{ item.raw.titulo }}</span>
                  </template>
                  <template #subtitle>
                    {{ item.raw.descripcion }}
                  </template>
                </v-list-item>
              </template>

              <template #selection="{ item }">
                <div class="d-flex align-center">
                  <v-icon :color="item.raw.color" size="small" class="mr-2">
                    {{ item.raw.icono }}
                  </v-icon>
                  <span>{{ item.raw.titulo }} - {{ item.raw.descripcion }}</span>
                </div>
              </template>
            </v-select>
          </v-col>

          <!-- Sección de imagen -->
          <v-col cols="12">
            <v-divider class="my-2"></v-divider>
            <div class="text-subtitle-2 text-medium-emphasis mb-4">
              <v-icon size="small" class="mr-1">mdi-image</v-icon>
              Imagen de la Noticia
            </div>
          </v-col>

          <!-- Subida de Imagen -->
          <v-col cols="12" md="6">
            <v-file-input
              v-model="archivoImagen"
              label="Seleccionar imagen"
              variant="outlined"
              prepend-icon=""
              prepend-inner-icon="mdi-image-plus"
              accept="image/png, image/jpeg, image/jpg, image/webp, image/gif"
              :disabled="cargandoFormulario"
              :loading="subiendoImagen"
              show-size
              hint="Formatos: PNG, JPG, WEBP, GIF. Máx: 5MB"
              persistent-hint
              @update:model-value="onArchivoSeleccionado"
            >
              <template #selection="{ fileNames }">
                <v-chip
                  color="primary"
                  size="small"
                  class="mr-2"
                >
                  <v-icon start>mdi-image</v-icon>
                  {{ fileNames[0] }}
                </v-chip>
              </template>
            </v-file-input>
          </v-col>

          <!-- Preview de Imagen -->
          <v-col cols="12" md="6">
            <div v-if="previewImagen" class="preview-container">
              <div class="text-caption mb-2 text-medium-emphasis">Vista previa:</div>
              <v-card variant="outlined" class="preview-card">
                <v-img
                  :src="previewImagen"
                  aspect-ratio="16/9"
                  cover
                  class="preview-image"
                >
                  <template #placeholder>
                    <div class="d-flex align-center justify-center fill-height">
                      <v-progress-circular indeterminate color="primary"></v-progress-circular>
                    </div>
                  </template>
                </v-img>
                <v-card-actions class="pa-2">
                  <v-spacer></v-spacer>
                  <v-btn
                    size="small"
                    color="error"
                    variant="text"
                    @click="eliminarImagen"
                    :disabled="cargandoFormulario"
                  >
                    <v-icon start>mdi-delete</v-icon>
                    Eliminar
                  </v-btn>
                </v-card-actions>
              </v-card>
            </div>
            <div v-else class="preview-placeholder">
              <v-icon size="64" color="grey-lighten-2">mdi-image-off-outline</v-icon>
              <div class="text-caption text-medium-emphasis mt-2">No hay imagen seleccionada</div>
            </div>
          </v-col>

          <!-- Sección opcionales -->
          <v-col cols="12">
            <v-divider class="my-2"></v-divider>
            <div class="text-subtitle-2 text-medium-emphasis mb-4">Información Adicional (Opcional)</div>
          </v-col>

          <!-- Enlace Externo -->
          <v-col cols="12">
            <v-text-field
              v-model="formularioNoticia.enlace_externo"
              label="Enlace externo"
              variant="outlined"
              prepend-inner-icon="mdi-link"
              :disabled="cargandoFormulario"
              hint="URL para más información sobre la noticia"
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
            >
              <template #prepend>
                <v-icon color="warning">mdi-star</v-icon>
              </template>
            </v-switch>
            <div class="text-caption text-medium-emphasis ml-12">
              Las noticias destacadas aparecen primero en el carrusel, independiente de su prioridad
            </div>
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
        :loading="cargandoFormulario || subiendoImagen"
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

  .preview-container {
    .preview-card {
      max-width: 300px;

      .preview-image {
        border-radius: 4px;
      }
    }
  }

  .preview-placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 180px;
    border: 2px dashed rgba(var(--v-theme-on-surface), 0.12);
    border-radius: 4px;
    background: rgba(var(--v-theme-surface-variant), 0.5);
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

    .preview-container .preview-card {
      max-width: 100%;
    }
  }
}
</style>
