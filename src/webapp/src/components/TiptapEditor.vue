<script setup>
import { ref, watch, onMounted, onBeforeUnmount } from 'vue'
import { useEditor, EditorContent } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import Image from '@tiptap/extension-image'
import Link from '@tiptap/extension-link'
import TextAlign from '@tiptap/extension-text-align'
import Underline from '@tiptap/extension-underline'
import { Cropper } from 'vue-advanced-cropper'
import 'vue-advanced-cropper/dist/style.css'
import { api } from '@/services/api'

// Props
const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: 'Escribe aquí el contenido...'
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

// Emits
const emit = defineEmits(['update:modelValue'])

// Estados
const dialogCropper = ref(false)
const imagenOriginal = ref(null)
const cropperRef = ref(null)
const archivoImagen = ref(null)

// Editor con extensiones configuradas
const editor = useEditor({
  content: props.modelValue,
  editable: !props.disabled,
  extensions: [
    StarterKit.configure({
      heading: {
        levels: [1, 2, 3]
      }
    }),
    Image.configure({
      inline: false,
      allowBase64: false,
      HTMLAttributes: {
        class: 'editor-image'
      }
    }),
    Link.configure({
      openOnClick: false,
      HTMLAttributes: {
        target: '_blank',
        rel: 'noopener noreferrer'
      }
    }),
    TextAlign.configure({
      types: ['heading', 'paragraph']
    }),
    Underline
  ],
  onUpdate: ({ editor }) => {
    emit('update:modelValue', editor.getHTML())
  },
  editorProps: {
    attributes: {
      class: 'tiptap-editor-content',
      spellcheck: 'false'
    }
  }
})

// Watchers
watch(() => props.modelValue, (value) => {
  const isSame = editor.value.getHTML() === value
  if (!isSame) {
    editor.value.commands.setContent(value, false)
  }
})

watch(() => props.disabled, (disabled) => {
  editor.value?.setEditable(!disabled)
})

// Métodos para toolbar
const setLink = () => {
  const previousUrl = editor.value.getAttributes('link').href
  const url = window.prompt('URL del enlace:', previousUrl)

  if (url === null) return

  if (url === '') {
    editor.value.chain().focus().extendMarkRange('link').unsetLink().run()
    return
  }

  editor.value.chain().focus().extendMarkRange('link').setLink({ href: url }).run()
}

const abrirSelectorImagen = () => {
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = 'image/*'
  input.onchange = (e) => {
    const file = e.target.files?.[0]
    if (file) {
      onArchivoSeleccionado(file)
    }
  }
  input.click()
}

const onArchivoSeleccionado = (file) => {
  if (!file) return

  // Validar tamaño (10MB)
  const maxSize = 10 * 1024 * 1024
  if (file.size > maxSize) {
    alert('La imagen es muy grande. Máximo: 10MB')
    return
  }

  // Validar tipo
  if (!file.type.startsWith('image/')) {
    alert('Solo se permiten imágenes')
    return
  }

  archivoImagen.value = file

  // Cargar imagen para el cropper
  const reader = new FileReader()
  reader.onload = (e) => {
    imagenOriginal.value = e.target.result
    dialogCropper.value = true
  }
  reader.readAsDataURL(file)
}

const confirmarRecorte = async () => {
  const { canvas } = cropperRef.value.getResult()
  if (!canvas) return

  canvas.toBlob(async (blob) => {
    try {
      // Subir imagen al servidor
      const formData = new FormData()
      formData.append('file', blob, archivoImagen.value.name)

      const response = await api.post('/api/noticia/upload/imagen', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })

      // Insertar imagen en el editor
      const imageUrl = response.data.url || response.data.path
      editor.value.chain().focus().setImage({ src: imageUrl }).run()

      dialogCropper.value = false
      imagenOriginal.value = null
      archivoImagen.value = null
    } catch (error) {
      console.error('Error al subir imagen:', error)
      alert('Error al subir la imagen. Intenta nuevamente.')
    }
  }, 'image/jpeg', 0.9)
}

const cancelarRecorte = () => {
  dialogCropper.value = false
  imagenOriginal.value = null
  archivoImagen.value = null
}

// Lifecycle
onMounted(() => {
  // Hacer imágenes resizables
  const images = document.querySelectorAll('.tiptap-editor-content img')
  images.forEach(makeImageResizable)
})

onBeforeUnmount(() => {
  editor.value?.destroy()
})

