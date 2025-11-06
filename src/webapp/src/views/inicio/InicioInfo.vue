<script setup>
import { ref } from 'vue'
import organigrama from '@/assets/images/cpeyfp_organigrama.png'

const modalesInicio = ref({
  antecedentes: false,
  funcionalidad: false,
  finalidad: false,
  organigrama: false
})

const abrirModalInicio = (modal) => {
  modalesInicio.value[modal] = true
}
</script>

<template>
  <div class="py-8">
    <div id="sobre-nosotros"></div>
    <v-container>
      <div class="d-flex ga-3 justify-center flex-wrap">
        <v-btn class="font-weight-bold" color="primary" size="large" variant="elevated" @click="abrirModalInicio('antecedentes')">
          <v-icon icon="mdi-book-open-variant" class="mr-2"></v-icon>
          Antecedentes
        </v-btn>
        <v-btn class="font-weight-bold" color="primary" size="large" variant="elevated" @click="abrirModalInicio('funcionalidad')">
          <v-icon icon="mdi-school" class="mr-2"></v-icon>
          Funcionalidad
        </v-btn>
        <v-btn class="font-weight-bold" color="primary" size="large" variant="elevated" @click="abrirModalInicio('finalidad')">
          <v-icon icon="mdi-account-hard-hat" class="mr-2"></v-icon>
          Finalidad
        </v-btn>
        <v-btn class="font-weight-bold" color="primary" size="large" variant="elevated" @click="abrirModalInicio('organigrama')">
          <v-icon icon="mdi-sitemap" class="mr-2"></v-icon>
          Organigrama
        </v-btn>
      </div>
    </v-container>
  </div>

  <v-dialog v-model="modalesInicio.antecedentes" max-width="600">
    <v-card>
      <v-card-title class="d-flex align-center bg-primary text-white">
        <v-icon icon="mdi-book-open-variant" class="mr-2"></v-icon>
        <span>Antecedentes</span>
        <v-spacer></v-spacer>
        <v-btn icon size="small" variant="text" @click="modalesInicio.antecedentes = false">
          <v-icon icon="mdi-close"></v-icon>
        </v-btn>
      </v-card-title>
      <v-card-text class="pa-6">
        <p class="text-body-1">
          El <span class="font-weight-bold">Centro de Proyectos Especiales y Formación Permanente (CPEyFP)</span>, inicia sus actividades
          académicas en la gestión 2016, dando cumplimiento al modelo académico vigente de la
          <span class="font-weight-bold">Universidad Amazónica de Pando (UAP)</span>, además en reemplazo de la Unidad de Programas
          Especiales, con un principal objetivo de:
        </p>
        <p class="text-body-1 mt-4">
          Establecer cursos de formación técnica además de capacitación permanente dentro de la superior casa de estudios, dirigidos a la
          comunidad universitaria, así también, a la población en general, además de buscar convenios y alianzas estratégicas con
          instituciones públicas y privadas en cooperación específica al centro.
        </p>
      </v-card-text>
    </v-card>
  </v-dialog>

  <v-dialog v-model="modalesInicio.funcionalidad" max-width="600">
    <v-card>
      <v-card-title class="d-flex align-center bg-primary text-white">
        <v-icon icon="mdi-school" class="mr-2"></v-icon>
        <span>Funcionalidad</span>
        <v-spacer></v-spacer>
        <v-btn icon size="small" variant="text" @click="modalesInicio.funcionalidad = false">
          <v-icon icon="mdi-close"></v-icon>
        </v-btn>
      </v-card-title>
      <v-card-text class="pa-6">
        <p class="text-body-1">
          El <span class="font-weight-bold">Centro de Proyectos Especiales y Formación Permanente (CPEyFP)</span> funciona como una unidad
          de la Dirección Académica bajo la dependencia del Vicerrectorado
        </p>
        <div class="text-body-1 mt-4">
          <p class="mb-2">El <span class="font-weight-bold">CPEyFP</span> desarrolla y ejecuta tres proyectos principales:</p>
          <ul class="mx-4">
            <li>Subunidad de Admisión y Permanencia Estudiantil (Gabinete Psicopedagógico)</li>
            <li>Subunidad de la Escuela Técnica</li>
            <li>Subunidad Programa Especial de Titulación (PET).</li>
          </ul>
        </div>
      </v-card-text>
    </v-card>
  </v-dialog>

  <v-dialog v-model="modalesInicio.finalidad" max-width="600">
    <v-card>
      <v-card-title class="d-flex align-center bg-primary text-white">
        <v-icon icon="mdi-account-hard-hat" class="mr-2"></v-icon>
        <span>Finalidad</span>
        <v-spacer></v-spacer>
        <v-btn icon size="small" variant="text" @click="modalesInicio.finalidad = false">
          <v-icon icon="mdi-close"></v-icon>
        </v-btn>
      </v-card-title>
      <v-card-text class="pa-6">
        <p class="text-body-1">
          La finalidad de <span class="font-weight-bold">Centro de Proyectos Especiales y Formación Permanente (CPEyFP) </span>es:
        </p>

        <p class="text-body-1 mt-4">
          Brindar servicios a partir de proyectos de formación permanente y técnica respondiendo a las necesidades locales, además de
          favorecer el mejoramiento académico, para la mejora de la calidad de vida de la comunidad universitaria y población en general.
        </p>
      </v-card-text>
    </v-card>
  </v-dialog>

  <v-dialog v-model="modalesInicio.organigrama" max-width="900">
    <v-card>
      <v-card-title class="d-flex align-center bg-primary text-white">
        <v-icon icon="mdi-sitemap" class="mr-2"></v-icon>
        <span>Organigrama</span>
        <v-spacer></v-spacer>
        <v-btn icon size="small" variant="text" @click="modalesInicio.organigrama = false">
          <v-icon icon="mdi-close"></v-icon>
        </v-btn>
      </v-card-title>
      <v-card-text class="pa-6">
        <v-img :src="organigrama" max-width="100%" contain></v-img>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<style lang="scss" scoped>
</style>
