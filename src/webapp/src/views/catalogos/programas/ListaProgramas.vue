<script setup>
import { ref, onMounted } from 'vue'
import { api } from '@/services/api'
import { showError } from '@/utils/sweetalert'
import FormularioPrograma from '@/views/catalogos/programas/FormularioPrograma.vue';

const listaProgramas = ref([])
const cargando = ref(false)
const busqueda = ref('')
const mostrarFormulario = ref(false)
const programaSeleccionado = ref(null)

const headers = [
  { title: 'Programa', key: 'nombre_programa', sortable: true, width: '30%' },
  { title: 'Área', key: 'nombre_area', sortable: true, width: '20%' },
  { title: 'Dirigido a', key: 'perfiles_dirigidos', sortable: true, width: '25%' },
  { title: 'Habilidades', key: 'habilidades', sortable: false, width: '15%' },
  { title: 'Acciones', key: 'acciones', sortable: false, width: '10%' }
]

const obtenerProgramas = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/programa/vista/programas-admin')
    listaProgramas.value = response.data
  } catch (error) {
    console.error('Error al obtener programas:', error)
    await showError('Error al cargar programas')
  } finally {
    cargando.value = false
  }
}

const abrirFormularioNuevo = () => {
  programaSeleccionado.value = null
  mostrarFormulario.value = true
}

const abrirFormularioEditar = (programa) => {
  programaSeleccionado.value = programa
  mostrarFormulario.value = true
}

const cerrarFormulario = () => {
  mostrarFormulario.value = false
  programaSeleccionado.value = null
}

const handleGuardado = async () => {
  await obtenerProgramas()
  cerrarFormulario()
}

const getColorEstado = (estado) => {
  const colores = {
    'ACTIVO': 'success',
    'INACTIVO': 'warning',
    'ELIMINADO': 'error'
  }
  return colores[estado] || 'default'
}

onMounted(() => {
  obtenerProgramas()
})
</script>

<template>
  <div class="pa-4">
    <!-- Tabla de programas -->
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headers"
        :items="listaProgramas"
        :loading="cargando"
        :search="busqueda"
        loading-text="Cargando programas..."
        no-data-text="No hay programas registrados"
        density="comfortable"
      >
        <template #top>
          <v-toolbar class="rounded-t-lg">
            <v-container fluid class="py-4 px-4">
              <v-row align="center" no-gutters>
                <!-- Título -->
                <v-col cols="12" lg="auto" class="mb-3 mb-lg-0">
                  <div class="d-flex align-center">
                    <v-icon class="mr-2" color="primary">mdi-bookshelf</v-icon>
                    <span class="text-h6 font-weight-bold">Catálogo de Programas</span>
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
                        <span class="d-none d-sm-inline">Nuevo Programa</span>
                      </v-btn>
                    </v-col>
                  </v-row>
                </v-col>
              </v-row>
            </v-container>
          </v-toolbar>
        </template>

        <!-- Nombre -->
        <template #item.nombre_programa="{ item }">
          <div class="text-body-1 font-weight-medium">
            {{ item.nombre_programa }}
            <span class="text-caption text-medium-emphasis d-block">
              {{item.sigla}}
            </span>
          </div>
        </template>

        <template #item.perfiles_dirigidos="{ item }">
          <div v-if="item.perfiles_dirigidos">
            <div v-for="(perfil, index) in item.perfiles_dirigidos.split(',').map(p => p.trim())"
                 :key="index">
              • {{ perfil }}
            </div>
          </div>
          <span v-else class="text-grey">Sin perfiles asignados</span>
        </template>

        <!-- Habilidades -->
        <template #item.habilidades="{ item }">
          <div v-if="item.habilidades" class="d-flex flex-wrap ga-1">
            <v-chip
              v-for="(habilidad, index) in item.habilidades.split(', ').slice(0, 3)"
              :key="index"
              size="x-small"
              variant="tonal"
              color="primary"
            >
              <span class="ml-1">
                {{ habilidad }}
              </span>
            </v-chip>
            <v-chip
              v-if="item.habilidades.split(', ').length > 3"
              size="small"
              color="grey"
              variant="text"
            >
              +{{ item.habilidades.split(', ').length - 3 }}
            </v-chip>
          </div>
          <span v-else class="text-grey">Sin habilidades</span>
        </template>

        <!-- Acciones -->
        <template #item.acciones="{ item }">
          <v-btn
            icon="mdi-pencil"
            size="small"
            color="primary"
            @click="abrirFormularioEditar(item)"
          >
            <v-icon>mdi-pencil</v-icon>
            <v-tooltip activator="parent" location="top">Editar</v-tooltip>
          </v-btn>
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog Formulario -->
    <v-dialog
      v-model="mostrarFormulario"
      max-width="800px"
      persistent
      scrollable
    >
      <FormularioPrograma
        :programa="programaSeleccionado"
        @cerrar="cerrarFormulario"
        @guardado="handleGuardado"
      />
    </v-dialog>
  </div>
</template>
