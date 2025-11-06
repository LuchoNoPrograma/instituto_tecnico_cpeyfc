<script setup>
import imgDefault from '@/assets/images/img_default.png'
import { computed } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  programa: {
    type: Object,
    required: true
  }
})

const router = useRouter()

// Configuración de WhatsApp
const numeroWhatsApp = '59174771457'

// Computed properties
const programaTieneImagen = computed(() => !!props.programa.imagen)

const imagenPrograma = computed(() => {
  if (!programaTieneImagen.value) return imgDefault
  // Si imagen_url es una URL completa, usarla directamente
  if (props.programa.imagen.startsWith('http')) return props.programa.imagen
  // Si es un nombre de archivo, construir la ruta al endpoint
  return `/api/publico/programas/${props.programa.imagen}/imagen`
})

const inscripcionesCerradas = computed(() =>
  props.programa.estado !== 'INSCRIPCIONES ABIERTAS'
)

const mensajeWhatsApp = computed(() =>
  `Hola, me interesa información sobre el programa: ${props.programa.nombre}`
)

// Métodos
const abrirWhatsApp = () => {
  const url = `https://api.whatsapp.com/send/?phone=${numeroWhatsApp}&text=${encodeURIComponent(mensajeWhatsApp.value)}&type=phone_number&app_absent=0`
  window.open(url, '_blank')
}

const inscribirme = () => {
  router.push(`/inscripciones?programa=${props.programa.id}`)
}
</script>

<template>
  <v-card class="programa-card" elevation="4" rounded="xl" hover>
    <!-- Imagen del programa -->
    <div class="programa-card__imagen-container">
      <v-img
        :src="imagenPrograma"
        height="280"
        cover
        class="programa-card__imagen"
      >
        <template v-slot:placeholder>
          <v-row class="fill-height ma-0" align="center" justify="center">
            <v-progress-circular indeterminate color="primary"></v-progress-circular>
          </v-row>
        </template>
      </v-img>

      <!-- Chip de estado solo si inscripciones cerradas -->
      <v-chip
        v-if="inscripcionesCerradas"
        class="programa-card__chip-estado"
        color="error"
        size="small"
      >
        <v-icon icon="mdi-cancel" start size="small"></v-icon>
        Inscripciones cerradas
      </v-chip>
    </div>

    <!-- Contenido -->
    <v-card-text class="pa-4">
      <!-- Título del programa -->
      <h3 class="text-h6 font-weight-bold mb-2 programa-card__titulo">
        {{ programa.nombre }}
      </h3>

      <!-- Área académica -->
      <div class="d-flex align-center mb-2">
        <v-icon icon="mdi-book-open-variant" size="small" class="mr-2 text-primary"></v-icon>
        <span class="text-body-2 text-grey-darken-2">
          <span class="font-weight-medium">Área:</span> {{ programa.area }}
        </span>
      </div>

      <v-divider class="my-3"></v-divider>

      <!-- Modalidad -->
      <div class="d-flex align-center mb-2">
        <v-icon icon="mdi-school" size="small" class="mr-2 text-grey-darken-1"></v-icon>
        <span class="text-body-2 text-grey-darken-2">
          <span class="font-weight-medium">Modalidad:</span> {{ programa.modalidad }}
        </span>
      </div>

      <!-- Carga horaria (usando duracion del mapeo) -->
      <div class="d-flex align-center mb-2">
        <v-icon icon="mdi-clock-outline" size="small" class="mr-2 text-grey-darken-1"></v-icon>
        <span class="text-body-2 text-grey-darken-2">
          <span class="font-weight-medium">Duración:</span> {{ programa.duracion }}
        </span>
      </div>

      <!-- Precio -->
      <div class="d-flex align-center mb-3">
        <v-icon icon="mdi-currency-usd" size="small" class="mr-2 text-grey-darken-1"></v-icon>
        <span class="text-h6 font-weight-bold text-primary">
          {{ programa.precioColegiatura ? `${programa.precioColegiatura} Bs.` : 'Consultar' }}
        </span>
      </div>

      <v-divider class="my-3"></v-divider>

      <!-- Inscripciones abiertas hasta -->
      <div class="mb-2">
        <p class="text-body-2 font-weight-medium text-grey-darken-3 mb-1">
          Inscripciones abiertas hasta:
        </p>
        <p class="text-body-1 font-weight-bold text-primary">
          {{ programa.fechaInscripcion }}
        </p>
      </div>

      <!-- Días restantes -->
      <div v-if="!inscripcionesCerradas && programa.diasRestantes > 0" class="d-flex align-center">
        <v-icon icon="mdi-timer-sand" size="small" class="mr-2 text-warning"></v-icon>
        <span class="text-body-2 text-warning font-weight-medium">
          {{ programa.diasRestantes }} días restantes
        </span>
      </div>
    </v-card-text>

    <!-- Acciones -->
    <v-card-actions class="pa-4 pt-0">
      <v-row dense>
        <v-col cols="12">
          <div class="d-flex ga-2">
            <!-- Botón WhatsApp -->
            <v-btn
              variant="outlined"
              color="success"
              size="default"
              @click="abrirWhatsApp"
              class="flex-grow-0"
            >
              <v-icon icon="mdi-whatsapp" start></v-icon>
              Más información
            </v-btn>

            <!-- Botón Inscribirme -->
            <v-btn
              v-if="!inscripcionesCerradas"
              variant="elevated"
              color="primary"
              size="default"
              @click="inscribirme"
              class="flex-grow-1"
            >
              INSCRIBIRME
              <v-icon icon="mdi-arrow-right" end></v-icon>
            </v-btn>
          </div>
        </v-col>
      </v-row>
    </v-card-actions>
  </v-card>
</template>

<style scoped lang="scss">
.programa-card {
  transition: all 0.3s ease;
  height: 100%;
  display: flex;
  flex-direction: column;

  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15) !important;
  }

  &__imagen-container {
    position: relative;
    overflow: hidden;
  }

  &__imagen {
    transition: transform 0.3s ease;

    &:hover {
      transform: scale(1.05);
    }
  }

  &__chip-estado {
    position: absolute;
    top: 12px;
    right: 12px;
    z-index: 2;
    font-weight: 600;
  }

  &__titulo {
    line-height: 1.4;
    color: rgb(var(--v-theme-primary));
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
    min-height: 2.8em;
  }

  .v-card-text {
    flex-grow: 1;
  }
}
</style>
