<script setup>
import {ref, onMounted, onUnmounted} from 'vue'
import {useRouter} from 'vue-router'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos.js'

const router = useRouter()

const abrirWhatsAppPrograma = (programa) => {
  const numeroWhatsApp = '+591' // Cambiar por el número real
  const mensaje = `Hola, me interesa información sobre el programa: ${programa.nombre}`
  const url = `https://wa.me/${numeroWhatsApp}?text=${encodeURIComponent(mensaje)}`
  window.open(url, '_blank')
}

const estadisticas = ref({
  estudiantes: 1250,
  programas: 15,
  docentes: 85,
  egresados: 2340
})

const carruselSlides = ref([
  {
    id: 1,
    titulo: 'ESCUELA TECNICA UAP',
    subtitulo: 'Innovación para el desarrollo continuo',
    descripcion: 'Formamos técnicos especializados para el mundo laboral con educación de calidad y tecnología de vanguardia.',
    imagen: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=1200',
    color: 'rgba(211, 47, 47, 0.8)' // Rojo institucional
  },
  {
    id: 2,
    titulo: 'ESCUELA TECNICA UAP',
    subtitulo: 'Excelencia educativa y formación integral',
    descripcion: 'Desarrollamos competencias técnicas y humanas para profesionales del futuro.',
    imagen: 'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=1200',
    color: 'rgba(25, 118, 210, 0.8)' // Azul institucional
  },
  {
    id: 3,
    titulo: 'ESCUELA TECNICA UAP',
    subtitulo: 'Preparando líderes técnicos',
    descripcion: 'Tu futuro profesional comienza aquí, con la mejor formación técnica especializada.',
    imagen: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=1200',
    color: 'rgba(211, 47, 47, 0.8)' // Rojo institucional
  }
])

// Programas desde API
const programasDestacados = ref([])
const cargandoProgramas = ref(false)

const noticias = ref([
  {
    id: 1,
    titulo: 'Inicio de Inscripciones 2025',
    resumen: 'Ya están abiertas las inscripciones para todos nuestros programas técnicos.',
    fecha: '15 Enero 2025',
    imagen: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=400'
  },
  {
    id: 2,
    titulo: 'Convenio con Empresas Locales',
    resumen: 'Nuevas oportunidades de práctica profesional para nuestros estudiantes.',
    fecha: '10 Enero 2025',
    imagen: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=400'
  },
  {
    id: 3,
    titulo: 'Graduación Promoción 2024',
    resumen: 'Celebramos el éxito de nuestros nuevos técnicos profesionales.',
    fecha: '20 Diciembre 2024',
    imagen: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400'
  }
])

const testimonios = ref([
  {
    id: 1,
    nombre: 'María González',
    programa: 'Técnico en Sistemas',
    testimonio: 'Gracias a CPEYFC pude desarrollar las habilidades que necesitaba para trabajar en el área de tecnología.',
    avatar: 'https://images.unsplash.com/photo-1494790108755-2616c9976b17?w=150',
    año: '2023'
  },
  {
    id: 2,
    nombre: 'Carlos Mendoza',
    programa: 'Técnico en Administración',
    testimonio: 'La formación práctica que recibí me permitió abrir mi propia empresa de consultoría.',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    año: '2022'
  },
  {
    id: 3,
    nombre: 'Ana Rodríguez',
    programa: 'Técnico en Enfermería',
    testimonio: 'Hoy trabajo en el hospital regional ayudando a salvar vidas. Todo comenzó en CPEYFC.',
    avatar: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=150',
    año: '2024'
  }
])

