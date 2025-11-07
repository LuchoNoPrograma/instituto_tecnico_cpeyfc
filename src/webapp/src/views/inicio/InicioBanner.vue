<script lang="ts" setup>
import escuelaTecnica from '@/assets/images/escuela_tecnica.png';
import uapBarra from '@/assets/images/uap_barra.jpg';
import fotoBaner1 from '@/assets/images/banner/imagen1.webp';
import fotoBaner2 from '@/assets/images/banner/imagen2.webp';
import fotoBaner3 from '@/assets/images/banner/imagen3.webp';
import fotoBaner4 from '@/assets/images/banner/imagen4.webp';

const scrollHastaSobreNosotros = () => {
  const element = document.querySelector('#sobre-nosotros');
  if (element) element.scrollIntoView({ behavior: 'smooth' });
};
</script>

<template>
  <div class="inicio-banner">
    <div class="inicio-banner__contenedor text-center">
      <h1 class="inicio-banner__contenedor-texto mb-5 text-white" data-aos="fade-up" data-aos-duration="500">
        CENTRO DE PROYECTOS ESPECIALES Y FORMACIÓN PERMANENTE
      </h1>
      <p class="mb-2 text-h6 font-weight-medium text-white" data-aos="fade-up" data-aos-duration="800">
        Innovación para el desarrollo continuo.
      </p>
      <div>
        <v-btn
          class="inicio-banner__contenedor-btn"
          color="white"
          icon
          size="x-large"
          variant="tonal"
          @click="scrollHastaSobreNosotros()"
        >
          <v-icon icon="mdi-chevron-down"></v-icon>
        </v-btn>
      </div>
    </div>
    <v-carousel :cycle="true" :interval="10000" :show-arrows="false" class="inicio-banner__carrusel" height="80vh">
      <v-carousel-item :src="fotoBaner1" class="darken-image" cover></v-carousel-item>
      <v-carousel-item :src="fotoBaner2" class="darken-image" cover></v-carousel-item>
      <v-carousel-item :src="fotoBaner3" class="darken-image" cover></v-carousel-item>
      <v-carousel-item :src="fotoBaner4" class="darken-image" cover></v-carousel-item>
      <v-carousel-item :src="escuelaTecnica" class="darken-image" cover></v-carousel-item>
      <v-carousel-item :src="uapBarra" class="darken-image" cover></v-carousel-item>
    </v-carousel>
  </div>
</template>

<style lang="scss" scoped>
.inicio-banner {
  position: relative;
  width: 100%;
}

.inicio-banner__contenedor {
  left: 50%;
  text-align: center !important;
  transform: translate(-50%, 30%);
  position: absolute;
  z-index: 2;
  padding: 0 1rem;

  @media (min-width: 1440px) {
    transform: translate(-50%, 90%);
  }

  &-texto {
    font-size: 3.75rem;
    line-height: 1.3;
    font-weight: 600;

    @media (max-width: 1264px) {
      font-size: 2rem;
    }

    @media (max-width: 800px) {
      font-size: 2rem;
    }

    @media (max-width: 768px) {
      font-size: 1.825rem;
    }
  }

  &-btn {
    font-size: 2.5rem;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    animation: floatAnimation 2.25s ease infinite;

    @media (max-width: 1264px) {
      font-size: 1.25rem;
    }

    @media (max-width: 800px) {
      font-size: 1.25rem;
    }

    @media (max-width: 768px) {
      font-size: 1.25rem;
    }
  }
}

@keyframes floatAnimation {
  0% {
    transform: translateY(0);
  }

  40% {
    transform: translateY(15px);
  }

  60% {
    transform: translateY(-5px);
  }

  80% {
    transform: translateY(5px);
  }

  100% {
    transform: translateY(0);
  }
}

.darken-image {
  filter: brightness(0.4);
  opacity: 0.6;
}

.inicio-banner__carrusel {
  :deep(.v-window-x-transition-enter-active),
  :deep(.v-window-x-transition-leave-active),
  :deep(.v-window-x-reverse-transition-enter-active),
  :deep(.v-window-x-reverse-transition-leave-active),
  :deep(.v-window-y-transition-enter-active),
  :deep(.v-window-y-transition-leave-active),
  :deep(.v-window-y-reverse-transition-enter-active),
  :deep(.v-window-y-reverse-transition-leave-active) {
    transition: opacity 1.3s cubic-bezier(0.2, 0.8, 0.5, 1), transform 1.3s cubic-bezier(0.25, 0.8, 0.5, 1) !important;
  }

  :deep(.v-window-x-transition-enter),
  :deep(.v-window-x-transition-leave-to),
  :deep(.v-window-x-reverse-transition-enter),
  :deep(.v-window-x-reverse-transition-leave-to),
  :deep(.v-window-y-transition-enter),
  :deep(.v-window-y-transition-leave-to),
  :deep(.v-window-y-reverse-transition-enter),
  :deep(.v-window-y-reverse-transition-leave-to) {
    opacity: 0;
  }

  :deep(.v-window-x-transition-enter-to),
  :deep(.v-window-x-transition-leave),
  :deep(.v-window-x-reverse-transition-enter-to),
  :deep(.v-window-x-reverse-transition-leave),
  :deep(.v-window-y-transition-enter-to),
  :deep(.v-window-y-transition-leave),
  :deep(.v-window-y-reverse-transition-enter-to),
  :deep(.v-window-y-reverse-transition-leave) {
    opacity: 1;
  }
}
</style>
