# Based on https://github.com/SmetDenis/Factorio-Mod-Pack/blob/main/Makefile

.PHONY: build
.DEFAULT_GOAL := build

MOD_NAME ?= `cat ./info.json | jq -r '.name'`
MOD_VERSION ?= `cat ./info.json | jq -r '.version'`

build:
	@echo Building New Package $(MOD_NAME)_$(MOD_VERSION)
	@rm    -fr ./build
	@mkdir -p  ./build
	@rsync -av `pwd` `pwd`/build        \
        --exclude build                     \
        --exclude .git                      \
        --exclude .idea                     \
        --exclude .gitignore                \
        --exclude example.png               \
        --exclude .xcf                      \
        --exclude publish_exclude.txt       \
        --exclude publish_mod.bat           \
        --exclude makefile                  \
        --exclude blender                   \
        --exclude cargo-ships-graphics      \
        --exclude todo                      \
        --exclude .zip                      \
        --exclude tmp.lua                   \
        --exclude temp
	@cd ./build; zip -r9q modfile.zip *
	@mv `pwd`/build/modfile.zip `pwd`/../$(MOD_NAME)_$(MOD_VERSION).zip
	@echo "It's ready"

clean:
	@echo Cleaning
	@rm    -fr ./build
	@echo Done Cleaning
