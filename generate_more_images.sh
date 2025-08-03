#!/bin/bash

# Script para generar más imágenes de prueba arquitectónicas
# Uso: ./generate_more_images.sh [nombre_proyecto]

PROJECT_NAME=${1:-"proyecto_$(date +%s)"}
OUTPUT_DIR="tmp/test_images"

echo "🎨 Generando imágenes para: $PROJECT_NAME"

# Crear directorio si no existe
mkdir -p "$OUTPUT_DIR"

# Paletas de colores arquitectónicos
PALETTES=(
    "#1E3A8A-#DBEAFE"  # Azul
    "#059669-#A7F3D0"  # Verde
    "#DC2626-#FEE2E2"  # Rojo
    "#D97706-#FEF3C7"  # Amarillo/Dorado
    "#374151-#F3F4F6"  # Gris
    "#7C2D12-#FED7AA"  # Naranja
    "#581C87-#F3E8FF"  # Púrpura
    "#164E63-#CFFAFE"  # Cian
)

# Seleccionar paleta aleatoria
PALETTE=${PALETTES[$RANDOM % ${#PALETTES[@]}]}

echo "📐 Usando paleta de colores: $PALETTE"

# Generar 3 imágenes con diferentes efectos
cd "$OUTPUT_DIR"

convert -size 800x600 gradient:"$PALETTE" -swirl 30 -blur 1x1 "${PROJECT_NAME}_1.jpg"
echo "✅ Generada: ${PROJECT_NAME}_1.jpg"

convert -size 800x600 gradient:"$PALETTE" -wave 8x80 -implode 0.1 "${PROJECT_NAME}_2.jpg"
echo "✅ Generada: ${PROJECT_NAME}_2.jpg"

convert -size 800x600 gradient:"$PALETTE" -distort wave '10x60 0,30' -blur 0.5x0.5 "${PROJECT_NAME}_3.jpg"
echo "✅ Generada: ${PROJECT_NAME}_3.jpg"

echo "🎉 ¡Completado! 3 imágenes generadas para '$PROJECT_NAME'"
echo "📁 Ubicación: $OUTPUT_DIR"
ls -la ${PROJECT_NAME}_*.jpg
