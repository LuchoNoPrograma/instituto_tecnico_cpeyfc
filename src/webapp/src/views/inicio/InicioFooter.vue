<script setup>
import cpeyfp_logo from '@/assets/images/cpeyfp_logo.png';
</script>

<template>
  <v-footer class="bg-dark text-white py-8">
    <v-container>
      <v-row>
        <v-col cols="12" md="3">
          <v-img :src="cpeyfp_logo" alt="CPEyFP Logo" max-width="200" contain class="mb-4" />
        </v-col>

        <v-col cols="12" md="3">
          <h5 class="text-h6 mb-4 font-weight-bold">Dirección</h5>
          <div class="footer-info">
            <p class="text-body-2 mb-1">
              <v-icon icon="mdi-map-marker" size="small" class="mr-2"></v-icon>
              Av. Las Palmas
            </p>
            <p class="text-body-2">
              <v-icon icon="mdi-school" size="small" class="mr-2"></v-icon>
              Campus Universitario
            </p>
            <p class="text-body-2 mt-2">
              Cobija, Pando - Bolivia
            </p>
          </div>
        </v-col>

        <v-col cols="12" md="3">
          <h5 class="text-h6 mb-4 font-weight-bold">Contactos</h5>
          <div class="footer-info">
            <p class="text-body-2 mb-1">
              <v-icon icon="mdi-phone" size="small" class="mr-2"></v-icon>
              +591 74771457
            </p>
            <p class="text-body-2 mb-1">
              <v-icon icon="mdi-email" size="small" class="mr-2"></v-icon>
              cpeyfc@uap.edu.bo
            </p>
            <p class="text-body-2">
              <v-icon icon="mdi-web" size="small" class="mr-2"></v-icon>
              www.uap.edu.bo
            </p>
          </div>
        </v-col>

        <v-col cols="12" md="3">
          <h5 class="text-h6 mb-4 font-weight-bold">Centro de Proyectos Especiales</h5>
          <p class="text-body-2">y Formación Permanente</p>
          <div class="mt-4">
            <v-btn icon size="small" variant="text" href="https://facebook.com" target="_blank" class="mr-2">
              <v-icon icon="mdi-facebook"></v-icon>
            </v-btn>
            <v-btn icon size="small" variant="text" href="https://twitter.com" target="_blank" class="mr-2">
              <v-icon icon="mdi-twitter"></v-icon>
            </v-btn>
            <v-btn icon size="small" variant="text" href="https://instagram.com" target="_blank">
              <v-icon icon="mdi-instagram"></v-icon>
            </v-btn>
          </div>
        </v-col>
      </v-row>

      <v-divider class="my-6 border-opacity-25"></v-divider>

      <v-row>
        <v-col cols="12" class="text-center">
          <p class="text-body-2 text-grey-lighten-1">
            © {{ new Date().getFullYear() }} Universidad Amazónica de Pando - CPEyFP. Todos los derechos reservados.
          </p>
        </v-col>
      </v-row>
    </v-container>
  </v-footer>
</template>

<style lang="scss" scoped>
.bg-dark {
  background: #1f1f1f;
}

.footer-info {
  p {
    color: rgba(255, 255, 255, 0.8);
  }
}

.v-btn {
  color: rgba(255, 255, 255, 0.8);

  &:hover {
    color: white;
  }
}
</style>
