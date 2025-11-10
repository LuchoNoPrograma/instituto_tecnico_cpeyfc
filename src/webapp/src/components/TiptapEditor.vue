<script setup>
import { ref, watch, onBeforeUnmount, nextTick } from 'vue'
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
  }
})

// Emits
const emit = defineEmits(['update:modelValue'])

// Estados
const fileInputRef = ref(null)
const cropOverlay = ref(false)
const imagenOriginal = ref(null)
const cropperRef = ref(null)
const currentImageNode = ref(null)
const currentImagePos = ref(null)
const uploadingImage = ref(false)
const contextMenu = ref(false)
const contextMenuX = ref(0)
const contextMenuY = ref(0)
const selectedImageElement = ref(null)
const menuActivatorRef = ref(null)

// Extensión de imagen personalizada con resize en 4 esquinas
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
      img.style.margin = 'auto'
      img.style.display = 'block'
      img.style.borderRadius = '8px'
      img.style.cursor = 'pointer'
      img.style.border = '2px solid transparent'

      // Variables de resize
      let isResizing = false
      let startX, startY, startWidth, startHeight, aspectRatio

      // Crear 4 handles de resize en las esquinas
      const handles = []
      const positions = [
        { name: 'nw', cursor: 'nw-resize', top: '-5px', left: '-5px' },
        { name: 'ne', cursor: 'ne-resize', top: '-5px', right: '-5px' },
        { name: 'sw', cursor: 'sw-resize', bottom: '-5px', left: '-5px' },
        { name: 'se', cursor: 'se-resize', bottom: '-5px', right: '-5px' }
      ]

      positions.forEach(pos => {
        const handle = document.createElement('div')
        handle.classList.add('resize-handle', `resize-handle-${pos.name}`)
        handle.style.cssText = `
          position: absolute;
          ${pos.top ? `top: ${pos.top};` : ''}
          ${pos.bottom ? `bottom: ${pos.bottom};` : ''}
          ${pos.left ? `left: ${pos.left};` : ''}
          ${pos.right ? `right: ${pos.right};` : ''}
          width: 14px;
          height: 14px;
          background: rgb(var(--v-theme-primary));
          border: 2px solid white;
          border-radius: 50%;
          cursor: ${pos.cursor};
          display: none;
          box-shadow: 0 2px 4px rgba(0,0,0,0.2);

        `

        handle.addEventListener('mousedown', (e) => {
          e.preventDefault()
          e.stopPropagation()
          isResizing = true
          startX = e.clientX
          startY = e.clientY
          startWidth = img.offsetWidth
          startHeight = img.offsetHeight
          aspectRatio = startWidth / startHeight

          const handleResize = (e) => {
            if (!isResizing) return

            let deltaX = 0
            let deltaY = 0

            // Calcular delta según la esquina
            if (pos.name === 'se') {
              deltaX = e.clientX - startX
              deltaY = e.clientY - startY
            } else if (pos.name === 'sw') {
              deltaX = -(e.clientX - startX)
              deltaY = e.clientY - startY
            } else if (pos.name === 'ne') {
              deltaX = e.clientX - startX
              deltaY = -(e.clientY - startY)
            } else if (pos.name === 'nw') {
              deltaX = -(e.clientX - startX)
              deltaY = -(e.clientY - startY)
            }

            // Usar el mayor delta y mantener proporción
            const maxDelta = Math.max(deltaX, deltaY)
            const newWidth = Math.max(100, Math.min(startWidth + maxDelta, 800))
            const newHeight = newWidth / aspectRatio

            img.style.width = newWidth + 'px'
            img.style.height = newHeight + 'px'
          }

          const stopResize = () => {
            if (isResizing) {
              isResizing = false
              const pos = getPos()
              if (typeof pos === 'number') {
                editor.commands.updateAttributes('image', {
                  width: img.offsetWidth,
                  height: img.offsetHeight
                })
              }
              document.removeEventListener('mousemove', handleResize)
              document.removeEventListener('mouseup', stopResize)
            }
          }

          document.addEventListener('mousemove', handleResize)
          document.addEventListener('mouseup', stopResize)
        })

        handles.push(handle)
      })

      // Container wrapper
      const container = document.createElement('div')
      container.style.cssText = `
        position: relative;
        display: inline-block;
        max-width: 100%;
      `

      container.appendChild(img)
      handles.forEach(handle => container.appendChild(handle))
      dom.appendChild(container)

      // Click en imagen para mostrar handles
      img.addEventListener('click', (e) => {
        e.stopPropagation()
        if (!editor.isEditable) return

        // Ocultar todos los handles
        img.style.border = '2px solid rgb(var(--v-theme-primary))';
        document.querySelectorAll('.resize-handle').forEach(h => {
          h.style.display = 'none'
        })

        // Mostrar handles de esta imagen
        handles.forEach(handle => {
          handle.style.display = 'block'
        })
      })

      img.addEventListener('contextmenu', (e) => {
        e.preventDefault()
        e.stopPropagation()
        if (!editor.isEditable) return

        // Cerrar menú si ya está abierto (para actualizar posición)
        if (contextMenu.value) {
          contextMenu.value = false
        }

        // Guardar referencia a la imagen y nodo
        selectedImageElement.value = img
        currentImageNode.value = node
        currentImagePos.value = getPos()

        // Posicionar el activator invisible
        contextMenuX.value = e.clientX
        contextMenuY.value = e.clientY

        // Mostrar menú después de que el activator se posicione
        nextTick(() => {
          contextMenu.value = true
        })
      })

      // Ocultar handles al hacer click fuera
      const hideHandles = (e) => {
        if (!container.contains(e.target)) {
          img.style.border = '2px solid transparent'
          handles.forEach(handle => {
            handle.style.display = 'none'
          })
        }
      }

      setTimeout(() => {
        document.addEventListener('click', hideHandles)
      }, 0)

      return {
        dom,
        update: (updatedNode) => {
          if (updatedNode.type.name !== 'image') return false
          img.src = updatedNode.attrs.src
          if (updatedNode.attrs.width) img.style.width = updatedNode.attrs.width + 'px'
          if (updatedNode.attrs.height) img.style.height = updatedNode.attrs.height + 'px'
          return true
        },
        destroy: () => {
          document.removeEventListener('click', hideHandles)
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
      },
      blockquote: false,
      horizontalRule: false
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

  // Subir directamente sin crop
  subirImagen(file)

  // Limpiar input
  event.target.value = ''
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

// Método para recortar imagen desde menú contextual
const recortarImagen = () => {
  contextMenu.value = false

  if (selectedImageElement.value) {
    // Cargar imagen para crop
    imagenOriginal.value = selectedImageElement.value.src
    cropOverlay.value = true
  }
}

const confirmarRecorte = async () => {
  const { canvas } = cropperRef.value.getResult()

  if (canvas && currentImagePos.value !== null) {
    canvas.toBlob(async (blob) => {
      try {
        // Subir imagen recortada
        const formData = new FormData()
        formData.append('file', blob, 'cropped-image.jpg')

        const response = await api.post(props.uploadEndpoint, formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        })

        if (response.data.success && response.data.url) {
          // Actualizar la imagen en el editor sin width/height para evitar distorsión
          editor.value.commands.updateAttributes('image', {
            src: response.data.url,
            width: null,
            height: null
          })
        }

        cropOverlay.value = false
        imagenOriginal.value = null
        selectedImageElement.value = null
        currentImageNode.value = null
        currentImagePos.value = null
      } catch (error) {
        console.error('Error al subir imagen recortada:', error)
        alert('Error al guardar la imagen recortada')
      }
    }, 'image/jpeg', 0.9)
  }
}

