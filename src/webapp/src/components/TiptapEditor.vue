<script setup>
import { ref, watch, onBeforeUnmount } from 'vue'
import { useEditor, EditorContent } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import Image from '@tiptap/extension-image'
import Link from '@tiptap/extension-link'
import Underline from '@tiptap/extension-underline'
import TextAlign from '@tiptap/extension-text-align'
import { Cropper } from 'vue-advanced-cropper'
import 'vue-advanced-cropper/dist/style.css'
import { api } from '@/services/api'
import { useTheme } from 'vuetify'

const theme = useTheme()

// Props
const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: 'Escribe aquí...'
  },
  disabled: {
    type: Boolean,
    default: false
  },
  uploadEndpoint: {
    type: String,
    required: true
  },
  enableImageCrop: {
    type: Boolean,
    default: true
  }
})

// Emits
const emit = defineEmits(['update:modelValue'])

// Estados
const fileInputRef = ref(null)
const dialogCropper = ref(false)
const imagenOriginal = ref(null)
const cropperRef = ref(null)
const imagenPendiente = ref(null)
const uploadingImage = ref(false)

// Extensión de imagen personalizada con resize
const CustomImage = Image.extend({
  addAttributes() {
    return {
      ...this.parent?.(),
      width: {
        default: null,
        renderHTML: attributes => {
          if (!attributes.width) return {}
          return { width: attributes.width }
        }
      },
      height: {
        default: null,
        renderHTML: attributes => {
          if (!attributes.height) return {}
          return { height: attributes.height }
        }
      },
      style: {
        default: null,
        renderHTML: attributes => {
          if (!attributes.style) return {}
          return { style: attributes.style }
        }
      }
    }
  },
  addNodeView() {
    return ({ node, getPos, editor }) => {
      const dom = document.createElement('div')
      dom.classList.add('image-wrapper')

      const img = document.createElement('img')
      img.src = node.attrs.src
      img.alt = node.attrs.alt || ''
      if (node.attrs.width) img.style.width = node.attrs.width + 'px'
      if (node.attrs.height) img.style.height = node.attrs.height + 'px'
      img.style.maxWidth = '100%'
      img.style.height = 'auto'
      img.style.margin = '1.5em auto'
      img.style.display = 'block'
      img.style.borderRadius = '8px'
      img.style.cursor = 'pointer'

      // Resize handles
      let isResizing = false
      let startX, startWidth

      const createResizeHandle = () => {
        const handle = document.createElement('div')
        handle.classList.add('resize-handle')
        handle.style.cssText = `
          position: absolute;
          right: -5px;
          bottom: -5px;
          width: 12px;
          height: 12px;
          background: rgb(var(--v-theme-primary));
          border: 2px solid white;
          border-radius: 50%;
          cursor: nwse-resize;
          display: none;
          box-shadow: 0 2px 4px rgba(0,0,0,0.2);
          z-index: 10;
        `

        handle.addEventListener('mousedown', (e) => {
          e.preventDefault()
          e.stopPropagation()
          isResizing = true
          startX = e.clientX
          startWidth = img.offsetWidth

          document.addEventListener('mousemove', handleMouseMove)
          document.addEventListener('mouseup', handleMouseUp)
        })

        return handle
      }

      const handleMouseMove = (e) => {
        if (!isResizing) return
        const deltaX = e.clientX - startX
        const newWidth = Math.max(100, Math.min(startWidth + deltaX, 800))
        img.style.width = newWidth + 'px'
      }

      const handleMouseUp = () => {
        if (isResizing) {
          isResizing = false
          // Actualizar el nodo con el nuevo tamaño
          const pos = getPos()
          if (typeof pos === 'number') {
            editor.commands.updateAttributes('image', {
              width: img.offsetWidth
            })
          }
          document.removeEventListener('mousemove', handleMouseMove)
          document.removeEventListener('mouseup', handleMouseUp)
        }
      }

      const resizeHandle = createResizeHandle()

      // Container wrapper para posicionar el handle
      const container = document.createElement('div')
      container.style.cssText = `
        position: relative;
        display: inline-block;
        max-width: 100%;
      `

      container.appendChild(img)
      container.appendChild(resizeHandle)
      dom.appendChild(container)

      // Mostrar/ocultar resize handle al hacer click en imagen
      img.addEventListener('click', (e) => {
        e.stopPropagation()
        if (!editor.isEditable) return

        // Ocultar todos los handles
        document.querySelectorAll('.resize-handle').forEach(h => {
          h.style.display = 'none'
        })

        // Mostrar este handle
        resizeHandle.style.display = 'block'
      })

      // Ocultar handle al hacer click fuera
      const hideHandle = (e) => {
        if (!container.contains(e.target)) {
          resizeHandle.style.display = 'none'
        }
      }

      // Agregar listener para clicks globales
      setTimeout(() => {
        document.addEventListener('click', hideHandle)
      }, 0)

      return {
        dom,
        update: (updatedNode) => {
          if (updatedNode.type.name !== 'image') return false
          img.src = updatedNode.attrs.src
          if (updatedNode.attrs.width) img.style.width = updatedNode.attrs.width + 'px'
          return true
        },
        destroy: () => {
          document.removeEventListener('click', hideHandle)
        }
      }
    }
  }
})

