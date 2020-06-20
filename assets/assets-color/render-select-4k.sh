#! /bin/bash

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"

INDEX="select.txt"
ASSETS_DIR="select-4k"
SRC_FILE="select.svg"

install -d $ASSETS_DIR

for i in `cat $INDEX`
do
if [ -f $ASSETS_DIR/$i.png ]; then
  echo $ASSETS_DIR/$i.png exists.
else
  echo
  echo Rendering $ASSETS_DIR/$i.png
  $INKSCAPE --export-id=$i \
            --export-dpi=192 \
            --export-id-only \
            --export-filename=$ASSETS_DIR/$i.png $SRC_FILE >/dev/null
  $OPTIPNG -o7 --quiet $ASSETS_DIR/$1.png
fi
done

exit 0
