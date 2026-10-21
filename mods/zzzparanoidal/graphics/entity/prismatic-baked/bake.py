#!/usr/bin/env python3
"""Bake Prismatic Belts base+mask layers into one pre-colored sheet per Bob belt tier.

Run from any directory: python bake.py [--prismatic PATH]
Default PATH: ../../../../prismatic-belts (the sibling mod in the same mods folder).

Why: Bob's basic/turbo/ultimate belts are drawn by Prismatic as two layers (base +
overlay-tinted mask), i.e. two sprites per belt tile and two shared 64-frame sheets in
the atlas. One pre-colored layer halves the sprites per tile. The Lua side
(tweaks/entity/prismatic-belts-sync.lua) uses these sheets only while the tint read
from the prototype equals TINTS below; otherwise it keeps the two-layer form.
Keep TINTS in sync with BAKED_TINTS in that Lua file.

Math is the Factorio 2.0.77 sprite shader (data/core/graphics/shaders/sprite.frag),
premultiplied alpha, flag 2 = tint_as_overlay:
  a = m.a * t.a
  c = 2*m.c*t.c                      if m.c < 0.5*m.a
      a - 2*(m.a - m.c)*(t.a - t.c)  otherwise
then normal premultiplied blending of the tinted mask over the base layer:
  out = mask' + base * (1 - mask'.a)
"""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image

DESTINATION = Path(__file__).resolve().parent

# name -> (prismatic sheet number, tint r, g, b, a); reskins-library default tiers 0, 4, 5.
TINTS = {
    "bob-basic": (0x80 / 255, 0x80 / 255, 0x80 / 255, 1.0),
    "bob-turbo": (0xB4 / 255, 0x59 / 255, 0xFF / 255, 1.0),
    "bob-ultimate": (0x2E / 255, 0xE5 / 255, 0x5C / 255, 1.0),
}
OUTPUTS = [
    ("bob-basic", 1),  # 16 frames, default for the slowest belt
    ("bob-basic", 3),  # 64 frames, optional startup setting
    ("bob-turbo", 3),
    ("bob-ultimate", 3),
]


def load_premultiplied(path):
    rgba = np.asarray(Image.open(path).convert("RGBA"), dtype=np.float32) / 255.0
    rgba[..., :3] *= rgba[..., 3:4]
    return rgba


def overlay(mask, tint):
    t = np.asarray(tint, dtype=np.float32)
    m_c, m_a = mask[..., :3], mask[..., 3:4]
    alpha = m_a * t[3]
    x = 2.0 * m_c * t[:3]
    y = alpha - 2.0 * (m_a - m_c) * (t[3] - t[:3])
    out = np.empty_like(mask)
    out[..., :3] = np.where(m_c < 0.5 * m_a, x, y)
    out[..., 3:4] = alpha
    return out


def bake(prismatic, name, sheet):
    folder = prismatic / "graphics" / "entity" / "standard"
    base = load_premultiplied(folder / f"transport-belt-{sheet}-base.png")
    mask = overlay(load_premultiplied(folder / f"transport-belt-{sheet}-mask.png"), TINTS[name])
    out = mask + base * (1.0 - mask[..., 3:4])
    out = np.clip(out, 0.0, 1.0)
    a = out[..., 3:4]
    rgb = np.where(a > 0, out[..., :3] / np.maximum(a, 1e-8), 0.0)
    straight = np.concatenate([np.clip(rgb, 0.0, 1.0), a], axis=-1)
    image = Image.fromarray(np.rint(straight * 255.0).astype(np.uint8))
    frames = 16 * 2 ** (sheet - 1)
    target = DESTINATION / f"{name}-transport-belt-{frames}.png"
    image.save(target, optimize=True)
    print(target.name, image.size, target.stat().st_size // 1024, "KB")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prismatic", type=Path, default=DESTINATION.parents[3] / "prismatic-belts")
    args = parser.parse_args()
    for name, sheet in OUTPUTS:
        bake(args.prismatic, name, sheet)


if __name__ == "__main__":
    main()
