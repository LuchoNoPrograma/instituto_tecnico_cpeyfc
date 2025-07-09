#!/usr/bin/env bash
set -euo pipefail

# ╭──────────────────────────────────────────╮
# │ Script: generar_backup_sql.sh           │
# │ Objetivo: Crear backup SQL plano de BD  │
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
FILENAME="dump-${DB_NAME}-${TIMESTAMP}.sql"
TARGET="$BACKUP_DIR/$FILENAME"

# ── EXPORTAR CONTRASEÑA Y EJECUTAR pg_dump ────────────────────────────
export PGPASSWORD="$PASS"

echo ""
echo "📄 Generando backup SQL plano de '$DB_NAME' en:"
echo "   $TARGET"

# Opciones para SQL plano:
# --verbose: Muestra progreso detallado
# --clean: Incluye comandos DROP antes de CREATE
# --if-exists: Usa IF EXISTS en los DROP (evita errores si no existe)
# --create: Incluye comando para crear la base de datos
# --insert: Usa comandos INSERT en lugar de COPY (más compatible)
# --column-inserts: Incluye nombres de columnas en INSERT
# --disable-triggers: Desactiva triggers durante la restauración
pg_dump -U "$USER" -h "$HOST" -p "$PORT" \
  --verbose \
  --clean \
  --if-exists \
  --create \
  --insert \
  --column-inserts \
  --disable-triggers \
  "$DB_NAME" > "$TARGET"

echo ""
echo "✅ Backup SQL creado con éxito 🎉"
echo "   $(ls -lh "$TARGET" | awk '{print $5, $9}')"

# ── OPCIONAL: COMPRIMIR EL ARCHIVO SQL ────────────────────────────────
echo ""
echo "🗜️  ¿Deseas comprimir el archivo SQL? (será más pequeño)"
echo "   El archivo original se mantendrá."
echo -n "   Comprimir? [y/N]: "
read -r compress

if [[ "$compress" =~ ^[Yy] ]]; then
  echo "   Comprimiendo..."
  gzip -k "$TARGET"  # -k mantiene el original
  echo "   ✅ Comprimido: ${TARGET}.gz"
  echo "   📊 Comparación de tamaños:"
  echo "      Original: $(ls -lh "$TARGET" | awk '{print $5}')"
  echo "      Comprimido: $(ls -lh "${TARGET}.gz" | awk '{print $5}')"
fi

echo ""
echo "🎯 Para restaurar este backup, usa:"
echo "   psql -U $USER -h $HOST -p $PORT -d postgres -f \"$TARGET\""