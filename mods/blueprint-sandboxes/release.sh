#!/usr/bin/env bash

name=$(cat info.json | jq -r .name)
version=$(cat info.json | jq -r .version)

# Create git tag for this version
git tag -f "$version"

mkdir release

# Prepare zip for Factorio native use and mod portal
git archive --prefix "${name}_$version/" \
  -o "release/${name}_$version.zip" \
  HEAD
