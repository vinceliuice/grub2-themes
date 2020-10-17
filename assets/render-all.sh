#!/bin/bash

COLORS=("color" "white")
TYPES=("icons" "select")
RESOLUTIONS=("1080p" "2k" "4k")

for COLOR in "${COLORS[@]}"; do
  for TYPE in "${TYPES[@]}"; do
    for RESOLUTION in "${RESOLUTIONS[@]}"; do
      echo "./render-assets.sh \"$COLOR\" \"$TYPE\" \"$RESOLUTION\": "
      ./render-assets.sh "$COLOR" "$TYPE" "$RESOLUTION"
    done
  done
done
