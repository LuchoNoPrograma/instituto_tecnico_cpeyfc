<template>
  <v-container fluid>
    <v-card>
      <v-card-title>
        <span class="text-h5">Reporte de Obligaciones de Pago por Programa</span>
        <v-spacer></v-spacer>
        <v-btn color="success" @click="exportarExcel" prepend-icon="mdi-file-excel">
          Exportar Excel
        </v-btn>
      </v-card-title>

      <v-card-text>
        <!-- Filtros -->
        <v-row>
          <v-col cols="12" md="3">
            <v-select
              v-model="filtros.programa"
              @update:model-value="aplicarFiltros"
              :items="programas"
              label="Programa"
              clearable
            ></v-select>
          </v-col>
          <v-col cols="12" md="2">
            <v-select
              v-model="filtros.grupo"
              @update:model-value="aplicarFiltros"
              :items="grupos"
              label="Grupo"
              clearable
            ></v-select>
          </v-col>
          <v-col cols="12" md="3">
            <v-text-field
              v-model="filtros.busqueda"
              @input="aplicarFiltros"
              label="Buscar por Nombre/CI"
              prepend-inner-icon="mdi-magnify"
              clearable
            ></v-text-field>
          </v-col>
          <v-col cols="12" md="2">
            <v-select
              v-model="filtros.estadoPago"
              @update:model-value="aplicarFiltros"
              :items="estadosPago"
              label="Estado Pago"
              clearable
            ></v-select>
          </v-col>
          <v-col cols="12" md="2">
            <v-btn @click="limpiarFiltros" color="grey" variant="outlined" block>
              <v-icon>mdi-broom</v-icon>
              Limpiar
            </v-btn>
          </v-col>
        </v-row>

        <!-- Resumen -->
        <v-row class="mb-4">
          <v-col cols="12" md="3">
            <v-card color="blue" variant="tonal">
              <v-card-text>
                <div class="text-h6">{{ datosResumen.totalEstudiantes }}</div>
                <div class="text-caption">Total Estudiantes</div>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col cols="12" md="3">
            <v-card color="orange" variant="tonal">
              <v-card-text>
                <div class="text-h6">{{ formatearMonto(datosResumen.totalPendiente) }}</div>
                <div class="text-caption">Deuda Pendiente</div>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col cols="12" md="3">
            <v-card color="green" variant="tonal">
              <v-card-text>
                <div class="text-h6">{{ formatearMonto(datosResumen.totalPagado) }}</div>
                <div class="text-caption">Total Pagado</div>
              </v-card-text>
            </v-card>
          </v-col>
          <v-col cols="12" md="3">
            <v-card color="purple" variant="tonal">
              <v-card-text>
                <div class="text-h6">{{ formatearMonto(datosResumen.totalGeneral) }}</div>
                <div class="text-caption">Total General</div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

        <!-- Tabla -->
        <v-data-table
          :headers="headers"
          :items="datosFiltrados"
          :loading="cargando"
          :items-per-page="50"
          class="elevation-1"
          loading-text="Cargando datos..."
          no-data-text="No se encontraron registros"
        >
          <template v-slot:item.estudiante="{ item }">
            <div>
              <div class="font-weight-bold">{{ item.nombre }}</div>
              <div class="text-caption text-grey">{{ item.ap_paterno }} {{ item.ap_materno }}</div>
            </div>
          </template>

          <template v-slot:item.contacto="{ item }">
            <div class="text-caption">
              <div><v-icon size="x-small">mdi-phone</v-icon> {{ item.nro_celular }}</div>
              <div><v-icon size="x-small">mdi-email</v-icon> {{ item.correo }}</div>
            </div>
          </template>

          <template v-slot:item.programa="{ item }">
            <div>
              <div class="font-weight-bold">{{ item.sigla_programa }}</div>
              <div class="text-caption">{{ item.nombre_programa }}</div>
              <v-chip size="x-small" color="blue">{{ item.nombre_modalidad }}</v-chip>
            </div>
          </template>

          <template v-slot:item.grupo="{ item }">
            <div>
              <div>{{ item.nombre_grupo }}</div>
              <div class="text-caption text-grey">{{ item.gestion_inicio }}</div>
            </div>
          </template>

          <template v-slot:item.matricula="{ item }">
            <div>
              <div>{{ item.cod_ins_matricula }}</div>
              <v-chip size="x-small" :color="getColorMatricula(item.estado_matricula)">
                {{ item.estado_matricula }}
              </v-chip>
            </div>
          </template>

          <template v-slot:item.concepto="{ item }">
            <div>
              <div class="font-weight-bold">{{ item.nombre_concepto }}</div>
