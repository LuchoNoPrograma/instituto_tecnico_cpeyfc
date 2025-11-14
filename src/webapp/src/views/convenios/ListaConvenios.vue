<script setup>
import { onMounted, ref, computed } from 'vue'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos.js'
import { showRegistrado, showModificado, showError, showConfirmar } from '@/utils/sweetalert.js'
import FormularioConvenio from '@/views/convenios/FormularioConvenio.vue'
import FormularioConvenioDescuento from '@/views/convenios/FormularioConvenioDescuento.vue'

const convenios = ref([])
const programasAprobados = ref([])
const conceptosPago = ref([])
const cargando = ref(false)
const busqueda = ref('')

// Estados de dialog convenio
const dialogFormulario = ref(false)
const convenioSeleccionado = ref(null)
const esEdicion = computed(() => !!convenioSeleccionado.value)

// Estados de dialog descuentos
const dialogDescuentos = ref(false)
const descuentosConvenio = ref([])
const cargandoDescuentos = ref(false)
const dialogFormularioDescuento = ref(false)
const descuentoSeleccionado = ref(null)
const esEdicionDescuento = computed(() => !!descuentoSeleccionado.value)

const headersConvenios = [
  { title: 'Institución', key: 'nombre_institucion', sortable: true },
  { title: 'Tipo', key: 'tipo_institucion', sortable: true },
  { title: 'NIT', key: 'nit', sortable: true },
  { title: 'Contacto', key: 'contacto_nombre', sortable: true },
  { title: 'Vigencia', key: 'vigencia', sortable: false },
  { title: 'Acciones', key: 'acciones', sortable: false }
]

const headersDescuentos = [
  { title: 'Programa', key: 'programa', sortable: true },
  { title: 'Concepto', key: 'concepto', sortable: true },
  { title: 'Tipo', key: 'tipo_descuento', sortable: true },
  { title: 'Valor', key: 'valor_display', sortable: true },
  { title: 'Vigencia', key: 'vigencia', sortable: false },
  { title: 'Acciones', key: 'acciones', sortable: false }
]

const conveniosFormateados = computed(() => {
  return convenios.value.map(convenio => ({
    ...convenio,
    vigencia: formatearVigencia(convenio.fecha_inicio_convenio, convenio.fecha_fin_convenio)
  }))
})

const descuentosFormateados = computed(() => {
  return descuentosConvenio.value.map(descuento => {
    const programa = descuento.id_aca_programa_aprobado
      ? programasAprobados.value.find(p => p.id_aca_programa_aprobado === descuento.id_aca_programa_aprobado)
      : null

    const concepto = descuento.id_fin_concepto_pago
      ? conceptosPago.value.find(c => c.id_fin_concepto_pago === descuento.id_fin_concepto_pago)
      : null
    return {
      ...descuento,
      programa: programa ? `${programa.programa_nombre} (${programa.gestion})` : 'Todos los programas',
      concepto: concepto ? concepto.nombre_concepto : 'Todos los conceptos',
      valor_display: descuento.tipo_descuento === 'PORCENTUAL'
        ? `${descuento.valor_descuento}%`
        : `Bs. ${descuento.valor_descuento}`,
      vigencia: formatearVigencia(descuento.fecha_inicio_vigencia, descuento.fecha_fin_vigencia)

    }
  })
})

const formatearVigencia = (inicio, fin) => {
  if (!inicio && !fin) return 'Sin definir'
  if (!fin) return `Desde ${formatoFecha.ddMMaaaa(inicio)}`
  return `${formatoFecha.ddMMaaaa(inicio)} Al ${formatoFecha.ddMMaaaa(fin)}`
}

const obtenerConvenios = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/convenios/activos')
    convenios.value = response.data
  } catch (error) {
    showError('Error al cargar convenios')
    console.error(error)
  } finally {
    cargando.value = false
  }
}

const obtenerProgramasAprobados = async () => {
  try {
    const response = await api.get('/api/programa-aprobado/vista/programas-aprobados')
    programasAprobados.value = response.data
  } catch (error) {
    console.error('Error al obtener programas:', error)
  }
}

const obtenerConceptosPago = async () => {
  try {
    const response = await api.get('/api/concepto-pago/activo')
    conceptosPago.value = response.data
  } catch (error) {
    console.error('Error al obtener conceptos de pago:', error)
  }
}

// Funciones de convenios
const abrirDialogNuevo = () => {
  convenioSeleccionado.value = null
  dialogFormulario.value = true
}

