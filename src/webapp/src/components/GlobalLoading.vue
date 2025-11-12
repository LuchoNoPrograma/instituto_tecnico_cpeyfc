<script setup>
import { computed } from 'vue'
import { useLoadingStore } from '@/stores/loading'

// Props
const props = defineProps({
  scoped: {
    type: Boolean,
    default: false,
    description: 'Si es true, el loading se limita al contenedor padre (position: absolute). Si es false, cubre toda la pantalla (position: fixed)'
  }
})

const loadingStore = useLoadingStore()
const isLoading = computed(() => loadingStore.isLoading)
const message = computed(() => loadingStore.message)
</script>

<template>
  <Transition name="fade">
    <div
      v-if="isLoading"
      class="loading-overlay"
      :class="{ 'loading-overlay--scoped': scoped }"
    >
      <div class="loading-container">
        <div class="spinner-container">
          <v-progress-circular
            indeterminate
            color="primary"
            size="64"
            width="6"
          ></v-progress-circular>
        </div>
        <div v-if="message" class="loading-message">
          {{ message }}
        </div>
      </div>
    </div>
  </Transition>
</template>

<style lang="scss" scoped>
// Animaciones fade in/fade out
.fade-enter-active {
  transition: opacity 0.3s ease-in;
}

.fade-leave-active {
  transition: opacity 0.3s ease-out;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.fade-enter-to,
.fade-leave-from {
  opacity: 1;
}

// Estilos del overlay
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;

  // Modo scoped: se limita al contenedor padre
  &--scoped {
    position: absolute;
    z-index: 100;
  }
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
  padding: 2rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  min-width: 200px;
}

.spinner-container {
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
}

.loading-message {
  color: rgb(var(--v-theme-primary));
  font-size: 1rem;
  font-weight: 500;
  text-align: center;
  max-width: 300px;
  animation: fadeInText 0.5s ease-in;
}

@keyframes fadeInText {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

// Responsive
@media (max-width: 600px) {
  .loading-container {
    padding: 1.5rem;
    min-width: 150px;
  }

  .loading-message {
    font-size: 0.875rem;
  }
}
</style>
