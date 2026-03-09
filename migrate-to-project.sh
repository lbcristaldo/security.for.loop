#!/bin/bash
# Script para migrar archivos generados al proyecto real

PROJECT_DIR="$HOME/projects/security.for.loop"
TEMP_DIR="/tmp/estructura-proyecto"

echo "Migrando archivos a $PROJECT_DIR"

mkdir -p "$PROJECT_DIR"

copy_with_structure() {
  local src="$1"
  local dest="$2"

  if [ -f "$src" ]; then
    rel_path="${src#$TEMP_DIR/}"
    target_dir="$dest/$(dirname "$rel_path")"
    mkdir -p "$target_dir"
    cp "$src" "$dest/$rel_path"
    echo "  Copiado: $rel_path"
  fi
}

export -f copy_with_structure

find "$TEMP_DIR" -type f -not -name "migrate-to-project.sh" | while read -r file; do
  copy_with_structure "$file" "$PROJECT_DIR"
done

echo ""
echo "Migración completada!"
echo "Los archivos están en: $PROJECT_DIR"
echo ""
echo "Para ver la estructura:"
echo "  cd $PROJECT_DIR && tree -L 3"