const abrirDialogEditar = (convenio) => {
  convenioSeleccionado.value = convenio
  dialogFormulario.value = true
}

const cerrarDialogFormulario = () => {
  dialogFormulario.value = false
  convenioSeleccionado.value = null
}

const guardarConvenio = async (datos) => {
  try {
    if (esEdicion.value) {
      await api.put(`/api/convenio/${convenioSeleccionado.value.id_convenio}`, datos)
      showModificado()
    } else {
      await api.post('/api/convenio', datos)
      showRegistrado()
    }
    cerrarDialogFormulario()
    obtenerConvenios()
  } catch (error) {
    showError(error.response?.data?.message || 'Error al guardar el convenio')
  }
}

const eliminarConvenio = async (convenio) => {
  const resultado = await showConfirmar(
    '¿Eliminar convenio?',
    `Se eliminará el convenio con ${convenio.nombre_institucion}`
  )

  if (!resultado.isConfirmed) return

  try {
    await api.delete(`/api/convenio/${convenio.id_convenio}`)
    showModificado('Convenio eliminado')
    obtenerConvenios()
  } catch (error) {
    showError(error.response?.data?.message || 'Error al eliminar convenio')
  }
}

// Funciones de descuentos
const abrirDescuentos = async (convenio) => {
  convenioSeleccionado.value = convenio
  dialogDescuentos.value = true
  await obtenerDescuentosConvenio(convenio.id_convenio)
}

const cerrarDescuentos = () => {
  dialogDescuentos.value = false
  convenioSeleccionado.value = null
  descuentosConvenio.value = []
}

const obtenerDescuentosConvenio = async (idConvenio) => {
  cargandoDescuentos.value = true
  try {
    const response = await api.get(`/api/convenio/${idConvenio}/descuentos`)
    descuentosConvenio.value = response.data
  } catch (error) {
    showError('Error al cargar descuentos')
    console.error(error)
  } finally {
    cargandoDescuentos.value = false
  }
}

const abrirDialogNuevoDescuento = () => {
  descuentoSeleccionado.value = null
  dialogFormularioDescuento.value = true
}

const abrirDialogEditarDescuento = (descuento) => {
  descuentoSeleccionado.value = descuento
  dialogFormularioDescuento.value = true
}

const cerrarDialogFormularioDescuento = () => {
  dialogFormularioDescuento.value = false
  descuentoSeleccionado.value = null
}

const guardarDescuento = async (datos) => {
  try {
    if (esEdicionDescuento.value) {
      await api.put(`/api/convenio/descuento/${descuentoSeleccionado.value.id_descuento_convenio}`, datos)
      showModificado()
    } else {
      await api.post('/api/convenio/descuento', datos)
      showRegistrado()
    }
    cerrarDialogFormularioDescuento()
    await obtenerDescuentosConvenio(convenioSeleccionado.value.id_convenio)
  } catch (error) {
    showError(error.response?.data?.message || 'Error al guardar el descuento')
  }
}

const eliminarDescuento = async (descuento) => {
  const resultado = await showConfirmar(
    '¿Eliminar descuento?',
    'Se eliminará este descuento del convenio'
  )

  if (!resultado.isConfirmed) return

  try {
    await api.delete(`/api/convenio/descuento/${descuento.id_descuento_convenio}`)
    showModificado('Descuento eliminado')
    await obtenerDescuentosConvenio(convenioSeleccionado.value.id_convenio)
  } catch (error) {
    showError(error.response?.data?.message || 'Error al eliminar descuento')
  }
}

onMounted(async () => {
  await Promise.all([
    obtenerConvenios(),
    obtenerProgramasAprobados(),
    obtenerConceptosPago()
  ])
})
</script>

