<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos'
import imagenNoDisponible from '@/assets/images/img_default.png'
import logoInstitucion from '@/assets/images/logo.png'
import InicioHeader from '@/views/inicio/InicioHeader.vue';

const route = useRoute()
const router = useRouter()

// Estados
const noticia = ref(null)
const noticiasRecientes = ref([])
const cargandoNoticia = ref(false)
const cargandoRecientes = ref(false)
const error = ref(null)

// Computed
const imagenNoticia = computed(() => {
  if (!noticia.value) return imagenNoDisponible
  return noticia.value.imagen_url || noticia.value.imagen_uri || imagenNoDisponible
})

const contenidoHTML = computed(() => {
  if (!noticia.value?.contenido) return ''
  return noticia.value.contenido
})

const breadcrumbs = computed(() => [
  {
    title: 'Inicio',
    disabled: false,
    to: '/'
  },
  {
    title: 'Noticias',
    disabled: false,
    to: '/#noticias'
  },
  {
    title: noticia.value?.titulo || 'Cargando...',
    disabled: true
  }
])

// Watcher
watch(() => route.params.id, async (newId, oldId) => {
  if (newId !== oldId) {
    window.scrollTo({ top: 0, behavior: 'smooth' })
    await Promise.all([
      cargarNoticia(),
      cargarNoticiasRecientes()
    ])
  }
}, { immediate: false })

// Métodos
const cargarNoticia = async () => {
  cargandoNoticia.value = true
  error.value = null

  try {
    const id = route.params.id
    const response = await api.get(`/api/publico/noticia/${id}`)
    noticia.value = response.data
    actualizarMetaTags()
  } catch (err) {
    console.error('Error al cargar noticia:', err)
    error.value = 'No se pudo cargar la noticia'
  } finally {
    cargandoNoticia.value = false
  }
}

const cargarNoticiasRecientes = async () => {
  cargandoRecientes.value = true

  try {
    const response = await api.get('/api/publico/noticia/carrusel', {
      params: { limit: 4 }
    })

    const idActual = parseInt(route.params.id)
    const recientes = response.data.filter(n => n.id_pub_noticia !== idActual)
    noticiasRecientes.value = recientes.slice(0, 3)
  } catch (err) {
    console.error('Error al cargar noticias recientes:', err)
    noticiasRecientes.value = []
  } finally {
    cargandoRecientes.value = false
  }
}

const actualizarMetaTags = () => {
  if (!noticia.value) return

  document.title = `${noticia.value.titulo} | Instituto Técnico CPEyFC`

  updateMetaTag('og:title', noticia.value.titulo)
  updateMetaTag('og:description', (noticia.value.resumen || '').substring(0, 200))
  updateMetaTag('og:image', imagenNoticia.value)
  updateMetaTag('og:url', window.location.href)
  updateMetaTag('og:type', 'article')

  updateMetaTag('twitter:card', 'summary_large_image')
  updateMetaTag('twitter:title', noticia.value.titulo)
  updateMetaTag('twitter:description', (noticia.value.resumen || '').substring(0, 200))
  updateMetaTag('twitter:image', imagenNoticia.value)
}

const updateMetaTag = (property, content) => {
  let element = document.querySelector(`meta[property="${property}"]`) ||
    document.querySelector(`meta[name="${property}"]`)

  if (!element) {
    element = document.createElement('meta')
    if (property.startsWith('og:')) {
      element.setAttribute('property', property)
    } else {
      element.setAttribute('name', property)
    }
    document.head.appendChild(element)
  }

  element.setAttribute('content', content)
}

const volverNoticias = () => {
  router.push('/#noticias')
}

const verNoticiaReciente = (noticiaReciente) => {
  const slug = generarSlug(noticiaReciente.titulo)
  router.push(`/noticias/${noticiaReciente.id_pub_noticia}/${slug}`)
}

const generarSlug = (titulo) => {
  return titulo
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-+|-+$/g, '')
    .substring(0, 100)
}

onMounted(async () => {
  await Promise.all([
    cargarNoticia(),
    cargarNoticiasRecientes()
  ])
})
</script>

