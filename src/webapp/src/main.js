/**
 * main.js
 *
 * Bootstraps Vuetify and other plugins then mounts the App`
 */

// Plugins
import { registerPlugins } from '@/plugins'
import { AgGridVue } from "ag-grid-vue3";

// Components
import App from './App.vue'

// Composables
import { createApp } from 'vue'

// Styles
import 'unfonts.css'
import {AllCommunityModule, ModuleRegistry} from 'ag-grid-community';
ModuleRegistry.registerModules([AllCommunityModule]);

const app = createApp(App)
app.component('AgGridVue', AgGridVue)

registerPlugins(app)

app.mount('#app')
