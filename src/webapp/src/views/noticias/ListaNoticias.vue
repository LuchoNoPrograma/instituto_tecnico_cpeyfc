<script setup>
import { onMounted, ref, computed } from 'vue'
import { api } from '@/services/api'
import FormularioNoticia from '@/views/noticias/FormularioNoticia.vue'
import formatoFecha from '@/helpers/formatos.js'

const noticias = ref([])
const cargando = ref(false)
const busqueda = ref('')

// Estados de dialog
const dialogFormulario = ref(false)
const noticiaSeleccionada = ref(null)
const esEdicion = computed(() => !!noticiaSeleccionada.value)

// Headers de la tabla
const headers = [
  { title: 'Título', key: 'titulo', sortable: true, width: '30%' },
  { title: 'Unidad', key: 'nombre_unidad', sortable: true, width: '20%' },
  { title: 'Fecha', key: 'fecha_noticia', sortable: true, width: '12%' },
  { title: 'Destacada', key: 'es_destacada', sortable: true, width: '10%' },
  { title: 'Prioridad', key: 'orden_prioridad', sortable: true, width: '10%' },
  { title: 'Estado', key: 'estado_noticia', sortable: true, width: '10%' },
  { title: 'Acciones', key: 'acciones', sortable: false, width: '8%' }
]

// Computed para formatear datos
const noticiasFormateadas = computed(() => {
  return noticias.value.map(noticia => ({
    ...noticia,
    fecha_formateada: noticia.fecha_noticia ? formatoFecha.ddMMaaaa(noticia.fecha_noticia) : 'Sin fecha'
  }))
})

const obtenerNoticias = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/noticia/vista/noticias-activas')
    noticias.value = response.data
  } catch (error) {
    console.error('Error al obtener noticias:', error)
  } finally {
    cargando.value = false
  }
}

const obtenerColorEstado = (estado) => {
  const colores = {
    'ACTIVO': 'success',
    'INACTIVO': 'warning',
    'ELIMINADO': 'error'
  }
  return colores[estado] || 'grey'
}

// Funciones de dialog
const abrirDialogRegistrar = () => {
  noticiaSeleccionada.value = null
  dialogFormulario.value = true
}

const abrirDialogEditar = (noticia) => {
  noticiaSeleccionada.value = noticia
  dialogFormulario.value = true
}

const cerrarDialog = () => {
  dialogFormulario.value = false
  noticiaSeleccionada.value = null
}

const guardarNoticia = async (datos) => {
  try {
    cargando.value = true

    if (esEdicion.value) {
      await api.put(`/api/noticia/${noticiaSeleccionada.value.id_pub_noticia}`, datos)
    } else {
      await api.post('/api/noticia', datos)
    }

    await obtenerNoticias()
    cerrarDialog()
    console.log('Noticia guardada exitosamente')
  } catch (error) {
    console.error('Error al guardar noticia:', error)
    alert('Error al guardar la noticia: ' + (error.response?.data || error.message))
  } finally {
    cargando.value = false
  }
}

const cambiarEstadoNoticia = async (noticia, nuevoEstado) => {
  const confirmacion = nuevoEstado === 'ELIMINADO'
    ? '¿Está seguro de eliminar esta noticia?'
    : `¿Cambiar el estado a ${nuevoEstado}?`

  if (!confirm(confirmacion)) return

  try {
    await api.patch(`/api/noticia/${noticia.id_pub_noticia}/estado`, {
      estado: nuevoEstado
    })

    await obtenerNoticias()
    console.log('Estado actualizado exitosamente')
  } catch (error) {
    console.error('Error al cambiar estado:', error)
    alert('Error al cambiar el estado: ' + (error.response?.data || error.message))
  }
}

onMounted(() => {
  obtenerNoticias()
})
</script>

