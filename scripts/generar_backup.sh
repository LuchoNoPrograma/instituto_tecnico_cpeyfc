#!/usr/bin/env bash
set -euo pipefail

# ╭──────────────────────────────────────────╮
# │ Script: generar_backup.sh               │
# │ Objetivo: Crear backup binario de BD    │
# ╰──────────────────────────────────────────╯

# ── RUTA AL PROPERTIES Y RECURSOS ────────────────────────────────────
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

# ── EXTRAER CONFIGS ───────────────────────────────────────────────────
URL=$(getProperty 'spring.datasource.url')
USER=$(getProperty 'spring.datasource.username')
PASS=$(getProperty 'spring.datasource.password')
BACKUP_DIR_PROP=$(getProperty 'config.ruta.backups')

# ── DEFINIR Y CREAR CARPETA DE BACKUPS ────────────────────────────────
if [[ -z "$BACKUP_DIR_PROP" ]]; then
  BACKUP_DIR="$PROPS_DIR/backups"
else
  if [[ "$BACKUP_DIR_PROP" = /* ]]; then
    BACKUP_DIR="$BACKUP_DIR_PROP"
  else
    BACKUP_DIR="$PROPS_DIR/$BACKUP_DIR_PROP"
  fi
fi

if [[ ! -d "$BACKUP_DIR" ]]; then
  echo "📁 No existe carpeta de backups. Creando:"
  echo "   $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
fi

# ── PARSEAR URL JDBC PARA OBTENER HOST, PUERTO Y NOMBRE BD ────────────
# Formato esperado: jdbc:postgresql://host:puerto/BD_NAME
stripped=${URL#jdbc:postgresql://}
host_and_rest=${stripped%%/*}
DB_NAME=${stripped#*/}
HOST=${host_and_rest%%:*}
PORT=${host_and_rest#*:}
[[ "$PORT" == "$HOST" ]] && PORT=5432

# ── PREPARAR NOMBRE DE ARCHIVO CON TIMESTAMP ──────────────────────────
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="dump-${DB_NAME}-${TIMESTAMP}.backup"
TARGET="$BACKUP_DIR/$FILENAME"

# ── EXPORTAR CONTRASEÑA Y EJECUTAR pg_dump ────────────────────────────
export PGPASSWORD="$PASS"

echo ""
echo "💾 Generando backup binario de '$DB_NAME' en:"
echo "   $TARGET"
pg_dump -U "$USER" -h "$HOST" -p "$PORT" -F c -f "$TARGET" "$DB_NAME"

echo ""
echo "✅ Backup creado con éxito 🎉"
echo "   $(ls -lh "$TARGET" | awk '{print $5, $9}')"
