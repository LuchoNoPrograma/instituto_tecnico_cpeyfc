<script setup>
import { ref, onMounted } from 'vue'
import { api } from '@/services/api'
import { showError, showSuccess, showConfirmation } from '@/utils/sweetalert'
import FormularioRequisito from './FormularioRequisito.vue'

const listaRequisitos = ref([])
const cargando = ref(false)
const busqueda = ref('')
const mostrarFormulario = ref(false)
const requisitoSeleccionado = ref(null)

const headers = [
  { title: 'Requisito', key: 'nombre_requisito', sortable: true, width: '30%' },
  { title: 'Descripción', key: 'descripcion', sortable: false, width: '45%' },
  { title: 'Orden', key: 'orden_presentacion', sortable: true, width: '10%' },
  { title: 'Acciones', key: 'acciones', sortable: false, width: '15%' }
]

const obtenerRequisitos = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/requisitos')
    listaRequisitos.value = response.data
  } catch (error) {
    console.error('Error al obtener requisitos:', error)
    await showError('Error al cargar requisitos')
  } finally {
    cargando.value = false
  }
}

const abrirFormularioNuevo = () => {
  requisitoSeleccionado.value = null
  mostrarFormulario.value = true
}

const abrirFormularioEditar = (requisito) => {
  requisitoSeleccionado.value = requisito
  mostrarFormulario.value = true
}

const cerrarFormulario = () => {
  mostrarFormulario.value = false
  requisitoSeleccionado.value = null
}

const handleGuardado = async () => {
  await obtenerRequisitos()
  cerrarFormulario()
}

const eliminarRequisito = async (requisito) => {
  const confirmado = await showConfirmation(
    '¿Está seguro?',
    `Se eliminará el requisito "${requisito.nombre_requisito}"`
  )

  if (confirmado) {
    try {
      const response = await api.delete(`/api/requisito/${requisito.id_aca_requisito}`)
      if (response.data.success) {
        await showSuccess(response.data.message)
        await obtenerRequisitos()
      } else {
        await showError(response.data.message)
      }
    } catch (error) {
      console.error('Error al eliminar requisito:', error)
      await showError('Error al eliminar el requisito')
    }
  }
}

onMounted(() => {
  obtenerRequisitos()
})
</script>

<template>
  <div class="pa-4">
    <!-- Tabla de requisitos -->
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headers"
        :items="listaRequisitos"
        :loading="cargando"
        :search="busqueda"
        loading-text="Cargando requisitos..."
        no-data-text="No hay requisitos registrados"
        density="comfortable"
      >
        <template #top>
          <v-toolbar class="rounded-t-lg">
            <v-container fluid class="py-4 px-4">
              <v-row align="center" no-gutters>
                <!-- Título -->
                <v-col cols="12" lg="auto" class="mb-3 mb-lg-0">
                  <div class="d-flex align-center">
                    <v-icon class="mr-2" color="primary">mdi-file-document</v-icon>
                    <span class="text-h6 font-weight-bold">Requisitos de Inscripción</span>
                  </div>
                </v-col>

                <v-spacer class="d-none d-sm-block"></v-spacer>

                <!-- Acciones -->
                <v-col cols="12" lg="auto">
                  <v-row align="center" justify="end" no-gutters class="ga-2">
                    <!-- Búsqueda -->
                    <v-col cols="auto" class="flex-grow-1 flex-lg-grow-0">
                      <v-text-field
                        v-model="busqueda"
                        append-inner-icon="mdi-magnify"
                        label="Buscar..."
                        single-line
                        hide-details
                        variant="outlined"
                        density="compact"
                        style="min-width: 200px; max-width: 280px;"
                      ></v-text-field>
                    </v-col>

                    <!-- Botón nuevo -->
                    <v-col cols="auto">
                      <v-btn
                        color="primary"
                        variant="elevated"
                        @click="abrirFormularioNuevo"
                      >
                        <v-icon start>mdi-plus</v-icon>
                        <span class="d-none d-sm-inline">Nuevo Requisito</span>
                      </v-btn>
                    </v-col>
                  </v-row>
                </v-col>
              </v-row>
            </v-container>
          </v-toolbar>
        </template>

        <!-- Nombre del requisito -->
        <template #item.nombre_requisito="{ item }">
          <div class="text-body-1 font-weight-medium">
            {{ item.nombre_requisito }}
          </div>
        </template>

        <!-- Descripción -->
        <template #item.descripcion="{ item }">
          <div class="text-body-2">
            {{ item.descripcion || 'Sin descripción' }}
          </div>
        </template>

        <!-- Orden -->
        <template #item.orden_presentacion="{ item }">
          <v-chip size="small" color="secondary" variant="tonal">
            {{ item.orden_presentacion }}
          </v-chip>
        </template>

        <!-- Acciones -->
        <template #item.acciones="{ item }">
          <v-btn
            icon
            size="small"
            color="primary"
            class="mr-1"
            @click="abrirFormularioEditar(item)"
          >
            <v-icon>mdi-pencil</v-icon>
            <v-tooltip activator="parent" location="top">Editar</v-tooltip>
          </v-btn>

          <v-btn
            icon
            size="small"
            color="error"
            @click="eliminarRequisito(item)"
          >
            <v-icon>mdi-delete</v-icon>
            <v-tooltip activator="parent" location="top">Eliminar</v-tooltip>
          </v-btn>
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog Formulario -->
    <v-dialog
      v-model="mostrarFormulario"
      max-width="600px"
      persistent
      scrollable
    >
      <FormularioRequisito
        :requisito="requisitoSeleccionado"
        @cerrar="cerrarFormulario"
        @guardado="handleGuardado"
      />
    </v-dialog>
  </div>
</template>
