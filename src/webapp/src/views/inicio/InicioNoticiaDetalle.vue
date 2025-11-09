<script setup>
import { computed } from 'vue'
import formatoFecha from '@/helpers/formatos'
import imagenNoDisponible from '@/assets/images/img_default.png'

const props = defineProps({
  noticia: {
    type: Object,
    required: true
  },
  modelValue: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])

const dialogVisible = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const obtenerImagen = () => {
  return props.noticia?.imagen_url || props.noticia?.imagen_uri || imagenNoDisponible
}

const tieneEnlaceExterno = computed(() => !!props.noticia?.enlace_externo)

const abrirEnlaceExterno = () => {
  if (props.noticia?.enlace_externo) {
    window.open(props.noticia.enlace_externo, '_blank')
  }
}

const cerrar = () => {
  dialogVisible.value = false
}
</script>

<template>
  <v-dialog
    v-model="dialogVisible"
    max-width="900px"
    scrollable
    :fullscreen="$vuetify.display.xs"
  >
    <v-card class="noticia-detalle">
      <!-- Barra superior con botón cerrar -->
      <v-toolbar
        color="transparent"
        flat
        class="noticia-detalle__toolbar"
      >
        <v-spacer></v-spacer>
        <v-btn
          icon="mdi-close"
          variant="text"
          @click="cerrar"
          size="small"
        ></v-btn>
      </v-toolbar>

      <!-- Imagen de portada a todo ancho -->
      <div class="noticia-detalle__portada">
        <v-img
          :src="obtenerImagen()"
          aspect-ratio="16/9"
          cover
          class="noticia-detalle__portada-img"
        >
          <template #error>
            <v-img :src="imagenNoDisponible" aspect-ratio="16/9" cover></v-img>
          </template>

          <!-- Overlay oscuro sutil -->
          <div class="noticia-detalle__portada-overlay"></div>

          <!-- Badges flotantes -->
          <div class="noticia-detalle__badges">
            <v-chip
              v-if="noticia.es_destacada"
              color="warning"
              size="default"
              class="elevation-4"
            >
              <v-icon start>mdi-star</v-icon>
              Destacada
            </v-chip>
          </div>
        </v-img>
      </div>

      <!-- Contenido del artículo -->
      <v-card-text class="noticia-detalle__contenido pa-0">
        <div class="noticia-detalle__container">
          <!-- Encabezado del artículo -->
          <header class="noticia-detalle__header">
            <!-- Título principal -->
            <h1 class="noticia-detalle__titulo">
              {{ noticia.titulo }}
            </h1>

            <!-- Metadata -->
            <div class="noticia-detalle__meta">
              <div class="d-flex flex-wrap align-center ga-4">
                <!-- Unidad -->
                <div class="d-flex align-center">
                  <v-icon icon="mdi-domain" size="small" class="mr-2 text-primary"></v-icon>
                  <span class="text-body-2 font-weight-medium">{{ noticia.nombre_unidad }}</span>
                </div>

                <v-divider vertical class="hidden-xs"></v-divider>

                <!-- Fecha -->
                <div class="d-flex align-center">
                  <v-icon icon="mdi-calendar" size="small" class="mr-2 text-medium-emphasis"></v-icon>
                  <span class="text-body-2 text-medium-emphasis">
                    {{ formatoFecha.literario(noticia.fecha_noticia) }}
                  </span>
                </div>
              </div>
            </div>

            <v-divider class="my-6"></v-divider>
          </header>

          <!-- Contenido principal -->
          <article class="noticia-detalle__articulo">
            <div class="noticia-detalle__texto">
              {{ noticia.resumen }}
            </div>
          </article>

          <!-- Call to action - Enlace externo -->
          <div v-if="tieneEnlaceExterno" class="noticia-detalle__cta">
            <v-divider class="mb-6"></v-divider>
            <v-card
              color="primary"
              variant="tonal"
              class="pa-4"
            >
              <div class="d-flex align-center justify-space-between flex-wrap ga-3">
                <div>
                  <div class="text-h6 font-weight-bold mb-1">
                    ¿Quieres saber más?
                  </div>
                  <div class="text-body-2 text-medium-emphasis">
                    Visita el enlace completo para obtener más información
                  </div>
                </div>
                <v-btn
                  color="primary"
                  variant="elevated"
                  size="large"
                  append-icon="mdi-open-in-new"
                  @click="abrirEnlaceExterno"
                >
                  Ver más información
                </v-btn>
              </div>
            </v-card>
          </div>
        </div>
      </v-card-text>

      <!-- Footer con acciones -->
      <v-divider></v-divider>
      <v-card-actions class="pa-4 justify-center">
        <v-btn
          variant="text"
          @click="cerrar"
        >
          Cerrar
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<style lang="scss" scoped>
.noticia-detalle {
  &__toolbar {
    position: absolute;
    top: 0;
    right: 0;
    left: 0;
    z-index: 10;
    background: linear-gradient(to bottom, rgba(0, 0, 0, 0.3), transparent) !important;

    :deep(.v-btn) {
      background: rgba(255, 255, 255, 0.9);
      backdrop-filter: blur(8px);
    }
  }

  &__portada {
    position: relative;
    width: 100%;

    &-overlay {
      position: absolute;
      inset: 0;
      background: linear-gradient(
        to bottom,
        transparent 0%,
        transparent 60%,
        rgba(0, 0, 0, 0.05) 100%
      );
    }

    &-img {
      width: 100%;
    }
  }

  &__badges {
    position: absolute;
    bottom: 16px;
    left: 16px;
    z-index: 2;
  }

  &__contenido {
    background: white;
  }

  &__container {
    max-width: 720px;
    margin: 0 auto;
    padding: 32px 24px;

    @media (min-width: 768px) {
      padding: 48px 40px;
    }
  }

  &__header {
    margin-bottom: 32px;
  }

  &__titulo {
    font-size: 2rem;
    font-weight: 700;
    line-height: 1.2;
    color: rgb(var(--v-theme-on-surface));
    margin-bottom: 24px;
    letter-spacing: -0.02em;

    @media (min-width: 768px) {
      font-size: 2.5rem;
    }
  }

  &__meta {
    color: rgb(var(--v-theme-on-surface-variant));
  }

  &__articulo {
    margin-bottom: 32px;
  }

  &__texto {
    font-size: 1.125rem;
    line-height: 1.8;
    color: rgb(var(--v-theme-on-surface));
    white-space: pre-wrap;
    word-wrap: break-word;

    // Estilos tipo Medium para el texto
    p {
      margin-bottom: 1.5em;
    }

    &::first-letter {
      font-size: 3.2em;
      line-height: 1;
      float: left;
      margin: 0.05em 0.1em 0 0;
      font-weight: 700;
      color: rgb(var(--v-theme-primary));
    }
  }

  &__cta {
    margin-top: 40px;
  }
}

// Ajustes responsive
@media (max-width: 600px) {
  .noticia-detalle {
    &__titulo {
      font-size: 1.75rem;
    }

    &__texto {
      font-size: 1rem;
      line-height: 1.7;
    }
  }
}
</style>
