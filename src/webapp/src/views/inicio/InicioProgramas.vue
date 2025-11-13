<script setup>
import { onMounted, ref } from 'vue'
import { api } from '@/services/api'
import InicioProgramaCard from '@/views/inicio/InicioProgramaCard.vue'

const listaProgramas = ref([])
const cargandoProgramas = ref(false)

onMounted(async () => {
  cargandoProgramas.value = true
  try {
    const response = await api.get('/api/publico/programas-ofertados')
    listaProgramas.value = response.data
  } catch (error) {
    console.error('Error al obtener programas ofertados:', error)
    listaProgramas.value = []
  } finally {
    cargandoProgramas.value = false
  }
})
</script>

<template>
  <section class="programas-section">
    <v-container>
      <div class="section-header" data-aos="fade-up">
        <h2 class="section-title">Nuestros Programas</h2>
        <p class="section-subtitle">
          Descubre las carreras técnicas que te prepararán para el éxito profesional
        </p>
      </div>

      <!-- Loading state -->
      <div v-if="cargandoProgramas" class="text-center my-8">
        <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
        <p class="mt-4 text-h6">Cargando programas disponibles...</p>
      </div>

      <!-- No hay programas -->
      <div v-else-if="listaProgramas.length === 0" class="text-center my-8">
        <v-icon size="64" color="grey-lighten-1">mdi-school-outline</v-icon>
        <p class="text-h6 mt-4 text-grey">No hay programas disponibles en este momento</p>
      </div>

      <!-- Lista de programas -->
      <v-row v-else class="programas-grid">
        <v-col
          v-for="(programa, index) in listaProgramas"
          :key="programa.id_aca_programa_aprobado"
          cols="12"
          sm="6"
          md="4"
          lg="4"
          xl="3"
          data-aos="fade-up"
          :data-aos-delay="50 * (index % 8)"
        >
          <inicio-programa-card :programa="programa" />
        </v-col>
      </v-row>
    </v-container>
  </section>
</template>

<style scoped lang="scss">
.programas-section {
  padding: 3rem 0;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  min-height: 100vh;

  .section-header {
    text-align: center;
    margin-bottom: 3rem;

    .section-title {
      font-size: 3rem;
      font-weight: 700;
      color: #D32F2F;
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
        background: #1976D2;
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

  .programas-grid {
    margin-top: 2rem;
  }
}

@media (max-width: 960px) {
  .programas-section {
    .section-header .section-title {
      font-size: 2.2rem !important;
    }

    .section-subtitle {
      font-size: 1rem !important;
    }
  }
}

@media (max-width: 600px) {
  .programas-section {
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
