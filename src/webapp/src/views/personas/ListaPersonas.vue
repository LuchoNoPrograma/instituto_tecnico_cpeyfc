<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '@/services/api'

const router = useRouter()
const personas = ref([])
const cargando = ref(false)
const busqueda = ref('')

const headers = [
  { title: 'Nombre', key: 'nombre', sortable: true },
  { title: 'Apellido Paterno', key: 'ap_paterno', sortable: true },
  { title: 'CI', key: 'ci', sortable: true },
  { title: 'Celular', key: 'nro_celular' },
  { title: 'Acciones', key: 'acciones', sortable: false }
]

const obtenerPersonas = async () => {
  cargando.value = true
  try {
    const response = await api.get('/api/persona/vista/personas-activas')
    personas.value = response.data
  } catch (error) {
    console.error('Error al obtener personas:', error)
  } finally {
    cargando.value = false
  }
}

const verDetalle = (persona) => {
  router.push(`/personas/${persona.id}`)
}

const editarPersona = (persona) => {
  router.push(`/personas/${persona.id}/editar`)
}

const nuevaPersona = () => {
  router.push('/personas/nuevo')
}

onMounted(() => {
  obtenerPersonas()
})
</script>

<template>
  <div class="lista-personas">
    <v-card>
      <v-data-table
        :headers="headers"
        :items="personas"
        :loading="cargando"
        :search="busqueda"
        :items-per-page="50"
        loading-text="Cargando personas..."
        no-data-text="No hay personas registradas"
        class="elevation-1"
      >
        <template #top>
          <v-toolbar title="Lista de personas registradas">
            <template #append>
              <v-btn color="primary" variant="elevated">
                <v-icon icon="mdi-plus" class="mr-1"></v-icon>
                Registrar
              </v-btn>
            </template>
          </v-toolbar>
        </template>
        <template #item.acciones="{ item }">
          <v-btn
            icon="mdi-eye"
            size="small"
            color="info"
            variant="text"
            @click="verDetalle(item)"
          ></v-btn>
          <v-btn
            icon="mdi-pencil"
            size="small"
            color="warning"
            variant="text"
            @click="editarPersona(item)"
          ></v-btn>
        </template>
      </v-data-table>
    </v-card>
  </div>
</template>

<style lang="scss" scoped>
.lista-personas {
  .header-seccion {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;

    .titulo-pagina {
      color: #1976D2;
      font-weight: 600;
      margin: 0;
    }
  }
}

// Responsive
@media (max-width: 600px) {
  .lista-personas .header-seccion {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
}
</style>
