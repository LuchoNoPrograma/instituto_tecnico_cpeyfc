<script setup>
import { ref, watch } from 'vue'
import { api } from '@/services/api'
import { showError, showModificado } from '@/utils/sweetalert'

const props = defineProps({
  perfil: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['cerrar', 'guardado'])

const requisitosDisponibles = ref([])
const requisitosSeleccionados = ref([])
const guardando = ref(false)
const cargando = ref(false)

const cargarDatos = async () => {
  cargando.value = true
  try {
    // Cargar todos los requisitos disponibles
    const responseRequisitos = await api.get('/api/requisitos')
    requisitosDisponibles.value = responseRequisitos.data

    // Cargar requisitos ya asignados
    const responseAsignados = await api.get(`/api/perfil-estudiante/${props.perfil.id_aca_perfil_estudiante}/requisitos`)

    // Pre-seleccionar los requisitos asignados
    requisitosSeleccionados.value = responseAsignados.data.map(r => r.id_aca_requisito)
  } catch (error) {
    console.error('Error al cargar datos:', error)
    await showError('Error al cargar los requisitos')
  } finally {
    cargando.value = false
  }
}

const guardar = async () => {
  if (requisitosSeleccionados.value.length === 0) {
    await showError('Debe seleccionar al menos un requisito')
    return
  }

  guardando.value = true
  try {
    const datos = {
      requisitos: requisitosSeleccionados.value
    }

    const response = await api.post(
      `/api/perfil-estudiante/${props.perfil.id_aca_perfil_estudiante}/requisitos`,
      datos
    )

    if (response.data.success) {
      await showModificado(response.data.message)
      emit('guardado')
    } else {
      await showError(response.data.message)
    }
  } catch (error) {
    console.error('Error al asignar requisitos:', error)
    await showError('Error al asignar los requisitos')
  } finally {
    guardando.value = false
  }
}

// Cargar requisitos disponibles y pre-seleccionar los asignados
watch(() => props.perfil, async (nuevoPerfil) => {
  if (nuevoPerfil) {
    await cargarDatos()
  }
}, { immediate: true })


const cancelar = () => {
  emit('cerrar')
}
</script>

<template>
  <v-card>
    <v-card-title class="d-flex align-center pa-4 bg-primary">
      <v-icon class="mr-2">mdi-file-document-multiple</v-icon>
      <span>Asignar Requisitos - {{ perfil?.nombre_perfil }}</span>
    </v-card-title>

    <v-divider></v-divider>

    <v-card-text class="pa-4">
      <v-alert type="info" variant="tonal" class="mb-4" density="compact">
        Selecciona los requisitos que debe cumplir este perfil de estudiante
      </v-alert>

      <v-progress-linear
        v-if="cargando"
        indeterminate
        color="primary"
        class="mb-4"
      ></v-progress-linear>

      <v-autocomplete
        v-model="requisitosSeleccionados"
        :items="requisitosDisponibles"
        item-title="nombre_requisito"
        item-value="id_aca_requisito"
        label="Seleccionar requisitos"
        placeholder="Buscar y seleccionar requisitos..."
        multiple
        chips
        closable-chips
        clearable
        :loading="cargando"
        :disabled="cargando"
        variant="outlined"
        density="comfortable"
        color="primary"
      >
        <template #chip="{ item, props }">
          <v-chip
            v-bind="props"
            color="primary"
            closable
          >
            {{ item.title }}
          </v-chip>
        </template>

        <template #item="{ item, props }">
          <v-list-item v-bind="props">
            <template #prepend>
              <v-icon
                :color="requisitosSeleccionados.includes(item.value) ? 'primary' : 'grey'"
              >
                {{ requisitosSeleccionados.includes(item.value) ? 'mdi-checkbox-marked' : 'mdi-checkbox-blank-outline' }}
              </v-icon>
            </template>
          </v-list-item>
        </template>

        <template #selection="{ item, index }">
          <v-chip
            v-if="index < 3"
            closable
            color="primary"
            @click:close="requisitosSeleccionados.splice(index, 1)"
          >
            {{ item.title }}
          </v-chip>
          <span
            v-if="index === 3"
            class="text-grey text-caption align-self-center"
          >
            (+{{ requisitosSeleccionados.length - 3 }} más)
          </span>
        </template>
      </v-autocomplete>

      <v-alert
        v-if="requisitosSeleccionados.length > 0"
        type="success"
        variant="tonal"
        class="mt-4"
        density="compact"
      >
        {{ requisitosSeleccionados.length }} requisito(s) seleccionado(s)
      </v-alert>
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
        :disabled="cargando || requisitosSeleccionados.length === 0"
        @click="guardar"
      >
        <v-icon start>mdi-content-save</v-icon>
        Guardar Asignación
      </v-btn>
    </v-card-actions>
  </v-card>
</template>
