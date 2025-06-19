<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const route = useRoute()
const { login } = useAuth()

// Estados del formulario
const formulario = ref({
  nombreUsuario: '',
  password: ''
})

const mostrarPassword = ref(false)
const cargando = ref(false)
const error = ref('')

// Validaciones
const reglasUsuario = computed(() => [
  v => !!v || 'El nombre de usuario es requerido',
  v => (v && v.length >= 3) || 'Mínimo 3 caracteres'
])

const reglasPassword = computed(() => [
  v => !!v || 'La contraseña es requerida',
  v => (v && v.length >= 4) || 'Mínimo 4 caracteres'
])

const formularioValido = computed(() => {
  return formulario.value.nombreUsuario.length >= 3 &&
    formulario.value.password.length >= 4
})

// Iniciar sesión
const iniciarSesion = async () => {
  if (!formularioValido.value) return

  cargando.value = true
  error.value = ''

  try {
    await login({
      nombreUsuario: formulario.value.nombreUsuario,
      password: formulario.value.password
    })

    // Redirigir a la página solicitada o al dashboard
    const redirect = route.query.redirect || '/dashboard'
    router.push(redirect)

  } catch (err) {
    error.value = 'Credenciales incorrectas. Por favor verifique sus datos.'
    console.error('Error de login:', err)
  } finally {
    cargando.value = false
  }
}

// Demo credentials (remover en producción)
const usarDemo = () => {
  formulario.value.nombreUsuario = 'admin'
  formulario.value.password = 'admin123'
}
</script>

<template>
  <div class="login-container">
    <div class="login-card-container">
      <!-- Logo y header institucional -->
      <div class="login-header">
        <div class="logo-container">
          <v-avatar size="80" color="primary">
            <v-icon size="48" color="white">mdi-school</v-icon>
          </v-avatar>
        </div>

        <h1 class="institution-name">CPEYFC</h1>
        <p class="institution-subtitle">
          Centro Profesional de Enseñanza y Formación Continua
        </p>
        <p class="login-subtitle">
          Sistema de Gestión Académica
        </p>
      </div>

      <!-- Formulario de login -->
      <v-card class="login-card" elevation="8">
        <v-card-title class="text-center pb-4">
          <h2 class="login-title">Iniciar Sesión</h2>
        </v-card-title>

        <v-card-text>
          <v-form @submit.prevent="iniciarSesion">
            <!-- Campo usuario -->
            <v-text-field
              v-model="formulario.nombreUsuario"
              :rules="reglasUsuario"
              label="Nombre de Usuario"
              prepend-inner-icon="mdi-account"
              variant="outlined"
              class="mb-3"
              :disabled="cargando"
              autofocus
              autocomplete="username"
            ></v-text-field>

            <!-- Campo contraseña -->
            <v-text-field
              v-model="formulario.password"
              :rules="reglasPassword"
              :type="mostrarPassword ? 'text' : 'password'"
              label="Contraseña"
              prepend-inner-icon="mdi-lock"
              :append-inner-icon="mostrarPassword ? 'mdi-eye' : 'mdi-eye-off'"
              variant="outlined"
              class="mb-4"
              :disabled="cargando"
              autocomplete="current-password"
              @click:append-inner="mostrarPassword = !mostrarPassword"
            ></v-text-field>

            <!-- Mensaje de error -->
            <v-alert
              v-if="error"
              type="error"
              variant="tonal"
              class="mb-4"
              closable
              @click:close="error = ''"
            >
              {{ error }}
            </v-alert>

            <!-- Botón de login -->
            <v-btn
              :loading="cargando"
              :disabled="!formularioValido"
              type="submit"
              color="primary"
              size="large"
              variant="flat"
              block
              class="mb-3"
            >
              <v-icon start>mdi-login</v-icon>
              Iniciar Sesión
            </v-btn>

            <!-- Enlaces adicionales -->
            <div class="text-center">
              <v-btn
                variant="text"
                color="primary"
                size="small"
                @click="$router.push('/recuperar-contrasena')"
              >
                ¿Olvidaste tu contraseña?
              </v-btn>
            </div>
          </v-form>
        </v-card-text>

        <!-- Demo helper (remover en producción) -->
        <v-card-actions class="justify-center">
          <v-btn
            variant="outlined"
            color="info"
            size="small"
            @click="usarDemo"
          >
            <v-icon start>mdi-test-tube</v-icon>
            Demo
          </v-btn>
        </v-card-actions>
      </v-card>

      <!-- Footer -->
      <div class="login-footer">
        <p class="text-center text-medium-emphasis">
          © 2025 CPEYFC - Universidad Amazónica de Pando
        </p>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.login-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  position: relative;

  // Patrón de fondo sutil
  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-image:
      radial-gradient(circle at 25px 25px, rgba(255,255,255,.2) 2px, transparent 0),
      radial-gradient(circle at 75px 75px, rgba(255,255,255,.1) 2px, transparent 0);
    background-size: 100px 100px;
    opacity: 0.5;
  }
}

.login-card-container {
  width: 100%;
  max-width: 420px;
  position: relative;
  z-index: 1;
}

.login-header {
  text-align: center;
  margin-bottom: 2rem;
  color: white;

  .logo-container {
    margin-bottom: 1rem;

    .v-avatar {
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    }
  }

  .institution-name {
    font-size: 2.5rem;
    font-weight: 700;
    margin-bottom: 0.5rem;
    text-shadow: 0 2px 4px rgba(0,0,0,0.3);
  }

  .institution-subtitle {
    font-size: 1rem;
    opacity: 0.9;
    margin-bottom: 0.5rem;
    font-weight: 300;
  }

  .login-subtitle {
    font-size: 0.9rem;
    opacity: 0.8;
    font-weight: 300;
  }
}

.login-card {
  backdrop-filter: blur(10px);
  background: rgba(255, 255, 255, 0.95) !important;
  border-radius: 16px !important;
  border: 1px solid rgba(255, 255, 255, 0.2);

  .login-title {
    color: #1976D2;
    font-weight: 600;
    font-size: 1.5rem;
  }
}

.login-footer {
  margin-top: 2rem;
  color: rgba(255, 255, 255, 0.8);
  font-size: 0.875rem;
}

// Responsive
@media (max-width: 600px) {
  .login-container {
    padding: 0.5rem;
  }

  .login-header {
    .institution-name {
      font-size: 2rem;
    }

    .institution-subtitle {
      font-size: 0.9rem;
    }
  }
}

// Animaciones
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.login-card-container {
  animation: fadeInUp 0.6s ease-out;
}
</style>
