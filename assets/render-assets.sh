#!/bin/bash

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"

if [[ "$1" == "color" ]]; then
  cd "assets-color" || exit 1
elif [[ "$1" == "white" ]]; then
  cd "assets-white" || exit 1
else
  echo "Please use either 'color' or 'white'"
  exit 1
fi

if [[ "$2" == "icons" ]]; then
  EXPORT_TYPE="icons"
  INDEX="../logos.txt"
  SRC_FILE="../logos-$1.svg"
elif [[ "$2" == "select" ]]; then
  EXPORT_TYPE="select"
  INDEX="../select.txt"
  SRC_FILE="../select.svg"
else
  echo "Please use either 'icons' or 'select'"
  exit 1
fi

if [[ "$3" == "1080p" ]]; then
  ASSETS_DIR="$EXPORT_TYPE-1080p"
  EXPORT_DPI="96"
elif [[ "$3" == "2k" ]] || [[ "$3" == "2K" ]]; then
  ASSETS_DIR="$EXPORT_TYPE-2k"
  EXPORT_DPI="144"
elif [[ "$3" == "4k" ]] || [[ "$3" == "4K" ]]; then
  ASSETS_DIR="$EXPORT_TYPE-4k"
  EXPORT_DPI="192"
else
  echo "Please use either '1080p', '2k' or '4k'"
  exit 1
fi

install -d "$ASSETS_DIR"

while read -r i; do
  if [[ -f "$ASSETS_DIR/$i.png" ]]; then
    echo "$ASSETS_DIR/$i.png exists"
  elif [[ "$i" == "" ]]; then
    continue
  else
    echo -e "\nRendering $ASSETS_DIR/$i.png"
    $INKSCAPE "--export-id=$i" \
              "--export-dpi=$EXPORT_DPI" \
              "--export-id-only" \
              "--export-filename=$ASSETS_DIR/$i.png" "$SRC_FILE" >/dev/null
    #$OPTIPNG -o7 --quiet "$ASSETS_DIR/$i.png"
  fi
done < "$INDEX"

if [[ "$EXPORT_TYPE" == "icons" ]]; then
  cd $ASSETS_DIR || exit 1
  cp -a archlinux.png arch.png
  cp -a gnu-linux.png linux.png
  cp -a gnu-linux.png unknown.png
  cp -a gnu-linux.png lfs.png
  cp -a manjaro.png Manjaro.i686.png
  cp -a manjaro.png Manjaro.x86_64.png
  cp -a pop-os.png pop.png
  cp -a driver.png memtest.png
fi
exit 0