<!--              <div class="text-caption">{{ item.concepto_descripcion }}</div>-->
              <v-chip v-if="item.nombre_param" size="x-small" color="grey" class="mt-1">
                {{ item.nombre_param }}: {{ item.valor_parametro }}
              </v-chip>
            </div>
          </template>

          <template v-slot:item.deuda_sin_descuento="{ item }">
            <div class="text-right">{{ formatearMonto(item.deuda_sin_descuento) }}</div>
          </template>

          <template v-slot:item.deuda_con_descuento="{ item }">
            <div class="text-right">{{ formatearMonto(item.deuda_con_descuento) }}</div>
          </template>

          <template v-slot:item.saldo_pendiente="{ item }">
            <div class="text-right font-weight-bold" :class="getSaldoClass(item.saldo_pendiente)">
              {{ formatearMonto(item.saldo_pendiente) }}
            </div>
          </template>

          <template v-slot:item.estado_pago="{ item }">
            <v-chip size="small" :color="getColorEstadoPago(item.estado_pago)">
              {{ obtenerTextoEstado(item.estado_pago) }}
            </v-chip>
          </template>

          <template v-slot:item.fecha_obligacion="{ item }">
            {{ formatearFecha(item.fecha_obligacion) }}
          </template>

          <template v-slot:item.acciones="{ item }">
            <div class="d-flex flex-column ga-1">
              <v-btn @click="verDetalle(item)" size="x-small" color="blue" variant="tonal">
                <v-icon>mdi-eye</v-icon>
              </v-btn>
              <v-btn
                v-if="item.saldo_pendiente > 0"
                @click="registrarPago(item)"
                size="x-small"
                color="green"
                variant="tonal"
              >
                <v-icon>mdi-cash</v-icon>
              </v-btn>
            </div>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script>
import {api} from '@/services/api.js';