const cancelarRecorte = () => {
  cropOverlay.value = false
  imagenOriginal.value = null
  selectedImageElement.value = null
  currentImageNode.value = null
  currentImagePos.value = null
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

      <!-- Deshacer/Rehacer -->
      <v-btn-group density="compact" variant="outlined">
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

    <!-- Activator invisible para el menú contextual -->
    <div
      ref="menuActivatorRef"
      :style="{
        position: 'fixed',
        left: contextMenuX + 'px',
        top: contextMenuY + 'px',
        width: '1px',
        height: '1px',
        pointerEvents: 'none',
        zIndex: 9998
      }"
    ></div>

    <!-- Menú contextual -->
    <v-menu
      v-model="contextMenu"
      :activator="menuActivatorRef"
      location="start"
      :offset="0"
      :close-on-content-click="true"
    >
      <v-list density="compact" min-width="180">
        <v-list-item @click="recortarImagen" :disabled="uploadingImage">
          <template #prepend>
            <v-icon>mdi-crop</v-icon>
          </template>
          <v-list-item-title>Recortar</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>

    <!-- Overlay de crop in-place -->
    <div v-if="cropOverlay" class="crop-overlay" @click.self="cancelarRecorte">
      <div class="crop-container">
        <div class="crop-header">
          <span class="text-h6">Recortar Imagen</span>
          <v-btn icon size="small" variant="text" @click="cancelarRecorte">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </div>

        <div class="cropper-wrapper">
          <Cropper
            ref="cropperRef"
            class="cropper"
            :src="imagenOriginal"
          />
        </div>

        <div class="crop-actions">
          <v-btn variant="text" @click="cancelarRecorte">
            Cancelar
          </v-btn>
          <v-btn color="primary" variant="elevated" @click="confirmarRecorte">
            <v-icon start>mdi-check</v-icon>
            Confirmar
          </v-btn>
        </div>
      </div>
    </div>
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

  .crop-overlay {
    width: 100%;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.8);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;

    .crop-container {
      background: rgba(var(--v-theme-surface), 1);
      border-radius: 8px;
      width: 100%;
      max-width: 90vw;
      max-height: 90vh;
      display: flex;
      flex-direction: column;
      overflow: hidden;

      .crop-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 16px 20px;
        background: rgb(var(--v-theme-primary));
        color: white;
      }

      .cropper-wrapper {
        height: 60vh;
        background: rgba(var(--v-theme-surface-variant), 1);
        padding: 20px;

        .cropper {
          height: 100%;
        }
      }

      .crop-actions {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 12px;
        padding: 16px 20px;
        border-top: 1px solid rgba(var(--v-border-color), var(--v-border-opacity));
      }
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

  a {
    color: rgb(var(--v-theme-primary));
    text-decoration: underline;

    &:hover {
      text-decoration: none;
    }
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

    .crop-overlay .crop-container .cropper-wrapper {
      height: 50vh;
    }
  }
}
</style>
