<script setup>
import { ref, computed, nextTick } from 'vue'
import { api } from '@/services/api'

const abierto = ref(false)
const minimizado = ref(false)
const mensajeUsuario = ref('')
const conversacion = ref([])
const cargando = ref(false)
const mensajesContainer = ref(null)

const toggleChat = () => {
  abierto.value = !abierto.value
  if (abierto.value && conversacion.value.length === 0) {
    // Mensaje de bienvenida
    conversacion.value.push({
      tipo: 'bot',
      texto: '¡Hola! Soy el asistente virtual del Instituto Técnico CPEyFC. ¿En qué puedo ayudarte hoy? Puedo responder preguntas sobre nuestros programas, inscripciones, costos y más.',
      timestamp: new Date()
    })
  }
}

const toggleMinimizar = () => {
  minimizado.value = !minimizado.value
}

const enviarMensaje = async () => {
  if (!mensajeUsuario.value.trim()) return

  const mensaje = mensajeUsuario.value.trim()
  mensajeUsuario.value = ''

  // Agregar mensaje del usuario
  conversacion.value.push({
    tipo: 'usuario',
    texto: mensaje,
    timestamp: new Date()
  })

  // Scroll al final
  await nextTick()
  scrollToBottom()

  // Mostrar indicador de carga
  cargando.value = true

  try {
    const response = await api.post('/api/publico/chatbot', {
      mensaje: mensaje
    })

    // Agregar respuesta del bot
    conversacion.value.push({
      tipo: 'bot',
      texto: response.data.respuesta || 'Lo siento, no pude procesar tu consulta.',
      timestamp: new Date()
    })
  } catch (error) {
    console.error('Error al enviar mensaje:', error)
    conversacion.value.push({
      tipo: 'bot',
      texto: 'Lo siento, ocurrió un error al procesar tu consulta. Por favor intenta nuevamente.',
      timestamp: new Date(),
      error: true
    })
  } finally {
    cargando.value = false
    await nextTick()
    scrollToBottom()
  }
}

const scrollToBottom = () => {
  if (mensajesContainer.value) {
    mensajesContainer.value.scrollTop = mensajesContainer.value.scrollHeight
  }
}

const limpiarChat = () => {
  conversacion.value = [{
    tipo: 'bot',
    texto: '¡Hola! Soy el asistente virtual del Instituto Técnico CPEyFC. ¿En qué puedo ayudarte hoy?',
    timestamp: new Date()
  }]
}