<template>
  <inicio-header></inicio-header>
  <div class="noticia-detalle">
    <!-- Main Content -->
    <v-container class="noticia-container">
      <!-- Loading State con Skeleton -->
      <div v-if="cargandoNoticia">
        <v-row>
          <!-- Skeleton Main Article -->
          <v-col cols="12" lg="8">
            <article class="article-wrapper">
              <!-- Skeleton Portada - ANCHO COMPLETO -->
              <div class="article-portada">
                <v-skeleton-loader
                  type="image"
                  height="450"
                  width="100%"
                  class="portada-imagen"
                ></v-skeleton-loader>
              </div>

              <!-- Skeleton Título - ANCHO COMPLETO -->
              <div class="mt-4 mb-4">
                <v-skeleton-loader type="heading" height="40" width="100%" class="mb-3"></v-skeleton-loader>
                <v-skeleton-loader type="heading" height="40" width="85%"></v-skeleton-loader>
              </div>

              <!-- Skeleton Metadata -->
              <div class="article-meta mb-4">
                <div class="d-flex align-center ga-3 flex-wrap">
                  <v-skeleton-loader type="chip" width="200" height="28"></v-skeleton-loader>
                  <v-skeleton-loader type="chip" width="200" height="28"></v-skeleton-loader>
                </div>
              </div>

              <v-divider class="my-6"></v-divider>

              <!-- Skeleton Contenido - ANCHO COMPLETO -->
              <div class="article-body">
                <v-skeleton-loader type="paragraph" width="100%" class="mb-4"></v-skeleton-loader>
                <v-skeleton-loader type="paragraph" width="100%" class="mb-4"></v-skeleton-loader>
                <v-skeleton-loader type="paragraph" width="95%" class="mb-6"></v-skeleton-loader>

                <v-skeleton-loader type="image" height="350" width="100%" class="my-6"></v-skeleton-loader>

                <v-skeleton-loader type="paragraph" width="100%" class="mb-4"></v-skeleton-loader>
                <v-skeleton-loader type="paragraph" width="100%" class="mb-4"></v-skeleton-loader>
                <v-skeleton-loader type="paragraph" width="90%"></v-skeleton-loader>
              </div>

              <v-divider class="my-8"></v-divider>

              <!-- Skeleton Footer -->
              <div class="article-footer">
                <div class="d-flex align-center justify-space-between flex-wrap ga-4 mb-6">
                  <v-skeleton-loader type="image" width="120" height="50"></v-skeleton-loader>
                  <div class="d-flex ga-2">
                    <v-skeleton-loader type="button" width="40" height="40"></v-skeleton-loader>
                  </div>
                </div>
                <v-skeleton-loader type="button" width="200" height="44"></v-skeleton-loader>
              </div>
            </article>
          </v-col>

          <!-- Skeleton Sidebar -->
          <v-col cols="12" lg="4">
            <aside class="sidebar-content">
              <div class="sidebar-sticky">
                <div class="d-flex align-center mb-6">
                  <v-skeleton-loader type="heading" width="220" height="32"></v-skeleton-loader>
                </div>

                <!-- Skeleton Noticias Recientes -->
                <div class="noticias-recientes-list">
                  <v-card
                    v-for="i in 3"
                    :key="`skeleton-${i}`"
                    class="noticia-reciente-card mb-4"
                    elevation="2"
                  >
                    <v-skeleton-loader type="card-avatar" height="180" width="100%"></v-skeleton-loader>
                  </v-card>
                </div>
              </div>
            </aside>
          </v-col>
        </v-row>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="text-center my-12">
        <v-icon size="64" color="error">mdi-alert-circle</v-icon>
        <p class="text-h6 mt-4">{{ error }}</p>
        <v-btn color="primary" class="mt-4" @click="volverNoticias">
          Volver a Noticias
        </v-btn>
      </div>

      <!-- Content -->
      <div v-else-if="noticia">
        <!-- Breadcrumbs -->
        <v-breadcrumbs :items="breadcrumbs" class="px-0 mb-6">
          <template #divider>
            <v-icon>mdi-chevron-right</v-icon>
          </template>
        </v-breadcrumbs>

        <v-row>
          <!-- Main Article Column -->
          <v-col cols="12" lg="8">
            <article class="article-wrapper">
              <div class="article-portada">
                <v-img
                  :src="imagenNoticia"
                  aspect-ratio="16/9"
                  cover
                  class="portada-imagen"
                >
                  <template #error>
                    <v-img :src="imagenNoDisponible" aspect-ratio="16/9" cover></v-img>
                  </template>
                </v-img>
              </div>

              <!-- Título -->
              <h1 class="article-title mt-4">{{ noticia.titulo }}</h1>

              <!-- Metadata Bar -->
              <div class="article-meta">
                <div class="meta-item">
                  <v-icon size="small" color="primary">mdi-domain</v-icon>
                  <span>{{ noticia.nombre_unidad }}</span>
                </div>

                <v-divider vertical class="mx-3"></v-divider>

                <div class="meta-item">
                  <v-icon size="small" color="primary">mdi-calendar</v-icon>
                  <span>{{ formatoFecha.literario(noticia.fecha_noticia) }}</span>
                </div>
              </div>

              <v-divider class="my-6"></v-divider>

              <!-- Contenido Rich Text -->
              <div class="article-body" v-html="contenidoHTML"></div>

              <!-- Footer del artículo -->
              <v-divider class="my-8"></v-divider>

              <div class="article-footer">
                <div class="d-flex align-center justify-space-between flex-wrap ga-4">
                  <!-- Logo -->
                  <div class="logo-container">
                    <v-img
                      :src="logoInstitucion"
                      max-width="120"
                      class="logo-institucional"
                    ></v-img>
                  </div>

                  <!-- Redes sociales -->
                  <div class="d-flex align-center ga-3">
                    <span class="text-body-2 text-medium-emphasis">Visitar:</span>

                    <v-btn
                      icon
                      size="small"
                      variant="outlined"
                      color="primary"
                      href="https://www.facebook.com/info.cpe.fp.uap/"
                      target="_blank"
                    >
                      <v-icon>mdi-facebook</v-icon>
                      <v-tooltip activator="parent" location="bottom">
                        Visitar Facebook
                      </v-tooltip>
                    </v-btn>
                  </div>
                </div>

                <!-- Botón Volver -->
                <v-btn
                  color="primary"
                  variant="outlined"
                  size="large"
                  class="mt-6"
                  @click="volverNoticias"
                >
                  <v-icon start>mdi-arrow-left</v-icon>
                  Volver a Noticias
                </v-btn>
              </div>
            </article>
          </v-col>

          <!-- Sidebar -->
          <v-col cols="12" lg="4">
            <aside class="sidebar-content">
              <div class="sidebar-sticky">
                <h3 class="sidebar-title">
                  <v-icon color="primary" class="mr-2">mdi-newspaper-variant</v-icon>
                  Noticias Recientes
                </h3>

                <!-- Loading recientes con skeleton -->
                <div v-if="cargandoRecientes" class="noticias-recientes-list">
                  <v-card
                    v-for="i in 3"
                    :key="`skeleton-${i}`"
                    class="noticia-reciente-card mb-4"
                    elevation="2"
                  >
                    <v-skeleton-loader type="image" height="150"></v-skeleton-loader>
                    <v-card-text class="pa-3">
                      <v-skeleton-loader type="heading" class="mb-2"></v-skeleton-loader>
                      <v-skeleton-loader type="text" width="120"></v-skeleton-loader>
                    </v-card-text>
                  </v-card>
                </div>

                <!-- Lista de noticias recientes -->
                <div v-else class="noticias-recientes-list">
                  <v-card
                    v-for="noticiaReciente in noticiasRecientes"
                    :key="noticiaReciente.id_pub_noticia"
                    class="noticia-reciente-card mb-4"
                    elevation="2"
                    hover
                    @click="verNoticiaReciente(noticiaReciente)"
                  >
                    <v-img
                      :src="noticiaReciente.imagen_url || noticiaReciente.imagen_uri || imagenNoDisponible"
                      aspect-ratio="16/9"
                      cover
                      class="noticia-reciente-imagen"
                    >
                      <template #error>
                        <v-img :src="imagenNoDisponible" aspect-ratio="16/9" cover></v-img>
                      </template>
                    </v-img>

                    <v-card-text class="pa-3">
                      <div class="noticia-reciente-titulo">
                        {{ noticiaReciente.titulo }}
                      </div>

                      <div class="d-flex align-center ga-2 mt-2">
                        <v-icon size="x-small" color="primary">mdi-calendar</v-icon>
                        <span class="text-caption text-medium-emphasis">
                          {{ formatoFecha.literario(noticiaReciente.fecha_noticia) }}
                        </span>
                      </div>
                    </v-card-text>
                  </v-card>

                  <!-- Mensaje si no hay recientes -->
                  <div v-if="noticiasRecientes.length === 0" class="text-center text-medium-emphasis py-4">
                    <v-icon size="48" color="grey-lighten-1">mdi-newspaper-variant-outline</v-icon>
                    <p class="mt-2">No hay más noticias recientes</p>
                  </div>
                </div>
              </div>
            </aside>
          </v-col>
        </v-row>
      </div>
    </v-container>
  </div>
