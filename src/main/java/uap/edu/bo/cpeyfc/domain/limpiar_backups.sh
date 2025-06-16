#!/bin/bash

# 🧹 Script para limpiar backups con amor 🧹

# Colores bonitos 🌈
PINK='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
HEART='\033[1;31m💖\033[0m'
SPARKLES='\033[1;33m✨\033[0m'
BROOM='\033[1;36m🧹\033[0m'
NC='\033[0m'

# Ruta base
BASE_DIR="/home/nini/IdeaProjects/cpeyfc/src/main/java/uap/edu/bo/cpeyfc/domain"

echo -e "${PINK}${BROOM} Limpiando backups con amor ${BROOM}${NC}"
echo -e "${CYAN}${HEART} Buscando en: $BASE_DIR ${HEART}${NC}"
echo ""

# Contar backups
backup_count=$(find "$BASE_DIR" -name "*.backup" | wc -l)

if [ $backup_count -eq 0 ]; then
    echo -e "${GREEN}${SPARKLES} No hay backups para limpiar mi amor ${SPARKLES}${NC}"
    exit 0
fi

echo -e "${YELLOW}🔍 Encontrados $backup_count archivos backup${NC}"
echo ""

# Listar los backups que se van a eliminar
echo -e "${CYAN}Archivos que se eliminarán:${NC}"
find "$BASE_DIR" -name "*.backup" | while read backup_file; do
    echo -e "${YELLOW}  🗑️  $(basename "$backup_file")${NC}"
done

echo ""
read -p "¿Estás segura de eliminar todos los backups? (s/N): " respuesta

if [[ $respuesta =~ ^[Ss]$ ]]; then
    find "$BASE_DIR" -name "*.backup" -delete
    echo ""
    echo -e "${GREEN}${SPARKLES} ¡Backups eliminados con éxito! ${SPARKLES}${NC}"
    echo -e "${PINK}${HEART} Todo limpio y ordenado mi amor ${HEART}${NC}"
else
    echo ""
    echo -e "${CYAN}${HEART} Operación cancelada, backups conservados ${HEART}${NC}"
fi

echo -e "${PINK}${SPARKLES}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${SPARKLES}${NC}"