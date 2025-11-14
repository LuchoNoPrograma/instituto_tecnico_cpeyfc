<script setup>
import { ref, watch, onMounted } from 'vue'
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

// Cargar requisitos disponibles y pre-seleccionar los asignados
watch(() => props.perfil, async (nuevoPerfil) => {
  if (nuevoPerfil) {
    await cargarDatos()
  }
}, { immediate: true })

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

const cancelar = () => {
  emit('cerrar')
}

const toggleRequisito = (idRequisito) => {
  const index = requisitosSeleccionados.value.indexOf(idRequisito)
  if (index > -1) {
    requisitosSeleccionados.value.splice(index, 1)
  } else {
    requisitosSeleccionados.value.push(idRequisito)
  }
}

const estaSeleccionado = (idRequisito) => {
  return requisitosSeleccionados.value.includes(idRequisito)
}
</script>

<template>
  <v-card>
    <v-card-title class="d-flex align-center pa-4 bg-secondary">
      <v-icon class="mr-2">mdi-file-document-multiple</v-icon>
      <span>Asignar Requisitos - {{ perfil?.nombre_perfil }}</span>
    </v-card-title>

    <v-divider></v-divider>

    <v-card-text class="pa-4" style="max-height: 500px; overflow-y: auto;">
      <v-alert type="info" variant="tonal" class="mb-4" density="compact">
        Selecciona los requisitos que debe cumplir este perfil de estudiante
      </v-alert>

      <v-progress-linear v-if="cargando" indeterminate color="primary" class="mb-4"></v-progress-linear>

      <v-list v-else>
        <v-list-item
          v-for="requisito in requisitosDisponibles"
          :key="requisito.id_aca_requisito"
          @click="toggleRequisito(requisito.id_aca_requisito)"
          class="mb-2 rounded border"
          :class="estaSeleccionado(requisito.id_aca_requisito) ? 'bg-blue-lighten-5' : ''"
        >
          <template #prepend>
            <v-checkbox
              :model-value="estaSeleccionado(requisito.id_aca_requisito)"
              hide-details
              color="primary"
              @click.stop="toggleRequisito(requisito.id_aca_requisito)"
            ></v-checkbox>
          </template>

          <v-list-item-title class="font-weight-medium">
            {{ requisito.nombre_requisito }}
          </v-list-item-title>

          <v-list-item-subtitle v-if="requisito.descripcion" class="mt-1">
            {{ requisito.descripcion }}
          </v-list-item-subtitle>

          <template #append>
            <v-chip size="small" color="secondary" variant="tonal">
              Orden: {{ requisito.orden_presentacion }}
            </v-chip>
          </template>
        </v-list-item>

        <v-list-item v-if="requisitosDisponibles.length === 0" class="text-center">
          <v-list-item-title class="text-grey">
            No hay requisitos disponibles
          </v-list-item-title>
        </v-list-item>
      </v-list>

      <v-alert v-if="requisitosSeleccionados.length > 0" type="success" variant="tonal" class="mt-4" density="compact">
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