</template>


<style scoped lang="scss">
.noticia-detalle {
  background: #ffffff;
  min-height: 100vh;

  // Hero Section
  .hero-section {
    position: relative;
    width: 100%;
    max-height: 500px;
    overflow: hidden;

    .hero-image {
      width: 100%;
    }

    .hero-overlay {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      height: 200px;
      background: linear-gradient(to top, rgba(0, 0, 0, 0.6), transparent);
    }
  }

  // Container más amplio
  .noticia-container {
    max-width: 1400px !important; // 👈 Más ancho que el default de Vuetify
    padding-top: 2rem;
    padding-bottom: 3rem;
  }

  // Article Wrapper - Ocupa el 100% de su columna
  .article-wrapper {
    width: 100%;
    background: white;

    .article-title {
      font-size: 2.5rem;
      font-weight: 700;
      line-height: 1.3;
      color: rgb(var(--v-theme-primary));
      margin-bottom: 1.5rem;
    }

    .article-meta {
      display: flex;
      align-items: center;
      flex-wrap: wrap;
      gap: 8px;

      .meta-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 0.95rem;
        color: #666;
      }
    }

    // Article Body - CLAVE: No colapsa con imágenes pequeñas
    .article-body {
      font-size: 1.1rem;
      line-height: 1.8;
      color: #333;


      :deep(h1),
      :deep(h2),
      :deep(h3) {
        margin-top: 1.5em;
        margin-bottom: 0.7em;
        font-weight: 600;
        color: #222;
      }

      :deep(h1) {
        font-size: 2rem;
      }

      :deep(h2) {
        font-size: 1.6rem;
      }

      :deep(h3) {
        font-size: 1.3rem;
      }

      :deep(ul),
      :deep(ol) {
        margin-bottom: 1.2em;
        padding-left: 2em;

        li {
          margin-bottom: 0.6em;
        }
      }

      :deep(a) {
        color: rgb(var(--v-theme-primary));
        text-decoration: underline;

        &:hover {
          text-decoration: none;
        }
      }

      // Imágenes respetan sus atributos width/height
      :deep(img) {
        max-width: 100%;
        height: auto;
        display: block;
        margin: 1.5em auto;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        transition: box-shadow 0.3s ease;

        &:hover {
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
      }

      :deep(blockquote) {
        border-left: 4px solid rgb(var(--v-theme-primary));
        padding-left: 1.5em;
        margin: 1.5em 0;
        font-style: italic;
        color: #555;
        background: #f9f9f9;
        padding: 1em 1.5em;
        border-radius: 4px;
      }

      :deep(code) {
        background: rgba(var(--v-theme-surface-variant), 1);
        padding: 2px 6px;
        border-radius: 4px;
        font-family: 'Courier New', monospace;
        font-size: 0.9em;
      }

      :deep(pre) {
        background: #2d2d2d;
        color: #f8f8f2;
        padding: 1em;
        border-radius: 8px;
        overflow-x: auto;
        margin: 1em 0;

        code {
          background: none;
          padding: 0;
          color: inherit;
        }
      }
    }

    .article-footer {
      .logo-container {
        .logo-institucional {
          opacity: 0.6;
          transition: opacity 0.3s;

          &:hover {
            opacity: 1;
          }
        }
      }
    }
  }

  // Sidebar Content
  .sidebar-content {
    .sidebar-sticky {
      position: sticky;
      top: 80px;

      .sidebar-title {
        font-size: 1.3rem;
        font-weight: 600;
        margin-bottom: 1.5rem;
        display: flex;
        align-items: center;
      }

      .noticias-recientes-list {
        .noticia-reciente-card {
          cursor: pointer;
          transition: all 0.3s ease;

          &:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15) !important;
          }

          .noticia-reciente-imagen {
            border-radius: 8px 8px 0 0;
          }

          .noticia-reciente-titulo {
            font-size: 0.95rem;
            font-weight: 600;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            color: #333;
          }
        }
      }
    }
  }
}

// Responsive
@media (max-width: 1264px) {
  .noticia-detalle {
    .hero-section {
      max-height: 400px;
    }
  }
}

@media (max-width: 960px) {
  .noticia-detalle {
    .hero-section {
      max-height: 300px;
    }

    .article-wrapper {
      .article-title {
        font-size: 1.8rem;
      }

      .article-body {
        font-size: 1rem;
        line-height: 1.7;
      }
    }

    .sidebar-content {
      margin-top: 3rem;

      .sidebar-sticky {
        position: static;
      }
    }
  }
}

@media (max-width: 600px) {
  .noticia-detalle {
    .hero-section {
      max-height: 250px;
    }

    .article-wrapper {
      .article-title {
        font-size: 1.5rem;
      }

      .article-meta {
        flex-direction: column;
        align-items: flex-start;

        .v-divider {
          display: none;
        }
      }
    }
  }
}
</style>
