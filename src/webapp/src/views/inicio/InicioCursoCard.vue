<script setup>
import imgDefault from '@/assets/images/img_default.png'
import { computed } from 'vue'

const props = defineProps({
  curso: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['click:img', 'click:inscribirme'])

const cursoTieneImagen = computed(() => !!props.curso.imagen)
const imagenCurso = computed(() => (cursoTieneImagen.value ? `data:image/jpeg;base64,${props.curso.imagen}` : imgDefault))

const precioMinimo = computed(() => {
  if (!props.curso.aranceles || props.curso.aranceles.length === 0) return 'Consultar'
  const precios = props.curso.aranceles.map((a) => a.arancelCurso)
  return `Desde ${Math.min(...precios)} Bs.`
})

const preinscripcionCerrada = computed(() => new Date() >= new Date(props.curso.fechaLimitePreinscripcion))

const numeroWhatsApp = '59174771457'
const mensajeWhatsApp = computed(
  () => `Hola, necesito información sobre el curso: ${props.curso.nombreCurso}`
)

const abrirWhatsApp = () => {
  const url = `https://web.whatsapp.com/send?phone=${numeroWhatsApp}&text=${encodeURIComponent(mensajeWhatsApp.value)}`
  window.open(url, '_blank')
}

const verFichaTecnica = () => {
  emit('click:img', {
    imgUrl: imagenCurso.value,
    curso: props.curso,
    cursoTieneImg: cursoTieneImagen.value
  })
}

const inscribirme = () => {
  emit('click:inscribirme', {
    imgUrl: imagenCurso.value,
    curso: props.curso,
    cursoTieneImg: cursoTieneImagen.value
  })
}
</script>

<template>
  <v-card class="curso-card" elevation="2" rounded="lg" hover>
    <!-- Imagen -->
    <div class="curso-card__imagen-container" @click="verFichaTecnica">
      <v-img :src="imagenCurso" height="200" cover class="curso-card__imagen">
        <template v-slot:placeholder>
          <v-row class="fill-height ma-0" align="center" justify="center">
            <v-progress-circular indeterminate color="primary"></v-progress-circular>
          </v-row>
        </template>
      </v-img>

      <!-- Chip de estado si está cerrada -->
      <v-chip v-if="preinscripcionCerrada" class="curso-card__chip-estado" color="error" size="small">
        <v-icon icon="mdi-cancel" start size="small"></v-icon>
        Preinscripciones cerradas
      </v-chip>
    </div>

    <!-- Contenido -->
    <v-card-text class="pa-4">
      <!-- Título -->
      <h3 class="text-h6 font-weight-bold mb-3 curso-card__titulo">
        {{ curso.nombreCurso }}
      </h3>

      <!-- Modalidad -->
      <div class="d-flex align-center mb-2">
        <v-icon icon="mdi-school" size="small" class="mr-2 text-grey-darken-1"></v-icon>
        <span class="text-body-2 text-grey-darken-2">{{ curso.modalidadNombre }}</span>
      </div>

      <!-- Precio -->
      <div class="d-flex align-center mb-3">
        <v-icon icon="mdi-currency-usd" size="small" class="mr-2 text-grey-darken-1"></v-icon>
        <span class="text-h6 font-weight-bold text-primary">{{ precioMinimo }}</span>
      </div>

      <!-- Link ficha técnica -->
      <v-btn
        variant="text"
        size="small"
        color="grey-darken-2"
        class="pa-0 mb-3"
        @click="verFichaTecnica"
        prepend-icon="mdi-file-document-outline"
      >
        Ver ficha técnica
      </v-btn>
    </v-card-text>

    <!-- Acciones -->
    <v-card-actions class="pa-4 pt-0 d-flex ga-2">
      <v-btn
        variant="outlined"
        color="success"
        size="small"
        @click="abrirWhatsApp"
        prepend-icon="mdi-whatsapp"
        class="flex-grow-0"
      >
        Solicitar info
      </v-btn>

      <v-btn
        v-if="!preinscripcionCerrada"
        variant="elevated"
        color="primary"
        size="large"
        @click="inscribirme"
        prepend-icon="mdi-pen-plus"
        class="flex-grow-1"
      >
        Inscribirme
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

<style scoped lang="scss">
.curso-card {
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
    cursor: pointer;
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
  }

  &__titulo {
    line-height: 1.4;
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
