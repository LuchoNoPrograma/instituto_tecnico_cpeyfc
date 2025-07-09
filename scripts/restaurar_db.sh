#!/usr/bin/env bash
set -euo pipefail

# ╭──────────────────────────────────────────╮
# │ Script: restaurar_bd.sh                 │
# │ Objetivo: Restaura la BD desde backup   │
# ╰──────────────────────────────────────────╯

echo "🚀 ===== INICIANDO RESTAURACIÓN DE BASE DE DATOS ===== 🚀"
echo ""

# ── RUTA AL PROPERTIES Y CARPETA RESOURCES ────────────────────────────
PROPERTIES="$(dirname "$0")/../src/main/resources/application-dev.properties"
PROPS_DIR="$(dirname "$PROPERTIES")"

echo "📂 Verificando archivos de configuración..."
if [[ ! -f "$PROPERTIES" ]]; then
  echo "❌ No se encontró ${PROPERTIES}. Ajusta la ruta en el script."
  exit 1
fi
echo "✅ Archivo de propiedades encontrado: $(basename "$PROPERTIES")"

# ── FUNCIÓN PARA EXTRAER PROPIEDADES ──────────────────────────────────
getProperty() {
  local raw
  raw=$(grep -E "^$1=" "$PROPERTIES" | cut -d'=' -f2- | tr -d '\r')
  if [[ "$raw" =~ \$\{[^:]+:(.*)\} ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo "$raw"
  fi
}

echo ""
echo "🔧 Extrayendo configuración de la base de datos..."

# ── EXTRAEMOS CONFIGS ─────────────────────────────────────────────────
URL=$(getProperty 'spring.datasource.url')
USER=$(getProperty 'spring.datasource.username')
PASS=$(getProperty 'spring.datasource.password')
BACKUP_DIR_PROP=$(getProperty 'config.ruta.backups')

echo "✅ Usuario: $USER"
echo "✅ URL: $URL"

# ── DEFINIMOS LA CARPETA DE BACKUPS ────────────────────────────────────
echo ""
echo "📁 Configurando directorio de backups..."

if [[ -z "$BACKUP_DIR_PROP" ]]; then
  BACKUP_DIR="$PROPS_DIR/backups"
else
  # ruta absoluta o relativa dentro de resources
  if [[ "$BACKUP_DIR_PROP" = /* ]]; then
    BACKUP_DIR="$BACKUP_DIR_PROP"
  else
    BACKUP_DIR="$PROPS_DIR/$BACKUP_DIR_PROP"
  fi
fi

echo "📂 Directorio de backups: $BACKUP_DIR"

# ── CREAMOS CARPETA DE BACKUPS SI NO EXISTE ───────────────────────────
if [[ ! -d "$BACKUP_DIR" ]]; then
  echo "🏗️ Carpeta de backups no encontrada. Creando..."
  mkdir -p "$BACKUP_DIR"
  echo "✅ Carpeta creada exitosamente"
else
  echo "✅ Carpeta de backups ya existe"
fi

# ── PARSEAMOS LA URL JDBC ─────────────────────────────────────────────
echo ""
echo "🔍 Parseando información de conexión..."

# jdbc:postgresql://host:puerto/BD_NAME
stripped=${URL#jdbc:postgresql://}
host_and_rest=${stripped%%/*}
DB_NAME=${stripped#*/}
HOST=${host_and_rest%%:*}
PORT=${host_and_rest#*:}

[[ "$PORT" == "$HOST" ]] && PORT=5432

echo "🏠 Host: $HOST"
echo "🚪 Puerto: $PORT"
echo "🗃️ Base de datos: $DB_NAME"

# ── BUSCAMOS EL BACKUP MÁS RECIENTE ───────────────────────────────────
echo ""
echo "🔎 Buscando el backup más reciente..."

LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/dump-"$DB_NAME"-* 2>/dev/null | head -n 1 || true)

if [[ -z "$LATEST_BACKUP" ]]; then
  echo "❌ No se encontró ningún backup para '$DB_NAME' en:"
  echo "   📂 $BACKUP_DIR"
  echo "   💡 Por favor, genera al menos un backup antes de restaurar."
  exit 1
fi

echo "✅ Backup seleccionado: $(basename "$LATEST_BACKUP")"
echo "📊 Tamaño del archivo: $(ls -lh "$LATEST_BACKUP" | awk '{print $5}')"
echo "📅 Fecha de creación: $(ls -l "$LATEST_BACKUP" | awk '{print $6, $7, $8}')"

# ── VERIFICAR TIPO DE BACKUP ──────────────────────────────────────────
echo ""
echo "🔬 Analizando tipo de backup..."
BACKUP_TYPE=$(file "$LATEST_BACKUP")
echo "📋 Tipo detectado: $BACKUP_TYPE"

# ── ELIMINAR Y CREAR BASE DE DATOS ────────────────────────────────────
export PGPASSWORD="$PASS"

echo ""
echo "🗑️ Preparando base de datos..."
echo "🧹 Eliminando BD '$DB_NAME' (si existe)..."
if dropdb -h "$HOST" -p "$PORT" -U "$USER" "$DB_NAME" 2>/dev/null; then
  echo "✅ Base de datos '$DB_NAME' eliminada exitosamente"
else
  echo "ℹ️ La base de datos '$DB_NAME' no existía, continuando..."
fi

echo ""
echo "🏗️ Creando nueva base de datos '$DB_NAME'..."
if createdb -h "$HOST" -p "$PORT" -U "$USER" "$DB_NAME"; then
  echo "✅ Base de datos '$DB_NAME' creada exitosamente"
else
  echo "❌ Error al crear la base de datos '$DB_NAME'"
  exit 1
fi

# ── RESTAURACIÓN SEGÚN TIPO DE BACKUP ─────────────────────────────────
echo ""
echo "🔄 Iniciando proceso de restauración..."
echo "📁 Archivo: $(basename "$LATEST_BACKUP")"

if echo "$BACKUP_TYPE" | grep -qi 'PostgreSQL custom database dump'; then
  echo "🛠️ Formato: Backup binario/custom de PostgreSQL"
  echo ""
  echo "⚡ Ejecutando pg_restore..."
  echo "🔧 Parámetros: --no-owner --role=$USER"
  echo "🎯 Destino: $USER@$HOST:$PORT/$DB_NAME"
  echo ""

  # Ejecutar pg_restore sin verbose y capturar solo errores críticos
  if pg_restore --no-owner --role="$USER" -U "$USER" \
                -h "$HOST" -p "$PORT" -d "$DB_NAME" \
                "$LATEST_BACKUP" 2>/dev/null; then
    echo "✅ Restauración de backup binario completada exitosamente"
  else
    # Si falla, mostrar qué errores están ocurriendo
    echo "⚠️ Detectando posibles incompatibilidades de versión..."
    echo "🔄 Reintentando con tolerancia a errores..."

    # Capturar errores para mostrar los importantes
    ERROR_OUTPUT=$(pg_restore --no-owner --role="$USER" -U "$USER" \
                              -h "$HOST" -p "$PORT" -d "$DB_NAME" \
                              --exit-on-error=false \
                              "$LATEST_BACKUP" 2>&1)

    # Filtrar solo errores importantes (no los warnings de configuración)
    CRITICAL_ERRORS=$(echo "$ERROR_OUTPUT" | grep -v "transaction_timeout\|idle_session_timeout\|unrecognized configuration parameter\|warning:" | grep -i "error:")

    if [[ -z "$CRITICAL_ERRORS" ]]; then
      echo "✅ Restauración completada (algunos parámetros de compatibilidad ignorados)"
    else
      echo "❌ Error crítico durante la restauración:"
      echo ""
      echo "🚨 Errores encontrados:"
      echo "$CRITICAL_ERRORS"
      echo ""
      echo "💡 Revisa la conectividad y permisos de la base de datos"
      exit 1
    fi
  fi
else
  echo "📜 Formato: Archivo SQL de texto plano"
  echo ""
  echo "⚡ Ejecutando psql..."
  echo "🎯 Destino: $USER@$HOST:$PORT/$DB_NAME"
  echo ""

  if psql -U "$USER" -h "$HOST" -p "$PORT" \
          -d "$DB_NAME" -f "$LATEST_BACKUP"; then
    echo ""
    echo "✅ Restauración de SQL completada exitosamente"
  else
    echo ""
    echo "❌ Error durante la restauración del archivo SQL"
    echo "💡 Revisa los logs anteriores para más detalles"
    exit 1
  fi
fi

echo ""
echo "🎉 ===== RESTAURACIÓN COMPLETADA CON ÉXITO ===== 🎉"
echo "✨ La base de datos '$DB_NAME' ha sido restaurada correctamente"
echo "🕐 Proceso finalizado: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""