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
import imagenNoDisponible from '@/assets/images/img_default.png'

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
const archivoImagen = ref(null)
const previewImagen = ref(null)
const arrastrando = ref(false)

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

const $v = useVuelidate(esquemaReglas, formularioNoticia)

// Computed
const textoBoton = computed(() =>
  props.esEdicion ? 'Actualizar Noticia' : 'Publicar Noticia'
)

const tieneImagen = computed(() => previewImagen.value !== null && previewImagen.value !== '')

const obtenerImagenPreview = computed(() => {
  return previewImagen.value || imagenNoDisponible
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
const procesarArchivo = (file) => {
  if (!file) return

  if (!(file instanceof File)) {
    console.error('No es un archivo válido')
    return
  }

  // Validar tamaño (10MB)
  const maxSize = 10 * 1024 * 1024
  if (file.size > maxSize) {
    alert('La imagen es muy grande. Máximo: 10MB')
    return
  }

  // Validar tipo
  if (!file.type.startsWith('image/')) {
    alert('Solo se permiten imágenes')
    return
  }

  archivoImagen.value = file

  // Preview
  const reader = new FileReader()
  reader.onload = (e) => {
    previewImagen.value = e.target.result
  }
  reader.readAsDataURL(file)
}

const onArchivoSeleccionado = (file) => {
  procesarArchivo(file)
}

const editarImagen = () => {
  abrirSelectorArchivo()
}

const abrirSelectorArchivo = () => {
  document.getElementById('file-input-hidden').click()
}

// Preparar datos para envío
const guardar = async () => {
  const esValido = await validarFormulario($v.value)
  if (!esValido) return

  cargandoFormulario.value = true

  try {
    const formData = new FormData()

    if (archivoImagen.value) {
      formData.append('file', archivoImagen.value)
    }

    const datos = {
      id_aca_unidad: formularioNoticia.id_aca_unidad,
      titulo: formularioNoticia.titulo,
      resumen: formularioNoticia.resumen,
      enlace_externo: formularioNoticia.enlace_externo || null,
      fecha_noticia: formularioNoticia.fecha_noticia,
      es_destacada: formularioNoticia.es_destacada,
      orden_prioridad: formularioNoticia.orden_prioridad
    }

    if (props.esEdicion && props.noticia?.imagen_uri) {
      datos.imagen_uri_antigua = props.noticia.imagen_uri
    }

    formData.append('datos', JSON.stringify(datos))

    emit('guardar', formData)
    limpiarFormulario()
  } catch (error) {
    console.error('Error al preparar datos:', error)
    alert('Error al preparar los datos')
  } finally {
    cargandoFormulario.value = false
  }
}

const cargarDatosNoticia = (noticia) => {
  if (!noticia) {
    previewImagen.value = null
    return
  }

  formularioNoticia.id_aca_unidad = noticia.id_aca_unidad
  formularioNoticia.titulo = noticia.titulo
  formularioNoticia.resumen = noticia.resumen
  formularioNoticia.enlace_externo = noticia.enlace_externo || ''
  formularioNoticia.fecha_noticia = noticia.fecha_noticia ? new Date(noticia.fecha_noticia) : new Date()
  formularioNoticia.es_destacada = noticia.es_destacada || false
  formularioNoticia.orden_prioridad = noticia.orden_prioridad || 0

  // 👇 Solo asignar si realmente hay imagen
  if (noticia.imagen_url || noticia.imagen_uri) {
    previewImagen.value = noticia.imagen_url || noticia.imagen_uri
  } else {
    previewImagen.value = null
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
  <div class="formulario-noticia-pro">
    <!-- Zona de Imagen Principal -->
    <div class="imagen-section">
      <!-- Preview Grande (solo si hay imagen) -->
      <div v-if="tieneImagen" class="imagen-preview-container">
        <v-img
          :src="previewImagen"
          aspect-ratio="16/9"
          cover
          class="imagen-preview"
        >
          <template #error>
            <!-- Si la imagen falla, mostrar el file-upload -->
            <div class="error-fallback">
              <v-file-upload
                v-model="archivoImagen"
                label="Error al cargar imagen - Selecciona otra"
                variant="outlined"
                prepend-icon="mdi-image-plus"
                accept="image/*"
                :disabled="cargandoFormulario"
                show-size
                scrim
                @update:model-value="onArchivoSeleccionado"
                class="ma-4 w-100"
              />
            </div>
          </template>
        </v-img>

        <!-- Overlay solo con botón editar -->
        <div class="imagen-overlay">
          <v-btn
            icon="mdi-pencil"
            color="white"
            size="large"
            @click="editarImagen"
            :disabled="cargandoFormulario"
          >
            <v-icon>mdi-pencil</v-icon>
            <v-tooltip activator="parent" location="bottom">Cambiar imagen</v-tooltip>
          </v-btn>
        </div>
      </div>

      <!-- File Upload visible cuando NO hay imagen -->
      <div v-else class="file-upload-container">
        <v-file-upload
          v-model="archivoImagen"
          label="Seleccionar imagen de portada"
          variant="outlined"
          prepend-icon="mdi-image-plus"
          accept="image/*"
          :disabled="cargandoFormulario"
          show-size
          scrim
          chips
          @update:model-value="onArchivoSeleccionado"
          class="ma-6 w-100"
        >
          <template #hint>
            <div class="text-center mt-2">
              PNG, JPG, WEBP, GIF • Máximo 10MB
            </div>
          </template>
        </v-file-upload>
      </div>
      <input
        id="file-input-hidden"
        type="file"
        accept="image/*"
        style="display: none"
        @change="(e) => onArchivoSeleccionado(e.target.files[0])"
      >
    </div>

    <!-- Contenido del formulario -->
    <v-card-text class="pa-6">
      <v-form>
        <!-- Título Grande -->
        <v-text-field
          v-model="formularioNoticia.titulo"
          :error-messages="obtenerErroresCampo($v.titulo)"
          placeholder="Título de tu noticia..."
          variant="outlined"
          :disabled="cargandoFormulario"
          counter="255"
          class="titulo-field mb-4"
        >
          <template #prepend-inner>
            <v-icon color="primary">mdi-format-title</v-icon>
          </template>
        </v-text-field>

        <!-- Info Básica en Grid -->
        <v-row class="mb-4">
          <v-col cols="12" md="6">
            <v-select
              v-model="formularioNoticia.id_aca_unidad"
              :items="unidades"
              :error-messages="obtenerErroresCampo($v.id_aca_unidad)"
              item-title="nombre_unidad"
              item-value="id_aca_unidad"
              label="Unidad que publica"
              variant="outlined"
              :disabled="cargandoFormulario"
            >
              <template #prepend-inner>
                <v-icon>mdi-domain</v-icon>
              </template>
            </v-select>
          </v-col>

          <v-col cols="12" md="6">
            <v-date-input
              v-model="formularioNoticia.fecha_noticia"
              :error-messages="obtenerErroresCampo($v.fecha_noticia)"
              label="Fecha de publicación"
              variant="outlined"
              :disabled="cargandoFormulario"
            >
              <template #prepend-inner>
                <v-icon>mdi-calendar</v-icon>
              </template>
            </v-date-input>
          </v-col>
        </v-row>

        <!-- Contenido Principal -->
        <v-textarea
          v-model="formularioNoticia.resumen"
          :error-messages="obtenerErroresCampo($v.resumen)"
          label="Contenido de la noticia"
          placeholder="Escribe aquí el contenido completo de tu noticia..."
          variant="outlined"
          :disabled="cargandoFormulario"
          counter="2000"
          rows="8"
          auto-grow
          class="mb-4"
        >
          <template #prepend-inner>
            <v-icon>mdi-text</v-icon>
          </template>
        </v-textarea>

        <!-- Configuración Avanzada -->
        <v-expansion-panels class="mb-4">
          <v-expansion-panel>
            <v-expansion-panel-title>
              <div class="d-flex align-center">
                <v-icon class="mr-2">mdi-cog</v-icon>
                Configuración Avanzada
              </div>
            </v-expansion-panel-title>
            <v-expansion-panel-text>
              <v-row>
                <!-- Prioridad -->
                <v-col cols="12" md="6">
                  <v-select
                    v-model="formularioNoticia.orden_prioridad"
                    :items="opcionesPrioridad"
                    item-title="titulo"
                    item-value="valor"
                    label="Prioridad"
                    variant="outlined"
                    :disabled="cargandoFormulario"
                  >
                    <template #prepend-inner>
                      <v-icon>mdi-priority-high</v-icon>
                    </template>

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
                        <span>{{ item.raw.titulo }}</span>
                      </div>
                    </template>
                  </v-select>
                </v-col>

                <!-- Enlace Externo -->
                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="formularioNoticia.enlace_externo"
                    label="Enlace externo (opcional)"
                    placeholder="https://..."
                    variant="outlined"
                    :disabled="cargandoFormulario"
                  >
                    <template #prepend-inner>
                      <v-icon>mdi-link</v-icon>
                    </template>
                  </v-text-field>
                </v-col>

                <!-- Destacada -->
                <v-col cols="12">
                  <v-card variant="outlined" class="pa-4">
                    <div class="d-flex align-center justify-space-between">
                      <div class="d-flex align-center">
                        <v-icon color="warning" class="mr-3" size="large">mdi-star</v-icon>
                        <div>
                          <div class="text-subtitle-1 font-weight-medium">Noticia Destacada</div>
                          <div class="text-caption text-medium-emphasis">
                            Aparecerá primero en el carrusel
                          </div>
                        </div>
                      </div>
                      <v-switch
                        v-model="formularioNoticia.es_destacada"
                        color="warning"
                        hide-details
                        :disabled="cargandoFormulario"
                      ></v-switch>
                    </div>
                  </v-card>
                </v-col>
              </v-row>
            </v-expansion-panel-text>
          </v-expansion-panel>
        </v-expansion-panels>
      </v-form>
    </v-card-text>

    <!-- Acciones Fijas -->
    <v-divider></v-divider>
    <v-card-actions class="pa-6 bg-surface">
      <v-spacer></v-spacer>
      <v-btn
        size="large"
        variant="text"
        @click="cancelar"
        :disabled="cargandoFormulario"
      >
        Cancelar
      </v-btn>
      <v-btn
        size="large"
        color="primary"
        variant="elevated"
        :loading="cargandoFormulario"
        @click="guardar"
      >
        <v-icon start>{{ props.esEdicion ? 'mdi-check' : 'mdi-send' }}</v-icon>
        {{ textoBoton }}
      </v-btn>
    </v-card-actions>
  </div>
</template>

<style lang="scss" scoped>
.formulario-noticia-pro {
  .imagen-section {
    position: relative;
    background: #f5f5f5;

    .file-upload-container {
      min-height: 200px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .error-fallback {
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: rgba(var(--v-theme-error), 0.1);
    }

    .imagen-preview-container {
      position: relative;
      max-height: 400px;
      overflow: hidden;

      .imagen-preview {
        width: 100%;
      }

      .imagen-overlay {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 16px;
        opacity: 0;
        transition: opacity 0.3s ease;

        &:hover {
          opacity: 1;
        }
      }
    }
  }

  .titulo-field {
    :deep(.v-field__input) {
      font-size: 1.5rem;
      font-weight: 500;
      line-height: 1.4;
    }
  }

  .v-card-text {
    max-height: 60vh;
    overflow-y: auto;
  }
}

@media (max-width: 600px) {
  .formulario-noticia-pro {
    .titulo-field {
      :deep(.v-field__input) {
        font-size: 1.25rem;
      }
    }

    .v-card-actions {
      flex-direction: column;
      gap: 8px;

      .v-btn {
        width: 100%;
      }
    }
  }
}
</style>
