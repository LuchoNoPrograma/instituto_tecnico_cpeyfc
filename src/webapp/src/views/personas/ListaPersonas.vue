<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '@/services/api'
import FormularioPersona from '@/views/personas/FormularioPersona.vue'

const router = useRouter()
const personas = ref([])
const cargando = ref(false)
const busqueda = ref('')

// Estados de dialog unificado
const dialogFormulario = ref(false)
const personaSeleccionada = ref(null)
const esEdicion = computed(() => !!personaSeleccionada.value)

const headers = [
  { title: 'Nombre Completo', key: 'nombre_completo', sortable: true },
  { title: 'CI', key: 'ci', sortable: true },
  { title: 'Celular', key: 'nro_celular' },
  { title: 'Correo', key: 'correo' },
  { title: 'Acciones', key: 'acciones', sortable: false }
]

// Computed para mostrar nombre completo
const personasConNombreCompleto = computed(() => {
  return personas.value.map(persona => ({
    ...persona,
    nombre_completo: `${persona.nombre} ${persona.ap_paterno} ${persona.ap_materno || ''}`.trim()
  }))
})

// Computed para título del dialog
const tituloDialog = computed(() =>
  esEdicion.value ? 'Editar Persona' : 'Registrar Nueva Persona'
)

const iconoDialog = computed(() =>
  esEdicion.value ? 'mdi-account-edit' : 'mdi-account-plus'
)

const obtenerPersonas = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/persona/vista/personas-activas')
    personas.value = response.data
  } catch (error) {
    console.error('Error al obtener personas:', error)
  } finally {
    cargando.value = false
  }
}

const abrirDialogRegistrar = () => {
  personaSeleccionada.value = null
  dialogFormulario.value = true
}

const abrirDialogEditar = (persona) => {
  personaSeleccionada.value = persona
  dialogFormulario.value = true
}

const cerrarDialog = () => {
  dialogFormulario.value = false
  personaSeleccionada.value = null
}

const manejarGuardado = async (datosPersona) => {
  try {
    if (esEdicion.value) {
      await api.put(`/api/persona/${personaSeleccionada.value.id_prs_persona}`, datosPersona)
      console.log('Persona actualizada exitosamente')
    } else {
      await api.post('/api/persona', datosPersona)
      console.log('Persona registrada exitosamente')
    }

    await obtenerPersonas()
    cerrarDialog()
  } catch (error) {
    console.error('Error al guardar persona:', error)
    throw error
  }
}

const verDetalle = (persona) => {
  router.push(`/personas/${persona.id_prs_persona}`)
}

onMounted(() => {
  obtenerPersonas()
})
</script>

<template>
  <div class="pa-4">
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headers"
        :items="personasConNombreCompleto"
        :loading="cargando"
        loading-text="Cargando personas..."
        :search="busqueda"
        no-data-text="No hay personas registradas"
        class="rounded-lg"
      >
        <template #top>
          <v-toolbar flat class="rounded-t-lg">
            <v-toolbar-title class="text-h6 font-weight-bold d-flex align-center">
              <v-icon class="mr-2" color="primary">mdi-account-group</v-icon>
              Gestión de Personas
            </v-toolbar-title>

            <v-spacer></v-spacer>
            <v-text-field
              v-model="busqueda"
              append-inner-icon="mdi-magnify"
              class="mx-2"
              label="Buscar personas..."
              single-line
              hide-details
              variant="outlined"
              density="compact"
              style="max-width: 300px;"
            />

            <div class="d-flex align-center ga-3">
              <v-btn
                color="primary"
                variant="elevated"
                @click="abrirDialogRegistrar"
              >
                <v-icon start>mdi-plus</v-icon>
                Registrar Persona
              </v-btn>
            </div>
          </v-toolbar>
        </template>

        <template #item.correo="{ item }">
          <span v-if="item.correo" class="text-body-2">{{ item.correo }}</span>
          <span v-else class="text-medium-emphasis text-caption font-italic">Sin correo</span>
        </template>

        <template #item.acciones="{ item }">
          <div class="d-flex ga-2">
            <v-btn
              icon="mdi-eye"
              size="small"
              color="info"
              variant="elevated"
              @click="verDetalle(item)"
            >
              <v-icon>mdi-eye</v-icon>
              <v-tooltip activator="parent" location="top">Ver detalle</v-tooltip>
            </v-btn>

            <v-btn
              icon="mdi-pencil"
              size="small"
              color="primary"
              variant="elevated"
              @click="abrirDialogEditar(item)"
            >
              <v-icon>mdi-pencil</v-icon>
              <v-tooltip activator="parent" location="top">Editar</v-tooltip>
            </v-btn>
          </div>
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog unificado -->
    <v-dialog
      v-model="dialogFormulario"
      max-width="600px"
      persistent
      class="ma-2"
    >
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary text-white d-flex align-center pa-4">
          <v-icon start>{{ iconoDialog }}</v-icon>
          {{ tituloDialog }}
        </v-card-title>

        <FormularioPersona
          :persona="personaSeleccionada"
          :es-edicion="esEdicion"
          @guardar="manejarGuardado"
          @cancelar="cerrarDialog"
        />
      </v-card>
    </v-dialog>
  </div>
</template>

<style lang="scss" scoped>
// Responsive
@media (max-width: 960px) {
  .v-toolbar {
    .d-flex.align-center.ga-3 {
      flex-direction: column;
      align-items: stretch !important;
      gap: 12px !important;
    }

    .v-toolbar-title {
      text-align: center;
      margin-bottom: 8px;
    }
  }
}
</style>