// Helper para hacer imágenes resizables
const makeImageResizable = (img) => {
  let startX, startY, startWidth, startHeight

  const resizeHandle = document.createElement('div')
  resizeHandle.className = 'resize-handle'

  img.parentElement.style.position = 'relative'
  img.parentElement.appendChild(resizeHandle)

  const startResize = (e) => {
    startX = e.clientX
    startY = e.clientY
    startWidth = img.clientWidth
    startHeight = img.clientHeight
    document.addEventListener('mousemove', resize)
    document.addEventListener('mouseup', stopResize)
  }

  const resize = (e) => {
    const width = startWidth + (e.clientX - startX)
    img.style.width = width + 'px'
  }

  const stopResize = () => {
    document.removeEventListener('mousemove', resize)
    document.removeEventListener('mouseup', stopResize)
  }

  resizeHandle.addEventListener('mousedown', startResize)
}
</script>

<template>
  <div class="tiptap-editor">
    <!-- Toolbar -->
    <div v-if="editor" class="editor-toolbar">
      <!-- Text formatting -->
      <div class="toolbar-group">
        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive('bold') }"
          @click="editor.chain().focus().toggleBold().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-bold</v-icon>
          <v-tooltip activator="parent" location="bottom">Negrita</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive('italic') }"
          @click="editor.chain().focus().toggleItalic().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-italic</v-icon>
          <v-tooltip activator="parent" location="bottom">Cursiva</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive('underline') }"
          @click="editor.chain().focus().toggleUnderline().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-underline</v-icon>
          <v-tooltip activator="parent" location="bottom">Subrayado</v-tooltip>
        </v-btn>
      </div>

      <v-divider vertical class="mx-2"></v-divider>

      <!-- Headings -->
      <div class="toolbar-group">
        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive('heading', { level: 1 }) }"
          @click="editor.chain().focus().toggleHeading({ level: 1 }).run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-header-1</v-icon>
          <v-tooltip activator="parent" location="bottom">Título 1</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive('heading', { level: 2 }) }"
          @click="editor.chain().focus().toggleHeading({ level: 2 }).run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-header-2</v-icon>
          <v-tooltip activator="parent" location="bottom">Título 2</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive('heading', { level: 3 }) }"
          @click="editor.chain().focus().toggleHeading({ level: 3 }).run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-header-3</v-icon>
          <v-tooltip activator="parent" location="bottom">Título 3</v-tooltip>
        </v-btn>
      </div>

      <v-divider vertical class="mx-2"></v-divider>

      <!-- Lists -->
      <div class="toolbar-group">
        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive('bulletList') }"
          @click="editor.chain().focus().toggleBulletList().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-list-bulleted</v-icon>
          <v-tooltip activator="parent" location="bottom">Lista con viñetas</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive('orderedList') }"
          @click="editor.chain().focus().toggleOrderedList().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-list-numbered</v-icon>
          <v-tooltip activator="parent" location="bottom">Lista numerada</v-tooltip>
        </v-btn>
      </div>

      <v-divider vertical class="mx-2"></v-divider>

      <!-- Alignment -->
      <div class="toolbar-group">
        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive({ textAlign: 'left' }) }"
          @click="editor.chain().focus().setTextAlign('left').run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-align-left</v-icon>
          <v-tooltip activator="parent" location="bottom">Alinear izquierda</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive({ textAlign: 'center' }) }"
          @click="editor.chain().focus().setTextAlign('center').run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-align-center</v-icon>
          <v-tooltip activator="parent" location="bottom">Centrar</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive({ textAlign: 'right' }) }"
          @click="editor.chain().focus().setTextAlign('right').run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-align-right</v-icon>
          <v-tooltip activator="parent" location="bottom">Alinear derecha</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive({ textAlign: 'justify' }) }"
          @click="editor.chain().focus().setTextAlign('justify').run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-align-justify</v-icon>
          <v-tooltip activator="parent" location="bottom">Justificar</v-tooltip>
        </v-btn>
      </div>

      <v-divider vertical class="mx-2"></v-divider>

      <!-- Media -->
      <div class="toolbar-group">
        <v-btn
          size="small"
          variant="text"
          icon
          @click="abrirSelectorImagen"
          :disabled="disabled"
        >
          <v-icon>mdi-image-plus</v-icon>
          <v-tooltip activator="parent" location="bottom">Insertar imagen</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          variant="text"
          icon
          :class="{ 'is-active': editor.isActive('link') }"
          @click="setLink"
          :disabled="disabled"
        >
          <v-icon>mdi-link</v-icon>
          <v-tooltip activator="parent" location="bottom">Insertar enlace</v-tooltip>
        </v-btn>
      </div>

      <v-divider vertical class="mx-2"></v-divider>

      <!-- Undo/Redo -->
      <div class="toolbar-group">
        <v-btn
          size="small"
          variant="text"
          icon
          @click="editor.chain().focus().undo().run()"
          :disabled="!editor.can().undo() || disabled"
        >
          <v-icon>mdi-undo</v-icon>
          <v-tooltip activator="parent" location="bottom">Deshacer</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          variant="text"
          icon
          @click="editor.chain().focus().redo().run()"
          :disabled="!editor.can().redo() || disabled"
        >
          <v-icon>mdi-redo</v-icon>
          <v-tooltip activator="parent" location="bottom">Rehacer</v-tooltip>
        </v-btn>
      </div>
    </div>

    <!-- Editor Content -->
    <div class="editor-content-wrapper">
      <editor-content :editor="editor" />
      <div v-if="!modelValue && !disabled" class="editor-placeholder">
        {{ placeholder }}
      </div>
    </div>

    <!-- Dialog del Cropper -->
    <v-dialog v-model="dialogCropper" max-width="900px" persistent>
      <v-card>
        <v-card-title class="bg-primary text-white pa-4">
          <v-icon start>mdi-crop</v-icon>
          Ajustar Imagen
        </v-card-title>

        <v-card-text class="pa-6">
          <div class="cropper-container">
            <Cropper
              ref="cropperRef"
              class="cropper"
              :src="imagenOriginal"
              :stencil-props="{ aspectRatio: 16 / 9 }"
            />
          </div>
          <div class="text-caption text-center text-medium-emphasis mt-4">
            Arrastra y ajusta la imagen para seleccionar el área que deseas mostrar
          </div>
        </v-card-text>

        <v-card-actions class="pa-4">
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="cancelarRecorte">Cancelar</v-btn>
          <v-btn color="primary" variant="elevated" @click="confirmarRecorte">
            <v-icon start>mdi-check</v-icon>
            Confirmar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<style lang="scss" scoped>
