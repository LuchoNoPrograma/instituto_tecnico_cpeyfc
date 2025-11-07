<script setup>
import formatoFecha from '@/helpers/formatos'

const props = defineProps({
  noticia: {
    type: Object,
    required: true
  }
})

const openLink = () => {
  if (props.noticia.enlace_externo) {
    window.open(props.noticia.enlace_externo, '_blank')
  }
}
</script>

<template>
  <v-card class="noticia-card" elevation="4" rounded="lg" height="100%">
    <v-img
      v-if="noticia.imagen_uri"
      :src="noticia.imagen_uri"
      height="200"
      cover
      class="noticia-imagen"
    >
      <v-chip
        v-if="noticia.es_destacada"
        color="error"
        size="small"
        class="ma-2"
      >
        Destacada
      </v-chip>
    </v-img>

    <v-card-title class="text-h5 font-weight-bold">
      {{ noticia.titulo }}
    </v-card-title>

    <v-card-subtitle class="mt-2">
      <div class="d-flex align-center gap-2">
        <v-icon icon="mdi-calendar" size="small"></v-icon>
        {{ formatoFecha.completo(noticia.fecha_noticia) }}
      </div>
      <div v-if="noticia.nombre_unidad" class="mt-1">
        <v-icon icon="mdi-domain" size="small"></v-icon>
        {{ noticia.nombre_unidad }}
      </div>
    </v-card-subtitle>

    <v-card-text>
      <p class="text-body-2 text-truncate-3">
        {{ noticia.resumen }}
      </p>
    </v-card-text>

    <v-card-actions class="pa-4">
      <v-btn
        v-if="noticia.enlace_externo"
        color="primary"
        variant="text"
        append-icon="mdi-arrow-right"
        @click="openLink"
      >
        Leer más
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

<style scoped lang="scss">
.noticia-card {
  transition: transform 0.3s ease, box-shadow 0.3s ease;

  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2) !important;
  }
}

.text-truncate-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
