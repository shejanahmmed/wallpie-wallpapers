#!/bin/bash

# Configuration
USERNAME="shejanahmmed"
REPO="wallpie-wallpapers"
BRANCH="main"
BASE_DIR="wallpapers"
OUTPUT="wallpapers.json"

# Start JSON array
echo "[" > "$OUTPUT"

# Find all images in the category subdirectories
# Supported extensions: jpg, jpeg, png, webp, bmp
IMAGES=$(find "$BASE_DIR" -maxdepth 2 -mindepth 2 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \))

COUNT=0
TOTAL=$(echo "$IMAGES" | wc -l)

while read -r file; do
    if [ -z "$file" ]; then continue; fi
    
    # Get filename and extension
    FILENAME=$(basename "$file")
    NAME_NO_EXT="${FILENAME%.*}"
    
    # Format Name: replace underscores/hyphens with spaces and capitalize
    # nature_sunset -> Nature Sunset
    NAME=$(echo "$NAME_NO_EXT" | sed 's/[_-]/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
    
    # Get Category: the parent folder name
    CATEGORY_RAW=$(basename "$(dirname "$file")")
    CATEGORY=$(echo "$CATEGORY_RAW" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    
    # URL construction
    # Use the relative path from the root of the repo
    URL_PATH="${file#./}"
    URL="https://raw.githubusercontent.com/$USERNAME/$REPO/$BRANCH/$URL_PATH"
    
    # Get Upload Date from Git
    UPLOAD_DATE=$(git log -1 --format=%as -- "$file")
    if [ -z "$UPLOAD_DATE" ]; then
        UPLOAD_DATE=$(date +%Y-%m-%d)
    fi

    # Add to JSON
    echo "  {" >> "$OUTPUT"
    echo "    \"name\": \"$NAME\"," >> "$OUTPUT"
    echo "    \"category\": \"$CATEGORY\"," >> "$OUTPUT"
    echo "    \"url\": \"$URL\"," >> "$OUTPUT"
    echo "    \"uploadDate\": \"$UPLOAD_DATE\"" >> "$OUTPUT"
    
    COUNT=$((COUNT + 1))
    
    # Add comma if not the last item
    if [ "$COUNT" -lt "$TOTAL" ]; then
        echo "  }," >> "$OUTPUT"
    else
        echo "  }" >> "$OUTPUT"
    fi
done <<< "$IMAGES"

# End JSON array
echo "]" >> "$OUTPUT"

echo "Successfully generated $OUTPUT with $COUNT wallpapers."
