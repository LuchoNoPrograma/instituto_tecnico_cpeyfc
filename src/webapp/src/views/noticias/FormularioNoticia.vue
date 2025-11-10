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
import { Cropper } from 'vue-advanced-cropper'
import 'vue-advanced-cropper/dist/style.css'
import TiptapEditor from '@/components/TiptapEditor.vue'

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
  contenido: '',
  imagen_uri: '',
  fecha_noticia: new Date(),
  orden_prioridad: 0
})

// Estados
const cargandoFormulario = ref(false)
const unidades = ref([])
const archivoImagen = ref(null)
const previewImagen = ref(null)

// Estados del cropper
const dialogCropper = ref(false)
const imagenOriginal = ref(null)
const cropperRef = ref(null)

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
  contenido: {
    esRequerido,
    longitudMinima: longitudMinima(20)
  },
  fecha_noticia: { esRequerido }
}))

const $v = useVuelidate(esquemaReglas, formularioNoticia)

// Computed
const textoBoton = computed(() =>
  props.esEdicion ? 'Actualizar Noticia' : 'Publicar Noticia'
)

const tieneImagen = computed(() => previewImagen.value !== null && previewImagen.value !== '')

// Cargar datos
const cargarUnidades = async () => {
  try {
    const response = await api.get('/api/unidad/vista/unidades-activas')
    unidades.value = response.data
  } catch (error) {
    console.error('Error al cargar unidades:', error)
  }
}

// Manejo de imágenes con cropper
const onArchivoSeleccionado = (file) => {
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

  // Cargar imagen para el cropper
  const reader = new FileReader()
  reader.onload = (e) => {
    imagenOriginal.value = e.target.result
    dialogCropper.value = true
  }
  reader.readAsDataURL(file)
}

const confirmarRecorte = async () => {
  const { canvas } = cropperRef.value.getResult()

  if (canvas) {
    // Convertir canvas a blob
    canvas.toBlob((blob) => {
      // Crear archivo desde blob
      const archivoRecortado = new File([blob], 'noticia.jpg', { type: 'image/jpeg' })
      archivoImagen.value = archivoRecortado

      // Generar preview
      const urlPreview = canvas.toDataURL('image/jpeg', 0.9)
      previewImagen.value = urlPreview

      dialogCropper.value = false
    }, 'image/jpeg', 0.9)
  }
}

const cancelarRecorte = () => {
  dialogCropper.value = false
  imagenOriginal.value = null
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
      contenido: formularioNoticia.contenido,
      fecha_noticia: formularioNoticia.fecha_noticia,
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
  formularioNoticia.contenido = noticia.contenido

  if (noticia.fecha_noticia) {
    const fechaParts = noticia.fecha_noticia.split('-') // "2025-11-08"
    formularioNoticia.fecha_noticia = new Date(fechaParts[0], fechaParts[1] - 1, fechaParts[2])
  }

  formularioNoticia.orden_prioridad = noticia.orden_prioridad || 0

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
    contenido: '',
    imagen_uri: '',
    fecha_noticia: new Date(),
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
          aspect-ratio="4/3"
          cover
          class="imagen-preview"
        >
          <template #error>
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

        <!-- Overlay con botón editar -->
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
              PNG, JPG, WEBP, GIF • Máximo 10MB • Se recortará a formato 16:9
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

        <!-- Contenido Principal con Editor Rich Text -->
        <div class="mb-4">
          <label class="text-subtitle-2 text-medium-emphasis mb-2 d-block">
            Contenido de la noticia *
          </label>
          <TiptapEditor
            v-model="formularioNoticia.contenido"
            placeholder="Escribe aquí el contenido completo de tu noticia con formato..."
            :disabled="cargandoFormulario"
            upload-endpoint="/api/noticia/upload/imagen"
            :enable-image-crop="true"
          />
          <div v-if="$v.contenido.$errors.length" class="text-error text-caption mt-1">
            {{ $v.contenido.$errors[0].$message }}
          </div>
        </div>

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

    <!-- Dialog del Cropper -->
    <v-dialog
      v-model="dialogCropper"
      max-width="900px"
      persistent
    >
      <v-card>
        <v-card-title class="bg-primary text-white pa-4">
          <v-icon start>mdi-crop</v-icon>
          Ajustar Imagen (Formato 16:9)
        </v-card-title>

        <v-card-text class="pa-6">
          <div class="cropper-container">
            <Cropper
              ref="cropperRef"
              class="cropper"
              :src="imagenOriginal"
              :stencil-props="{
                aspectRatio: 16/9
              }"
            />
          </div>
          <div class="text-caption text-center text-medium-emphasis mt-4">
            Arrastra y ajusta la imagen para seleccionar el área que deseas mostrar
          </div>
        </v-card-text>

        <v-card-actions class="pa-4">
          <v-spacer></v-spacer>
          <v-btn
            variant="text"
            @click="cancelarRecorte"
          >
            Cancelar
          </v-btn>
          <v-btn
            color="primary"
            variant="elevated"
            @click="confirmarRecorte"
          >
            <v-icon start>mdi-check</v-icon>
            Confirmar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
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

  .cropper-container {
    height: 500px;
    background: #f5f5f5;

    .cropper {
      height: 100%;
      background: #f5f5f5;
    }
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

    .cropper-container {
      height: 300px;
    }
  }
}
</style>
