<script setup>
import { onMounted, ref, computed } from 'vue'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos.js'
import { showRegistrado, showModificado, showError, showConfirmar } from '@/utils/sweetalert.js'

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

// Formulario convenio
const formularioConvenio = ref({
  nombre_institucion: '',
  tipo_institucion: '',
  nit: '',
  contacto_nombre: '',
  contacto_telefono: '',
  contacto_email: '',
  fecha_inicio_convenio: null,
  fecha_fin_convenio: null,
  observaciones: '',
  estado_convenio: 'ACTIVO'
})

// Formulario descuento
const formularioDescuento = ref({
  id_convenio: null,
  id_aca_programa_aprobado: null,
  id_fin_concepto_pago: null,
  tipo_descuento: 'PORCENTUAL',
  valor_descuento: null,
  fecha_inicio_vigencia: null,
  fecha_fin_vigencia: null,
  descripcion: '',
  estado_descuento_convenio: 'ACTIVO'
})

const headersConvenios = [
  { title: 'Institución', key: 'nombre_institucion', sortable: true },
  { title: 'Tipo', key: 'tipo_institucion', sortable: true },
  { title: 'NIT', key: 'nit', sortable: true },
  { title: 'Contacto', key: 'contacto_nombre', sortable: true },
  { title: 'Vigencia', key: 'vigencia', sortable: false },
  { title: 'Estado', key: 'estado_convenio', sortable: true },
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
  return descuentosConvenio.value.map(descuento => ({
    ...descuento,
    programa: descuento.id_aca_programa_aprobado ? 'Específico' : 'Todos',
    concepto: descuento.id_fin_concepto_pago ? 'Específico' : 'Todos',
    valor_display: descuento.tipo_descuento === 'PORCENTUAL'
      ? `${descuento.valor_descuento}%`
      : `Bs. ${descuento.valor_descuento}`,
    vigencia: formatearVigencia(descuento.fecha_inicio_vigencia, descuento.fecha_fin_vigencia)
  }))
})

const formatearVigencia = (inicio, fin) => {
  if (!inicio && !fin) return 'Sin definir'
  if (!fin) return `Desde ${formatoFecha.ddMMaaaa(inicio)}`
  return `${formatoFecha.ddMMaaaa(inicio)} - ${formatoFecha.ddMMaaaa(fin)}`
}

