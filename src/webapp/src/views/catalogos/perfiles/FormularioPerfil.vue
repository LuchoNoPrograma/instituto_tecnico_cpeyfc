<script setup>
import { ref, watch, computed } from 'vue'
import { api } from '@/services/api'
import { showError, showSuccess } from '@/utils/sweetalert'

const props = defineProps({
  perfil: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['cerrar', 'guardado'])

const formulario = ref({
  nombre_perfil: '',
  descripcion: ''
})

const guardando = ref(false)
const modoEdicion = computed(() => props.perfil !== null)

// Cargar datos si es edición
watch(() => props.perfil, (nuevoPerfil) => {
  if (nuevoPerfil) {
    formulario.value = {
      nombre_perfil: nuevoPerfil.nombre_perfil || '',
      descripcion: nuevoPerfil.descripcion || ''
    }
  } else {
    limpiarFormulario()
  }
}, { immediate: true })

const limpiarFormulario = () => {
  formulario.value = {
    nombre_perfil: '',
    descripcion: ''
  }
}

const validarFormulario = () => {
  if (!formulario.value.nombre_perfil || formulario.value.nombre_perfil.trim() === '') {
    showError('El nombre del perfil es requerido')
    return false
  }
  if (formulario.value.nombre_perfil.length > 50) {
    showError('El nombre del perfil no puede exceder 50 caracteres')
    return false
  }
  return true
}

const guardar = async () => {
  if (!validarFormulario()) return

  guardando.value = true
  try {
    const datos = {
      nombre_perfil: formulario.value.nombre_perfil.trim(),
      descripcion: formulario.value.descripcion?.trim() || null
    }

    let response
    if (modoEdicion.value) {
      response = await api.put(`/api/perfil-estudiante/${props.perfil.id_aca_perfil_estudiante}`, datos)
    } else {
      response = await api.post('/api/perfil-estudiante', datos)
    }

    if (response.data.success) {
      await showSuccess(response.data.message)
      emit('guardado')
    } else {
      await showError(response.data.message)
    }
  } catch (error) {
    console.error('Error al guardar perfil:', error)
    await showError('Error al guardar el perfil')
  } finally {
    guardando.value = false
  }
}

const cancelar = () => {
  emit('cerrar')
}
</script>

<template>
  <v-card>
    <v-card-title class="d-flex align-center pa-4 bg-primary">
      <v-icon class="mr-2">mdi-account-group</v-icon>
      <span>{{ modoEdicion ? 'Editar' : 'Nuevo' }} Perfil</span>
    </v-card-title>

    <v-divider></v-divider>

    <v-card-text class="pa-6">
      <v-form @submit.prevent="guardar">
        <v-row>
          <v-col cols="12">
            <v-text-field
              v-model="formulario.nombre_perfil"
              label="Nombre del perfil *"
              hint="Ej: Estudiante colegio, Docente, Niñ@s, Universitario"
              persistent-hint
              counter="50"
              maxlength="50"
              variant="outlined"
              density="comfortable"
              :disabled="guardando"
            ></v-text-field>
          </v-col>

          <v-col cols="12">
            <v-textarea
              v-model="formulario.descripcion"
              label="Descripción"
              rows="3"
              variant="outlined"
              density="comfortable"
              :disabled="guardando"
            ></v-textarea>
          </v-col>
        </v-row>
      </v-form>
    </v-card-text>

    <v-divider></v-divider>

    <v-card-actions class="pa-4">
      <v-spacer></v-spacer>
      <v-btn
        color="grey-darken-1"
        variant="text"
        :disabled="guardando"
        @click="cancelar"
      >
        Cancelar
      </v-btn>
      <v-btn
        color="primary"
        variant="elevated"
        :loading="guardando"
        @click="guardar"
      >
        <v-icon start>mdi-content-save</v-icon>
        Guardar
      </v-btn>
    </v-card-actions>
  </v-card>
</template>
