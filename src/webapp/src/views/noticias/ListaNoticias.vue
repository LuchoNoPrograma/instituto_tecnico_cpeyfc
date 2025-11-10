<script setup>
import { onMounted, ref, computed, watch } from 'vue'
import { api } from '@/services/api'
import FormularioNoticia from '@/views/noticias/FormularioNoticia.vue'
import formatoFecha from '@/helpers/formatos.js'
import imagenNoDisponible from '@/assets/images/img_default.png'
import {showConfirmar, showError, showModificado, showRegistrado} from '@/utils/sweetalert.js';
import {useDebounceBusqueda} from '@/helpers/debounce.js';

// Estados de datos
const noticias = ref([])
const cargando = ref(false)
const busqueda = ref('')

// Paginación
const paginacion = ref({
  page: 1,
  size: 9,
  total: 0,
  total_pages: 0,
  has_next: false,
  has_previous: false
})

// Estados de dialog
const dialogFormulario = ref(false);
const noticiaSeleccionada = ref(null);
const busquedaCargando = ref(false);
const esEdicion = computed(() => !!noticiaSeleccionada.value)

// Funciones de obtención de datos
const obtenerNoticias = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/noticia', {
      params: {
        page: paginacion.value.page,
        size: paginacion.value.size,
        busqueda: busqueda.value || undefined
      }
    })

    noticias.value = response.data.data
    paginacion.value = response.data.pagination
  } catch (error) {
    console.error('Error al obtener noticias:', error)
  } finally {
    cargando.value = false
  }
}

// Computed
const obtenerColorPrioridad = (orden) => {
  if (orden >= 10) return { color: 'error', icono: 'mdi-arrow-up', texto: 'Alta' }
  if (orden >= 5) return { color: 'warning', icono: 'mdi-minus', texto: 'Media' }
  return { color: 'grey', icono: 'mdi-arrow-down', texto: 'Baja' }
}

const obtenerColorEstado = (estado) => {
  const colores = {
    'ACTIVO': 'success',
    'INACTIVO': 'warning',
    'ELIMINADO': 'error'
  }
  return colores[estado] || 'grey'
}

// Función actualizada
const obtenerImagenUrl = (noticia) => {
  // Si tiene imagen_url o imagen_uri, úsala, sino usa la imagen por defecto
  if (noticia.imagen_url && noticia.imagen_url.trim() !== '') {
    return noticia.imagen_url
  }
  if (noticia.imagen_uri && noticia.imagen_uri.trim() !== '') {
    return noticia.imagen_uri
  }
  return imagenNoDisponible
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

// Persistir noticia
const guardarNoticia = async (formData) => {
  try {
    cargando.value = true

    if (esEdicion.value) {
      await api.put(
        `/api/noticia/${noticiaSeleccionada.value.id_pub_noticia}`,
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data'
          }
        }
      )
      showModificado('La noticia ha sido actualizada correctamente')
    } else {
      await api.post('/api/noticia', formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      })
      showRegistrado('La noticia ha sido publicada exitosamente')
    }

    await obtenerNoticias()
    cerrarDialog()
  } catch (error) {
    console.error('Error al guardar noticia:', error)
    showError(error.response?.data?.message || 'No se pudo guardar la noticia')
  } finally {
    cargando.value = false
  }
}

const cambiarEstadoNoticia = async (noticia, nuevoEstado) => {
  const mensajes = {
    'ELIMINADO': {
      titulo: '¿Eliminar noticia?',
      mensaje: 'Esta acción no se puede deshacer',
      textoConfirmar: 'Sí, eliminar',
      tipo: 'delete'
    },
    'ACTIVO': {
      titulo: '¿Activar noticia?',
      mensaje: 'La noticia será visible en el carrusel',
      textoConfirmar: 'Sí, activar',
      tipo: 'update'
    },
    'INACTIVO': {
      titulo: '¿Desactivar noticia?',
      mensaje: 'La noticia no será visible en el carrusel',
      textoConfirmar: 'Sí, desactivar',
      tipo: 'update'
    }
  }

  const config = mensajes[nuevoEstado]
  const resultado = await showConfirmar({
    titulo: config.titulo,
    mensaje: config.mensaje,
    textoConfirmar: config.textoConfirmar,
    tipo: config.tipo
  })

  if (!resultado.isConfirmed) return

  try {
    await api.patch(`/api/noticia/${noticia.id_pub_noticia}/estado`, {
      estado: nuevoEstado
    })

    showModificado('El estado ha sido actualizado correctamente')
    await obtenerNoticias()
  } catch (error) {
    console.error('Error al cambiar estado:', error)
    showError(error.response?.data?.message || 'No se pudo cambiar el estado')
  }
}

// Paginación
const cambiarPagina = (nuevaPagina) => {
  paginacion.value.page = nuevaPagina
  obtenerNoticias()
}

