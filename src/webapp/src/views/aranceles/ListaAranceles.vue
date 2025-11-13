<script setup>
import { onMounted, ref, computed } from 'vue'
import { api } from '@/services/api'
import formatoFecha from '@/helpers/formatos.js'
import { showRegistrado, showModificado, showError, showConfirmar } from '@/utils/sweetalert.js'
import FormularioArancel from '@/views/aranceles/FormularioArancel.vue'

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
  return `${formatoFecha.ddMMaaaa(inicio)} Al ${formatoFecha.ddMMaaaa(fin)}`
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
  dialogFormulario.value = true
}

const abrirDialogEditar = (arancel) => {
  arancelSeleccionado.value = arancel
  dialogFormulario.value = true
}

const cerrarDialogFormulario = () => {
  dialogFormulario.value = false
  arancelSeleccionado.value = null
}

const guardarArancel = async (datos) => {
  try {
    if (esEdicion.value) {
      await api.put(`/api/arancel/${arancelSeleccionado.value.id_arancel}`, datos)
      showModificado()
    } else {
      await api.post('/api/arancel', datos)
      showRegistrado()
    }
    cerrarDialogFormulario()
    obtenerAranceles()
  } catch (error) {
    showError(error.response?.data?.message || 'Error al guardar el arancel')
  }
}

const eliminarArancel = async (arancel) => {
  const resultado = await showConfirmar(
    '¿Eliminar arancel?',
    `Se eliminará el arancel de ${arancel.nombre_concepto}`
  )

  if (!resultado.isConfirmed) return

  try {
    await api.delete(`/api/arancel/${arancel.id_arancel}`)
    showModificado('Arancel eliminado')
    obtenerAranceles()
  } catch (error) {
    showError(error.response?.data?.message || 'Error al eliminar arancel')
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
                        variant="elevated"
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
          <div class="d-flex ga-1">
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
              @click="eliminarArancel(item)"
            />
          </div>
        </template>
      </v-data-table>
    </v-card>

    <!-- Dialog Formulario -->
    <v-dialog v-model="dialogFormulario" max-width="800px" persistent>
      <v-card class="rounded-lg">
        <v-card-title class="text-h6 bg-primary text-white">
          <v-icon start>mdi-cash-multiple</v-icon>
          {{ esEdicion ? 'Editar Arancel' : 'Nuevo Arancel' }}
        </v-card-title>

        <FormularioArancel
          :arancel="arancelSeleccionado"
          :es-edicion="esEdicion"
          :tipos-beneficiario="tiposBeneficiario"
          :conceptos-pago="conceptosPago"
          :programas-aprobados="programasAprobados"
          @guardar="guardarArancel"
          @cancelar="cerrarDialogFormulario"
        />
      </v-card>
    </v-dialog>
  </div>
</template>
