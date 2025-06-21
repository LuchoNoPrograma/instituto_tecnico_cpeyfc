<script setup>
  import { computed, ref } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { useAuth } from '@/composables/useAuth'

  const router = useRouter()
  const route = useRoute()
  const { login } = useAuth()

  // Estados del formulario
  const formulario = ref({
    nombreUsuario: '',
    password: '',
  })

  const mostrarPassword = ref(false)
  const cargando = ref(false)
  const error = ref('')

  // Validaciones
  const reglasUsuario = computed(() => [
    v => !!v || 'El nombre de usuario es requerido',
    v => (v && v.length >= 3) || 'Mínimo 3 caracteres',
  ])

  const reglasPassword = computed(() => [
    v => !!v || 'La contraseña es requerida',
    v => (v && v.length >= 4) || 'Mínimo 4 caracteres',
  ])

  const formularioValido = computed(() => {
    return formulario.value.nombreUsuario.length >= 3
      && formulario.value.password.length >= 4
  })

  // Iniciar sesión
  const iniciarSesion = async () => {
    if (!formularioValido.value) return

    cargando.value = true
    error.value = ''

    try {
      await login({
        nombreUsuario: formulario.value.nombreUsuario,
        password: formulario.value.password,
      })

      // Redirigir a la página solicitada o al dashboard
      const redirect = route.query.redirect || '/dashboard'
      router.push(redirect)
    } catch (error_) {
      error.value = 'Credenciales incorrectas. Por favor verifique sus datos.'
      console.error('Error de login:', error_)
    } finally {
      cargando.value = false
    }
  }

  // Demo credentials (remover en producción)
  const usarDemo = () => {
    formulario.value.nombreUsuario = 'sistema'
    formulario.value.password = 'sistema'
  }
</script>

<template>
  <v-app class="login-app">
    <v-main class="login-main">
      <v-container class="login-container pa-0" fluid>
        <v-row class="fill-height" no-gutters>
          <!-- Panel izquierdo - Información institucional -->
          <v-col
            class="institutional-panel d-flex align-center justify-center"
            cols="12"
            md="7"
          >
            <div class="institutional-content text-center">
              <!-- Logo Universidad -->
              <div class="university-logo mb-6">
                <v-avatar class="elevation-8" color="white" size="120">
                  <v-icon color="#1976D2" size="80">mdi-school-outline</v-icon>
                </v-avatar>
              </div>

              <!-- Información institucional -->
              <div class="institution-info">
                <h1 class="university-title mb-2">
                  Universidad Amazónica de Pando
                </h1>
                <h2 class="center-title mb-4">
                  CPEYFC
                </h2>
                <p class="center-subtitle mb-6">
                  Centro de Proyectos Especiales y Formación Continua
                </p>

                <div class="location-info mb-6">
                  <v-chip
                    color="white"
                    prepend-icon="mdi-map-marker"
                    size="large"
                    variant="outlined"
                  >
                    Cobija, Pando - Bolivia
                  </v-chip>
                </div>

                <!-- Características del sistema -->
                <div class="system-features">
                  <v-row class="justify-center">
                    <v-col cols="auto">
                      <v-card class="feature-card pa-3" color="white" variant="outlined">
                        <v-icon class="mb-2" color="#1976D2" size="24">mdi-account-school</v-icon>
                        <div class="feature-text">Gestión Académica Integral</div>
                      </v-card>
                    </v-col>
                    <v-col cols="auto">
                      <v-card class="feature-card pa-3" color="white" variant="outlined">
                        <v-icon class="mb-2" color="#1976D2" size="24">mdi-certificate</v-icon>
                        <div class="feature-text">Certificación Digital</div>
                      </v-card>
                    </v-col>
                    <v-col cols="auto">
                      <v-card class="feature-card pa-3" color="white" variant="outlined">
                        <v-icon class="mb-2" color="#1976D2" size="24">mdi-security</v-icon>
                        <div class="feature-text">Plataforma Segura</div>
                      </v-card>
                    </v-col>
                  </v-row>
                </div>
              </div>
            </div>
          </v-col>

          <!-- Panel derecho - Formulario de login -->
          <v-col
            class="login-panel d-flex align-center justify-center"
            cols="12"
            md="5"
          >
            <div class="login-form-container">
              <!-- Header del formulario -->
              <div class="login-form-header text-center mb-8">
                <v-icon class="mb-3" color="#1976D2" size="48">mdi-login-variant</v-icon>
                <h2 class="login-form-title mb-2">Acceso al Sistema</h2>
                <p class="login-form-subtitle">
                  Ingrese sus credenciales para continuar
                </p>
              </div>

              <!-- Formulario -->
              <v-card class="login-form-card pa-8" elevation="0" variant="outlined">
                <v-form @submit.prevent="iniciarSesion">
                  <!-- Campo usuario -->
                  <v-text-field
                    v-model="formulario.nombreUsuario"
                    autocomplete="username"
                    autofocus
                    class="mb-4"
                    color="#1976D2"
                    :disabled="cargando"
                    hide-details="auto"
                    label="Nombre de Usuario"
                    prepend-inner-icon="mdi-account-circle"
                    :rules="reglasUsuario"
                    variant="outlined"
                  />

                  <!-- Campo contraseña -->
                  <v-text-field
                    v-model="formulario.password"
                    :append-inner-icon="mostrarPassword ? 'mdi-eye' : 'mdi-eye-off'"
                    autocomplete="current-password"
                    class="mb-6"
                    color="#1976D2"
                    :disabled="cargando"
                    hide-details="auto"
                    label="Contraseña"
                    prepend-inner-icon="mdi-lock"
                    :rules="reglasPassword"
                    :type="mostrarPassword ? 'text' : 'password'"
                    variant="outlined"
                    @click:append-inner="mostrarPassword = !mostrarPassword"
                  />

                  <!-- Mensaje de error -->
                  <v-alert
                    v-if="error"
                    class="mb-6"
                    closable
                    type="error"
                    variant="tonal"
                    @click:close="error = ''"
                  >
                    {{ error }}
                  </v-alert>

                  <!-- Botón de login -->
                  <v-btn
                    block
                    class="mb-4 login-btn"
                    color="#1976D2"
                    :disabled="!formularioValido"
                    :loading="cargando"
                    size="large"
                    type="submit"
                    variant="flat"
                  >
                    <v-icon start>mdi-login</v-icon>
                    Iniciar Sesión
                  </v-btn>

                  <!-- Enlaces adicionales -->
                  <div class="text-center">
                    <v-btn
                      color="#1976D2"
                      size="small"
                      variant="text"
                      @click="$router.push('/recuperar-contrasena')"
                    >
                      <v-icon size="16" start>mdi-help-circle</v-icon>
                      ¿Olvidaste tu contraseña?
                    </v-btn>
                  </div>
                </v-form>

                <!-- Demo helper (remover en producción) -->
                <v-divider class="my-6" />
                <div class="text-center">
                  <v-btn
                    color="#1976D2"
                    size="small"
                    variant="outlined"
                    @click="usarDemo"
                  >
                    <v-icon size="16" start>mdi-test-tube</v-icon>
                    Credenciales Demo
                  </v-btn>
                </div>
              </v-card>

              <!-- Footer -->
              <div class="login-footer text-center mt-6">
                <p class="text-caption text-medium-emphasis">
                  © 2025 Universidad Amazónica de Pando - CPEYFC
                </p>
                <p class="text-caption text-medium-emphasis">
                  Sistema de Gestión Académica v1.0
                </p>
              </div>
            </div>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<style lang="scss" scoped>
