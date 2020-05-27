#! /bin/bash

INKSCAPE="/usr/bin/inkscape"

INDEX="logos.txt"
ASSETS_DIR="icons-1080p_21:9"
SRC_FILE="logos.svg"

install -d $ASSETS_DIR

for i in `cat $INDEX`
do
if [ -f $ASSETS_DIR/$i.png ]; then
  echo $ASSETS_DIR/$i.png exists.
else
  echo
  echo Rendering $ASSETS_DIR/$i.png
  $INKSCAPE --export-id=$i \
            --export-id-only \
            --export-png=$ASSETS_DIR/$i.png $SRC_FILE >/dev/null
fi
done

cd $ASSETS_DIR
cp -a archlinux.png arch.png
cp -a gnu-linux.png linux.png
cp -a gnu-linux.png unknown.png
cp -a gnu-linux.png lfs.png
cp -a manjaro.png Manjaro.i686.png
cp -a manjaro.png Manjaro.x86_64.png
cp -a driver.png memtest.png

exit 0
