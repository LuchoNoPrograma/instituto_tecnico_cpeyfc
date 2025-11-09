<script setup>
import { ref, computed } from 'vue'
import formatoFecha from '@/helpers/formatos'
import imagenNoDisponible from '@/assets/images/img_default.png'
import InicioNoticiaDetalle from './InicioNoticiaDetalle.vue'

const props = defineProps({
  noticia: {
    type: Object,
    required: true
  }
})

// Estado del modal
const mostrarDetalle = ref(false)

const obtenerImagen = () => {
  return props.noticia.imagen_url || props.noticia.imagen_uri || imagenNoDisponible
}

const tieneEnlaceExterno = computed(() => !!props.noticia.enlace_externo)

const abrirDetalle = () => {
  mostrarDetalle.value = true
}

const abrirEnlaceExterno = () => {
  if (props.noticia.enlace_externo) {
    window.open(props.noticia.enlace_externo, '_blank')
  }
}
</script>

<template>
  <v-card class="noticia-card" elevation="4" rounded="lg">
    <!-- Imagen -->
    <v-img
      :src="obtenerImagen()"
      aspect-ratio="16/9"
      cover
      class="noticia-imagen"
    >
      <template #error>
        <v-img :src="imagenNoDisponible" height="275" cover></v-img>
      </template>

      <!-- Badges -->
      <div class="badges-overlay pa-2">
        <v-chip
          v-if="noticia.es_destacada"
          color="warning"
          size="small"
          class="mr-1"
        >
          <v-icon start size="small">mdi-star</v-icon>
          Destacada
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
        {{ formatoFecha.literario(noticia.fecha_noticia) }}
      </div>

      <div class="d-flex align-center ga-2 mb-3">
        <v-icon size="small">mdi-domain</v-icon>
        {{ noticia.nombre_unidad }}
      </div>
    </v-card-text>

    <!-- Acciones -->
    <v-card-actions class="pa-3">
      <v-row dense>
        <!-- Botón "Leer más" - siempre visible -->
        <v-col cols="12" :sm="tieneEnlaceExterno ? 6 : 12">
          <v-btn
            color="primary"
            variant="elevated"
            append-icon="mdi-book-open-page-variant"
            @click="abrirDetalle"
            block
          >
            Leer más
          </v-btn>
        </v-col>

        <!-- Botón "Enlace externo" - solo si existe -->
        <v-col v-if="tieneEnlaceExterno" cols="12" sm="6">
          <v-btn
            color="secondary"
            variant="outlined"
            append-icon="mdi-open-in-new"
            @click="abrirEnlaceExterno"
            block
          >
            Ver enlace
          </v-btn>
        </v-col>
      </v-row>
    </v-card-actions>

    <!-- Modal de detalle -->
    <InicioNoticiaDetalle
      v-model="mostrarDetalle"
      :noticia="noticia"
    />
  </v-card>
</template>

<style scoped lang="scss">
.noticia-card {
  display: flex;
  flex-direction: column;
  transition: transform 0.3s ease, box-shadow 0.3s ease;

  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2) !important;
  }

  .noticia-imagen {
    position: relative;

    .badges-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
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
}
</style>
