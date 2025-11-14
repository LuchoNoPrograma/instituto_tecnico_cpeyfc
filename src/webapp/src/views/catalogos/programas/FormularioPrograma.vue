<script setup>
import { ref, computed, watch, onMounted, reactive } from 'vue'
import { api } from '@/services/api'
import { useVuelidate } from '@vuelidate/core'
import {
  esRequerido,
  longitudMinima,
  longitudMaxima,
  obtenerErroresCampo,
  validarFormulario as validarFormularioHelper
} from '@/helpers/validations'
import { showRegistrado, showModificado, showError, showCargando, cerrarCargando } from '@/utils/sweetalert'
import { Cropper } from 'vue-advanced-cropper'
import 'vue-advanced-cropper/dist/style.css'

const props = defineProps({
  programa: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['cerrar', 'guardado'])

const pasoActual = ref(1)
const totalPasos = 3
const cargando = ref(false)
const listaAreas = ref([])

// Estados de imagen
const imagenPreview = ref(null)
const imagenFile = ref(null)
const dialogCropper = ref(false)
const imagenOriginal = ref(null)
const cropperRef = ref(null)

// Estado habilidades
const habilidadInput = ref('')

const formulario = reactive({
  id_aca_programa: null,
  id_aca_area: null,
  nombre_programa: '',
  sigla: '',
  objetivo: '',
  imagen_url: null,
  habilidades: []
})

// Validaciones por paso
const reglasBasico = computed(() => ({
  nombre_programa: {
    esRequerido,
    longitudMinima: longitudMinima(3),
    longitudMaxima: longitudMaxima(150)
  },
  sigla: {
    esRequerido,
    longitudMinima: longitudMinima(2),
    longitudMaxima: longitudMaxima(10)
  },
  id_aca_area: {
    esRequerido
  }
}))

const reglasDescripcion = computed(() => ({
  objetivo: {
    longitudMaxima: longitudMaxima(1000)
  }
}))

const $vBasico = useVuelidate(reglasBasico, formulario)
const $vDescripcion = useVuelidate(reglasDescripcion, formulario)

const esEdicion = computed(() => !!props.programa)
const tituloDialog = computed(() => esEdicion.value ? 'Editar Programa' : 'Nuevo Programa')
const puedeAvanzar = computed(() => {
  if (pasoActual.value === 1) return !$vBasico.value.$invalid
  if (pasoActual.value === 2) return !$vDescripcion.value.$invalid
  return true
})

const obtenerAreas = async () => {
  try {
    const response = await api.get('/api/area/vista/areas-activas')
    listaAreas.value = response.data
  } catch (error) {
    console.error('Error al obtener áreas:', error)
  }
}

// Navegación
const siguientePaso = async () => {
  if (pasoActual.value === 1) {
    const esValido = await validarFormularioHelper($vBasico.value)
    if (!esValido) return
  }

  if (pasoActual.value === 2) {
    const esValido = await validarFormularioHelper($vDescripcion.value)
    if (!esValido) return
  }

  pasoActual.value++
}

const pasoAnterior = () => {
  if (pasoActual.value > 1) pasoActual.value--
}

// Imagen
const handleFileSelect = (event) => {
  const file = event.target.files[0]
  if (!file) return

  if (file.size > 10 * 1024 * 1024) {
    showError('La imagen no debe superar 10MB')
    return
  }

  if (!file.type.startsWith('image/')) {
    showError('Solo se permiten imágenes')
    return
  }

  const reader = new FileReader()
  reader.onload = (e) => {
    imagenOriginal.value = e.target.result
    dialogCropper.value = true
  }
  reader.readAsDataURL(file)
}

const confirmarRecorte = () => {
  const { canvas } = cropperRef.value.getResult()

  if (canvas) {
    canvas.toBlob((blob) => {
      imagenFile.value = new File([blob], 'programa.jpg', { type: 'image/jpeg' })
      imagenPreview.value = canvas.toDataURL('image/jpeg', 0.9)
      dialogCropper.value = false
    }, 'image/jpeg', 0.9)
  }
}

const cancelarRecorte = () => {
  dialogCropper.value = false
  imagenOriginal.value = null
}

const eliminarImagen = () => {
  imagenPreview.value = null
  imagenFile.value = null
  formulario.imagen_url = null
}

const editarImagen = () => {
  document.getElementById('file-input-programa').click()
}

// Habilidades
const agregarHabilidad = () => {
  const habilidad = habilidadInput.value.trim()
  if (!habilidad) return

  if (formulario.habilidades.includes(habilidad)) {
    showError('Esta habilidad ya fue agregada')
    return
  }

  formulario.habilidades.push(habilidad)
  habilidadInput.value = ''
}

const eliminarHabilidad = (index) => {
  formulario.habilidades = formulario.habilidades.filter((_, i) => i !== index)
}

const handleKeyDownHabilidad = (event) => {
  if (event.key === 'Enter') {
    event.preventDefault()
    agregarHabilidad()
  }
}

// Guardar
const guardarPrograma = async () => {
  if (habilidadInput.value && habilidadInput.value.trim()) {
    agregarHabilidad()
  }

  showCargando('Guardando programa...', 'Por favor espere')
  cargando.value = true

  try {
    const formData = new FormData()

    const datos = {
      id_aca_area: formulario.id_aca_area,
      nombre_programa: formulario.nombre_programa,
      sigla: formulario.sigla,
      objetivo: formulario.objetivo || null,
      habilidades: formulario.habilidades,
      imagen_url_antigua: formulario.imagen_url || null
    }

    formData.append('datos', JSON.stringify(datos))

    if (imagenFile.value) {
      formData.append('file', imagenFile.value)
    }

    if (esEdicion.value) {
      await api.put(`/api/programa/${formulario.id_aca_programa}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      cerrarCargando()
      await showModificado('Programa actualizado exitosamente')
    } else {
      await api.post('/api/programa', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      cerrarCargando()
      await showRegistrado('Programa registrado exitosamente')
    }

    emit('guardado')
  } catch (error) {
    cerrarCargando()
    console.error('Error al guardar programa:', error)
    await showError(error.response?.data?.message || 'Error al guardar el programa')
  } finally {
    cargando.value = false
  }
}

const cerrar = () => {
  emit('cerrar')
}

watch(() => props.programa, (nuevo) => {
  if (nuevo) {
    Object.assign(formulario, {
      id_aca_programa: nuevo.id_aca_programa,
      id_aca_area: nuevo.id_aca_area,
      nombre_programa: nuevo.nombre_programa,
      sigla: nuevo.sigla,
      objetivo: nuevo.objetivo || '',
      imagen_url: nuevo.imagen_url || null,
      habilidades: nuevo.habilidades ? nuevo.habilidades.split(', ') : []
    })

    if (nuevo.imagen_url) {
      imagenPreview.value = '/api' + nuevo.imagen_url
    }
  } else {
    Object.assign(formulario, {
      id_aca_programa: null,
      id_aca_area: null,
      nombre_programa: '',
      sigla: '',
      objetivo: '',
      imagen_url: null,
      habilidades: []
    })
    imagenPreview.value = null
    imagenFile.value = null
  }
  pasoActual.value = 1
}, { immediate: true })

onMounted(() => {
  obtenerAreas()
})
</script>

<template>
  <v-card>
    <v-card-title class="d-flex justify-space-between align-center bg-primary">
      <span class="text-h5 text-white">{{ tituloDialog }}</span>
      <v-btn icon="mdi-close" variant="text" color="white" @click="cerrar"></v-btn>
    </v-card-title>

    <v-card-text class="pa-6">
      <!-- Stepper -->
      <v-stepper v-model="pasoActual" class="mb-6" elevation="0">
        <v-stepper-header>
          <v-stepper-item
            :complete="pasoActual > 1"
            :value="1"
            title="Información Básica"
            subtitle="Programa y área"
          ></v-stepper-item>

          <v-divider></v-divider>

          <v-stepper-item
            :complete="pasoActual > 2"
            :value="2"
            title="Descripción e Imagen"
            subtitle="Objetivo y visual"
          ></v-stepper-item>

          <v-divider></v-divider>

          <v-stepper-item
            :value="3"
            title="Habilidades"
            subtitle="Tags del programa"
          ></v-stepper-item>
        </v-stepper-header>
      </v-stepper>

      <!-- PASO 1: Información Básica -->
      <div v-if="pasoActual === 1">
        <h3 class="text-h6 mb-4">Información Básica</h3>

        <v-row>
          <v-col cols="12">
            <v-text-field
              v-model="formulario.nombre_programa"
              label="Nombre del Programa *"
              variant="outlined"
              density="comfortable"
              prepend-inner-icon="mdi-school"
              :error-messages="obtenerErroresCampo($vBasico.nombre_programa)"
              @blur="$vBasico.nombre_programa.$touch()"
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="6">
            <v-text-field
              v-model="formulario.sigla"
              label="Sigla *"
              variant="outlined"
              density="comfortable"
              prepend-inner-icon="mdi-tag"
              :error-messages="obtenerErroresCampo($vBasico.sigla)"
              @blur="$vBasico.sigla.$touch()"
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="6">
            <v-select
              v-model="formulario.id_aca_area"
              label="Área Académica *"
              :items="listaAreas"
              item-title="nombre_area"
              item-value="id_aca_area"
              variant="outlined"
              density="comfortable"
              prepend-inner-icon="mdi-domain"
              :error-messages="obtenerErroresCampo($vBasico.id_aca_area)"
              @blur="$vBasico.id_aca_area.$touch()"
            ></v-select>
          </v-col>
        </v-row>
      </div>

      <!-- PASO 2: Descripción e Imagen -->
      <div v-if="pasoActual === 2">
        <h3 class="text-h6 mb-4">Descripción e Imagen</h3>

        <v-row>
          <v-col cols="12">
            <v-textarea
              v-model="formulario.objetivo"
              label="Objetivo del Programa (opcional)"
              variant="outlined"
              rows="4"
              prepend-inner-icon="mdi-text"
              :error-messages="obtenerErroresCampo($vDescripcion.objetivo)"
              @blur="$vDescripcion.objetivo.$touch()"
            ></v-textarea>
          </v-col>

          <!-- Imagen -->
          <v-col cols="12">
            <label class="text-subtitle-2 text-medium-emphasis mb-2 d-block">
              <v-icon size="small" class="mr-1">mdi-image</v-icon>
              Imagen Representativa (16:9 - opcional)
            </label>

            <!-- Preview -->
            <div v-if="imagenPreview" class="imagen-preview-container mb-4">
              <v-img
                :src="imagenPreview"
                aspect-ratio="16/9"
                cover
                class="rounded"
              ></v-img>

              <div class="imagen-overlay">
                <v-btn
                  icon="mdi-pencil"
                  color="white"
                  @click="editarImagen"
                >
                  <v-icon>mdi-pencil</v-icon>
                  <v-tooltip activator="parent">Cambiar imagen</v-tooltip>
                </v-btn>
                <v-btn
                  icon="mdi-delete"
                  color="error"
                  @click="eliminarImagen"
                >
                  <v-icon>mdi-delete</v-icon>
                  <v-tooltip activator="parent">Eliminar imagen</v-tooltip>
                </v-btn>
              </div>
            </div>

            <!-- Upload -->
            <v-file-upload
              v-else
              v-model="imagenFile"
              label="Seleccionar imagen"
              variant="outlined"
              prepend-icon="mdi-image-plus"
              accept="image/*"
              show-size
              chips
              @update:model-value="handleFileSelect"
            >
              <template #hint>
                <div class="text-caption text-center mt-2">
                  PNG, JPG, WEBP • Máximo 10MB • Se recortará a 16:9
                </div>
              </template>
            </v-file-upload>

            <input
              id="file-input-programa"
              type="file"
              accept="image/*"
              style="display: none"
              @change="handleFileSelect"
            >
          </v-col>
        </v-row>
      </div>

      <!-- PASO 3: Habilidades -->
      <div v-if="pasoActual === 3">
        <h3 class="text-h6 mb-4">Habilidades del Programa</h3>

        <v-row>
          <v-col cols="12">
            <v-text-field
              v-model="habilidadInput"
              label="Agregar habilidad"
              variant="outlined"
              density="comfortable"
              placeholder="Escribe y presiona Enter"
              prepend-inner-icon="mdi-star"
              append-inner-icon="mdi-plus"
              @click:append-inner="agregarHabilidad"
              @keydown="handleKeyDownHabilidad"
            ></v-text-field>
          </v-col>

          <v-col cols="12">
            <v-card variant="outlined" min-height="200">
              <v-card-title class="text-subtitle-1">
                Habilidades Agregadas
              </v-card-title>
              <v-card-text>
                <div v-if="formulario.habilidades.length === 0" class="text-center text-grey pa-4">
                  No hay habilidades agregadas
                </div>
                <div v-else class="d-flex flex-wrap ga-2">
                  <v-chip
                    v-for="(habilidad, index) in formulario.habilidades"
                    :key="index"
                    closable
                    color="primary"
                    @click:close="eliminarHabilidad(index)"
                  >
                    {{ habilidad }}
                  </v-chip>
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </div>
    </v-card-text>

    <!-- Acciones -->
    <v-card-actions class="pa-6 pt-0">
      <v-btn
        v-if="pasoActual > 1"
        variant="text"
        @click="pasoAnterior"
        :disabled="cargando"
      >
        <v-icon start>mdi-arrow-left</v-icon>
        Anterior
      </v-btn>

      <v-spacer></v-spacer>

      <v-btn
        variant="text"
        @click="cerrar"
        :disabled="cargando"
      >
        Cancelar
      </v-btn>

      <v-btn
        v-if="pasoActual < totalPasos"
        color="primary"
        variant="elevated"
        :disabled="!puedeAvanzar"
        @click="siguientePaso"
      >
        Siguiente
        <v-icon end>mdi-arrow-right</v-icon>
      </v-btn>

      <v-btn
        v-if="pasoActual === totalPasos"
        color="primary"
        variant="elevated"
        :loading="cargando"
        @click="guardarPrograma"
      >
        <v-icon start>mdi-content-save</v-icon>
        {{ esEdicion ? 'Actualizar' : 'Guardar' }} Programa
      </v-btn>
    </v-card-actions>

    <!-- Dialog Cropper -->
    <v-dialog v-model="dialogCropper" max-width="800px" persistent>
      <v-card>
        <v-card-title class="bg-primary text-white">
          <v-icon start>mdi-crop</v-icon>
          Ajustar Imagen (16:9)
        </v-card-title>
        <v-card-text class="pa-6">
          <div class="cropper-container">
            <Cropper
              ref="cropperRef"
              :src="imagenOriginal"
              :stencil-props="{ aspectRatio: 16/9 }"
            />
          </div>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="cancelarRecorte">Cancelar</v-btn>
          <v-btn color="primary" @click="confirmarRecorte">
            <v-icon start>mdi-check</v-icon>
            Confirmar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-card>
</template>

<style scoped>
.imagen-preview-container {
  position: relative;
  overflow: hidden;
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
}

.imagen-preview-container:hover .imagen-overlay {
  opacity: 1;
}

.cropper-container {
  height: 500px;
  background: #f5f5f5;
}

.v-stepper {
  box-shadow: none !important;
  background: transparent !important;
}
</style>
