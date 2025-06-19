<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import LayoutBlanco from '@/layouts/LayoutBlanco.vue'
import LayoutCompleto from '@/layouts/LayoutCompleto.vue'

const route = useRoute()
const { initializeAuth } = useAuth()

// Inicializar autenticación
initializeAuth()

const layoutActual = computed(() => {
  // 1. Si está especificado manualmente, úsalo
  if (route.meta.layout) {
    return route.meta.layout === 'LayoutCompleto' ? LayoutCompleto : LayoutBlanco
  }

  if (route.meta.requiresAuth) {
    return LayoutCompleto
  }

  return LayoutBlanco
})
</script>

<template>
  <component :is="layoutActual">
    <router-view />
  </component>
</template>

<style lang="scss">
// Estilos globales
body {
  font-family: 'Roboto', sans-serif;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
