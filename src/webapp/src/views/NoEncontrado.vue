<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const mensaje = ref('')

const mensajes404 = [
  '¡Oops! Esta página se fue de vacaciones',
  'La página que buscas está estudiando para sus exámenes',
  '404 - Página no encontrada en nuestros archivos académicos',
  'Esta URL necesita inscribirse primero',
  '¡Houston, tenemos un problema académico!'
]

const volverInicio = () => {
  router.push('/')
}

const volverDashboard = () => {
  router.push('/dashboard')
}

const irBusqueda = () => {
  router.push('/buscar')
}

onMounted(() => {
  // Mensaje aleatorio
  mensaje.value = mensajes404[Math.floor(Math.random() * mensajes404.length)]
})
</script>

<template>
  <div class="not-found-container">
    <div class="not-found-content">
      <!-- Ilustración 404 -->
      <div class="illustration-container">
        <div class="number-404">
          <span class="number-4">4</span>
          <div class="number-0">
            <v-icon size="120" color="primary">mdi-school</v-icon>
          </div>
          <span class="number-4">4</span>
        </div>
      </div>

      <!-- Contenido del error -->
      <div class="error-content">
        <h1 class="error-title">¡Página No Encontrada!</h1>

        <p class="error-message">
          {{ mensaje }}
        </p>

        <p class="error-description">
          La página que estás buscando no existe o ha sido movida.
          Te sugerimos volver al inicio o buscar lo que necesitas.
        </p>

        <!-- Búsqueda rápida -->
        <div class="search-section">
          <h3 class="search-title">¿Qué estabas buscando?</h3>

          <v-row justify="center">
            <v-col cols="12" sm="8" md="6">
              <v-text-field
                placeholder="Buscar en CPEYFC..."
                prepend-inner-icon="mdi-magnify"
                variant="outlined"
                hide-details
                @keyup.enter="irBusqueda"
              ></v-text-field>
            </v-col>
          </v-row>
        </div>

        <!-- Botones de acción -->
        <div class="action-buttons">
          <v-btn
            color="primary"
            size="large"
            variant="flat"
            prepend-icon="mdi-home"
            @click="volverInicio"
            class="me-4"
          >
            Ir al Inicio
          </v-btn>

          <v-btn
            color="secondary"
            size="large"
            variant="outlined"
            prepend-icon="mdi-view-dashboard"
            @click="volverDashboard"
          >
            Panel Principal
          </v-btn>
        </div>

        <!-- Enlaces útiles -->
        <div class="helpful-links">
          <h4 class="links-title">Enlaces Útiles</h4>

          <v-row justify="center">
            <v-col cols="12" sm="6" md="4">
              <v-card variant="outlined" class="link-card">
                <v-card-text class="text-center">
                  <v-icon size="48" color="primary" class="mb-2">
                    mdi-account-group
                  </v-icon>
                  <div class="text-h6 mb-1">Personas</div>
                  <div class="text-body-2 text-medium-emphasis">
                    Gestión de personas
                  </div>
                </v-card-text>
                <v-card-actions>
                  <v-btn
                    variant="text"
                    color="primary"
                    block
                    @click="$router.push('/personas')"
                  >
                    Ir a Personas
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-col>

            <v-col cols="12" sm="6" md="4">
              <v-card variant="outlined" class="link-card">
                <v-card-text class="text-center">
                  <v-icon size="48" color="success" class="mb-2">
                    mdi-school
                  </v-icon>
                  <div class="text-h6 mb-1">Programas</div>
                  <div class="text-body-2 text-medium-emphasis">
                    Programas académicos
                  </div>
                </v-card-text>
                <v-card-actions>
                  <v-btn
                    variant="text"
                    color="success"
                    block
                    @click="$router.push('/programas')"
                  >
                    Ver Programas
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-col>

            <v-col cols="12" sm="6" md="4">
              <v-card variant="outlined" class="link-card">
                <v-card-text class="text-center">
                  <v-icon size="48" color="info" class="mb-2">
                    mdi-help-circle
                  </v-icon>
                  <div class="text-h6 mb-1">Ayuda</div>
                  <div class="text-body-2 text-medium-emphasis">
                    Centro de ayuda
                  </div>
                </v-card-text>
                <v-card-actions>
                  <v-btn
                    variant="text"
                    color="info"
                    block
                    @click="$router.push('/ayuda')"
                  >
                    Obtener Ayuda
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-col>
          </v-row>
        </div>
      </div>
    </div>

    <!-- Particles background -->
    <div class="particles"></div>
  </div>
</template>

<style lang="scss" scoped>
.not-found-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  position: relative;
  overflow: hidden;
}

.not-found-content {
  max-width: 1000px;
  width: 100%;
  text-align: center;
  position: relative;
  z-index: 1;
}

.illustration-container {
  margin-bottom: 3rem;

  .number-404 {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    margin-bottom: 2rem;

    .number-4 {
      font-size: 8rem;
      font-weight: 900;
      color: #1976D2;
      text-shadow: 0 4px 8px rgba(0,0,0,0.1);
      line-height: 1;
    }

    .number-0 {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 120px;
      height: 120px;
      border: 4px solid #1976D2;
      border-radius: 50%;
      background: rgba(25, 118, 210, 0.1);
    }
  }
}

.error-content {
  .error-title {
    font-size: 2.5rem;
    font-weight: 700;
    color: #1976D2;
    margin-bottom: 1rem;
  }

  .error-message {
    font-size: 1.2rem;
    color: #666;
    margin-bottom: 1rem;
    font-weight: 500;
  }

  .error-description {
    font-size: 1rem;
    color: #888;
    margin-bottom: 3rem;
    max-width: 600px;
    margin-left: auto;
    margin-right: auto;
  }
}

.search-section {
  margin-bottom: 3rem;

  .search-title {
    color: #1976D2;
    margin-bottom: 1.5rem;
    font-weight: 600;
  }
}

.action-buttons {
  margin-bottom: 3rem;
}

.helpful-links {
  .links-title {
    color: #1976D2;
    margin-bottom: 2rem;
    font-weight: 600;
  }

  .link-card {
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    cursor: pointer;
    height: 100%;

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 16px rgba(0,0,0,0.1) !important;
    }
  }
}

.particles {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image:
    radial-gradient(circle at 20% 50%, rgba(25, 118, 210, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(255, 82, 82, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 40% 80%, rgba(0, 188, 212, 0.1) 0%, transparent 50%);
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-20px); }
}

// Responsive
@media (max-width: 960px) {
  .illustration-container .number-404 {
    .number-4 {
      font-size: 6rem;
    }

    .number-0 {
      width: 100px;
      height: 100px;

      .v-icon {
        font-size: 100px !important;
      }
    }
  }

  .error-content .error-title {
    font-size: 2rem;
  }
}

@media (max-width: 600px) {
  .not-found-container {
    padding: 1rem;
  }

  .illustration-container .number-404 {
    flex-direction: column;
    gap: 0.5rem;

    .number-4 {
      font-size: 4rem;
    }

    .number-0 {
      width: 80px;
      height: 80px;

      .v-icon {
        font-size: 80px !important;
      }
    }
  }

  .action-buttons {
    .v-btn {
      margin: 0.5rem;
      width: 100%;
    }
  }
}
</style>
