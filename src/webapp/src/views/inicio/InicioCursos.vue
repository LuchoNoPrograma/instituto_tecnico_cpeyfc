<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos'
import InicioCursoCard from '@/views/inicio/InicioCursoCard.vue'

const router = useRouter()
const listaCurso = ref([])
const cargandoCursos = ref(false)

const obtenerColorEstado = (estado) => {
  const colores = {
    'INSCRIPCIONES ABIERTAS': 'success',
    'PROXIMAMENTE': 'info',
    'INSCRIPCIONES CERRADAS': 'error'
  }
  return colores[estado] || 'info'
}

const calcularDuracion = (cargaHoraria, planAnho) => {
  if (planAnho) return `Plan ${planAnho}`
  if (cargaHoraria) {
    if (cargaHoraria <= 800) return '1 año'
    if (cargaHoraria <= 1600) return '2 años'
    return '2.5 años'
  }
  return '2 años'
}

const obtenerImagenPorDefecto = (area) => {
  const imagenesPorArea = {
    'Sistemas': 'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=400',
    'Informática': 'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=400',
    'Enfermería': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
    'Salud': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
    'Administración': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    'Empresa': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    'Idiomas': 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400'
  }

  for (const [key, imagen] of Object.entries(imagenesPorArea)) {
    if (area && area.toLowerCase().includes(key.toLowerCase())) {
      return imagen
    }
  }

  return 'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=400'
}

const verPrograma = (programa) => {
  router.push(`/inscripciones?programa=${programa.id}`)
}

const abrirWhatsAppPrograma = (programa) => {
  const numeroWhatsApp = '59174771457'
  const mensaje = `Hola, me interesa información sobre el programa: ${programa.nombre}`
  const url = `https://wa.me/${numeroWhatsApp}?text=${encodeURIComponent(mensaje)}`
  window.open(url, '_blank')
}

