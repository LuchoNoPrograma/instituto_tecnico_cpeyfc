<script setup>
import { ref, watch, computed } from 'vue'
import { api } from '@/services/api'
import { showError, showRegistrado, showModificado } from '@/utils/sweetalert'

const props = defineProps({
  requisito: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['cerrar', 'guardado'])

const formulario = ref({
  nombre_requisito: '',
  descripcion: '',
  orden_presentacion: 100
})

const guardando = ref(false)
const modoEdicion = computed(() => props.requisito !== null)

// Cargar datos si es edición
watch(() => props.requisito, (nuevoRequisito) => {
  if (nuevoRequisito) {
    formulario.value = {
      nombre_requisito: nuevoRequisito.nombre_requisito || '',
      descripcion: nuevoRequisito.descripcion || '',
      orden_presentacion: nuevoRequisito.orden_presentacion || 100
    }
  } else {
    limpiarFormulario()
  }
}, { immediate: true })

const limpiarFormulario = () => {
  formulario.value = {
    nombre_requisito: '',
    descripcion: '',
    orden_presentacion: 100
  }
}

const validarFormulario = () => {
  if (!formulario.value.nombre_requisito || formulario.value.nombre_requisito.trim() === '') {
    showError('El nombre del requisito es requerido')
    return false
  }
  if (formulario.value.nombre_requisito.length > 100) {
    showError('El nombre del requisito no puede exceder 100 caracteres')
    return false
  }
  if (formulario.value.orden_presentacion < 1) {
    showError('El orden de presentación debe ser mayor a 0')
    return false
  }
  return true
}

const guardar = async () => {
  if (!validarFormulario()) return

  guardando.value = true
  try {
    const datos = {
      nombre_requisito: formulario.value.nombre_requisito.trim(),
      descripcion: formulario.value.descripcion?.trim() || null,
      orden_presentacion: parseInt(formulario.value.orden_presentacion)
    }

    let response
    if (modoEdicion.value) {
      response = await api.put(`/api/requisito/${props.requisito.id_aca_requisito}`, datos)
    } else {
      response = await api.post('/api/requisito', datos)
    }

    if (response.data.success) {
      if (modoEdicion.value) {
        await showModificado(response.data.message)
      } else {
        await showRegistrado(response.data.message)
      }
      emit('guardado')
    } else {
      await showError(response.data.message)
    }
  } catch (error) {
    console.error('Error al guardar requisito:', error)
    await showError('Error al guardar el requisito')
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
      <v-icon class="mr-2">mdi-file-document</v-icon>
      <span>{{ modoEdicion ? 'Editar' : 'Nuevo' }} Requisito</span>
    </v-card-title>

    <v-divider></v-divider>

    <v-card-text class="pa-6">
      <v-form @submit.prevent="guardar">
        <v-row>
          <v-col cols="12">
            <v-text-field
              v-model="formulario.nombre_requisito"
              label="Nombre del requisito *"
              hint="Ej: Fotocopia CI, Título bachiller, Baucher de pago"
              persistent-hint
              counter="100"
              maxlength="100"
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

          <v-col cols="12">
            <v-text-field
              v-model.number="formulario.orden_presentacion"
              label="Orden de presentación"
              type="number"
              min="1"
              variant="outlined"
              density="comfortable"
              :disabled="guardando"
              hint="Define el orden en que se mostrará el requisito"
              persistent-hint
            ></v-text-field>
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