<template>
  <div class="pa-4">
    <!-- Tabla de noticias -->
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headers"
        :items="noticiasFormateadas"
        :loading="cargando"
        :search="busqueda"
        loading-text="Cargando noticias..."
        no-data-text="No hay noticias registradas"
        class="rounded-lg"
        density="comfortable"
      >
        <template #top>
          <v-toolbar flat class="rounded-t-lg pa-4">
            <v-toolbar-title class="text-h6 font-weight-bold d-flex align-center">
              <v-icon class="mr-2" color="primary">mdi-newspaper</v-icon>
              Administración de Noticias
            </v-toolbar-title>
            <v-spacer></v-spacer>

            <div class="d-flex align-center ga-3 flex-wrap">
              <v-text-field
                v-model="busqueda"
                append-inner-icon="mdi-magnify"
                label="Buscar noticias..."
                single-line
                hide-details
                variant="outlined"
                density="compact"
                class="search-field"
              ></v-text-field>

              <v-btn
                color="primary"
                variant="elevated"
                class="btn-nuevo"
                @click="abrirDialogRegistrar"
              >
                <v-icon start>mdi-plus</v-icon>
                Nueva Noticia
              </v-btn>
            </div>
          </v-toolbar>
        </template>

        <template #item.titulo="{ item }">
          <div>
            <div class="text-body-1 font-weight-medium">
              {{ item.titulo }}
            </div>
            <div class="text-caption text-medium-emphasis" v-if="item.resumen">
              {{ item.resumen.substring(0, 80) }}{{ item.resumen.length > 80 ? '...' : '' }}
            </div>
          </div>
        </template>

        <template #item.fecha_noticia="{ item }">
          <div class="d-flex align-center">
            <v-icon size="small" class="mr-1">mdi-calendar</v-icon>
            <span class="text-body-2">{{ item.fecha_formateada }}</span>
          </div>
        </template>

        <template #item.es_destacada="{ item }">
          <v-icon
            :color="item.es_destacada ? 'warning' : 'grey'"
            size="small"
          >
            {{ item.es_destacada ? 'mdi-star' : 'mdi-star-outline' }}
          </v-icon>
        </template>

        <template #item.orden_prioridad="{ item }">
          <v-chip
            :color="item.orden_prioridad >= 10 ? 'error' : item.orden_prioridad >= 5 ? 'warning' : 'grey'"
            size="small"
            variant="flat"
          >
            <v-icon start size="x-small">
              {{ item.orden_prioridad >= 10 ? 'mdi-arrow-up' : item.orden_prioridad >= 5 ? 'mdi-minus' : 'mdi-arrow-down' }}
            </v-icon>
            {{ item.orden_prioridad >= 10 ? 'Alta' : item.orden_prioridad >= 5 ? 'Media' : 'Baja' }}
          </v-chip>
        </template>

        <template #item.estado_noticia="{ item }">
          <v-chip
            :color="obtenerColorEstado(item.estado_noticia)"
            size="small"
            variant="flat"
          >
            {{ item.estado_noticia }}
          </v-chip>
        </template>

        <template #item.acciones="{ item }">
          <div class="d-flex ga-1">
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

            <v-menu>
              <template #activator="{ props }">
                <v-btn
                  color="primary"
                  icon="mdi-dots-vertical"
                  size="small"
                  variant="elevated"
                  v-bind="props"
                >
                  <v-icon>mdi-dots-vertical</v-icon>
                </v-btn>
              </template>

              <v-list density="compact">
                <v-list-item
                  @click="cambiarEstadoNoticia(item, 'ACTIVO')"
                  :disabled="item.estado_noticia === 'ACTIVO'"
                >
                  <template #prepend>
                    <v-icon color="success">mdi-check-circle</v-icon>
                  </template>
                  <v-list-item-title>Activar</v-list-item-title>
                </v-list-item>

                <v-list-item
                  @click="cambiarEstadoNoticia(item, 'INACTIVO')"
                  :disabled="item.estado_noticia === 'INACTIVO'"
                >
                  <template #prepend>
                    <v-icon color="warning">mdi-pause-circle</v-icon>
                  </template>
                  <v-list-item-title>Desactivar</v-list-item-title>
                </v-list-item>

                <v-divider></v-divider>

                <v-list-item @click="cambiarEstadoNoticia(item, 'ELIMINADO')">
                  <template #prepend>
                    <v-icon color="error">mdi-delete</v-icon>
                  </template>
                  <v-list-item-title>Eliminar</v-list-item-title>
                </v-list-item>
              </v-list>
            </v-menu>
          </div>
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog para formulario -->
    <v-dialog
      v-model="dialogFormulario"
      max-width="800px"
      persistent
      class="ma-2"
    >
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary text-white d-flex align-center pa-4">
          <v-icon start>{{ esEdicion ? 'mdi-newspaper-variant' : 'mdi-newspaper-plus' }}</v-icon>
          {{ esEdicion ? 'Editar Noticia' : 'Nueva Noticia' }}
        </v-card-title>

        <FormularioNoticia
          :noticia="noticiaSeleccionada"
          :es-edicion="esEdicion"
          @cancelar="cerrarDialog"
          @guardar="guardarNoticia"
        />
      </v-card>
    </v-dialog>
  </div>
</template>

<style lang="scss" scoped>
.search-field {
  min-width: 280px;
  max-width: 350px;
}

.btn-nuevo {
  min-width: 160px;
  flex-shrink: 0;
}

@media (max-width: 960px) {
  .v-toolbar {
    .d-flex.align-center.ga-3 {
      flex-direction: column;
      align-items: stretch !important;
      gap: 16px !important;
      width: 100%;
    }

    .v-toolbar-title {
      text-align: center;
      margin-bottom: 8px;
    }

    .search-field {
      min-width: 100%;
      max-width: 100%;
    }

    .btn-nuevo {
      min-width: 100%;
    }
  }
}

@media (max-width: 600px) {
  .v-toolbar {
    padding: 16px !important;
  }
}
</style>