// Editor
const editor = useEditor({
  content: props.modelValue,
  editable: !props.disabled,
  extensions: [
    StarterKit.configure({
      heading: {
        levels: [1, 2, 3]
      }
    }),
    CustomImage,
    Underline,
    Link.configure({
      openOnClick: false,
      HTMLAttributes: {
        target: '_blank',
        rel: 'noopener noreferrer'
      }
    }),
    TextAlign.configure({
      types: ['heading', 'paragraph', 'image']
    })
  ],
  editorProps: {
    attributes: {
      class: 'tiptap-editor-content',
      style: `min-height: 300px; padding: 16px; outline: none;`
    }
  },
  onUpdate: ({ editor }) => {
    emit('update:modelValue', editor.getHTML())
  }
})

// Watchers
watch(() => props.modelValue, (value) => {
  if (editor.value && value !== editor.value.getHTML()) {
    editor.value.commands.setContent(value, false)
  }
})

watch(() => props.disabled, (disabled) => {
  if (editor.value) {
    editor.value.setEditable(!disabled)
  }
})

// Métodos
const abrirSelectorImagen = () => {
  fileInputRef.value.click()
}

const onArchivoSeleccionado = (event) => {
  const file = event.target.files[0]
  if (!file) return

  if (!file.type.startsWith('image/')) {
    alert('Solo se permiten imágenes')
    return
  }

  const maxSize = 10 * 1024 * 1024
  if (file.size > maxSize) {
    alert('La imagen es muy grande. Máximo: 10MB')
    return
  }

  if (props.enableImageCrop) {
    // Abrir cropper
    const reader = new FileReader()
    reader.onload = (e) => {
      imagenOriginal.value = e.target.result
      imagenPendiente.value = file
      dialogCropper.value = true
    }
    reader.readAsDataURL(file)
  } else {
    // Subir directamente
    subirImagen(file)
  }

  // Limpiar input
  event.target.value = ''
}

const confirmarRecorte = async () => {
  const { canvas } = cropperRef.value.getResult()

  if (canvas) {
    canvas.toBlob(async (blob) => {
      const archivoRecortado = new File([blob], 'image.jpg', { type: 'image/jpeg' })
      await subirImagen(archivoRecortado)
      dialogCropper.value = false
      imagenOriginal.value = null
    }, 'image/jpeg', 0.9)
  }
}

const cancelarRecorte = () => {
  dialogCropper.value = false
  imagenOriginal.value = null
  imagenPendiente.value = null
}

const subirImagen = async (file) => {
  uploadingImage.value = true

  try {
    const formData = new FormData()
    formData.append('file', file)

    const response = await api.post(props.uploadEndpoint, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })

    if (response.data.success && response.data.url) {
      editor.value.chain().focus().setImage({ src: response.data.url }).run()
    } else {
      throw new Error(response.data.message || 'Error al subir imagen')
    }
  } catch (error) {
    console.error('Error al subir imagen:', error)
    alert('Error al subir la imagen: ' + (error.response?.data?.message || error.message))
  } finally {
    uploadingImage.value = false
  }
}

const insertarEnlace = () => {
  const previousUrl = editor.value.getAttributes('link').href
  const url = window.prompt('Ingresa la URL:', previousUrl)

  if (url === null) return

  if (url === '') {
    editor.value.chain().focus().extendMarkRange('link').unsetLink().run()
    return
  }

  editor.value.chain().focus().extendMarkRange('link').setLink({ href: url }).run()
}

const eliminarEnlace = () => {
  editor.value.chain().focus().unsetLink().run()
}

onBeforeUnmount(() => {
  if (editor.value) {
    editor.value.destroy()
  }
})
</script>

