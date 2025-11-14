<script setup>
import { ref, onMounted } from 'vue'
import { api } from '@/services/api'
import { showError, showEliminado, showConfirmar } from '@/utils/sweetalert'
import FormularioPerfil from './FormularioPerfil.vue'
import AsignarRequisitosModal from './AsignarRequisitosModal.vue'

const listaPerfiles = ref([])
const cargando = ref(false)
const busqueda = ref('')
const mostrarFormulario = ref(false)
const mostrarAsignarRequisitos = ref(false)
const perfilSeleccionado = ref(null)

const headers = [
  { title: 'Perfil', key: 'nombre_perfil', sortable: true, width: '30%' },
  { title: 'Descripción', key: 'descripcion', sortable: false, width: '50%' },
  { title: 'Acciones', key: 'acciones', sortable: false, width: '20%' }
]

const obtenerPerfiles = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/perfiles-estudiante')
    listaPerfiles.value = response.data
  } catch (error) {
    console.error('Error al obtener perfiles:', error)
    await showError('Error al cargar perfiles')
  } finally {
    cargando.value = false
  }
}

const abrirFormularioNuevo = () => {
  perfilSeleccionado.value = null
  mostrarFormulario.value = true
}

const abrirFormularioEditar = (perfil) => {
  perfilSeleccionado.value = perfil
  mostrarFormulario.value = true
}

const abrirAsignarRequisitos = (perfil) => {
  perfilSeleccionado.value = perfil
  mostrarAsignarRequisitos.value = true
}

const cerrarFormulario = () => {
  mostrarFormulario.value = false
  perfilSeleccionado.value = null
}

const cerrarAsignarRequisitos = () => {
  mostrarAsignarRequisitos.value = false
  perfilSeleccionado.value = null
}

const handleGuardado = async () => {
  await obtenerPerfiles()
  cerrarFormulario()
}

const handleRequisitosAsignados = async () => {
  await obtenerPerfiles()
  cerrarAsignarRequisitos()
}

const eliminarPerfil = async (perfil) => {
  const result = await showConfirmar({
    titulo: '¿Está seguro?',
    mensaje: `Se eliminará el perfil "${perfil.nombre_perfil}"`,
    textoConfirmar: 'Sí, eliminar',
    textoCancelar: 'Cancelar',
    tipo: 'delete'
  })

  if (result.isConfirmed) {
    try {
      const response = await api.delete(`/api/perfil-estudiante/${perfil.id_aca_perfil_estudiante}`)
      if (response.data.success) {
        await showEliminado(response.data.message)
        await obtenerPerfiles()
      } else {
        await showError(response.data.message)
      }
    } catch (error) {
      console.error('Error al eliminar perfil:', error)
      await showError('Error al eliminar el perfil')
    }
  }
}

onMounted(() => {
  obtenerPerfiles()
})
</script>

<template>
  <div class="pa-4">
    <!-- Tabla de perfiles -->
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headers"
        :items="listaPerfiles"
        :loading="cargando"
        :search="busqueda"
        loading-text="Cargando perfiles..."
        no-data-text="No hay perfiles registrados"
        density="comfortable"
      >
        <template #top>
          <v-toolbar class="rounded-t-lg">
            <v-container fluid class="py-4 px-4">
              <v-row align="center" no-gutters>
                <!-- Título -->
                <v-col cols="12" lg="auto" class="mb-3 mb-lg-0">
                  <div class="d-flex align-center">
                    <v-icon class="mr-2" color="primary">mdi-account-group</v-icon>
                    <span class="text-h6 font-weight-bold">Perfiles de Estudiante</span>
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
                        <span class="d-none d-sm-inline">Nuevo Perfil</span>
                      </v-btn>
                    </v-col>
                  </v-row>
                </v-col>
              </v-row>
            </v-container>
          </v-toolbar>
        </template>

        <!-- Nombre del perfil -->
        <template #item.nombre_perfil="{ item }">
          <div class="text-body-1 font-weight-medium">
            {{ item.nombre_perfil }}
          </div>
        </template>

        <!-- Descripción -->
        <template #item.descripcion="{ item }">
          <div class="text-body-2">
            {{ item.descripcion || 'Sin descripción' }}
          </div>
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
            color="secondary"
            class="mr-1"
            @click="abrirAsignarRequisitos(item)"
          >
            <v-icon>mdi-file-document-multiple</v-icon>
            <v-tooltip activator="parent" location="top">Asignar Requisitos</v-tooltip>
          </v-btn>

          <v-btn
            icon
            size="small"
            color="error"
            @click="eliminarPerfil(item)"
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
      <FormularioPerfil
        :perfil="perfilSeleccionado"
        @cerrar="cerrarFormulario"
        @guardado="handleGuardado"
      />
    </v-dialog>

    <!-- Dialog Asignar Requisitos -->
    <v-dialog
      v-model="mostrarAsignarRequisitos"
      max-width="700px"
      persistent
      scrollable
    >
      <AsignarRequisitosModal
        :perfil="perfilSeleccionado"
        @cerrar="cerrarAsignarRequisitos"
        @guardado="handleRequisitosAsignados"
      />
    </v-dialog>
  </div>
</template>