// Obtener programas de la API
const obtenerProgramasOfertados = async () => {
  cargandoProgramas.value = true
  try {
    const response = await api.get('/api/publico/programas-ofertados')

    // Mapear datos de la vista a la estructura del componente
    programasDestacados.value = response.data.map(programa => ({
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
    // Fallback a programas de ejemplo si falla la API
    programasDestacados.value = []
  } finally {
    cargandoProgramas.value = false
  }
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

const obtenerColorEstado = (estado) => {
  const colores = {
    'INSCRIPCIONES ABIERTAS': 'success',
    'PROXIMAMENTE': 'info',
    'INSCRIPCIONES CERRADAS': 'error'
  }
  return colores[estado] || 'info'
}

const verPrograma = (programa) => {
  router.push(`/inscripciones?programa=${programa.id}`)
}

const verNoticia = (noticia) => {
  router.push(`/noticias/${noticia.id}`)
}

const scrollToProgramas = () => {
  document.querySelector('.programas-section').scrollIntoView({
    behavior: 'smooth'
  })
}

const whatsappPosition = ref(0)

const abrirWhatsApp = () => {
  const numeroWhatsApp = '+591'
  const mensaje = 'Hola, me interesa información sobre la Escuela Técnica UAP'
  const url = `https://wa.me/${numeroWhatsApp}?text=${encodeURIComponent(mensaje)}`
  window.open(url, '_blank')
}

const handleScroll = () => {
  const scrollTop = document.documentElement.scrollTop
  whatsappPosition.value = scrollTop * 0.00
}

onMounted(() => {
  animarContadores()
  obtenerProgramasOfertados()

  if (window.AOS) {
    window.AOS.init({
      duration: 1000,
      once: true
    })
  }

  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

const animarContadores = () => {
  console.log('Animando contadores...')
}
</script>

<template>
  <div class="inicio-publico ma-0 pa-0">
    <!-- Hero Carousel Section -->
    <section class="hero-carousel-section">
      <v-carousel
        height="100vh"
        :show-arrows="false"
        hide-delimiter-background
        hide-delimiters
        cycle
        interval="5000"
        class="hero-carousel ma-0"
      >
        <v-carousel-item
          v-for="slide in carruselSlides"
          :key="slide.id"
          class="carousel-slide"
        >
          <div class="slide-background">
            <v-img
              :src="slide.imagen"
              height="100vh"
              cover
              class="slide-image"
            >
              <div class="slide-overlay" :style="{ background: slide.color }"></div>
            </v-img>
          </div>

          <div class="slide-content">
            <v-container>
              <v-row align="center" justify="center" class="fill-height">
                <v-col cols="12" md="10" class="text-center">
                  <!-- Título principal -->
                  <h1 class="hero-title" data-aos="fade-up">
                    {{ slide.titulo }}
                  </h1>

                  <!-- Subtítulo -->
                  <h2 class="hero-subtitle" data-aos="fade-up" data-aos-delay="200">
                    {{ slide.subtitulo }}
                  </h2>

                  <!-- Descripción -->
                  <p class="hero-description" data-aos="fade-up" data-aos-delay="400">
                    {{ slide.descripcion }}
                  </p>

                  <!-- Botones de acción -->
                  <div class="hero-actions" data-aos="fade-up" data-aos-delay="600">
                    <v-btn
                      color="white"
                      size="x-large"
                      variant="flat"
                      prepend-icon="mdi-school"
                      @click="scrollToProgramas"
                      class="me-4 mb-4 action-btn"
                    >
                      Ver Programas
                    </v-btn>

                    <v-btn
                      color="transparent"
                      size="x-large"
                      variant="outlined"
                      prepend-icon="mdi-play"
                      class="mb-4 action-btn-outline"
                      to="/login"
                    >
                      Iniciar sesion
                    </v-btn>
                  </div>
                </v-col>
              </v-row>
            </v-container>
          </div>
        </v-carousel-item>
      </v-carousel>

      <!-- Botón flotante chevron -->
      <v-btn
        fab
        color="white"
        size="large"
        class="scroll-down-btn"
        @click="scrollToProgramas"
        elevation="4"
      >
        <v-icon size="24" color="primary">mdi-chevron-down</v-icon>
      </v-btn>

      <!-- Indicadores personalizados -->
      <div class="carousel-indicators">
        <div class="indicators-container">
          <v-container>
            <div class="d-flex justify-center">
              <div class="custom-indicators">
                <span
                  v-for="(slide, index) in carruselSlides"
                  :key="index"
                  class="indicator-dot"
                  :class="{ active: index === 0 }"
                ></span>
              </div>
            </div>
          </v-container>
        </div>
      </div>
    </section>

    <!-- Estadísticas -->
    <section class="estadisticas-section" data-aos="fade-up">
      <v-container>
        <v-row>
          <v-col
            v-for="(stat, key) in estadisticas"
            :key="key"
            cols="6"
            md="3"
            data-aos="zoom-in"
            :data-aos-delay="100 * Object.keys(estadisticas).indexOf(key)"
          >
            <div class="estadistica-item">
              <div class="estadistica-numero">
                {{ stat.toLocaleString() }}+
              </div>
              <div class="estadistica-label">
                {{ key.charAt(0).toUpperCase() + key.slice(1) }}
              </div>
            </div>
          </v-col>
        </v-row>
      </v-container>
    </section>

    <!-- Programas Destacados -->
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
          <v-progress-circular indeterminate color="primary"></v-progress-circular>
          <p class="mt-4">Cargando programas disponibles...</p>
        </div>

        <!-- No hay programas -->
        <div v-else-if="programasDestacados.length === 0" class="text-center my-8">
          <v-icon size="64" color="grey-lighten-1">mdi-school-outline</v-icon>
          <p class="text-h6 mt-4 text-grey">No hay programas disponibles en este momento</p>
        </div>

        <!-- Lista de programas -->
        <v-row v-else>
          <v-col
            v-for="(programa, index) in programasDestacados"
            :key="programa.id"
            cols="12"
            md="4"
            data-aos="fade-up"
            :data-aos-delay="200 * index"
          >
            <v-card
              class="programa-card-nueva elevation-8"
              height="100%"
            >
              <!-- Imagen del programa arriba -->
              <div class="programa-imagen-container">
                <v-img
                  :src="programa.imagen"
                  height="200"
                  cover
                  class="programa-imagen-nueva"
                >
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
                <h3 class="programa-titulo-nuevo">
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
                  <v-list-item v-if="programa.estado === 'INSCRIPCIONES ABIERTAS' && programa.diasRestantes > 0" class="px-4 py-2">
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

                  <v-list-item class="px-4 py-2">
                    <v-btn
                      :color="programa.estado === 'INSCRIPCIONES ABIERTAS' ? 'primary' : 'grey'"
                      :disabled="programa.estado !== 'INSCRIPCIONES ABIERTAS'"
                      variant="elevated"
                      @click="verPrograma(programa)"
                      block
                      size="large"
                      class="inscripcion-btn"
                      prepend-icon="mdi-account-plus"
                    >
                      {{ programa.estado === 'INSCRIPCIONES ABIERTAS' ? 'Inscribirme' : 'Inscripciones Cerradas' }}
                    </v-btn>
                  </v-list-item>
                </v-list>
              </v-card-text>

              <!-- Botones de acción -->
              <v-card-actions class="programa-acciones">
                <!-- Botón secundario de información -->
                <v-btn
                  color="success"
                  variant="outlined"
                  @click="abrirWhatsAppPrograma(programa)"
                  block
                  size="large"
                  class="info-btn mt-2"
                  prepend-icon="mdi-whatsapp"
                >
                  Solicitar info
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </section>

    <!-- Testimonios -->
    <section class="testimonios-section">
      <v-container>
        <div class="section-header" data-aos="fade-up">
          <h2 class="section-title">Lo Que Dicen Nuestros Egresados</h2>
          <p class="section-subtitle">
            Historias de éxito que nos inspiran a seguir formando profesionales
          </p>
        </div>

        <v-row>
          <v-col
            v-for="(testimonio, index) in testimonios"
            :key="testimonio.id"
            cols="12"
            md="4"
            data-aos="fade-up"
            :data-aos-delay="200 * index"
          >
            <v-card class="testimonio-card" elevation="2">
              <v-card-text>
                <div class="testimonio-content">
                  <v-icon color="primary" size="32" class="quote-icon">
                    mdi-format-quote-open
                  </v-icon>

                  <p class="testimonio-texto">
                    "{{ testimonio.testimonio }}"
                  </p>

                  <div class="testimonio-autor">
                    <v-avatar size="48" class="me-3">
                      <v-img :src="testimonio.avatar"></v-img>
                    </v-avatar>

                    <div>
                      <div class="autor-nombre">{{ testimonio.nombre }}</div>
                      <div class="autor-programa">{{ testimonio.programa }}</div>
                      <div class="autor-año">Promoción {{ testimonio.año }}</div>
                    </div>
                  </div>
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </section>

    <!-- Noticias -->
    <section class="noticias-section">
      <v-container>
        <div class="section-header" data-aos="fade-up">
          <h2 class="section-title">Últimas Noticias</h2>
          <p class="section-subtitle">
            Mantente al día con las novedades de nuestra institución
          </p>
        </div>

        <v-row>
          <v-col
            v-for="(noticia, index) in noticias"
            :key="noticia.id"
            cols="12"
            md="4"
            data-aos="fade-up"
            :data-aos-delay="200 * index"
          >
            <v-card
              class="noticia-card"
              @click="verNoticia(noticia)"
            >
              <v-img
                :src="noticia.imagen"
                height="200"
                cover
              ></v-img>

              <v-card-title>{{ noticia.titulo }}</v-card-title>

              <v-card-text>
                <p class="noticia-resumen">{{ noticia.resumen }}</p>
                <div class="noticia-fecha">{{ noticia.fecha }}</div>
              </v-card-text>

              <v-card-actions>
                <v-btn
                  variant="text"
                  color="primary"
                  @click="verNoticia(noticia)"
                >
                  Leer Más
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </section>

    <!-- Call to Action -->
    <section class="cta-section" data-aos="fade-up">
      <v-container>
        <v-row justify="center">
          <v-col cols="12" md="8" class="text-center">
            <h2 class="cta-title">¿Listo para Cambiar tu Futuro?</h2>
            <p class="cta-subtitle">
              Únete a miles de estudiantes que han transformado sus vidas
              con nuestros programas técnicos especializados.
            </p>

            <div class="cta-actions">
              <v-btn
                color="white"
                size="large"
                variant="flat"
                prepend-icon="mdi-account-plus"
                @click="scrollToProgramas"
                class="me-4 cta-btn"
              >
                Inscríbete Ahora
              </v-btn>

              <v-btn
                color="white"
                size="large"
                variant="outlined"
                prepend-icon="mdi-phone"
                class="cta-btn-outline"
              >
                Contáctanos
              </v-btn>
            </div>
          </v-col>
        </v-row>
      </v-container>
    </section>

    <!-- Botón Flotante WhatsApp que sigue el scroll -->
    <v-btn
      fab
      color="#25D366"
      size="large"
      class="whatsapp-btn"
      :style="{ transform: `translateY(${whatsappPosition}px)` }"
      @click="abrirWhatsApp"
      elevation="8"
    >
      <v-icon size="32" color="white">mdi-whatsapp</v-icon>
    </v-btn>
  </div>
</template>

<style lang="scss" scoped>
.inicio-publico {
  margin: 0 !important;
  padding: 0 !important;
  width: 100% !important;

  // Hero Carousel Section
  .hero-carousel-section {
    position: relative;
    height: 100vh;
    overflow: hidden;

    .hero-carousel {
      height: 100vh !important;
      margin: 0 !important;
      width: 100% !important;

      .carousel-slide {
        position: relative;
        height: 100vh;

        .slide-background {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          z-index: 1;

          .slide-image {
            width: 100%;
            height: 100vh;
          }

          .slide-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 2;
          }
        }

        .slide-content {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          z-index: 3;
          color: white;
          display: flex;
          align-items: center;

          .hero-title {
            font-size: 4rem;
            font-weight: 900;
            margin-bottom: 1rem;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.5);
            line-height: 1.1;
            letter-spacing: 2px;
          }

          .hero-subtitle {
            font-size: 1.8rem;
            font-weight: 400;
            margin-bottom: 1rem;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
            opacity: 0.95;
          }

          .hero-description {
            font-size: 1.2rem;
            margin-bottom: 2.5rem;
            opacity: 0.9;
            max-width: 700px;
            margin-left: auto;
            margin-right: auto;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
          }

          .hero-actions {
            .action-btn {
              background: white !important;
              color: #D32F2F !important;
              font-weight: 600;
              text-transform: uppercase;
              letter-spacing: 1px;
              box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
              transition: all 0.3s ease;

              &:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 16px rgba(0, 0, 0, 0.4);
              }
            }

            .action-btn-outline {
              border: 2px solid white !important;
              color: white !important;
              font-weight: 600;
              text-transform: uppercase;
              letter-spacing: 1px;
              transition: all 0.3s ease;

              &:hover {
                background: white !important;
                color: #D32F2F !important;
                transform: translateY(-2px);
              }
            }
          }
        }
      }
    }

    .scroll-down-btn {
      position: absolute;
      bottom: 6rem;
      left: 50%;
      transform: translateX(-50%);
      z-index: 5;
      animation: bounce 2s infinite;
    }

    .carousel-indicators {
      position: absolute;
      bottom: 2rem;
      left: 0;
      right: 0;
      z-index: 4;

      .indicators-container {
        .custom-indicators {
          display: flex;
          gap: 12px;
          justify-content: center;

          .indicator-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.5);
            transition: all 0.3s ease;
            cursor: pointer;

            &.active {
              background: white;
              transform: scale(1.2);
            }

            &:hover {
              background: rgba(255, 255, 255, 0.8);
            }
          }
        }
      }
    }
  }

  // Estadísticas
  .estadisticas-section {
    background: white;
    padding: 4rem 0;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);

    .estadistica-item {
      text-align: center;
      transition: transform 0.3s ease;

      &:hover {
        transform: translateY(-5px);
      }

      .estadistica-numero {
        font-size: 3.5rem;
        font-weight: 900;
        color: #D32F2F;
        line-height: 1;
        margin-bottom: 0.5rem;
        text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }

      .estadistica-label {
        font-size: 1.1rem;
        color: #666;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
    }
  }

  // Secciones generales
  .programas-section,
  .testimonios-section,
  .noticias-section {
    padding: 2rem 0;

    &:nth-child(even) {
      background: #FAFAFA;
    }
  }

  .section-header {
    text-align: center;
    margin-bottom: 4rem;

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

  .programas-section {
    padding: 3rem 0;
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);

    .programa-card-nueva {
      border-radius: 20px !important;
      overflow: hidden;
      transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
      background: white;
      border: 1px solid rgba(0, 0, 0, 0.05);
      box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1) !important;

      &:hover {
        transform: translateY(-12px);
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15) !important;
      }

      .programa-imagen-container {
        position: relative;
        overflow: hidden;

        .programa-imagen-nueva {
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

        &:hover .programa-imagen-nueva {
          transform: scale(1.05);
        }
      }

      .programa-contenido {
        padding: 1.5rem;

        .programa-titulo-nuevo {
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
          margin-bottom: 1.5rem;
        }
      }

      .programa-acciones {
        padding: 0 1.5rem 1.5rem;
        flex-direction: column;

        .inscripcion-btn {
          font-weight: 700;
          text-transform: uppercase;
          letter-spacing: 1px;
          background: linear-gradient(45deg, #1976D2, #1565C0) !important;
          color: white !important;
          box-shadow: 0 4px 15px rgba(25, 118, 210, 0.3) !important;
          transition: all 0.3s ease;

          &:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(25, 118, 210, 0.4) !important;
          }

          &:disabled {
            background: #ccc !important;
            color: #666 !important;
            box-shadow: none !important;
          }

          .v-icon {
            margin-right: 8px;
          }
        }

        .info-btn {
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.5px;
          border: 2px solid #25D366 !important;
          color: #25D366 !important;
          transition: all 0.3s ease;

          &:hover {
            background: #25D366 !important;
            color: white !important;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(37, 211, 102, 0.3);
          }

          .v-icon {
            margin-right: 8px;
          }
        }
      }
    }
  }

  // Testimonios
  .testimonio-card {
    height: 100%;
    transition: all 0.3s ease;
    border-radius: 16px !important;
    border: 2px solid transparent;

    &:hover {
      transform: translateY(-8px);
      border-color: #D32F2F;
      box-shadow: 0 12px 24px rgba(211, 47, 47, 0.15) !important;
    }

    .testimonio-content {
      .quote-icon {
        margin-bottom: 1rem;
      }

      .testimonio-texto {
        font-style: italic;
        margin-bottom: 1.5rem;
        color: #444;
        line-height: 1.6;
        font-size: 1.1rem;
      }

      .testimonio-autor {
        display: flex;
        align-items: center;

        .autor-nombre {
          font-weight: 600;
          color: #D32F2F;
          font-size: 1.1rem;
        }

        .autor-programa {
          font-size: 0.9rem;
          color: #666;
        }

        .autor-año {
          font-size: 0.8rem;
          color: #999;
        }
      }
    }
  }

  // Noticias
  .noticia-card {
    height: 100%;
    transition: all 0.3s ease;
    cursor: pointer;
    border-radius: 16px !important;

    &:hover {
      transform: translateY(-8px);
      box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15) !important;
    }

    .noticia-resumen {
      margin-bottom: 1rem;
      color: #444;
      line-height: 1.6;
    }

    .noticia-fecha {
      font-size: 0.9rem;
      color: #999;
      font-weight: 500;
    }
  }

  // Call to Action
  .cta-section {
    background: linear-gradient(135deg, #D32F2F 0%, #B71C1C 100%);
    color: white;
    padding: 5rem 0;
    position: relative;
    overflow: hidden;

    &::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="dots" width="20" height="20" patternUnits="userSpaceOnUse"><circle cx="10" cy="10" r="2" fill="rgba(255,255,255,0.1)"/></pattern></defs><rect width="100" height="100" fill="url(%23dots)"/></svg>');
    }

    .cta-title {
      font-size: 3rem;
      font-weight: 700;
      margin-bottom: 1rem;
      position: relative;
      z-index: 2;
    }

    .cta-subtitle {
      font-size: 1.3rem;
      margin-bottom: 2.5rem;
      opacity: 0.9;
      position: relative;
      z-index: 2;
    }

    .cta-actions {
      position: relative;
      z-index: 2;

      .cta-btn {
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 1px;
        transition: all 0.3s ease;

        &:hover {
          transform: translateY(-2px);
          box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
        }
      }

      .cta-btn-outline {
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 1px;
        transition: all 0.3s ease;

        &:hover {
          background: white !important;
          color: #D32F2F !important;
          transform: translateY(-2px);
        }
      }
    }
  }

  // Botón WhatsApp que sigue el scroll
  .whatsapp-btn {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    z-index: 1000;
    animation: pulse 2s infinite;
    transition: transform 0.1s ease-out;

    &:hover {
      transform: scale(1.1) !important;
      animation-play-state: paused;
    }
  }
}