onMounted(async () => {
  cargandoCursos.value = true
  try {
    const response = await api.get('/api/publico/programas-ofertados')

    // Mapear datos de la vista a la estructura del componente
    listaCurso.value = response.data.map(programa => ({
      id: programa.id_aca_programa_aprobado,
      nombre: programa.nombre_programa,
      duracion: calcularDuracion(programa.carga_horaria, programa.plan_anho),
      modalidad: programa.nombre_modalidad,
      imagen: programa.imagen_url || obtenerImagenPorDefecto(programa.nombre_area),
      fechaInscripcion: formatoFecha.ddMMaaaa(programa.fecha_fin_inscripcion),
      area: programa.nombre_area,
      estado: programa.estado_inscripcion,
      diasRestantes: programa.dias_restantes_inscripcion,
      preinscritos: programa.total_preinscritos,
      matriculados: programa.total_matriculados,
      precioMatricula: programa.precio_matricula,
      precioColegiatura: programa.precio_colegiatura,
      grupo: programa.nombre_grupo
    }))
  } catch (error) {
    console.error('Error al obtener programas ofertados:', error)
    listaCurso.value = []
  } finally {
    cargandoCursos.value = false
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
      <div v-if="cargandoCursos" class="text-center my-8">
        <v-progress-circular indeterminate color="primary"></v-progress-circular>
        <p class="mt-4">Cargando programas disponibles...</p>
      </div>

      <!-- No hay programas -->
      <div v-else-if="listaCurso.length === 0" class="text-center my-8">
        <v-icon size="64" color="grey-lighten-1">mdi-school-outline</v-icon>
        <p class="text-h6 mt-4 text-grey">No hay programas disponibles en este momento</p>
      </div>

      <!-- Lista de programas -->
      <v-row v-else>
        <v-col
          v-for="(programa, index) in listaCurso"
          :key="programa.id"
          cols="12"
          md="4"
          data-aos="fade-up"
          :data-aos-delay="100 * index"
        >
          <v-card class="programa-card elevation-8" height="100%">
            <!-- Imagen del programa -->
            <div class="programa-imagen-container">
              <v-img :src="programa.imagen" height="200" cover class="programa-imagen">
              </v-img>

              <!-- Badge de estado -->
              <v-chip
                :color="obtenerColorEstado(programa.estado)"
                variant="elevated"
                class="estado-chip"
                size="small"
              >
                {{ programa.estado }}
              </v-chip>
            </div>

            <!-- Contenido principal -->
            <v-card-text class="programa-contenido">
              <!-- Título del programa -->
              <h3 class="programa-titulo">
                {{ programa.nombre }}
              </h3>

              <!-- Información del programa -->
              <v-list class="programa-info-list bg-grey-lighten-4 rounded-lg ma-0" density="compact">
                <!-- Inscripción hasta -->
                <v-list-item class="px-4 py-2">
                  <template v-slot:prepend>
                    <v-icon>mdi-calendar</v-icon>
                  </template>
                  <v-list-item-title class="text-body-2 font-weight-medium text-grey-darken-2">
                    Inscripción hasta:
                  </v-list-item-title>
                  <template v-slot:append>
                    <v-chip color="red" variant="elevated" size="small" class="font-weight-bold">
                      {{ programa.fechaInscripcion }}
                    </v-chip>
                  </template>
                </v-list-item>

                <v-divider class="mx-4"></v-divider>

                <!-- Modalidad -->
                <v-list-item class="px-4 py-2">
                  <template v-slot:prepend>
                    <v-icon>mdi-laptop</v-icon>
                  </template>
                  <v-list-item-title class="text-body-2 font-weight-medium text-grey-darken-2">
                    Modalidad:
                  </v-list-item-title>
                  <template v-slot:append>
                    <v-chip color="blue" variant="elevated" size="small" class="font-weight-bold">
                      {{ programa.modalidad }}
                    </v-chip>
                  </template>
                </v-list-item>

                <v-divider class="mx-4"></v-divider>

                <!-- Duración -->
                <v-list-item class="px-4 py-2">
                  <template v-slot:prepend>
                    <v-icon>mdi-clock-outline</v-icon>
                  </template>
                  <v-list-item-title class="text-body-2 font-weight-medium text-grey-darken-2">
                    Duración:
                  </v-list-item-title>
                  <template v-slot:append>
                    <span class="text-body-2 font-weight-bold">{{ programa.duracion }}</span>
                  </template>
                </v-list-item>

                <!-- Días restantes (solo si están abiertas) -->
                <template v-if="programa.estado === 'INSCRIPCIONES ABIERTAS' && programa.diasRestantes > 0">
                  <v-divider class="mx-4"></v-divider>
                  <v-list-item class="px-4 py-2">
                    <template v-slot:prepend>
                      <v-icon color="warning">mdi-timer-sand</v-icon>
                    </template>
                    <v-list-item-title class="text-body-2 font-weight-medium text-grey-darken-2">
                      Días restantes:
                    </v-list-item-title>
                    <template v-slot:append>
                      <v-chip color="warning" variant="elevated" size="small" class="font-weight-bold">
                        {{ programa.diasRestantes }} días
                      </v-chip>
                    </template>
                  </v-list-item>
                </template>
              </v-list>
            </v-card-text>

            <!-- Botones de acción -->
            <v-card-actions class="programa-acciones pa-4">
              <v-row dense>
                <v-col cols="12">
                  <v-btn
                    :color="programa.estado === 'INSCRIPCIONES ABIERTAS' ? 'primary' : 'grey'"
                    :disabled="programa.estado !== 'INSCRIPCIONES ABIERTAS'"
                    variant="elevated"
                    @click="verPrograma(programa)"
                    block
                    size="large"
                    prepend-icon="mdi-account-plus"
                  >
                    {{ programa.estado === 'INSCRIPCIONES ABIERTAS' ? 'Inscribirme' : 'Inscripciones Cerradas' }}
                  </v-btn>
                </v-col>
                <v-col cols="12">
                  <v-btn
                    color="success"
                    variant="outlined"
                    @click="abrirWhatsAppPrograma(programa)"
                    block
                    size="large"
                    prepend-icon="mdi-whatsapp"
                  >
                    Solicitar info
                  </v-btn>
                </v-col>
              </v-row>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </section>
</template>

<style scoped lang="scss">
.programas-section {
  padding: 3rem 0;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);

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

  .programa-card {
    border-radius: 20px !important;
    overflow: hidden;
    transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
    background: white;
    border: 1px solid rgba(0, 0, 0, 0.05);

    &:hover {
      transform: translateY(-12px);
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15) !important;
    }

    .programa-imagen-container {
      position: relative;
      overflow: hidden;

      .programa-imagen {
        transition: transform 0.4s ease;
      }

      .estado-chip {
        position: absolute;
        top: 12px;
        right: 12px;
        z-index: 2;
        font-weight: 600;
        text-transform: uppercase;
      }

      &:hover .programa-imagen {
        transform: scale(1.05);
      }
    }

    .programa-contenido {
      padding: 1.5rem;

      .programa-titulo {
        font-size: 1.4rem;
        font-weight: 700;
        color: #1976D2;
        margin-bottom: 1.5rem;
        line-height: 1.3;
        text-align: center;
        border-bottom: 2px solid #e3f2fd;
        padding-bottom: 1rem;
      }

      .programa-info-list {
        border-left: 4px solid rgb(var(--v-theme-primary)) !important;
        margin-bottom: 0;
      }
    }

    .programa-acciones {
      padding: 0 1.5rem 1.5rem;
    }
  }
}

@media (max-width: 960px) {
  .programas-section {
    .section-header .section-title {
      font-size: 2.2rem !important;
    }

    .programa-card .programa-contenido .programa-titulo {
      font-size: 1.2rem;
    }
  }
}
</style>