.tiptap-editor {
  border: 1px solid rgba(0, 0, 0, 0.12);
  border-radius: 4px;
  overflow: hidden;

  .editor-toolbar {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 8px 12px;
    background: #f5f5f5;
    border-bottom: 1px solid rgba(0, 0, 0, 0.12);
    flex-wrap: wrap;

    .toolbar-group {
      display: flex;
      gap: 2px;
    }

    .v-btn {
      &.is-active {
        background: rgba(var(--v-theme-primary), 0.15);
        color: rgb(var(--v-theme-primary));
      }
    }
  }

  .editor-content-wrapper {
    position: relative;
    min-height: 200px;

    .editor-placeholder {
      position: absolute;
      top: 16px;
      left: 16px;
      color: #999;
      pointer-events: none;
      font-size: 1rem;
    }
  }

  :deep(.tiptap-editor-content) {
    padding: 16px;
    min-height: 200px;
    max-height: 500px;
    overflow-y: auto;
    outline: none;

    p {
      margin-bottom: 1em;
      line-height: 1.7;
    }

    h1 {
      font-size: 2rem;
      font-weight: 700;
      margin: 1.5em 0 0.5em;
      line-height: 1.3;
    }

    h2 {
      font-size: 1.5rem;
      font-weight: 600;
      margin: 1.3em 0 0.5em;
      line-height: 1.4;
    }

    h3 {
      font-size: 1.25rem;
      font-weight: 600;
      margin: 1.2em 0 0.5em;
      line-height: 1.4;
    }

    ul,
    ol {
      padding-left: 1.5em;
      margin-bottom: 1em;

      li {
        margin-bottom: 0.5em;
      }
    }

    a {
      color: rgb(var(--v-theme-primary));
      text-decoration: underline;
      cursor: pointer;

      &:hover {
        text-decoration: none;
      }
    }

    img {
      max-width: 100%;
      height: auto;
      display: block;
      margin: 1em 0;
      border-radius: 8px;
      cursor: pointer;
      transition: transform 0.2s;

      &:hover {
        transform: scale(1.02);
      }
    }

    blockquote {
      border-left: 4px solid rgb(var(--v-theme-primary));
      padding-left: 1em;
      margin: 1em 0;
      font-style: italic;
      color: #666;
    }

    code {
      background: #f5f5f5;
      padding: 2px 6px;
      border-radius: 4px;
      font-family: 'Courier New', monospace;
      font-size: 0.9em;
    }

    pre {
      background: #2d2d2d;
      color: #f8f8f2;
      padding: 1em;
      border-radius: 8px;
      overflow-x: auto;
      margin: 1em 0;

      code {
        background: none;
        padding: 0;
        color: inherit;
      }
    }
  }

  .cropper-container {
    height: 500px;
    background: #f5f5f5;

    .cropper {
      height: 100%;
      background: #f5f5f5;
    }
  }
}

@media (max-width: 600px) {
  .tiptap-editor {
    .editor-toolbar {
      padding: 6px 8px;
    }

    .cropper-container {
      height: 300px;
    }
  }
}
</style>