// Animaciones
@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateX(-50%) translateY(0);
  }
  40% {
    transform: translateX(-50%) translateY(-10px);
  }
  60% {
    transform: translateX(-50%) translateY(-5px);
  }
}

@keyframes pulse {
  0% {
    box-shadow: 0 0 0 0 rgba(37, 211, 102, 0.7);
  }
  70% {
    box-shadow: 0 0 0 10px rgba(37, 211, 102, 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(37, 211, 102, 0);
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

// Responsive
@media (max-width: 960px) {
  .inicio-publico {
    .hero-carousel-section .hero-carousel .carousel-slide .slide-content {
      .hero-title {
        font-size: 2.5rem;
      }

      .hero-subtitle {
        font-size: 1.4rem;
      }

      .hero-description {
        font-size: 1.1rem;
      }
    }

    .estadistica-item .estadistica-numero {
      font-size: 2.5rem;
    }

    .section-title {
      font-size: 2.2rem !important;
    }
  }
}

@media (max-width: 600px) {
  .inicio-publico {
    .hero-carousel-section .hero-carousel .carousel-slide .slide-content {
      .hero-title {
        font-size: 2rem;
        letter-spacing: 1px;
      }

      .hero-subtitle {
        font-size: 1.2rem;
      }

      .hero-description {
        font-size: 1rem;
      }

      .hero-actions {
        .v-btn {
          width: 100%;
          margin: 0.5rem 0;
        }
      }
    }

    .cta-actions .v-btn {
      width: 100%;
      margin: 0.5rem 0;
    }

    .whatsapp-btn {
      margin-bottom: 1rem !important;
      margin-right: 1rem !important;
    }
  }
}

@media (max-width: 960px) {
  .programa-card-nueva {
    .programa-contenido {
      .programa-titulo-nuevo {
        font-size: 1.2rem;
      }

      .programa-info .info-item {
        flex-direction: column;
        align-items: flex-start;
        gap: 0.5rem;

        .info-valor {
          align-self: flex-end;
        }
      }
    }
  }
}
</style>
