import { createVuetify } from 'vuetify'
import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'
import { es } from 'vuetify/locale'

// Paleta de colores CPEYFC
const colors = {
  // Colores principales institucionales
  primary: '#2f428c',      // Azul académico profesional
  secondary: '#FF5252',    // Rojo de acento/error
  accent: '#00BCD4',       // Cyan para destacados

  // Paleta extendida
  success: '#4CAF50',      // Verde éxito
  warning: '#FF9800',      // Naranja advertencia
  info: '#2196F3',         // Azul información
  error: '#FF5252',        // Rojo error

  // Colores de superficie
  surface: '#FFFFFF',
  background: '#FAFAFA',
  'surface-variant': '#F5F5F5',

  // Colores de texto
  'on-primary': '#FFFFFF',
  'on-secondary': '#FFFFFF',
  'on-surface': '#212121',
  'on-background': '#212121',

  // Colores académicos específicos
  academic: '#1565C0',     // Azul académico oscuro
  research: '#7B1FA2',     // Púrpura investigación
  student: '#2E7D32',      // Verde estudiantil
  admin: '#D32F2F',        // Rojo administrativo
}

export default createVuetify({
  // Idioma español
  locale: {
    locale: 'es',
    messages: { es }
  },

  // Sistema de themes
  theme: {
    defaultTheme: 'cpeyfc',
    themes: {
      // Theme principal CPEYFC
      cpeyfc: {
        dark: false,
        colors: {
          ...colors,
          // Gradientes personalizados (para CSS custom properties)
          'gradient-primary': 'linear-gradient(45deg, #1976D2 0%, #1565C0 100%)',
          'gradient-hero': 'linear-gradient(135deg, #1976D2 0%, #1565C0 50%, #0D47A1 100%)',
        }
      },

      // Theme oscuro opcional
      cpeyfc_dark: {
        dark: true,
        colors: {
          primary: '#64B5F6',
          secondary: '#FF8A80',
          accent: '#4DD0E1',
          success: '#81C784',
          warning: '#FFB74D',
          info: '#64B5F6',
          error: '#FF8A80',
          surface: '#121212',
          background: '#000000',
          'surface-variant': '#1E1E1E',
          'on-primary': '#000000',
          'on-secondary': '#000000',
          'on-surface': '#FFFFFF',
          'on-background': '#FFFFFF',
        }
      },

      // Theme para público general (más colorido)
      cpeyfc_public: {
        dark: false,
        colors: {
          ...colors,
          primary: '#1976D2',
          secondary: '#00BCD4',  // Cyan más amigable para público
          accent: '#FF9800',     // Naranja vibrante
        }
      }
    }
  },

  // Configuraciones por defecto de componentes
  defaults: {
    // Botones
    VBtn: {
      color: 'primary',
      variant: 'flat',
      style: 'text-transform: none; letter-spacing: 0.5px;'
    },

    VDataTable: {

    },

    // Campos de texto
    VTextField: {
      variant: 'outlined',
      density: 'comfortable',
      color: 'primary'
    },

    // Selectores
    VSelect: {
      variant: 'outlined',
      density: 'comfortable',
      color: 'primary'
    },

    // Cards
    VCard: {
      elevation: 2,
      class: 'rounded-lg'
    },

    // App Bar
    VAppBar: {
      elevation: 2
    },

    // Navigation Drawer
    VNavigationDrawer: {
      elevation: 2
    },

    VIcon: {
      size: 24
    }
  },

  // Sistema de display (responsive breakpoints)
  display: {
    mobileBreakpoint: 'sm',
    thresholds: {
      xs: 0,
      sm: 600,
      md: 960,
      lg: 1280,
      xl: 1920,
    },
  }
})
