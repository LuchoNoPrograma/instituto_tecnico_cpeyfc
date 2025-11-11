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
      texto: '¡Hola! Soy el asistente virtual del Instituto Técnico CPEyFP. ¿En qué puedo ayudarte hoy? Puedo responder preguntas sobre nuestros programas, inscripciones, costos y más.',
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
    texto: '¡Hola! Soy el asistente virtual del Instituto Técnico CPEyFP. ¿En qué puedo ayudarte hoy?',
    timestamp: new Date()
  }]
}

const formatearHora = (timestamp) => {
  return timestamp.toLocaleTimeString('es-BO', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

// NUEVA FUNCIÓN: Procesar markdown links a HTML
const procesarMarkdown = (texto) => {
  if (!texto) return ''

  // Convertir links markdown [texto](url) a HTML
  let html = texto.replace(
    /\[([^\]]+)\]\(([^)]+)\)/g,
    '<a href="$2" target="_blank" rel="noopener noreferrer" class="chatbot-link">$1</a>'
  )

  // Convertir saltos de línea a <br>
  html = html.replace(/\n/g, '<br>')

  return html
}
</script>

<template>
  <div class="chatbot-container">
    <!-- Botón flotante para abrir el chat -->
    <div v-if="!abierto" class="chatbot-fab-wrapper">
      <v-btn
        fab
        color="primary"
        size="large"
        class="chatbot-fab"
        @click="toggleChat"
        elevation="8"
      >
        <v-icon size="32">mdi-robot</v-icon>
      </v-btn>

      <!-- Tooltip animado -->
      <div class="chatbot-tooltip">
        <span>¿Necesitas ayuda? 💬</span>
      </div>
    </div>

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
            <div class="chatbot-subtitle">Instituto Técnico CPEyFP</div>
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
            <!-- Usar v-html para procesar el markdown -->
            <div class="mensaje-texto" v-html="procesarMarkdown(mensaje.texto)"></div>
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

.chatbot-fab-wrapper {
  position: relative;
}

.chatbot-fab {
  position: relative;
  animation: pulse-bot 2s infinite, bounce-gentle 3s ease-in-out infinite;
  transition: all 0.3s ease;

  &:hover {
    animation: none;
    transform: scale(1.1) rotate(5deg);

    ~ .chatbot-tooltip {
      opacity: 1;
      transform: translateX(-10px) scale(1);
    }
  }

  &::before {
    content: '';
    position: absolute;
    top: -2px;
    right: -2px;
    width: 16px;
    height: 16px;
    background: #4CAF50;
    border-radius: 50%;
    border: 3px solid white;
    animation: pulse-dot 2s infinite;
  }

  &::after {
    content: '';
    position: absolute;
    inset: -4px;
    border-radius: 50%;
    background: linear-gradient(45deg,
      rgba(var(--v-theme-primary), 0.3),
      rgba(var(--v-theme-primary), 0.1)
    );
    animation: rotate-border 3s linear infinite;
    z-index: -1;
  }
}

.chatbot-tooltip {
  position: absolute;
  right: 70px;
  top: 50%;
  transform: translateY(-50%) translateX(10px) scale(0.8);
  background: white;
  padding: 0.5rem 1rem;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transition: all 0.3s ease;
  font-weight: 600;
  color: #333;
  border: 2px solid rgb(var(--v-theme-primary));

  &::after {
    content: '';
    position: absolute;
    right: -8px;
    top: 50%;
    transform: translateY(-50%);
    width: 0;
    height: 0;
    border-left: 8px solid rgb(var(--v-theme-primary));
    border-top: 8px solid transparent;
    border-bottom: 8px solid transparent;
  }

  &::before {
    content: '';
    position: absolute;
    right: -6px;
    top: 50%;
    transform: translateY(-50%);
    width: 0;
    height: 0;
    border-left: 6px solid white;
    border-top: 6px solid transparent;
    border-bottom: 6px solid transparent;
    z-index: 1;
  }

  // Animación de aparición automática
  animation: tooltip-peek 8s ease-in-out 2s infinite;
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
    margin-bottom: 0.25rem;

    :deep(.chatbot-link) {
      color: rgb(var(--v-theme-primary));
      text-decoration: none;
      font-weight: 600;
      border-bottom: 2px solid rgb(var(--v-theme-primary));
      padding-bottom: 2px;
      transition: all 0.2s ease;
      display: inline-flex;
      align-items: center;
      gap: 4px;

      &:hover {
        background: rgba(var(--v-theme-primary), 0.1);
        border-radius: 4px;
        padding: 2px 6px;
        transform: translateY(-1px);
      }

      &::after {
        content: '→';
        font-size: 1.1em;
        transition: transform 0.2s ease;
      }

      &:hover::after {
        transform: translateX(3px);
      }
    }
  }

  .mensaje-hora {
    font-size: 0.7rem;
    opacity: 0.7;
    text-align: right;
  }
}

.mensaje-wrapper.usuario {
  .mensaje-texto :deep(.chatbot-link) {
    color: white;
    border-bottom-color: white;

    &:hover {
      background: rgba(255, 255, 255, 0.2);
    }
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
  50% {
    box-shadow: 0 0 0 15px rgba(var(--v-theme-primary), 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(var(--v-theme-primary), 0);
  }
}

@keyframes bounce-gentle {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

@keyframes pulse-dot {
  0%, 100% {
    transform: scale(1);
    opacity: 1;
  }
  50% {
    transform: scale(1.3);
    opacity: 0.7;
  }
}

@keyframes rotate-border {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

@keyframes tooltip-peek {
  0%, 90%, 100% {
    opacity: 0;
    transform: translateY(-50%) translateX(10px) scale(0.8);
  }
  10%, 80% {
    opacity: 1;
    transform: translateY(-50%) translateX(-10px) scale(1);
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

  .chatbot-tooltip {
    display: none;
  }
}
</style>
