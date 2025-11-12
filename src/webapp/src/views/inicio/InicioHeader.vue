<script setup lang="ts">
import { ref } from 'vue';
import logo from '@/assets/images/UAP-DIGITAL-BLANCO.png';
import { useDisplay } from 'vuetify';

const { mdAndUp } = useDisplay();
const drawer = ref(false);

const router = useRouter()
const irInicio = () => {
  router.push('/')
}
</script>

<template>
  <v-app-bar elevation="0" flat height="80" class="border-bottom position-fixed" color="primary" border="0">
    <v-img :src="logo" max-height="50" @click="irInicio" style="cursor: pointer"></v-img>
    <v-container class="d-flex align-center fill-height">

      <v-spacer></v-spacer>

      <div class="d-flex align-center ga-2">
        <template v-if="mdAndUp">
          <v-btn class="btn-header" variant="text" to="/login">Iniciar sesion</v-btn>
          <v-btn class="btn-header" variant="text" to="/#noticias">Noticias</v-btn>
<!--          <v-btn class="btn-header" variant="text" to="/programa-especial-de-titulacion">
            Programa especial de titulación
          </v-btn>-->
          <v-btn class="btn-header" variant="text" to="/escuela-tecnica">Escuela técnica</v-btn>
<!--          <v-btn class="btn-header" variant="text" to="/admision-y-permanencia-estudiantil">
            Admisión y permanencia estudiantil
          </v-btn>-->
        </template>
        <template v-else>
          <v-btn icon rounded="sm" variant="text" size="small" @click.stop="drawer = !drawer">
            <v-icon icon="mdi-menu"></v-icon>
          </v-btn>
        </template>
      </div>
    </v-container>
  </v-app-bar>

  <v-navigation-drawer v-model="drawer" temporary location="top" v-if="!mdAndUp">
    <v-list color="primary">
      <v-list-item to="/">
        <template v-slot:prepend>
          <v-icon icon="mdi-home"></v-icon>
        </template>
        <v-list-item-title class="ml-3">Inicio</v-list-item-title>
      </v-list-item>
      <v-list-item to="/#noticias">
        <template v-slot:prepend>
          <v-icon icon="mdi-newspaper"></v-icon>
        </template>
        <v-list-item-title class="ml-3">Noticias</v-list-item-title>
      </v-list-item>
      <v-list-item to="/programa-especial-de-titulacion">
        <template v-slot:prepend>
          <v-icon icon="mdi-school"></v-icon>
        </template>
        <v-list-item-title class="ml-3">Programa especial de titulación</v-list-item-title>
      </v-list-item>
      <v-list-item to="/escuela-tecnica">
        <template v-slot:prepend>
          <v-icon icon="mdi-account-hard-hat"></v-icon>
        </template>
        <v-list-item-title class="ml-3">Escuela técnica</v-list-item-title>
      </v-list-item>
      <v-list-item to="/admision-y-permanencia-estudiantil">
        <template v-slot:prepend>
          <v-icon icon="mdi-account-group"></v-icon>
        </template>
        <v-list-item-title class="ml-3">Admisión y permanencia estudiantil</v-list-item-title>
      </v-list-item>
    </v-list>
  </v-navigation-drawer>
</template>

<style lang="scss" scoped>

.btn-header {
  transition: all 0.45s ease;
  text-transform: uppercase !important;
  font-weight: 600 !important;
  color: white !important;

  &:hover {
    background-color: rgba(white, 0.1);
    transform: translateY(-3px);
  }
}
</style>