watch(busqueda, () => {
  busquedaCargando.value = true
  paginacion.value.page = 1
})

useDebounceBusqueda(busqueda, () => {
  obtenerNoticias().finally(() => {
    busquedaCargando.value = false
  })
}, 500)

onMounted(() => {
  obtenerNoticias()
})
</script>

<template>
  <div class="pa-4">
    <!-- Header -->
    <v-card class="mb-4 rounded-lg" flat>
      <v-card-text class="pa-6">
        <div class="d-flex flex-column flex-md-row align-start align-md-center ga-4">
          <div class="flex-grow-1">
            <div class="text-h5 font-weight-bold d-flex align-center mb-2">
              <v-icon class="mr-2" color="primary" size="32">mdi-newspaper</v-icon>
              Administración de Noticias
            </div>
            <div class="text-body-2 text-medium-emphasis">
              Gestiona las noticias que se mostrarán en el carrusel del sitio web
            </div>
          </div>

          <div class="d-flex ga-2 flex-wrap">
            <v-text-field
              v-model="busqueda"
              append-inner-icon="mdi-magnify"
              label="Buscar noticias..."
              variant="outlined"
              density="compact"
              hide-details
              class="search-field"
              clearable
              :loading="busquedaCargando"
            ></v-text-field>

            <v-btn
              color="primary"
              variant="elevated"
              size="large"
              @click="abrirDialogRegistrar"
            >
              <v-icon start>mdi-plus</v-icon>
              Nueva Noticia
            </v-btn>
          </div>
        </div>
        <v-divider class="mb-2 mt-3"></v-divider>
        <div class="d-flex align-center justify-space-between">
          <div class="text-body-2 text-medium-emphasis">
            Mostrando {{ ((paginacion.page - 1) * paginacion.size) + 1 }} -
            {{ Math.min(paginacion.page * paginacion.size, paginacion.total) }}
            de {{ paginacion.total }} noticias
          </div>

          <v-pagination
            v-model="paginacion.page"
            :length="paginacion.total_pages"
            :total-visible="5"
            @update:model-value="cambiarPagina"
            :disabled="cargando"
            rounded="circle"
            color="primary"
            variant="elevated"
          ></v-pagination>
        </div>
      </v-card-text>
    </v-card>

    <!-- Loading State -->
    <div v-if="cargando && noticias.length === 0" class="text-center py-12">
      <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
      <div class="text-body-1 text-medium-emphasis mt-4">Cargando noticias...</div>
    </div>

    <!-- Empty State -->
    <v-card v-else-if="!cargando && noticias.length === 0" class="pa-12 text-center rounded-lg" flat>
      <v-icon size="80" color="grey-lighten-2">mdi-newspaper-variant-outline</v-icon>
      <div class="text-h6 mt-4 text-medium-emphasis">
        {{ busqueda ? 'No se encontraron noticias' : 'No hay noticias registradas' }}
      </div>
      <div class="text-body-2 text-medium-emphasis mt-2">
        {{ busqueda ? 'Intenta con otros términos de búsqueda' : 'Comience creando su primera noticia' }}
      </div>
      <v-btn
        v-if="!busqueda"
        color="primary"
        variant="elevated"
        class="mt-6"
        @click="abrirDialogRegistrar"
      >
        <v-icon start>mdi-plus</v-icon>
        Crear Primera Noticia
      </v-btn>
    </v-card>

    <!-- Grid de Noticias -->
    <v-row v-else>
      <v-col
        v-for="noticia in noticias"
        :key="noticia.id_pub_noticia"
        cols="12"
        xs="12"
        sm="12"
        md="4"
        lg="4"
      >
        <v-card class="noticia-card rounded-lg" elevation="2">
          <!-- Imagen -->
          <v-img
            :src="obtenerImagenUrl(noticia)"
            aspect-ratio="16/9"
            cover
            class="noticia-imagen"
          >
            <!-- 👇 Sin placeholder, para que no muestre el loading infinito -->
            <template #error>
              <v-img
                :src="imagenNoDisponible"
                aspect-ratio="16/9"
                cover
                class="noticia-imagen"
              >
              </v-img>
            </template>

            <!-- Badges superiores -->
            <div class="badges-container pa-2">
              <v-chip
                v-if="noticia.es_destacada"
                color="warning"
                size="small"
                class="mr-1"
              >
                <v-icon start size="small">mdi-star</v-icon>
                Destacada
              </v-chip>

              <v-chip
                :color="obtenerColorPrioridad(noticia.orden_prioridad).color"
                size="small"
              >
                <v-icon start size="x-small">
                  {{ obtenerColorPrioridad(noticia.orden_prioridad).icono }}
                </v-icon>
                {{ obtenerColorPrioridad(noticia.orden_prioridad).texto }}
              </v-chip>
            </div>
          </v-img>

          <!-- Contenido -->
          <v-card-text class="pa-4">
            <!-- Título -->
            <div class="text-h6 font-weight-medium noticia-titulo">
              {{ noticia.titulo }}
            </div>

            <!-- Resumen -->
            <div class="text-body-2 text-medium-emphasis mb-2 noticia-resumen">
              {{ noticia.resumen }}
            </div>

            <!-- Info adicional -->
            <div class="d-flex align-center ga-2 mb-2">
              <v-icon size="small">mdi-calendar</v-icon>
              {{ formatoFecha.ddMMaaaa(noticia.fecha_noticia) }}
            </div>

            <div class="d-flex align-center ga-2 mb-3">
              <v-icon size="small">mdi-domain</v-icon>
              {{ noticia.nombre_unidad }}
            </div>

            <!-- Estado -->
            <v-chip
              :color="obtenerColorEstado(noticia.estado_noticia)"
              size="small"
              variant="flat"
            >
              {{ noticia.estado_noticia }}
            </v-chip>
          </v-card-text>

          <!-- Acciones -->
          <v-card-actions class="pa-4 pt-0">
            <v-btn
              color="primary"
              variant="elevated"
              class="flex-grow-1"
              @click="abrirDialogEditar(noticia)"
            >
              <v-icon start>mdi-pencil</v-icon>
              Editar
            </v-btn>

            <v-menu location="bottom">
              <template #activator="{ props }">
                <v-btn
                  color="primary"
                  variant="elevated"
                  icon="mdi-dots-vertical"
                  v-bind="props"
                >
                </v-btn>
              </template>

              <v-list density="compact">
                <v-list-item
                  @click="cambiarEstadoNoticia(noticia, 'ACTIVO')"
                  :disabled="noticia.estado_noticia === 'ACTIVO'"
                >
                  <template #prepend>
                    <v-icon color="success">mdi-check-circle</v-icon>
                  </template>
                  <v-list-item-title>Activar</v-list-item-title>
                </v-list-item>

                <v-list-item
                  @click="cambiarEstadoNoticia(noticia, 'INACTIVO')"
                  :disabled="noticia.estado_noticia === 'INACTIVO'"
                >
                  <template #prepend>
                    <v-icon color="warning">mdi-pause-circle</v-icon>
                  </template>
                  <v-list-item-title>Desactivar</v-list-item-title>
                </v-list-item>

                <v-divider></v-divider>

                <v-list-item @click="cambiarEstadoNoticia(noticia, 'ELIMINADO')">
                  <template #prepend>
                    <v-icon color="error">mdi-delete</v-icon>
                  </template>
                  <v-list-item-title>Eliminar</v-list-item-title>
                </v-list-item>
              </v-list>
            </v-menu>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>

    <!-- Paginación -->
    <v-card v-if="noticias.length > 0" class="mt-4 rounded-lg" flat>
      <v-card-text class="d-flex flex-column flex-md-row align-center justify-space-between ga-4 pa-4">
        <div class="text-body-2 text-medium-emphasis">
          Mostrando {{ ((paginacion.page - 1) * paginacion.size) + 1 }} -
          {{ Math.min(paginacion.page * paginacion.size, paginacion.total) }}
          de {{ paginacion.total }} noticias
        </div>

        <v-pagination
          v-model="paginacion.page"
          :length="paginacion.total_pages"
          :total-visible="5"
          @update:model-value="cambiarPagina"
          :disabled="cargando"
          rounded="circle"
          color="primary"
          variant="elevated"
        ></v-pagination>
      </v-card-text>
    </v-card>

    <!-- Dialog para formulario -->
    <v-dialog
      v-model="dialogFormulario"
      max-width="920px"
      persistent
      scrollable
    >
      <v-card class="rounded-lg">
        <v-card-title class="bg-primary text-white d-flex align-center pa-4 sticky-header">
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
}

.noticia-card {
  height: 100%;
  display: flex;
  flex-direction: column;

  .noticia-imagen {
    position: relative;

    .badges-container {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      display: flex;
      flex-wrap: wrap;
      gap: 4px;
      background: linear-gradient(to bottom, rgba(0, 0, 0, 0.3), transparent);
    }
  }

  .v-card-text {
    flex-grow: 1;
  }

  .noticia-titulo {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    line-height: 1.4;
    min-height: 2.8em;
  }

  .noticia-resumen {
    display: -webkit-box;
    -webkit-line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
    line-height: 1.5;
    min-height: 4.5em;
  }

  .v-card-actions {
    gap: 8px;
  }
}

.sticky-header {
  position: sticky;
  top: 0;
  z-index: 1;
}

@media (max-width: 960px) {
  .search-field {
    min-width: 100%;
  }
}
</style>