<template>
  <div class="tiptap-editor-wrapper">
    <!-- Toolbar -->
    <div class="tiptap-toolbar" v-if="editor">
      <v-btn-group density="compact" variant="outlined">
        <!-- Formato de texto -->
        <v-btn
          size="small"
          :class="{ 'active': editor.isActive('bold') }"
          @click="editor.chain().focus().toggleBold().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-bold</v-icon>
          <v-tooltip activator="parent" location="bottom">Negrita</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          :class="{ 'active': editor.isActive('italic') }"
          @click="editor.chain().focus().toggleItalic().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-italic</v-icon>
          <v-tooltip activator="parent" location="bottom">Cursiva</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          :class="{ 'active': editor.isActive('underline') }"
          @click="editor.chain().focus().toggleUnderline().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-underline</v-icon>
          <v-tooltip activator="parent" location="bottom">Subrayado</v-tooltip>
        </v-btn>
      </v-btn-group>

      <v-divider vertical class="mx-2"></v-divider>

      <!-- Headings -->
      <v-btn-group density="compact" variant="outlined">
        <v-btn
          size="small"
          :class="{ 'active': editor.isActive('heading', { level: 1 }) }"
          @click="editor.chain().focus().toggleHeading({ level: 1 }).run()"
          :disabled="disabled"
        >
          H1
          <v-tooltip activator="parent" location="bottom">Título 1</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          :class="{ 'active': editor.isActive('heading', { level: 2 }) }"
          @click="editor.chain().focus().toggleHeading({ level: 2 }).run()"
          :disabled="disabled"
        >
          H2
          <v-tooltip activator="parent" location="bottom">Título 2</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          :class="{ 'active': editor.isActive('heading', { level: 3 }) }"
          @click="editor.chain().focus().toggleHeading({ level: 3 }).run()"
          :disabled="disabled"
        >
          H3
          <v-tooltip activator="parent" location="bottom">Título 3</v-tooltip>
        </v-btn>
      </v-btn-group>

      <v-divider vertical class="mx-2"></v-divider>

      <!-- Listas -->
      <v-btn-group density="compact" variant="outlined">
        <v-btn
          size="small"
          :class="{ 'active': editor.isActive('bulletList') }"
          @click="editor.chain().focus().toggleBulletList().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-list-bulleted</v-icon>
          <v-tooltip activator="parent" location="bottom">Lista con viñetas</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          :class="{ 'active': editor.isActive('orderedList') }"
          @click="editor.chain().focus().toggleOrderedList().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-list-numbered</v-icon>
          <v-tooltip activator="parent" location="bottom">Lista numerada</v-tooltip>
        </v-btn>
      </v-btn-group>

      <v-divider vertical class="mx-2"></v-divider>

      <!-- Alineación -->
      <v-btn-group density="compact" variant="outlined">
        <v-btn
          size="small"
          :class="{ 'active': editor.isActive({ textAlign: 'left' }) }"
          @click="editor.chain().focus().setTextAlign('left').run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-align-left</v-icon>
          <v-tooltip activator="parent" location="bottom">Alinear izquierda</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          :class="{ 'active': editor.isActive({ textAlign: 'center' }) }"
          @click="editor.chain().focus().setTextAlign('center').run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-align-center</v-icon>
          <v-tooltip activator="parent" location="bottom">Centrar</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          :class="{ 'active': editor.isActive({ textAlign: 'right' }) }"
          @click="editor.chain().focus().setTextAlign('right').run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-align-right</v-icon>
          <v-tooltip activator="parent" location="bottom">Alinear derecha</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          :class="{ 'active': editor.isActive({ textAlign: 'justify' }) }"
          @click="editor.chain().focus().setTextAlign('justify').run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-align-justify</v-icon>
          <v-tooltip activator="parent" location="bottom">Justificar</v-tooltip>
        </v-btn>
      </v-btn-group>

      <v-divider vertical class="mx-2"></v-divider>

      <!-- Enlaces e imágenes -->
      <v-btn-group density="compact" variant="outlined">
        <v-btn
          size="small"
          @click="insertarEnlace"
          :disabled="disabled"
          :class="{ 'active': editor.isActive('link') }"
        >
          <v-icon>mdi-link</v-icon>
          <v-tooltip activator="parent" location="bottom">Insertar enlace</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          @click="eliminarEnlace"
          :disabled="disabled || !editor.isActive('link')"
        >
          <v-icon>mdi-link-off</v-icon>
          <v-tooltip activator="parent" location="bottom">Eliminar enlace</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          @click="abrirSelectorImagen"
          :disabled="disabled"
          :loading="uploadingImage"
        >
          <v-icon>mdi-image</v-icon>
          <v-tooltip activator="parent" location="bottom">Insertar imagen</v-tooltip>
        </v-btn>
      </v-btn-group>

      <v-divider vertical class="mx-2"></v-divider>

      <!-- Otros -->
      <v-btn-group density="compact" variant="outlined">
        <v-btn
          size="small"
          :class="{ 'active': editor.isActive('blockquote') }"
          @click="editor.chain().focus().toggleBlockquote().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-format-quote-close</v-icon>
          <v-tooltip activator="parent" location="bottom">Cita</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          @click="editor.chain().focus().setHorizontalRule().run()"
          :disabled="disabled"
        >
          <v-icon>mdi-minus</v-icon>
          <v-tooltip activator="parent" location="bottom">Línea horizontal</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          @click="editor.chain().focus().undo().run()"
          :disabled="!editor.can().undo() || disabled"
        >
          <v-icon>mdi-undo</v-icon>
          <v-tooltip activator="parent" location="bottom">Deshacer</v-tooltip>
        </v-btn>

        <v-btn
          size="small"
          @click="editor.chain().focus().redo().run()"
          :disabled="!editor.can().redo() || disabled"
        >
          <v-icon>mdi-redo</v-icon>
          <v-tooltip activator="parent" location="bottom">Rehacer</v-tooltip>
        </v-btn>
      </v-btn-group>
    </div>

    <!-- Editor Content -->
    <div class="tiptap-editor-container">
      <EditorContent :editor="editor" />
      <div v-if="!modelValue && !disabled" class="tiptap-placeholder">
        {{ placeholder }}
      </div>
    </div>

    <!-- Input oculto para imágenes -->
    <input
      ref="fileInputRef"
      type="file"
      accept="image/*"
      style="display: none"
      @change="onArchivoSeleccionado"
    >

    <!-- Dialog Cropper -->
    <v-dialog v-model="dialogCropper" max-width="800px" persistent>
      <v-card>
        <v-card-title class="bg-primary text-white pa-4">
          <v-icon start>mdi-crop</v-icon>
          Recortar Imagen
        </v-card-title>

        <v-card-text class="pa-6">
          <div class="cropper-container">
            <Cropper
              ref="cropperRef"
              class="cropper"
              :src="imagenOriginal"
            />
          </div>
          <div class="text-caption text-center text-medium-emphasis mt-4">
            Arrastra y ajusta la imagen como desees. Puedes recortar libremente.
          </div>
        </v-card-text>

        <v-card-actions class="pa-4">
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="cancelarRecorte">
            Cancelar
          </v-btn>
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
.tiptap-editor-wrapper {
  border: 1px solid rgba(var(--v-border-color), var(--v-border-opacity));
  border-radius: 4px;
  overflow: hidden;

  .tiptap-toolbar {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    padding: 12px;
    background: rgba(var(--v-theme-surface), 1);
    border-bottom: 1px solid rgba(var(--v-border-color), var(--v-border-opacity));

    :deep(.v-btn) {
      &.active {
        background: rgba(var(--v-theme-primary), 0.1);
        color: rgb(var(--v-theme-primary));
      }
    }
  }

  .tiptap-editor-container {
    position: relative;
    background: rgba(var(--v-theme-surface), 1);

    .tiptap-placeholder {
      position: absolute;
      top: 16px;
      left: 16px;
      color: rgba(var(--v-theme-on-surface), 0.38);
      pointer-events: none;
    }
  }

  .cropper-container {
    height: 500px;
    background: rgba(var(--v-theme-surface-variant), 1);

    .cropper {
      height: 100%;
    }
  }
}

