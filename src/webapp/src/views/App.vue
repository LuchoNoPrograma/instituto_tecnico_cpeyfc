<script setup>
import { useAuth } from '@/composables/useAuth'
const { initializeAuth } = useAuth();

initializeAuth()
</script>
<template>
  <v-app>
    <v-main>
      <router-view />
    </v-main>
  </v-app>
</template>
