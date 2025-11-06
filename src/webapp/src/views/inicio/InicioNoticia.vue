<script setup>
import { onMounted, ref } from 'vue'
import { api } from '@/services/api'
import InicioNoticiaCard from '@/views/inicio/InicioNoticiaCard.vue'

const listaNoticia = ref([])
const listaCarrusel = ref([])

onMounted(async () => {
  try {
    const response = await api.get('/noticia')
    listaNoticia.value = response.data

    // Dividir noticias en chunks de 2 para el carrusel
    const chunkSize = 2
    for (let i = 0; i < response.data.length; i += chunkSize) {
      const chunk = response.data.slice(i, i + chunkSize)
      listaCarrusel.value.push(chunk)
    }
  } catch (error) {
    console.error('Error cargando noticias:', error)
  }
})
</script>

<template>
  <div id="noticias" class="py-8 bg-grey-lighten-4">
    <v-container>
      <h2 class="text-h3 text-center font-weight-bold mb-8">Noticias</h2>

      <v-carousel
        v-if="listaCarrusel.length > 0"
        class="noticia-carrusel"
        height="400"
        cycle
        :interval="8000"
        hide-delimiter-background
        show-arrows="hover"
      >
        <v-carousel-item v-for="(chunk, index) in listaCarrusel" :key="index">
          <v-container class="fill-height">
            <v-row class="fill-height" align="center" justify="center">
              <v-col cols="12" md="6" v-for="(noticia, idx) in chunk" :key="idx">
                <inicio-noticia-card :noticia="noticia"></inicio-noticia-card>
              </v-col>
            </v-row>
          </v-container>
        </v-carousel-item>
      </v-carousel>

      <div v-else class="text-center py-8">
        <p class="text-h6 text-grey">No hay noticias disponibles en este momento.</p>
      </div>
    </v-container>
  </div>
</template>

<style scoped lang="scss">
.noticia-carrusel {
  :deep(.v-carousel__controls) {
    background: transparent;
  }
}
</style>
