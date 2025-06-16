#!/usr/bin/env bash
set -euo pipefail

# ╭──────────────────────────────────────────╮
# │ Script: restaurar_bd.sh                 │
# │ Objetivo: Restaura la BD desde backup   │
# ╰──────────────────────────────────────────╯

# ── RUTA AL PROPERTIES Y CARPETA RESOURCES ────────────────────────────
PROPERTIES="$(dirname "$0")/../src/main/resources/application-dev.properties"
PROPS_DIR="$(dirname "$PROPERTIES")"

if [[ ! -f "$PROPERTIES" ]]; then
  echo "❌ No se encontró ${PROPERTIES}. Ajusta la ruta en el script."
  exit 1
fi

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

# ── EXTRAEMOS CONFIGS ─────────────────────────────────────────────────
URL=$(getProperty 'spring.datasource.url')
USER=$(getProperty 'spring.datasource.username')
PASS=$(getProperty 'spring.datasource.password')
BACKUP_DIR_PROP=$(getProperty 'config.ruta.backups')

# ── DEFINIMOS LA CARPETA DE BACKUPS ────────────────────────────────────
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

# ── CREAMOS CARPETA DE BACKUPS SI NO EXISTE ───────────────────────────
if [[ ! -d "$BACKUP_DIR" ]]; then
  echo "📁 Carpeta de backups no encontrada. Creando en:"
  echo "   $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
fi

# ── PARSEAMOS LA URL JDBC ─────────────────────────────────────────────
# jdbc:postgresql://host:puerto/BD_NAME
stripped=${URL#jdbc:postgresql://}
host_and_rest=${stripped%%/*}
DB_NAME=${stripped#*/}
HOST=${host_and_rest%%:*}
PORT=${host_and_rest#*:}

[[ "$PORT" == "$HOST" ]] && PORT=5432

# ── BUSCAMOS EL BACKUP MÁS RECIENTE ───────────────────────────────────
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/dump-"$DB_NAME"-* 2>/dev/null | head -n 1 || true)

if [[ -z "$LATEST_BACKUP" ]]; then
  echo "❌ No se encontró ningún backup para '$DB_NAME' en:"
  echo "   $BACKUP_DIR"
  echo "   Por favor, genera al menos un backup antes de restaurar."
  exit 1
fi

echo "🔍 Backup seleccionado:"
echo "   $(basename "$LATEST_BACKUP")"

# ── ELIMINAR Y CREAR BASE DE DATOS ────────────────────────────────────
export PGPASSWORD="$PASS"

echo ""
echo "🧹 Eliminando BD '$DB_NAME'..."
dropdb -h "$HOST" -p "$PORT" -U "$USER" "$DB_NAME" || echo "ℹ️ No existía '$DB_NAME', seguimos..."

echo "🆕 Creando BD '$DB_NAME'..."
createdb -h "$HOST" -p "$PORT" -U "$USER" "$DB_NAME"

# ── RESTAURACIÓN SEGÚN TIPO DE BACKUP ─────────────────────────────────
echo ""
echo "🔄 Iniciando restauración..."

if file "$LATEST_BACKUP" | grep -qi 'PostgreSQL custom database dump'; then
  echo "🛠 Restaurando (formato custom/binario)..."
  pg_restore --no-owner --role="$USER" -U "$USER" \
             -h "$HOST" -p "$PORT" -d "$DB_NAME" \
             "$LATEST_BACKUP"
else
  echo "📜 Restaurando (SQL texto plano)..."
  psql -U "$USER" -h "$HOST" -p "$PORT" \
       -d "$DB_NAME" -f "$LATEST_BACKUP"
fi

echo ""
echo "✅ ¡Restauración completada con éxito! 🎉"
