<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// Estados reactivos
const estadisticas = ref({
  estudiantes: 1250,
  programas: 15,
  docentes: 85,
  egresados: 2340
})

const programasDestacados = ref([
  {
    id: 1,
    nombre: 'Técnico en Sistemas',
    descripcion: 'Formación integral en desarrollo de software y administración de sistemas.',
    duracion: '2 años',
    modalidad: 'Presencial',
    imagen: 'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=400',
    color: 'primary'
  },
  {
    id: 2,
    nombre: 'Técnico en Enfermería',
    descripcion: 'Preparación profesional para atención de salud y cuidados especializados.',
    duracion: '2.5 años',
    modalidad: 'Presencial',
    imagen: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
    color: 'success'
  },
  {
    id: 3,
    nombre: 'Técnico en Administración',
    descripcion: 'Desarrollo de competencias empresariales y gestión organizacional.',
    duracion: '2 años',
    modalidad: 'Semipresencial',
    imagen: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    color: 'info'
  }
])

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

const irInscripcion = () => {
  router.push('/inscripcion')
}

const verPrograma = (programa) => {
  router.push(`/programas/${programa.id}`)
}

const verNoticia = (noticia) => {
  router.push(`/noticias/${noticia.id}`)
}

onMounted(() => {
  // Animaciones de contadores
  animarContadores()
})

const animarContadores = () => {
  // Animación simple de contadores (puedes usar una librería como CountUp.js)
  console.log('Animando contadores...')
}
</script>

<template>
  <div class="inicio-publico">
    <!-- Hero Section -->
    <section class="hero-section">
      <div class="hero-background">
        <div class="hero-overlay"></div>
        <div class="hero-content">
          <v-container>
            <v-row align="center" justify="center">
              <v-col cols="12" md="8" class="text-center">
                <h1 class="hero-title">
                  Forma tu Futuro Profesional
                </h1>
                <p class="hero-subtitle">
                  En el Centro Profesional de Enseñanza y Formación Continua preparamos
                  técnicos especializados para el mundo laboral con educación de calidad.
                </p>

                <div class="hero-actions">
                  <v-btn
                    color="primary"
                    size="x-large"
                    variant="flat"
                    prepend-icon="mdi-school"
                    @click="irInscripcion"
                    class="me-4 mb-4"
                  >
                    Inscríbete Ahora
                  </v-btn>

                  <v-btn
                    color="white"
                    size="x-large"
                    variant="outlined"
                    prepend-icon="mdi-play"
                    class="mb-4"
                  >
                    Ver Video
                  </v-btn>
                </div>
              </v-col>
            </v-row>
          </v-container>
        </div>
      </div>
    </section>

    <!-- Estadísticas -->
    <section class="estadisticas-section">
      <v-container>
        <v-row>
          <v-col
            v-for="(stat, key) in estadisticas"
            :key="key"
            cols="6"
            md="3"
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
        <div class="section-header">
          <h2 class="section-title">Nuestros Programas</h2>
          <p class="section-subtitle">
            Descubre las carreras técnicas que te prepararán para el éxito profesional
          </p>
        </div>

        <v-row>
          <v-col
            v-for="programa in programasDestacados"
            :key="programa.id"
            cols="12"
            md="4"
          >
            <v-card
              class="programa-card"
              :color="programa.color"
              dark
              @click="verPrograma(programa)"
            >
              <v-img
                :src="programa.imagen"
                height="200"
                cover
              >
                <div class="programa-overlay">
                  <v-chip
                    :color="programa.color"
                    variant="elevated"
                    size="small"
                  >
                    {{ programa.modalidad }}
                  </v-chip>
                </div>
              </v-img>

              <v-card-title>{{ programa.nombre }}</v-card-title>

              <v-card-text>
                <p class="mb-3">{{ programa.descripcion }}</p>

                <div class="programa-meta">
                  <v-chip
                    variant="outlined"
                    size="small"
                    prepend-icon="mdi-clock"
                    class="me-2"
                  >
                    {{ programa.duracion }}
                  </v-chip>
                </div>
              </v-card-text>

              <v-card-actions>
                <v-btn variant="text" @click="verPrograma(programa)">
                  Más Información
                  <v-icon end>mdi-arrow-right</v-icon>
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
        <div class="section-header">
          <h2 class="section-title">Lo Que Dicen Nuestros Egresados</h2>
          <p class="section-subtitle">
            Historias de éxito que nos inspiran a seguir formando profesionales
          </p>
        </div>

        <v-row>
          <v-col
            v-for="testimonio in testimonios"
            :key="testimonio.id"
            cols="12"
            md="4"
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
        <div class="section-header">
          <h2 class="section-title">Últimas Noticias</h2>
          <p class="section-subtitle">
            Mantente al día con las novedades de nuestra institución
          </p>
        </div>

        <v-row>
          <v-col
            v-for="noticia in noticias"
            :key="noticia.id"
            cols="12"
            md="4"
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
    <section class="cta-section">
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
                color="primary"
                size="large"
                variant="flat"
                prepend-icon="mdi-account-plus"
                @click="irInscripcion"
                class="me-4"
              >
                Inscríbete Ahora
              </v-btn>

              <v-btn
                color="primary"
                size="large"
                variant="outlined"
                prepend-icon="mdi-phone"
              >
                Contáctanos
              </v-btn>
            </div>
          </v-col>
        </v-row>
      </v-container>
    </section>
  </div>