.login-app {
  width: 100% !important;
  overflow: hidden;
}

.login-main {
  height: 100vh !important;
}

.login-container {
  height: 100vh !important;
  min-height: 100vh;
}

// Panel institucional (izquierdo)
.institutional-panel {
  background: linear-gradient(135deg, #1976D2 0%, #1565C0 50%, #0D47A1 100%);
  position: relative;
  overflow: hidden;

  // Patrón de fondo
  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-image:
      radial-gradient(circle at 30% 20%, rgba(255,255,255,0.1) 2px, transparent 0),
      radial-gradient(circle at 70% 80%, rgba(255,255,255,0.08) 2px, transparent 0);
    background-size: 60px 60px;
    opacity: 0.6;
  }

  .institutional-content {
    position: relative;
    z-index: 1;
    color: white;
    max-width: 500px;
    padding: 2rem;
  }

  .university-logo {
    .v-avatar {
      border: 4px solid rgba(255,255,255,0.2);
    }
  }

  .university-title {
    font-size: 2.5rem;
    font-weight: 300;
    line-height: 1.2;
    text-shadow: 0 2px 4px rgba(0,0,0,0.3);
  }

  .center-title {
    font-size: 3.5rem;
    font-weight: 700;
    letter-spacing: 2px;
    text-shadow: 0 2px 4px rgba(0,0,0,0.3);
  }

  .center-subtitle {
    font-size: 1.25rem;
    font-weight: 300;
    opacity: 0.9;
    line-height: 1.4;
  }

  .location-info {
    .v-chip {
      background: rgba(255,255,255,0.15) !important;
      border-color: rgba(255,255,255,0.3) !important;
      color: white !important;
    }
  }

  .feature-card {
    background: rgba(255,255,255,0.95) !important;
    border-color: rgba(255,255,255,0.3) !important;
    backdrop-filter: blur(10px);
    min-width: 120px;

    .feature-text {
      font-size: 0.75rem;
      font-weight: 500;
      color: #1976D2;
      line-height: 1.2;
    }
  }
}

// Panel de login (derecho)
.login-panel {
  background: #FAFAFA;
  position: relative;
}

.login-form-container {
  width: 100%;
  max-width: 400px;
  padding: 2rem;
}

.login-form-header {
  .login-form-title {
    color: #1976D2;
    font-weight: 600;
    font-size: 1.75rem;
  }

  .login-form-subtitle {
    color: #666;
    font-size: 0.95rem;
  }
}

.login-form-card {
  border: 2px solid rgba(25, 118, 210, 0.1) !important;
  border-radius: 12px !important;
  background: white !important;
}

.login-btn {
  height: 48px !important;
  font-weight: 600 !important;
  border-radius: 8px !important;
}

.login-footer {
  margin-top: 1rem;
}

// Responsive
@media (max-width: 960px) {
  .institutional-panel {
    display: none !important;
  }

  .login-panel {
    background: linear-gradient(135deg, #1976D2 0%, #1565C0 50%, #0D47A1 100%);
  }

  .login-form-container {
    max-width: 450px;
  }

  .login-form-header {
    color: white;

    .login-form-title {
      color: white;
    }

    .login-form-subtitle {
      color: rgba(255,255,255,0.8);
    }
  }

  .login-footer {
    color: rgba(255,255,255,0.8);
  }
}

@media (max-width: 600px) {
  .login-form-container {
    padding: 1rem;
  }

  .institutional-panel {
    .university-title {
      font-size: 2rem;
    }

    .center-title {
      font-size: 2.5rem;
    }

    .center-subtitle {
      font-size: 1rem;
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

@keyframes fadeInLeft {
  from {
    opacity: 0;
    transform: translateX(-30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.institutional-content {
  animation: fadeInLeft 0.8s ease-out;
}

.login-form-container {
  animation: fadeInUp 0.8s ease-out;
}
</style>
