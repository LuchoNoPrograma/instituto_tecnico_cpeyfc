#!/bin/bash

# ✨ Script para agregar repositorios específicos SOLO en servicios ✨

# Colores bonitos 🌈
PINK='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
HEART='\033[1;31m💖\033[0m'
UNICORN='\033[1;35m🦄\033[0m'
SPARKLES='\033[1;33m✨\033[0m'
MAGIC='\033[1;36m🪄\033[0m'
NC='\033[0m'

# Ruta base a tu dominio
BASE_DIR="/home/nini/IdeaProjects/cpeyfc/src/main/java/uap/edu/bo/cpeyfc/domain"

echo -e "${PINK}${MAGIC} Agregando repositorios específicos en servicios ${MAGIC}${NC}"
echo -e "${CYAN}${HEART} Trabajando en: $BASE_DIR ${HEART}${NC}"
echo -e "${YELLOW}⚠️  Solo modificando servicios, repositorios intactos${NC}"
echo ""

# Función para convertir snake_case a PascalCase
snake_to_pascal() {
    echo "$1" | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^./\U&/'
}

# Función para convertir PascalCase a camelCase
pascal_to_camel() {
    echo "$1" | sed 's/^./\l&/'
}

# Contadores
total=0
actualizados=0

echo -e "${YELLOW}${SPARKLES} Procesando servicios...${NC}"
echo ""

# Buscar todos los archivos *Service.java en subdirectorios
find "$BASE_DIR" -mindepth 2 -type f -name "*Service.java" | while read service_file; do
    # Extraer información del archivo
    dir=$(basename $(dirname "$service_file"))
    service_name=$(basename "$service_file" .java)
    entity_name=$(snake_to_pascal "$dir")
    repo_class_name="${entity_name}Repository"
    repo_field_name=$(pascal_to_camel "$repo_class_name")

    echo -e "${CYAN}🔧 Procesando: ${YELLOW}$service_name${NC}"
    echo -e "${CYAN}   Directorio: ${YELLOW}$dir${NC}"
    echo -e "${CYAN}   Entidad: ${YELLOW}$entity_name${NC}"
    echo -e "${CYAN}   Repositorio a agregar: ${YELLOW}$repo_class_name $repo_field_name${NC}"

    # Verificar si ya tiene el repositorio específico
    if grep -q "$repo_class_name" "$service_file"; then
        echo -e "${GREEN}   ✅ Ya tiene el repositorio específico${NC}"
    else
        echo -e "${YELLOW}   🔄 Agregando repositorio específico...${NC}"

        # Hacer backup
        cp "$service_file" "$service_file.backup"

        # Leer el contenido actual
        temp_file=$(mktemp)

        # Procesar el archivo línea por línea
        while IFS= read -r line; do
            echo "$line" >> "$temp_file"

            # Si encuentra la línea del RepositorioGenericoCrud, agregar el nuevo repositorio después
            if echo "$line" | grep -q "private final RepositorioGenericoCrud"; then
                echo "    private final $repo_class_name $repo_field_name;" >> "$temp_file"
            fi
        done < "$service_file"

        # Reemplazar el archivo original
        mv "$temp_file" "$service_file"

        echo -e "${GREEN}   ${HEART} Repositorio específico agregado ${SPARKLES}${NC}"
        actualizados=$((actualizados + 1))
    fi

    echo ""
    total=$((total + 1))
done

echo -e "${PINK}${SPARKLES}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${SPARKLES}${NC}"
echo -e "${CYAN}${HEART} ¡Actualización completada mi amor! ${HEART}${NC}"
echo -e "${GREEN}${UNICORN} Servicios procesados: $total ${UNICORN}${NC}"
echo -e "${YELLOW}${MAGIC} Servicios actualizados: $actualizados ${MAGIC}${NC}"
echo -e "${PINK}${SPARKLES}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${SPARKLES}${NC}"
echo ""
echo -e "${CYAN}💡 Resultado esperado en cada servicio:${NC}"
echo -e "${YELLOW}   private final RepositorioGenericoCrud repositorio;${NC}"
echo -e "${YELLOW}   private final TgrMonografiaRepository tgrMonografiaRepository;${NC}"
echo ""
echo -e "${GREEN}✅ Repositorios no modificados (como pediste)${NC}"
echo ""
echo -e "${CYAN}💡 Ahora optimiza imports en IntelliJ:${NC}"
echo -e "${YELLOW}   Ctrl + Alt + O en todo el proyecto${NC}"
echo ""
echo -e "${PINK}🧹 Para limpiar backups cuando esté todo bien:${NC}"
echo -e "${YELLOW}   find \"$BASE_DIR\" -name \"*.backup\" -delete${NC}"