const obtenerColorEstado = (estado) => {
  return estado === 'ACTIVO' ? 'success' : 'error'
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

const abrirDialogNuevo = () => {
  convenioSeleccionado.value = null
  formularioConvenio.value = {
    nombre_institucion: '',
    tipo_institucion: '',
    nit: '',
    contacto_nombre: '',
    contacto_telefono: '',
    contacto_email: '',
    fecha_inicio_convenio: null,
    fecha_fin_convenio: null,
    observaciones: '',
    estado_convenio: 'ACTIVO'
  }
  dialogFormulario.value = true
}

const abrirDialogEditar = (convenio) => {
  convenioSeleccionado.value = convenio
  formularioConvenio.value = {
    nombre_institucion: convenio.nombre_institucion,
    tipo_institucion: convenio.tipo_institucion,
    nit: convenio.nit,
    contacto_nombre: convenio.contacto_nombre,
    contacto_telefono: convenio.contacto_telefono,
    contacto_email: convenio.contacto_email,
    fecha_inicio_convenio: convenio.fecha_inicio_convenio,
    fecha_fin_convenio: convenio.fecha_fin_convenio,
    observaciones: convenio.observaciones,
    estado_convenio: convenio.estado_convenio
  }
  dialogFormulario.value = true
}

const guardarConvenio = async () => {
  try {
    if (esEdicion.value) {
      await api.put(`/api/convenio/${convenioSeleccionado.value.id_convenio}`, formularioConvenio.value)
      showModificado()
    } else {
      await api.post('/api/convenio', formularioConvenio.value)
      showRegistrado()
    }
    dialogFormulario.value = false
    obtenerConvenios()
  } catch (error) {
    showError(error.response?.data?.message || 'Error al guardar el convenio')
  }
}

const eliminarConvenio = async (convenio) => {
  const confirmado = await showConfirmar(
    '¿Eliminar convenio?',
    `Se eliminará el convenio con ${convenio.nombre_institucion}`
  )

  if (confirmado) {
    try {
      await api.delete(`/api/convenio/${convenio.id_convenio}`)
      showModificado('Convenio eliminado')
      obtenerConvenios()
    } catch (error) {
      showError(error.response?.data?.message || 'Error al eliminar convenio')
    }
  }
}

// Funciones de descuentos
const abrirDescuentos = async (convenio) => {
  convenioSeleccionado.value = convenio
  dialogDescuentos.value = true
  await obtenerDescuentosConvenio(convenio.id_convenio)
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
  formularioDescuento.value = {
    id_convenio: convenioSeleccionado.value.id_convenio,
    id_aca_programa_aprobado: null,
    id_fin_concepto_pago: null,
    tipo_descuento: 'PORCENTUAL',
    valor_descuento: null,
    fecha_inicio_vigencia: null,
    fecha_fin_vigencia: null,
    descripcion: '',
    estado_descuento_convenio: 'ACTIVO'
  }
  dialogFormularioDescuento.value = true
}

const abrirDialogEditarDescuento = (descuento) => {
  descuentoSeleccionado.value = descuento
  formularioDescuento.value = {
    id_convenio: convenioSeleccionado.value.id_convenio,
    id_aca_programa_aprobado: descuento.id_aca_programa_aprobado,
    id_fin_concepto_pago: descuento.id_fin_concepto_pago,
    tipo_descuento: descuento.tipo_descuento,
    valor_descuento: parseFloat(descuento.valor_descuento),
    fecha_inicio_vigencia: descuento.fecha_inicio_vigencia,
    fecha_fin_vigencia: descuento.fecha_fin_vigencia,
    descripcion: descuento.descripcion,
    estado_descuento_convenio: descuento.estado_descuento_convenio
  }
  dialogFormularioDescuento.value = true
}

const guardarDescuento = async () => {
  try {
    if (esEdicionDescuento.value) {
      await api.put(`/api/convenio/descuento/${descuentoSeleccionado.value.id_descuento_convenio}`, formularioDescuento.value)
      showModificado()
    } else {
      await api.post('/api/convenio/descuento', formularioDescuento.value)
      showRegistrado()
    }
    dialogFormularioDescuento.value = false
    await obtenerDescuentosConvenio(convenioSeleccionado.value.id_convenio)
  } catch (error) {
    showError(error.response?.data?.message || 'Error al guardar el descuento')
  }
}

const eliminarDescuento = async (descuento) => {
  const confirmado = await showConfirmar(
    '¿Eliminar descuento?',
    'Se eliminará este descuento del convenio'
  )

  if (confirmado) {
    try {
      await api.delete(`/api/convenio/descuento/${descuento.id_descuento_convenio}`)
      showModificado('Descuento eliminado')
      await obtenerDescuentosConvenio(convenioSeleccionado.value.id_convenio)
    } catch (error) {
      showError(error.response?.data?.message || 'Error al eliminar descuento')
    }
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
                    <span class="text-h6 font-weight-bold">Gestión de Convenios</span>
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

        <template #[`item.estado_convenio`]="{ item }">
          <v-chip
            :color="obtenerColorEstado(item.estado_convenio)"
            size="small"
            variant="flat"
          >
            {{ item.estado_convenio }}
          </v-chip>
        </template>

        <template #[`item.acciones`]="{ item }">
          <v-btn
            icon="mdi-percent"
            size="small"
            variant="text"
            color="success"
            title="Gestionar Descuentos"
            @click="abrirDescuentos(item)"
          />
          <v-btn
            icon="mdi-pencil"
            size="small"
            variant="text"
            color="primary"
            @click="abrirDialogEditar(item)"
          />
          <v-btn
            icon="mdi-delete"
            size="small"
            variant="text"
            color="error"
            @click="eliminarConvenio(item)"
          />
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog Formulario Convenio -->
    <v-dialog v-model="dialogFormulario" max-width="800px" persistent>
      <v-card>
        <v-card-title class="text-h6 bg-primary text-white">
          <v-icon start>mdi-handshake</v-icon>
          {{ esEdicion ? 'Editar Convenio' : 'Nuevo Convenio' }}
        </v-card-title>

        <v-card-text class="pt-6">
          <v-row>
            <v-col cols="12" md="8">
              <v-text-field
                v-model="formularioConvenio.nombre_institucion"
                label="Nombre Institución *"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="4">
              <v-select
                v-model="formularioConvenio.tipo_institucion"
                :items="['COLEGIO', 'EMPRESA', 'FUNDACION', 'ONG', 'OTRO']"
                label="Tipo Institución *"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioConvenio.nit"
                label="NIT"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-select
                v-model="formularioConvenio.estado_convenio"
                :items="['ACTIVO', 'INACTIVO']"
                label="Estado"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioConvenio.contacto_nombre"
                label="Nombre Contacto"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioConvenio.contacto_telefono"
                label="Teléfono Contacto"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12">
              <v-text-field
                v-model="formularioConvenio.contacto_email"
                label="Email Contacto"
                type="email"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioConvenio.fecha_inicio_convenio"
                label="Fecha Inicio Convenio *"
                type="date"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioConvenio.fecha_fin_convenio"
                label="Fecha Fin Convenio (opcional)"
                type="date"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12">
              <v-textarea
                v-model="formularioConvenio.observaciones"
                label="Observaciones"
                variant="outlined"
                density="comfortable"
                rows="3"
              />
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="px-6 pb-4">
          <v-spacer />
          <v-btn
            variant="text"
            @click="dialogFormulario = false"
          >
            Cancelar
          </v-btn>
          <v-btn
            color="primary"
            variant="flat"
            @click="guardarConvenio"
          >
            {{ esEdicion ? 'Actualizar' : 'Guardar' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog Descuentos -->
    <v-dialog v-model="dialogDescuentos" max-width="1000px" persistent>
      <v-card>
        <v-card-title class="text-h6 bg-success text-white">
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
              <v-toolbar density="compact" class="mb-2">
                <v-spacer />
                <v-btn
                  color="success"
                  size="small"
                  prepend-icon="mdi-plus"
                  @click="abrirDialogNuevoDescuento"
                >
                  Agregar Descuento
                </v-btn>
              </v-toolbar>
            </template>

            <template #[`item.acciones`]="{ item }">
              <v-btn
                icon="mdi-pencil"
                size="x-small"
                variant="text"
                color="primary"
                @click="abrirDialogEditarDescuento(item)"
              />
              <v-btn
                icon="mdi-delete"
                size="x-small"
                variant="text"
                color="error"
                @click="eliminarDescuento(item)"
              />
            </template>
          </v-data-table>
        </v-card-text>

        <v-card-actions class="px-6 pb-4">
          <v-spacer />
          <v-btn
            variant="text"
            @click="dialogDescuentos = false"
          >
            Cerrar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog Formulario Descuento -->
    <v-dialog v-model="dialogFormularioDescuento" max-width="700px" persistent>
      <v-card>
        <v-card-title class="text-h6 bg-success text-white">
          <v-icon start>mdi-percent</v-icon>
          {{ esEdicionDescuento ? 'Editar Descuento' : 'Nuevo Descuento' }}
        </v-card-title>

        <v-card-text class="pt-6">
          <v-row>
            <v-col cols="12">
              <v-select
                v-model="formularioDescuento.id_aca_programa_aprobado"
                :items="programasAprobados"
                item-title="programa_nombre"
                item-value="id_aca_programa_aprobado"
                label="Programa (opcional - dejar vacío para todos)"
                variant="outlined"
                density="comfortable"
                clearable
              />
            </v-col>

            <v-col cols="12">
              <v-select
                v-model="formularioDescuento.id_fin_concepto_pago"
                :items="conceptosPago"
                item-title="nombre_concepto"
                item-value="id_fin_concepto_pago"
                label="Concepto (opcional - dejar vacío para todos)"
                variant="outlined"
                density="comfortable"
                clearable
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-select
                v-model="formularioDescuento.tipo_descuento"
                :items="['PORCENTUAL', 'FIJO']"
                label="Tipo Descuento *"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model.number="formularioDescuento.valor_descuento"
                :label="formularioDescuento.tipo_descuento === 'PORCENTUAL' ? 'Valor (%) *' : 'Valor (Bs.) *'"
                type="number"
                :suffix="formularioDescuento.tipo_descuento === 'PORCENTUAL' ? '%' : 'Bs.'"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioDescuento.fecha_inicio_vigencia"
                label="Fecha Inicio Vigencia *"
                type="date"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioDescuento.fecha_fin_vigencia"
                label="Fecha Fin Vigencia (opcional)"
                type="date"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12">
              <v-textarea
                v-model="formularioDescuento.descripcion"
                label="Descripción"
                variant="outlined"
                density="comfortable"
                rows="2"
              />
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="px-6 pb-4">
          <v-spacer />
          <v-btn
            variant="text"
            @click="dialogFormularioDescuento = false"
          >
            Cancelar
          </v-btn>
          <v-btn
            color="success"
            variant="flat"
            @click="guardarDescuento"
          >
            {{ esEdicionDescuento ? 'Actualizar' : 'Guardar' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>
