<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import formatoFecha from '@/helpers/formatos.js'
import imagenDefault from '@/assets/images/img_default.png';
import {useInicioStore} from '@/stores/inicio.js';

const props = defineProps({
  programa: {
    type: Object,
    required: true
  }
})

const router = useRouter()

// Configuración de WhatsApp
const numeroWhatsapp = '59174771457'

const obtenerImagen = computed(() => {
  if (props.programa.imagen_url) {
    return '/api' + props.programa.imagen_url
  }
  return imagenDefault
})
const inscripcionesCerradas = computed(() =>
  props.programa.estado_inscripcion !== 'INSCRIPCIONES ABIERTAS'
)

const mensajeWhatsapp = computed(() =>
  `Hola, me interesa información sobre el programa: ${props.programa.nombre_programa}`
)

// Métodos
const abrirWhatsapp = () => {
  const url = `https://api.whatsapp.com/send/?phone=${numeroWhatsapp}&text=${encodeURIComponent(mensajeWhatsapp.value)}&type=phone_number&app_absent=0`
  window.open(url, '_blank')
}

const inicioStore = useInicioStore()
const inscribirme = () => {
  inicioStore.programa = props.programa;
  router.push(`/inscripciones?programa=${props.programa.id_aca_programa_aprobado}`)
}
</script>

<template>
  <v-card class="programa-card" elevation="4" rounded="xl" hover>
    <!-- Imagen del programa -->
    <div class="programa-card__imagen-container">
      <v-img
        :src="obtenerImagen"
        min-height="250"
        aspect-ratio="16/9"
        cover
        class="programa-card__imagen"
      >
        <template v-slot:placeholder>
          <v-row class="fill-height ma-0" align="center" justify="center">
            <v-progress-circular indeterminate color="primary"></v-progress-circular>
          </v-row>
        </template>
      </v-img>

      <!-- Chip de área académica - lado derecho superior -->
      <v-chip
        class="programa-card__chip-area"
        color="primary"
        variant="elevated"
      >
        <v-icon icon="mdi-book-open-variant" start size="small"></v-icon>
        {{ programa.nombre_area }}
      </v-chip>

      <!-- Chip de estado inscripciones cerradas - lado izquierdo superior -->
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
      <h3 class="text-h6 font-weight-bold programa-card__titulo">
        {{ programa.nombre_programa }}
      </h3>

      <v-divider class="mb-2"></v-divider>

      <!-- Área -->
      <div class="meta-item d-flex align-center mb-2">
        <v-icon size="18" color="grey-darken-1" class="mr-2">mdi-domain</v-icon>
        <span class="text-body-2">{{ programa.nombre_area }}</span>
      </div>

      <!-- Modalidad -->
      <div class="meta-item d-flex align-center mb-2">
        <v-icon size="18" color="grey-darken-1" class="mr-2">mdi-laptop</v-icon>
        <span class="text-body-2">{{ programa.nombre_modalidad }}</span>
      </div>

      <!-- Duración -->
      <div v-if="programa.duracion" class="meta-item d-flex align-center mb-2">
        <v-icon size="18" color="grey-darken-1" class="mr-2">mdi-clock-outline</v-icon>
        <span class="text-body-2">{{ programa.duracion }}</span>
      </div>

      <!-- Carga horaria -->
      <div v-if="programa.carga_horaria" class="meta-item d-flex align-center mb-2">
        <v-icon size="18" color="grey-darken-1" class="mr-2">mdi-book-open</v-icon>
        <span class="text-body-2">{{ programa.carga_horaria }} horas</span>
      </div>

      <!-- Duración/Plan -->
<!--      <div class="d-flex align-center mb-3">
        <v-icon icon="mdi-clock-outline" size="small" class="mr-2 text-grey-darken-1"></v-icon>
        <span class="text-body-2 text-grey-darken-2">
          <span class="font-weight-medium">Plan:</span> {{ programa.plan_anho || 'Consultar' }}
        </span>
      </div>-->

      <v-divider class="mb-2"></v-divider>

      <!-- Inscripciones abiertas hasta -->
      <div class="mb-2">
        <p class="text-body-2 font-weight-medium text-grey-darken-3 mb-1">
          Inscripciones abiertas hasta:
        </p>
        <p class="text-body-1 font-weight-bold text-primary">
          {{ formatoFecha.literario(programa.fecha_fin_inscripcion) }}
        </p>
      </div>

      <!-- Días restantes -->
      <div v-if="!inscripcionesCerradas && programa.dias_restantes_inscripcion > 0" class="d-flex align-center">
        <v-icon icon="mdi-timer-sand" size="small" class="mr-2 text-warning"></v-icon>
        <span class="text-body-2 text-warning font-weight-medium">
          {{ programa.dias_restantes_inscripcion }} días restantes
        </span>
      </div>
    </v-card-text>

    <!-- Acciones -->
    <v-card-actions class="pa-4 pt-0">
      <v-row dense>
        <v-col cols="12">
          <div class="d-flex flex-wrap ga-2">
            <!-- Botón WhatsApp -->
            <v-btn
              variant="outlined"
              color="success"
              size="default"
              @click="abrir_whatsapp"
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
              @click="inscribirme"
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

  &__chip-area {
    position: absolute;
    top: 12px;
    right: 12px;
    z-index: 2;
    font-weight: 600;
  }

  &__chip-estado {
    position: absolute;
    top: 12px;
    left: 12px;
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
