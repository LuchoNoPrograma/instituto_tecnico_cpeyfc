<script setup>
import { onMounted, ref, computed } from 'vue'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos.js'
import { showRegistrado, showModificado, showError, showConfirmar } from '@/utils/sweetalert.js'

const aranceles = ref([])
const tiposBeneficiario = ref([])
const conceptosPago = ref([])
const programasAprobados = ref([])
const cargando = ref(false)
const busqueda = ref('')

// Estados de dialog
const dialogFormulario = ref(false)
const arancelSeleccionado = ref(null)
const esEdicion = computed(() => !!arancelSeleccionado.value)

// Formulario
const formularioArancel = ref({
  id_fin_concepto_pago: null,
  id_programa_aprobado: null,
  id_tipo_beneficiario: null,
  monto_base: null,
  fecha_inicio_vigencia: null,
  fecha_fin_vigencia: null,
  descripcion: '',
  estado_arancel: 'ACTIVO'
})

const headers = [
  { title: 'Concepto', key: 'nombre_concepto', sortable: true },
  { title: 'Programa', key: 'nombre_programa', sortable: true },
  { title: 'Tipo Beneficiario', key: 'tipo_beneficiario', sortable: true },
  { title: 'Monto Base', key: 'monto_base', sortable: true },
  { title: 'Vigencia', key: 'vigencia', sortable: false },
  { title: 'Estado', key: 'estado_vigencia', sortable: true },
  { title: 'Acciones', key: 'acciones', sortable: false }
]

const arancelesFormateados = computed(() => {
  return aranceles.value.map(arancel => ({
    ...arancel,
    vigencia: formatearVigencia(arancel.fecha_inicio_vigencia, arancel.fecha_fin_vigencia),
    monto_display: formatearMonto(arancel.monto_base)
  }))
})

const formatearVigencia = (inicio, fin) => {
  if (!inicio && !fin) return 'Sin definir'
  if (!fin) return `Desde ${formatoFecha.ddMMaaaa(inicio)}`
  return `${formatoFecha.ddMMaaaa(inicio)} - ${formatoFecha.ddMMaaaa(fin)}`
}

const formatearMonto = (monto) => {
  return `Bs. ${parseFloat(monto).toFixed(2)}`
}

const obtenerColorEstadoVigencia = (estado) => {
  return estado === 'VIGENTE' ? 'success' : 'error'
}

const obtenerAranceles = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/aranceles/vigentes')
    aranceles.value = response.data
  } catch (error) {
    showError('Error al cargar aranceles')
    console.error(error)
  } finally {
    cargando.value = false
  }
}

