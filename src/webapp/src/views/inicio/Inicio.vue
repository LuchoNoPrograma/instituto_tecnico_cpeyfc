<script lang="ts" setup>
import { onMounted } from 'vue';
import AOS from 'aos';
import 'aos/dist/aos.css';
import InicioBanner from '@/views/inicio/InicioBanner.vue';
import InicioHeader from '@/views/inicio/InicioHeader.vue';
import InicioInfo from '@/views/inicio/InicioInfo.vue';
import InicioNoticia from '@/views/inicio/InicioNoticia.vue';
import InicioProgramas from '@/views/inicio/InicioProgramas.vue';
import InicioFooter from '@/views/inicio/InicioFooter.vue';

onMounted(() => {
  AOS.init({
    duration: 800,
    once: true,
    offset: 100
  });
});

// Datos del botón de WhatsApp
const phone = '59174771457';
const message = 'ESCUELA TÉCNICA: Hola, ¿podrían enviarme más información sobre los cursos disponibles y sus planes de estudios? Gracias.';
const buttonText = '¿Cómo puedo ayudarte?';
const whatsappLink = `https://web.whatsapp.com/send?phone=${phone}&text=${encodeURIComponent(message)}`;
</script>

<template>
  <v-layout class="bg-containerBg">
    <v-main class="ma-0">
      <inicio-header></inicio-header>
      <inicio-banner></inicio-banner>

      <div id="sobre-nosotros"></div>

      <inicio-info></inicio-info>

      <inicio-programas></inicio-programas>

      <inicio-noticia></inicio-noticia>

      <inicio-footer></inicio-footer>
      <ChatbotIA></ChatbotIA>

      <!-- Botón flotante de WhatsApp -->
<!--      <a :href="whatsappLink" class="qlwapp-toggle" role="button" tabindex="0" target="_blank">
        <v-icon icon="mdi-whatsapp" size="large" color="white"></v-icon>
        <span class="qlwapp-text">{{ buttonText }}</span>
      </a>-->
    </v-main>
  </v-layout>
</template>

<style scoped lang="scss">
.qlwapp-toggle {
  position: fixed;
  z-index: 9999;
  bottom: 20px;
  right: 20px;
  background-color: #25d366;
  color: white;
  border-radius: 50px;
  padding: 12px 20px;
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 10px;
  box-shadow: 0 4px 12px rgba(37, 211, 102, 0.4);
  font-family: Arial, sans-serif;
  transition: all 0.3s ease;

  &:hover {
    background-color: #1ebe57;
    box-shadow: 0 6px 16px rgba(37, 211, 102, 0.6);
    transform: translateY(-2px);
  }

  .qlwapp-text {
    font-weight: 600;
    font-size: 14px;

    @media (max-width: 768px) {
      display: none;
    }
  }

  @media (max-width: 768px) {
    padding: 14px;
    border-radius: 50%;
    width: 56px;
    height: 56px;
    justify-content: center;
  }
}
</style>
