#!/bin/bash

DIR_NAME=".build"
BUILD_SCRIPTS_DIR="build-scripts"
CONTROL_LUA="control.lua"
DATA_LUA="data.lua"

if [ -d "$DIR_NAME" ]; then
  echo "Deleting old build directory."
	rm -rf $DIR_NAME
fi

echo "Creating build directory."
mkdir ./$DIR_NAME

# Copy files into the new directory
# - not the new build directory
# - not the build scripts folder
# - not any .sh script (e.g build.sh script)
# - not any .zip file (e.g. the build zip) 
# - not any .* hidden file (e.g. .git, .gitignore, .vscode, .documentation)
echo "Copying files to build directory"
find . -maxdepth 1 ! -regex '.*/'$DIR_NAME ! -regex '.*/'$BUILD_SCRIPTS_DIR ! -regex '.*/*.sh' ! -regex '.*/*.zip' ! -regex '.*/\..*' ! -regex '.' -exec cp -r '{}' $DIR_NAME \;

echo "Running pngquant on the png files."
find ./$DIR_NAME -name '*.png' -print0 | xargs -0 -P5 -L1 pngquant --ext .png --force 256

echo "Unsetting debug mode in control.lua and data.lua."
if test -f ./$DIR_NAME/$CONTROL_LUA; then
	sed -b -i -e 's/is_debug_mode = true/is_debug_mode = false/g' ./$DIR_NAME/$CONTROL_LUA
fi
if test -f ./$DIR_NAME/$DATA_LUA; then
	sed -b -i -e 's/is_debug_mode = true/is_debug_mode = false/g' ./$DIR_NAME/$DATA_LUA
fi

echo "Done prepackaging."
