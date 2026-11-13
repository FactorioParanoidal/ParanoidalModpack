#!/bin/bash
# Pack Blender renders into Factorio atlases; no resampling of animation cells.
set -euo pipefail
renders="${1:?Usage: build.sh RENDER_DIRECTORY [ASSET_DIRECTORY]}"
assets="${2:-mods/zzzparanoidal/graphics/anti-air-turret}"
mkdir -p "$assets"
pack() {
    local input="$1" start="$2" count="$3" grid="$4" output="$5"
    ffmpeg -hide_banner -loglevel error -y -threads 1 -start_number "$start" \
        -i "$renders/$input" -vf "tile=$grid:nb_frames=$count" \
        -frames:v 1 -threads 1 -pix_fmt rgba -update 1 "$assets/$output"
}
for group in {0..7}; do
    start=$((group * 16))
    pack 'shoot-%03d.png' "$start" 16 2x8 "shooting-$group.png"
    pack 'shoot-%03d-mask.png' "$start" 16 2x8 "shooting-mask-$group.png"
    pack 'shoot-shadow-%03d.png' "$start" 16 2x8 "shooting-shadow-$group.png"
    # A separate single-frame atlas keeps Factorio's line_length unambiguous.
    ffmpeg -hide_banner -loglevel error -y -threads 1 -start_number "$start" \
        -i "$renders/shoot-%03d.png" -vf "select='not(mod(n,2))',tile=1x8:nb_frames=8" \
        -frames:v 1 -threads 1 -pix_fmt rgba -update 1 "$assets/prepared-$group.png"
    ffmpeg -hide_banner -loglevel error -y -threads 1 -start_number "$start" \
        -i "$renders/shoot-%03d-mask.png" -vf "select='not(mod(n,2))',tile=1x8:nb_frames=8" \
        -frames:v 1 -threads 1 -pix_fmt rgba -update 1 "$assets/prepared-mask-$group.png"
    ffmpeg -hide_banner -loglevel error -y -threads 1 -start_number "$start" \
        -i "$renders/shoot-shadow-%03d.png" -vf "select='not(mod(n,2))',tile=1x8:nb_frames=8" \
        -frames:v 1 -threads 1 -pix_fmt rgba -update 1 "$assets/prepared-shadow-$group.png"
done
pack 'raise-%02d.png' 0 24 6x4 raising.png
pack 'raise-%02d-mask.png' 0 24 6x4 raising-mask.png
pack 'raise-shadow-%02d.png' 0 24 6x4 raising-shadow.png
for suffix in '' '-mask' '-shadow'; do
    case "$suffix" in
        -shadow) input='raise-shadow-%02d.png' ;;
        *) input="raise-%02d$suffix.png" ;;
    esac
    ffmpeg -hide_banner -loglevel error -y -threads 1 -i "$renders/$input" \
        -vf "select='not(mod(n,6))',tile=1x4:nb_frames=4" \
        -frames:v 1 -threads 1 -pix_fmt rgba -update 1 "$assets/folded$suffix.png"
done
for tier in {1..3}; do
    cp "$renders/base-$tier.png" "$assets/base-$tier.png"
    cp "$renders/icon-$tier.png" "$assets/technology-$tier.png"
    ffmpeg -hide_banner -loglevel error -y -threads 1 -i "$renders/icon-$tier.png" \
        -vf scale=128:128:flags=lanczos -frames:v 1 -threads 1 -update 1 "$assets/icon-$tier.png"
done
cp "$renders/base-shadow.png" "$assets/base-shadow.png"