</template>

<style lang="scss" scoped>
.inicio-publico {
  // Hero Section
  .hero-section {
    position: relative;
    min-height: 100vh;
    display: flex;
    align-items: center;

    .hero-background {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(135deg, #1976D2 0%, #1565C0 50%, #0D47A1 100%);

      &::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grid" width="10" height="10" patternUnits="userSpaceOnUse"><path d="M 10 0 L 0 0 0 10" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="0.5"/></pattern></defs><rect width="100" height="100" fill="url(%23grid)"/></svg>');
      }
    }

    .hero-overlay {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.3);
    }

    .hero-content {
      position: relative;
      z-index: 2;
      color: white;

      .hero-title {
        font-size: 3.5rem;
        font-weight: 700;
        margin-bottom: 1.5rem;
        text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        line-height: 1.2;
      }

      .hero-subtitle {
        font-size: 1.3rem;
        margin-bottom: 2.5rem;
        opacity: 0.95;
        max-width: 600px;
        margin-left: auto;
        margin-right: auto;
      }
    }
  }

  // Estadísticas
  .estadisticas-section {
    background: white;
    padding: 3rem 0;

    .estadistica-item {
      text-align: center;

      .estadistica-numero {
        font-size: 3rem;
        font-weight: 900;
        color: #1976D2;
        line-height: 1;
        margin-bottom: 0.5rem;
      }

      .estadistica-label {
        font-size: 1.1rem;
        color: #666;
        font-weight: 500;
        text-transform: capitalize;
      }
    }
  }

  // Secciones generales
  .programas-section,
  .testimonios-section,
  .noticias-section {
    padding: 4rem 0;

    &:nth-child(even) {
      background: #FAFAFA;
    }
  }

  .section-header {
    text-align: center;
    margin-bottom: 3rem;

    .section-title {
      font-size: 2.5rem;
      font-weight: 700;
      color: #1976D2;
      margin-bottom: 1rem;
    }

    .section-subtitle {
      font-size: 1.1rem;
      color: #666;
      max-width: 600px;
      margin: 0 auto;
    }
  }

  // Programas
  .programa-card {
    height: 100%;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    cursor: pointer;

    &:hover {
      transform: translateY(-8px);
      box-shadow: 0 12px 24px rgba(0,0,0,0.15) !important;
    }

    .programa-overlay {
      position: absolute;
      top: 1rem;
      right: 1rem;
    }

    .programa-meta {
      display: flex;
      gap: 0.5rem;
      flex-wrap: wrap;
    }
  }

  // Testimonios
  .testimonio-card {
    height: 100%;
    transition: transform 0.2s ease;

    &:hover {
      transform: translateY(-4px);
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
      }

      .testimonio-autor {
        display: flex;
        align-items: center;

        .autor-nombre {
          font-weight: 600;
          color: #1976D2;
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
    transition: transform 0.2s ease;
    cursor: pointer;

    &:hover {
      transform: translateY(-4px);
    }

    .noticia-resumen {
      margin-bottom: 1rem;
      color: #444;
    }

    .noticia-fecha {
      font-size: 0.9rem;
      color: #999;
    }
  }

  // Call to Action
  .cta-section {
    background: linear-gradient(135deg, #1976D2 0%, #1565C0 100%);
    color: white;
    padding: 4rem 0;

    .cta-title {
      font-size: 2.5rem;
      font-weight: 700;
      margin-bottom: 1rem;
    }

    .cta-subtitle {
      font-size: 1.2rem;
      margin-bottom: 2rem;
      opacity: 0.9;
    }
  }
}

// Responsive
@media (max-width: 960px) {
  .inicio-publico {
    .hero-content .hero-title {
      font-size: 2.5rem;
    }

    .estadistica-item .estadistica-numero {
      font-size: 2.5rem;
    }

    .section-title {
      font-size: 2rem !important;
    }
  }
}

@media (max-width: 600px) {
  .inicio-publico {
    .hero-content {
      .hero-title {
        font-size: 2rem;
      }

      .hero-subtitle {
        font-size: 1.1rem;
      }

      .hero-actions .v-btn {
        width: 100%;
        margin: 0.5rem 0;
      }
    }

    .cta-actions .v-btn {
      width: 100%;
      margin: 0.5rem 0;
    }
  }
}

// Animaciones
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

.hero-content {
  animation: fadeInUp 1s ease-out;
}
</style>
