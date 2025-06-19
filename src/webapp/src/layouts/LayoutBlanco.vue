<script setup>
// Layout minimalista para login, 404, etc.
</script>

<template>
  <v-app>
    <v-main class="d-flex align-center justify-center min-height-screen">
      <slot />
    </v-main>
  </v-app>
</template>

<style lang="scss" scoped>
.min-height-screen {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}
</style>
