<script setup>
import { onMounted, ref, computed } from 'vue'
import { api } from '@/services/api'
import InicioNoticiaCard from '@/views/inicio/InicioNoticiaCard.vue'

const listaNoticia = ref([])
const paginaActual = ref(1)
const noticiasPorPagina = 3
const cargandoNoticias = ref(false)

// Computed para paginación
const totalPaginas = computed(() => {
  return Math.ceil(listaNoticia.value.length / noticiasPorPagina)
})

const noticiasVisibles = computed(() => {
  const inicio = (paginaActual.value - 1) * noticiasPorPagina
  const fin = inicio + noticiasPorPagina
  return listaNoticia.value.slice(inicio, fin)
})

onMounted(async () => {
  cargandoNoticias.value = true
  try {
    const response = await api.get('/api/publico/noticia/carrusel')
    listaNoticia.value = response.data
  } catch (error) {
    console.error('Error cargando noticias:', error)
    listaNoticia.value = []
  } finally {
    cargandoNoticias.value = false
  }
})
</script>

<template>
  <section id="noticias" class="noticias-section">
    <v-container>
      <div class="section-header" data-aos="fade-up">
        <h2 class="section-title">Noticias y Eventos</h2>
        <p class="section-subtitle">
          Mantente informado sobre las últimas novedades y eventos de nuestra institución
        </p>
      </div>

      <!-- Loading state -->
      <div v-if="cargandoNoticias" class="text-center my-8">
        <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
        <p class="mt-4 text-h6">Cargando noticias...</p>
      </div>

      <!-- No hay noticias -->
      <div v-else-if="listaNoticia.length === 0" class="text-center my-8">
        <v-icon size="64" color="grey-lighten-1">mdi-newspaper-variant-outline</v-icon>
        <p class="text-h6 mt-4 text-grey">No hay noticias disponibles en este momento</p>
      </div>

      <!-- Grid de noticias -->
      <div v-else>
        <v-row class="noticias-grid">
          <v-col
            v-for="(noticia, index) in noticiasVisibles"
            :key="noticia.id_pub_noticia"
            cols="12"
            md="4"
            data-aos="fade-up"
            :data-aos-delay="100 * index"
          >
            <inicio-noticia-card :noticia="noticia" />
          </v-col>
        </v-row>

        <!-- Paginación -->
        <div v-if="totalPaginas > 1" class="d-flex justify-center mt-8">
          <v-pagination
            v-model="paginaActual"
            :length="totalPaginas"
            :total-visible="5"
            rounded="circle"
            color="primary"
            size="large"
            variant="elevated"
          ></v-pagination>
        </div>
      </div>
    </v-container>
  </section>
</template>

<style scoped lang="scss">
.noticias-section {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  min-height: 100vh;

  .section-header {
    text-align: center;
    margin-bottom: 3rem;

    .section-title {
      font-size: 3rem;
      font-weight: 700;
      color: #1976D2;
      margin-bottom: 1rem;
      position: relative;

      &::after {
        content: '';
        position: absolute;
        bottom: -10px;
        left: 50%;
        transform: translateX(-50%);
        width: 80px;
        height: 4px;
        background: #D32F2F;
        border-radius: 2px;
      }
    }

    .section-subtitle {
      font-size: 1.2rem;
      color: #666;
      max-width: 600px;
      margin: 0 auto;
      line-height: 1.6;
    }
  }

  .noticias-grid {
    margin-top: 2rem;
  }
}

@media (max-width: 960px) {
  .noticias-section {
    .section-header .section-title {
      font-size: 2.2rem !important;
    }

    .section-subtitle {
      font-size: 1rem !important;
    }
  }
}

@media (max-width: 600px) {
  .noticias-section {
    padding: 2rem 0;

    .section-header {
      margin-bottom: 2rem;

      .section-title {
        font-size: 1.8rem !important;
      }
    }
  }
}
</style>