<template>
  <div class="pa-4">
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headersConvenios"
        :items="conveniosFormateados"
        :loading="cargando"
        :search="busqueda"
        loading-text="Cargando convenios..."
        no-data-text="No hay convenios registrados"
        class="rounded-lg"
        density="comfortable"
      >
        <template #top>
          <v-toolbar class="rounded-t-lg">
            <v-container fluid class="py-4 px-4">
              <v-row align="center" no-gutters>
                <v-col cols="12" lg="auto" class="mb-3 mb-lg-0">
                  <div class="d-flex align-center">
                    <v-icon class="mr-2" color="primary">mdi-handshake</v-icon>
                    <span class="text-h6 font-weight-bold">Administrar Convenios</span>
                  </div>
                </v-col>

                <v-spacer class="d-none d-sm-block"></v-spacer>

                <v-col cols="12" lg="auto">
                  <v-row align="center" justify="end" no-gutters class="ga-2">
                    <v-col cols="auto" class="flex-grow-1 flex-lg-grow-0">
                      <v-text-field
                        v-model="busqueda"
                        append-inner-icon="mdi-magnify"
                        label="Buscar..."
                        single-line
                        hide-details
                        variant="outlined"
                        density="compact"
                        style="min-width: 200px"
                      />
                    </v-col>

                    <v-col cols="auto">
                      <v-btn
                        color="primary"
                        prepend-icon="mdi-plus"
                        variant="elevated"
                        @click="abrirDialogNuevo"
                      >
                        Nuevo Convenio
                      </v-btn>
                    </v-col>
                  </v-row>
                </v-col>
              </v-row>
            </v-container>
          </v-toolbar>
        </template>

        <template #[`item.acciones`]="{ item }">
          <div class="d-flex ga-1">
            <v-btn
              icon="mdi-percent"
              size="small"
              color="success"
              title="Adm. Descuentos"
              @click="abrirDescuentos(item)"
            />
            <v-btn
              icon="mdi-pencil"
              size="small"
              color="primary"
              @click="abrirDialogEditar(item)"
            />
            <v-btn
              icon="mdi-delete"
              size="small"
              color="error"
              @click="eliminarConvenio(item)"
            />
          </div>
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog Formulario Convenio -->
    <v-dialog v-model="dialogFormulario" max-width="920px" persistent>
      <v-card class="rounded-lg">
        <v-card-title class="text-h6 bg-primary text-white">
          <v-icon start>mdi-handshake</v-icon>
          {{ esEdicion ? 'Editar Convenio' : 'Nuevo Convenio' }}
        </v-card-title>

        <FormularioConvenio
          :convenio="convenioSeleccionado"
          :es-edicion="esEdicion"
          @guardar="guardarConvenio"
          @cancelar="cerrarDialogFormulario"
        />
      </v-card>
    </v-dialog>

    <!-- Dialog Descuentos -->
    <v-dialog v-model="dialogDescuentos" max-width="1000px" persistent>
      <v-card class="rounded-lg">
        <v-card-title class="text-h6 bg-primary text-white">
          <v-icon start>mdi-percent</v-icon>
          Descuentos - {{ convenioSeleccionado?.nombre_institucion }}
        </v-card-title>

        <v-card-text class="pt-4">
          <v-data-table
            :headers="headersDescuentos"
            :items="descuentosFormateados"
            :loading="cargandoDescuentos"
            loading-text="Cargando descuentos..."
            no-data-text="No hay descuentos registrados"
            density="compact"
          >
            <template #top>
              <v-toolbar density="compact" class="py-2">
                <v-spacer />
                <v-btn
                  color="primary"
                  variant="elevated"
                  prepend-icon="mdi-plus"
                  @click="abrirDialogNuevoDescuento"
                >
                  Agregar Descuento
                </v-btn>
              </v-toolbar>
            </template>

            <template #[`item.acciones`]="{ item }">
              <div class="d-flex ga-1">
                <v-btn
                  icon="mdi-pencil"
                  size="small"
                  color="primary"
                  @click="abrirDialogEditarDescuento(item)"
                />
                <v-btn
                  icon="mdi-delete"
                  size="small"
                  color="error"
                  @click="eliminarDescuento(item)"
                />
              </div>
            </template>
          </v-data-table>
        </v-card-text>

        <v-card-actions class="px-6 pb-4">
          <v-spacer />
          <v-btn
            variant="text"
            @click="cerrarDescuentos"
          >
            Cerrar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog Formulario Descuento -->
    <v-dialog v-model="dialogFormularioDescuento" max-width="920px" persistent>
      <v-card class="rounded-lg">
        <v-card-title class="text-h6 bg-primary text-white">
          <v-icon start>mdi-percent</v-icon>
          {{ esEdicionDescuento ? 'Editar Descuento' : 'Nuevo Descuento' }}
        </v-card-title>

        <FormularioConvenioDescuento
          :descuento="descuentoSeleccionado"
          :es-edicion="esEdicionDescuento"
          :id-convenio="convenioSeleccionado?.id_convenio"
          :programas-aprobados="programasAprobados"
          :conceptos-pago="conceptosPago"
          @guardar="guardarDescuento"
          @cancelar="cerrarDialogFormularioDescuento"
        />
      </v-card>
    </v-dialog>
  </div>
</template>