:deep(.tiptap-editor-content) {
  color: rgba(var(--v-theme-on-surface), 1);

  img {
    margin: 1.5em auto;
    display: block;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    transition: box-shadow 0.3s ease;

    &:hover {
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }
  }

  .image-wrapper {
    text-align: center;
    margin: 1.5em 0;
  }

  p {
    margin-bottom: 1em;
    line-height: 1.7;
  }

  h1, h2, h3 {
    margin-top: 1.5em;
    margin-bottom: 0.7em;
    font-weight: 600;
    color: rgba(var(--v-theme-on-surface), 0.87);
  }

  h1 {
    font-size: 2rem;
  }

  h2 {
    font-size: 1.6rem;
  }

  h3 {
    font-size: 1.3rem;
  }

  ul, ol {
    padding-left: 2em;
    margin-bottom: 1em;

    li {
      margin-bottom: 0.5em;
    }
  }

  blockquote {
    border-left: 4px solid rgb(var(--v-theme-primary));
    padding-left: 1.5em;
    margin: 1.5em 0;
    font-style: italic;
    color: rgba(var(--v-theme-on-surface), 0.7);
  }

  a {
    color: rgb(var(--v-theme-primary));
    text-decoration: underline;

    &:hover {
      text-decoration: none;
    }
  }

  hr {
    margin: 2em 0;
    border: none;
    border-top: 2px solid rgba(var(--v-border-color), var(--v-border-opacity));
  }

  code {
    background: rgba(var(--v-theme-surface-variant), 1);
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

@media (max-width: 600px) {
  .tiptap-editor-wrapper {
    .tiptap-toolbar {
      padding: 8px;
      gap: 4px;
    }

    .cropper-container {
      height: 300px;
    }
  }
}
</style>
