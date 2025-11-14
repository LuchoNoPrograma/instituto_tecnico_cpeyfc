<script setup lang="ts">
import { ref, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import logo from '@/assets/images/UAP-DIGITAL-BLANCO.png';
import { useDisplay } from 'vuetify';

const { mdAndUp } = useDisplay();
const drawer = ref(false);
const router = useRouter();
const route = useRoute();

// 🎯 MENÚ UNIFICADO
const menuItems = ref([
  {
    titulo: 'Iniciar Sesión',
    ruta: '/login',
    icono: 'mdi-login',
    esHash: false
  },
  {
    titulo: 'Programas',
    ruta: '/#programas',
    hash: 'programas',
    icono: 'mdi-school',
    esHash: true
  },
  {
    titulo: 'Noticias',
    ruta: '/#noticias',
    hash: 'noticias',
    icono: 'mdi-newspaper',
    esHash: true
  }
]);

const irInicio = () => {
  router.push('/');
  drawer.value = false;
};

const navegarA = (item: any) => {
  drawer.value = false;

  if (item.esHash) {
    if (route.path === '/') {
      scrollToSection(item.hash);
    } else {
      router.push('/').then(() => {
        setTimeout(() => scrollToSection(item.hash), 100);
      });
    }
  } else {
    router.push(item.ruta);
  }
};

// ✨ Smooth scroll SOLO en esta función, no global
const scrollToSection = (hash: string) => {
  const element = document.getElementById(hash);
  if (element) {
    const headerOffset = 100;
    const elementPosition = element.getBoundingClientRect().top;
    const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

    window.scrollTo({
      top: offsetPosition,
      behavior: 'smooth'
    });
  }
};

// Watch para URLs con hash
watch(() => route.hash, (newHash) => {
  if (newHash) {
    const hash = newHash.replace('#', '');
    setTimeout(() => scrollToSection(hash), 100);
  }
});
</script>

<template>
  <!-- App Bar con clipped-left -->
  <v-app-bar
    elevation="2"
    height="80"
    color="primary"
    app
    clipped-left
  >
    <v-container class="d-flex align-center fill-height">
      <!-- Logo -->
      <v-img
        :src="logo"
        max-height="50"
        max-width="200"
        contain
        @click="irInicio"
        class="cursor-pointer mr-4"
      ></v-img>

      <v-spacer></v-spacer>

      <!-- Menú Desktop -->
      <div v-if="mdAndUp" class="d-flex align-center ga-2">
        <v-btn
          v-for="item in menuItems"
          :key="item.ruta"
          variant="text"
          class="text-white font-weight-bold text-uppercase"
          @click="navegarA(item)"
        >
          {{ item.titulo }}
        </v-btn>
      </div>

      <!-- Botón Hamburguesa Mobile -->
      <v-btn
        v-else
        icon
        variant="text"
        @click.stop="drawer = !drawer"
      >
        <v-icon color="white">mdi-menu</v-icon>
      </v-btn>
    </v-container>
  </v-app-bar>

  <!-- Drawer Mobile - Con clipped para quedar DEBAJO del header -->
  <v-navigation-drawer
    v-model="drawer"
    temporary
    location="top"
    app
    clipped
  >
    <v-list nav density="comfortable">
      <!-- Inicio -->
      <v-list-item
        @click="irInicio"
        prepend-icon="mdi-home"
        title="Inicio"
      ></v-list-item>

      <v-divider class="my-2"></v-divider>

      <!-- Items dinámicos -->
      <v-list-item
        v-for="item in menuItems"
        :key="item.ruta"
        @click="navegarA(item)"
        :prepend-icon="item.icono"
        :title="item.titulo"
      ></v-list-item>
    </v-list>
  </v-navigation-drawer>
</template>

<style lang="scss" scoped>
.cursor-pointer {
  cursor: pointer;
}
</style>