const obtenerTiposBeneficiario = async () => {
  try {
    const response = await api.get('/api/tipos-beneficiario')
    tiposBeneficiario.value = response.data
  } catch (error) {
    console.error('Error al obtener tipos de beneficiario:', error)
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

const obtenerProgramasAprobados = async () => {
  try {
    const response = await api.get('/api/programa-aprobado/vista/programas-aprobados')
    programasAprobados.value = response.data
  } catch (error) {
    console.error('Error al obtener programas:', error)
  }
}

const abrirDialogNuevo = () => {
  arancelSeleccionado.value = null
  formularioArancel.value = {
    id_fin_concepto_pago: null,
    id_programa_aprobado: null,
    id_tipo_beneficiario: null,
    monto_base: null,
    fecha_inicio_vigencia: null,
    fecha_fin_vigencia: null,
    descripcion: '',
    estado_arancel: 'ACTIVO'
  }
  dialogFormulario.value = true
}

const abrirDialogEditar = (arancel) => {
  arancelSeleccionado.value = arancel
  formularioArancel.value = {
    id_fin_concepto_pago: arancel.id_fin_concepto_pago,
    id_programa_aprobado: arancel.id_aca_programa_aprobado || null,
    id_tipo_beneficiario: arancel.id_tipo_beneficiario,
    monto_base: parseFloat(arancel.monto_base),
    fecha_inicio_vigencia: arancel.fecha_inicio_vigencia,
    fecha_fin_vigencia: arancel.fecha_fin_vigencia,
    descripcion: arancel.descripcion_arancel || '',
    estado_arancel: arancel.estado_vigencia === 'VIGENTE' ? 'ACTIVO' : 'INACTIVO'
  }
  dialogFormulario.value = true
}

const guardarArancel = async () => {
  try {
    if (esEdicion.value) {
      await api.put(`/api/arancel/${arancelSeleccionado.value.id_arancel}`, formularioArancel.value)
      showModificado()
    } else {
      await api.post('/api/arancel', formularioArancel.value)
      showRegistrado()
    }
    dialogFormulario.value = false
    obtenerAranceles()
  } catch (error) {
    showError(error.response?.data?.message || 'Error al guardar el arancel')
  }
}

const eliminarArancel = async (arancel) => {
  const confirmado = await showConfirmar(
    '¿Eliminar arancel?',
    `Se eliminará el arancel de ${arancel.nombre_concepto}`
  )

  if (confirmado) {
    try {
      await api.delete(`/api/arancel/${arancel.id_arancel}`)
      showModificado('Arancel eliminado')
      obtenerAranceles()
    } catch (error) {
      showError(error.response?.data?.message || 'Error al eliminar arancel')
    }
  }
}

onMounted(async () => {
  await Promise.all([
    obtenerAranceles(),
    obtenerTiposBeneficiario(),
    obtenerConceptosPago(),
    obtenerProgramasAprobados()
  ])
})
</script>

<template>
  <div class="pa-4">
    <v-card class="rounded-lg">
      <v-data-table
        :headers="headers"
        :items="arancelesFormateados"
        :loading="cargando"
        :search="busqueda"
        loading-text="Cargando aranceles..."
        no-data-text="No hay aranceles registrados"
        class="rounded-lg"
        density="comfortable"
      >
        <template #top>
          <v-toolbar class="rounded-t-lg">
            <v-container fluid class="py-4 px-4">
              <v-row align="center" no-gutters>
                <v-col cols="12" lg="auto" class="mb-3 mb-lg-0">
                  <div class="d-flex align-center">
                    <v-icon class="mr-2" color="primary">mdi-cash-multiple</v-icon>
                    <span class="text-h6 font-weight-bold">Gestión de Aranceles</span>
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
                        Nuevo Arancel
                      </v-btn>
                    </v-col>
                  </v-row>
                </v-col>
              </v-row>
            </v-container>
          </v-toolbar>
        </template>

        <template #[`item.monto_base`]="{ item }">
          <span class="font-weight-bold">{{ item.monto_display }}</span>
        </template>

        <template #[`item.estado_vigencia`]="{ item }">
          <v-chip
            :color="obtenerColorEstadoVigencia(item.estado_vigencia)"
            size="small"
            variant="flat"
          >
            {{ item.estado_vigencia }}
          </v-chip>
        </template>

        <template #[`item.acciones`]="{ item }">
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
            @click="eliminarArancel(item)"
          />
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog Formulario -->
    <v-dialog v-model="dialogFormulario" max-width="700px" persistent>
      <v-card>
        <v-card-title class="text-h6 bg-primary text-white">
          <v-icon start>mdi-cash-multiple</v-icon>
          {{ esEdicion ? 'Editar Arancel' : 'Nuevo Arancel' }}
        </v-card-title>

        <v-card-text class="pt-6">
          <v-row>
            <v-col cols="12" md="6">
              <v-select
                v-model="formularioArancel.id_fin_concepto_pago"
                :items="conceptosPago"
                item-title="nombre_concepto"
                item-value="id_fin_concepto_pago"
                label="Concepto de Pago *"
                variant="outlined"
                density="comfortable"
                :rules="[v => !!v || 'Campo requerido']"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-select
                v-model="formularioArancel.id_tipo_beneficiario"
                :items="tiposBeneficiario"
                item-title="nombre_tipo"
                item-value="id_tipo_beneficiario"
                label="Tipo Beneficiario *"
                variant="outlined"
                density="comfortable"
                :rules="[v => !!v || 'Campo requerido']"
              />
            </v-col>

            <v-col cols="12">
              <v-select
                v-model="formularioArancel.id_programa_aprobado"
                :items="programasAprobados"
                item-title="programa_nombre"
                item-value="id_aca_programa_aprobado"
                label="Programa (opcional - dejar vacío para aplicar a todos)"
                variant="outlined"
                density="comfortable"
                clearable
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model.number="formularioArancel.monto_base"
                label="Monto Base (Bs.) *"
                type="number"
                prefix="Bs."
                variant="outlined"
                density="comfortable"
                :rules="[v => !!v || 'Campo requerido', v => v > 0 || 'Debe ser mayor a 0']"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-select
                v-model="formularioArancel.estado_arancel"
                :items="['ACTIVO', 'INACTIVO']"
                label="Estado"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioArancel.fecha_inicio_vigencia"
                label="Fecha Inicio Vigencia *"
                type="date"
                variant="outlined"
                density="comfortable"
                :rules="[v => !!v || 'Campo requerido']"
              />
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="formularioArancel.fecha_fin_vigencia"
                label="Fecha Fin Vigencia (opcional)"
                type="date"
                variant="outlined"
                density="comfortable"
              />
            </v-col>

            <v-col cols="12">
              <v-textarea
                v-model="formularioArancel.descripcion"
                label="Descripción"
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
            @click="guardarArancel"
          >
            {{ esEdicion ? 'Actualizar' : 'Guardar' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>
