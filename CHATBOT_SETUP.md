# Configuración del Chatbot de IA con Google Gemini

Este documento explica cómo configurar y usar el chatbot de IA integrado en la página de inicio del Instituto Técnico CPEyFC.

## ¿Qué es el Chatbot?

El chatbot es un asistente virtual basado en **Google Gemini AI** que ayuda a los visitantes de la página web a obtener información sobre:

- Programas académicos ofertados
- Modalidades de estudio
- Costos de matrícula y colegiaturas
- Fechas de inscripción
- Requisitos de admisión
- Información general del instituto

## Requisitos

1. **Google AI API Key** (Gemini)
2. **Cuenta de Google** (preferentemente educativa para mayor cuota gratuita)

## Paso 1: Obtener la API Key de Google Gemini

### Opción A: Con cuenta de estudiante (RECOMENDADO)

1. Inicia sesión en Google con tu **correo institucional de estudiante** (ej: `estudiante@universidad.edu`)
2. Visita: [Google AI Studio](https://aistudio.google.com/apikey)
3. Haz clic en **"Get API Key"** o **"Create API Key"**
4. Copia la API key generada

### Opción B: Con cuenta personal de Google

1. Inicia sesión con tu cuenta personal de Google
2. Visita: [Google AI Studio](https://aistudio.google.com/apikey)
3. Haz clic en **"Get API Key"** o **"Create API Key"**
4. Copia la API key generada

**Nota:** Las cuentas educativas suelen tener límites más generosos.

## Paso 2: Configurar la API Key en el Backend

Hay dos formas de configurar la API key:

### Opción A: Variable de Entorno (RECOMENDADO para producción)

En tu sistema, configura la variable de entorno:

**Linux/Mac:**
```bash
export GEMINI_API_KEY="tu_api_key_aqui"
```

**Windows (CMD):**
```cmd
set GEMINI_API_KEY=tu_api_key_aqui
```

**Windows (PowerShell):**
```powershell
$env:GEMINI_API_KEY="tu_api_key_aqui"
```

### Opción B: Configuración Directa (para desarrollo local)

Edita el archivo `src/main/resources/application-dev.properties`:

```properties
gemini.api.key=tu_api_key_aqui
gemini.api.model=gemini-1.5-flash
```

## Paso 3: Ejecutar la Aplicación

### Backend (Spring Boot):

```bash
# Con perfil dev
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# O si configuraste la variable de entorno
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### Frontend (Vue 3):

```bash
cd src/webapp
npm install
npm run dev
```

## Paso 4: Probar el Chatbot

1. Abre tu navegador en `http://localhost:3000`
2. Verás un botón flotante con un icono de robot en la esquina inferior derecha
3. Haz clic en el botón para abrir el chatbot
4. Escribe preguntas como:
   - "¿Qué programas técnicos ofrecen?"
   - "¿Cuánto cuesta la matrícula?"
   - "¿Cuáles son las fechas de inscripción?"
   - "¿Qué modalidades de estudio tienen?"

## Límites y Cuotas Gratuitas

Google Gemini API ofrece un tier gratuito con los siguientes límites:

- **Modelo gemini-1.5-flash:**
  - 15 peticiones por minuto (RPM)
  - 1 millón de tokens por día
  - 1,500 peticiones por día

Con una cuenta educativa estos límites pueden ser mayores.

## Solución de Problemas

### Error: "API key de Gemini no configurada"

**Causa:** La API key no está configurada correctamente.

**Solución:**
1. Verifica que configuraste la variable `GEMINI_API_KEY` o el archivo `application-dev.properties`
2. Reinicia la aplicación backend

### Error: "Error al comunicarse con Gemini"

**Causas posibles:**
1. API key inválida
2. Límite de cuota excedido
3. Problemas de conectividad

**Soluciones:**
1. Verifica que la API key sea correcta en [Google AI Studio](https://aistudio.google.com/apikey)
2. Revisa tus límites de uso en Google AI Studio
3. Verifica tu conexión a internet

### El chatbot no aparece en la página

**Causa:** El frontend no se compiló correctamente.

**Solución:**
1. Verifica que el frontend esté corriendo: `npm run dev` en `src/webapp`
2. Revisa la consola del navegador (F12) en busca de errores

## Arquitectura del Chatbot

### Backend (Spring Boot):

- **`ChatbotApi.java`**: Controlador REST que expone el endpoint `/api/publico/chatbot`
- **`ChatbotService.java`**: Servicio que obtiene información de programas desde la BD
- **`GeminiService.java`**: Servicio que se comunica con la API de Gemini
- **`ChatbotRequest.java` / `ChatbotResponse.java`**: DTOs para peticiones y respuestas

### Frontend (Vue 3):

- **`ChatbotIA.vue`**: Componente Vue con la interfaz del chat
- Integrado en `Inicio.vue` (página pública)

### Base de Datos:

El chatbot consulta la vista de programas ofertados:
```sql
SELECT * FROM ins_grupo WHERE estado = 'ACTIVO'
```

## Costos

**Google Gemini API es GRATUITA** dentro de los límites mencionados. No necesitas configurar ningún método de pago para el tier gratuito.

## Privacidad

- El chatbot **NO almacena** las conversaciones en la base de datos
- Las conversaciones se envían a Google Gemini API para procesamiento
- No se recopila información personal del usuario
- Lee los [Términos de Servicio de Google AI](https://ai.google.dev/terms) para más información

## Personalización

### Cambiar el modelo de IA:

En `application-dev.properties`:
```properties
gemini.api.model=gemini-1.5-pro  # Modelo más potente pero con menor cuota gratuita
```

Modelos disponibles:
- `gemini-1.5-flash` (recomendado, rápido y eficiente)
- `gemini-1.5-pro` (más potente pero con menor cuota gratuita)
- `gemini-1.0-pro` (versión anterior)

### Personalizar el prompt del chatbot:

Edita el método `construirPrompt()` en `GeminiService.java` para modificar:
- El tono de las respuestas
- Las instrucciones del asistente
- El contexto proporcionado

## Soporte

Si tienes problemas con la configuración:

1. Revisa los logs del backend en la consola
2. Revisa la consola del navegador (F12)
3. Consulta la documentación oficial de [Google AI](https://ai.google.dev/docs)

## Enlaces Útiles

- [Google AI Studio](https://aistudio.google.com/)
- [Documentación de Gemini API](https://ai.google.dev/docs)
- [Límites y cuotas](https://ai.google.dev/pricing)
- [Términos de servicio](https://ai.google.dev/terms)