export default {
  name: 'ReporteObligacionesPago',
  data() {
    return {
      obligaciones: [],
      datosFiltrados: [],
      cargando: false,
      filtros: {
        busqueda: '',
        programa: '',
        estadoPago: '',
        grupo: ''
      },
      headers: [
        { title: 'Programa', key: 'programa', sortable: false },
        { title: 'Grupo', key: 'grupo', sortable: false },
        { title: 'Estudiante', key: 'estudiante', sortable: false },
        { title: 'CI', key: 'ci' },
        { title: 'Contacto', key: 'contacto', sortable: false },
        { title: 'Matrícula', key: 'matricula', sortable: false },
        { title: 'Concepto', key: 'concepto', sortable: false },
        { title: 'Deuda Original', key: 'deuda_sin_descuento', align: 'end' },
        { title: 'Con Descuento', key: 'deuda_con_descuento', align: 'end' },
        { title: 'Saldo Pendiente', key: 'saldo_pendiente', align: 'end' },
        { title: 'Estado', key: 'estado_pago' },
        { title: 'Fecha', key: 'fecha_obligacion' },
        { title: 'Acciones', key: 'acciones', sortable: false }
      ],
      estadosPago: [
        { title: 'Pendiente', value: 'PENDIENTE' },
        { title: 'Pago Parcial', value: 'PAGO_PARCIAL' },
        { title: 'Pagado', value: 'PAGADO' }
      ]
    }
  },
  computed: {
    programas() {
      return [...new Set(this.obligaciones.map(o => o.nombre_programa))].sort()
    },
    grupos() {
      return [...new Set(this.obligaciones.map(o => o.nombre_grupo))].sort()
    },
    datosResumen() {
      const estudiantes = new Set(this.datosFiltrados.map(o => o.id_prs_persona))
      const totalPendiente = this.datosFiltrados.reduce((sum, o) => sum + parseFloat(o.saldo_pendiente || 0), 0)
      const totalPagado = this.datosFiltrados.reduce((sum, o) => {
        const deuda = parseFloat(o.deuda_con_descuento || 0)
        const pendiente = parseFloat(o.saldo_pendiente || 0)
        return sum + (deuda - pendiente)
      }, 0)

      return {
        totalEstudiantes: estudiantes.size,
        totalPendiente,
        totalPagado,
        totalGeneral: totalPendiente + totalPagado
      }
    }
  },
  methods: {
    async cargarDatos() {
      this.cargando = true
      try {
        const response = await api.get('/api/matricula/vista/obligaciones-pago')
        this.obligaciones = response.data
        this.aplicarFiltros()
      } catch (error) {
        console.error('Error al cargar obligaciones:', error)
        this.$toast?.error('Error al cargar los datos')
      } finally {
        this.cargando = false
      }
    },
    aplicarFiltros() {
      let datos = [...this.obligaciones]

      if (this.filtros.busqueda) {
        const busqueda = this.filtros.busqueda.toLowerCase()
        datos = datos.filter(o =>
          o.nombre.toLowerCase().includes(busqueda) ||
          o.ap_paterno.toLowerCase().includes(busqueda) ||
          o.ap_materno.toLowerCase().includes(busqueda) ||
          o.ci.includes(busqueda)
        )
      }

      if (this.filtros.programa) {
        datos = datos.filter(o => o.nombre_programa === this.filtros.programa)
      }

      if (this.filtros.estadoPago) {
        datos = datos.filter(o => o.estado_pago === this.filtros.estadoPago)
      }

      if (this.filtros.grupo) {
        datos = datos.filter(o => o.nombre_grupo === this.filtros.grupo)
      }

      this.datosFiltrados = datos
    },
    limpiarFiltros() {
      this.filtros = {
        busqueda: '',
        programa: '',
        estadoPago: '',
        grupo: ''
      }
      this.aplicarFiltros()
    },
    formatearMonto(valor) {
      return new Intl.NumberFormat('es-BO', {
        style: 'currency',
        currency: 'BOB'
      }).format(valor || 0)
    },
    formatearFecha(fecha) {
      if (!fecha) return ''
      return new Date(fecha).toLocaleDateString('es-BO')
    },
    getColorEstadoPago(estado) {
      const colores = {
        'PENDIENTE': 'red',
        'PAGO_PARCIAL': 'orange',
        'PAGADO': 'green'
      }
      return colores[estado] || 'grey'
    },
    getColorMatricula(estado) {
      const colores = {
        'ACTIVA': 'green',
        'INACTIVA': 'orange',
        'SUSPENDIDA': 'red'
      }
      return colores[estado] || 'grey'
    },
    getSaldoClass(saldo) {
      if (saldo == 0) return 'text-green'
      if (saldo > 0) return 'text-red'
      return ''
    },
    obtenerTextoEstado(estado) {
      const textos = {
        'PENDIENTE': 'Pendiente',
        'PAGO_PARCIAL': 'Pago Parcial',
        'PAGADO': 'Pagado'
      }
      return textos[estado] || estado
    },
    verDetalle(obligacion) {
      console.log('Ver detalle:', obligacion)
    },
    registrarPago(obligacion) {
      this.$router.push(`/pagos/registrar/${obligacion.id_fin_obligacion_pago}`)
    },
    exportarExcel() {
      // Implementar exportación si necesitas
      console.log('Exportar Excel')
    }
  },
  mounted() {
    this.cargarDatos()
  }
}
</script>
