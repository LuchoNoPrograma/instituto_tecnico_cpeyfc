<script setup>
import formatoFecha from '@/helpers/formatos'

const props = defineProps({
  noticia: {
    type: Object,
    required: true
  }
})
</script>

<template>
  <v-card class="noticia-card" elevation="4" rounded="lg" height="100%">
    <v-card-title class="text-h5 font-weight-bold">
      {{ noticia.titulo }}
    </v-card-title>
    <v-card-subtitle class="mt-2">
      <v-icon icon="mdi-calendar" size="small"></v-icon>
      {{ formatoFecha.completo(noticia.fechaPublicacion) }}
    </v-card-subtitle>
    <v-card-text>
      <p class="text-body-2 text-truncate-3">
        {{ noticia.contenido }}
      </p>
    </v-card-text>
    <v-card-actions class="pa-4">
      <v-btn color="primary" variant="text" append-icon="mdi-arrow-right">
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