const formatearHora = (timestamp) => {
  return timestamp.toLocaleTimeString('es-BO', {
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>

<template>
  <div class="chatbot-container">
    <!-- Botón flotante para abrir el chat -->
    <v-btn
      v-if="!abierto"
      fab
      color="primary"
      size="large"
      class="chatbot-fab"
      @click="toggleChat"
      elevation="8"
    >
      <v-icon size="32">mdi-robot</v-icon>
    </v-btn>

    <!-- Ventana del chat -->
    <v-card
      v-if="abierto"
      class="chatbot-card"
      :class="{ 'minimizado': minimizado }"
      elevation="12"
    >
      <!-- Header del chat -->
      <v-card-title class="chatbot-header">
        <div class="d-flex align-center w-100">
          <v-avatar size="40" color="white" class="me-3">
            <v-icon color="primary" size="24">mdi-robot</v-icon>
          </v-avatar>
          <div class="flex-grow-1">
            <div class="chatbot-title">Asistente Virtual</div>
            <div class="chatbot-subtitle">Instituto Técnico CPEyFC</div>
          </div>
          <v-btn
            icon
            size="small"
            variant="text"
            @click="toggleMinimizar"
            class="me-2"
          >
            <v-icon>{{ minimizado ? 'mdi-window-maximize' : 'mdi-window-minimize' }}</v-icon>
          </v-btn>
          <v-btn
            icon
            size="small"
            variant="text"
            @click="toggleChat"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </div>
      </v-card-title>

      <!-- Cuerpo del chat -->
      <v-card-text v-if="!minimizado" class="chatbot-body" ref="mensajesContainer">
        <div
          v-for="(mensaje, index) in conversacion"
          :key="index"
          class="mensaje-wrapper"
          :class="mensaje.tipo"
        >
          <div class="mensaje" :class="{ 'error': mensaje.error }">
            <div class="mensaje-texto">{{ mensaje.texto }}</div>
            <div class="mensaje-hora">{{ formatearHora(mensaje.timestamp) }}</div>
          </div>
        </div>

        <!-- Indicador de carga -->
        <div v-if="cargando" class="mensaje-wrapper bot">
          <div class="mensaje typing-indicator">
            <div class="typing-dots">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        </div>
      </v-card-text>

      <!-- Input de mensaje -->
      <v-card-actions v-if="!minimizado" class="chatbot-footer">
        <v-text-field
          v-model="mensajeUsuario"
          placeholder="Escribe tu pregunta..."
          variant="outlined"
          density="compact"
          hide-details
          @keyup.enter="enviarMensaje"
          :disabled="cargando"
          class="flex-grow-1"
        >
          <template v-slot:append-inner>
            <v-btn
              icon
              size="small"
              color="primary"
              @click="enviarMensaje"
              :disabled="!mensajeUsuario.trim() || cargando"
            >
              <v-icon>mdi-send</v-icon>
            </v-btn>
          </template>
        </v-text-field>

        <v-menu>
          <template v-slot:activator="{ props }">
            <v-btn
              icon
              size="small"
              variant="text"
              v-bind="props"
              class="ms-2"
            >
              <v-icon>mdi-dots-vertical</v-icon>
            </v-btn>
          </template>
          <v-list>
            <v-list-item @click="limpiarChat">
              <template v-slot:prepend>
                <v-icon>mdi-broom</v-icon>
              </template>
              <v-list-item-title>Limpiar chat</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </v-card-actions>
    </v-card>
  </div>
</template>

<style lang="scss" scoped>
.chatbot-container {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  z-index: 1000;
}

.chatbot-fab {
  animation: pulse-bot 2s infinite;

  &:hover {
    animation-play-state: paused;
  }
}

.chatbot-card {
  width: 400px;
  max-width: calc(100vw - 4rem);
  height: 600px;
  max-height: calc(100vh - 4rem);
  display: flex;
  flex-direction: column;
  border-radius: 16px !important;
  overflow: hidden;
  transition: all 0.3s ease;

  &.minimizado {
    height: 70px;
  }
}

.chatbot-header {
  background: linear-gradient(135deg, rgb(var(--v-theme-primary)) 0%, #1565C0 100%);
  color: white;
  padding: 1rem !important;
  border-bottom: none;

  .chatbot-title {
    font-size: 1.1rem;
    font-weight: 700;
    line-height: 1.2;
  }

  .chatbot-subtitle {
    font-size: 0.85rem;
    opacity: 0.9;
  }

  .v-btn {
    color: white;
  }
}

.chatbot-body {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem;
  background: #f5f5f5;
  display: flex;
  flex-direction: column;
  gap: 1rem;

  &::-webkit-scrollbar {
    width: 6px;
  }

  &::-webkit-scrollbar-track {
    background: transparent;
  }

  &::-webkit-scrollbar-thumb {
    background: #ccc;
    border-radius: 3px;

    &:hover {
      background: #999;
    }
  }
}

.mensaje-wrapper {
  display: flex;
  animation: fadeInUp 0.3s ease;

  &.usuario {
    justify-content: flex-end;

    .mensaje {
      background: linear-gradient(135deg, rgb(var(--v-theme-primary)) 0%, #1565C0 100%);
      color: white;
      border-radius: 18px 18px 4px 18px;
    }
  }

  &.bot {
    justify-content: flex-start;

    .mensaje {
      background: white;
      color: #333;
      border-radius: 18px 18px 18px 4px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

      &.error {
        background: #ffebee;
        border-left: 4px solid #f44336;
      }
    }
  }
}

.mensaje {
  max-width: 75%;
  padding: 0.75rem 1rem;
  word-wrap: break-word;

  .mensaje-texto {
    line-height: 1.5;
    white-space: pre-wrap;
    margin-bottom: 0.25rem;
  }

  .mensaje-hora {
    font-size: 0.7rem;
    opacity: 0.7;
    text-align: right;
  }
}

.typing-indicator {
  padding: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;

  .typing-dots {
    display: flex;
    gap: 4px;

    span {
      width: 8px;
      height: 8px;
      background: #999;
      border-radius: 50%;
      animation: typing 1.4s infinite;

      &:nth-child(2) {
        animation-delay: 0.2s;
      }

      &:nth-child(3) {
        animation-delay: 0.4s;
      }
    }
  }
}

.chatbot-footer {
  padding: 1rem !important;
  background: white;
  border-top: 1px solid #e0e0e0;
}

// Animaciones
@keyframes pulse-bot {
  0% {
    box-shadow: 0 0 0 0 rgba(var(--v-theme-primary), 0.7);
  }
  70% {
    box-shadow: 0 0 0 10px rgba(var(--v-theme-primary), 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(var(--v-theme-primary), 0);
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
  }
  30% {
    transform: translateY(-10px);
  }
}

// Responsive
@media (max-width: 600px) {
  .chatbot-container {
    bottom: 1rem;
    right: 1rem;
  }

  .chatbot-card {
    width: calc(100vw - 2rem);
    height: calc(100vh - 2rem);
    max-width: none;
    max-height: none;
  }

  .mensaje {
    max-width: 85%;
  }
}
</style>
