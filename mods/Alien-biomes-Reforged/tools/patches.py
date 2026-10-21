"""Reforged edits applied on top of upstream Alien Biomes code.

`reforge.py code` copies a fresh upstream alien-biomes into the mod, rewrites the
mod paths and then applies every entry of PATCHES in order. Each entry is one of
  ("replace", file, old, new)  old must occur exactly once in the file
  ("append",  file, text)      text is appended once (skipped if already present)
An anchor that is missing or ambiguous stops the update: inspect the new upstream
code by hand and fix the entry here instead of forcing it.

Keep the Reforged logic in its own files (prototypes/reforged/*, control/settings
files that upstream does not have); the patches below should only hook it in.
"""

P = "__Alien-biomes-Reforged__"

PATCHES = [
    # --- tiles: shared tint matrices -------------------------------------------------
    ("replace", "prototypes/biome/biomes.lua",
     'biomes.transitions = require("prototypes/tile/tile-transitions-static")',
     'local tint_matrices = require("prototypes/tint-matrices")\n'
     'biomes.transitions = require("prototypes/tile/tile-transitions-static")'),
    ("replace", "prototypes/biome/biomes.lua",
     '          "%s/graphics/terrain/"..biome_name..".png",' % P,
     '          (tint_matrices.tiles[biome_name] and tint_matrices.tiles[biome_name].picture)\n'
     '            or "%s/graphics/terrain/"..biome_name..".png",' % P),
    ("replace", "prototypes/biome/biomes.lua",
     '      if biome.axis then\n        tile_data.localised_name',
     '      if tint_matrices.tiles[biome_name] then\n'
     '        tile_data.tint = tint_matrices.tiles[biome_name].tint\n'
     '      end\n'
     '      if biome.axis then\n        tile_data.localised_name'),
    # --- sand dunes: one tinted matrix per shape --------------------------------------
    ("replace", "prototypes/decorative/rocks.lua",
     "        util.replace_filenames_recursive(rock.pictures, '|color|', color)\n",
     "        local dune_matrices = require(\"prototypes/tint-matrices\").dunes\n"
     "        for _, pic in pairs(rock.pictures) do\n"
     "          local idx = pic.filename and pic.filename:match(\"sand%-dune%-decal%-(%d+)%.png$\")\n"
     "          local m = idx and dune_matrices[idx]\n"
     "          if m and m.tints[color] then\n"
     "            pic.filename = m.file\n"
     "            pic.tint = m.tints[color]\n"
     "          else\n"
     "            pic.filename = util.replace(pic.filename, '|color|', color)\n"
     "          end\n"
     "        end\n"),
    # --- lava decals: untinted base + additive tinted glow -----------------------------
    ("replace", "prototypes/decorative/lava.lua",
     '  data_util.replace_filenames_recursive(lava.pictures, "|color|", variant)\n',
     '  local lava_matrices = require("prototypes/tint-matrices").lava\n'
     '  for i, pic in pairs(lava.pictures) do\n'
     '    local idx = pic.filename and pic.filename:match("lava%-decal%-(%d+)%.png$")\n'
     '    local m = idx and lava_matrices[idx]\n'
     '    if m and m.tints[variant] then\n'
     '      local base = {filename = m.base, width = pic.width, height = pic.height, shift = pic.shift, scale = pic.scale}\n'
     '      local glow = table.deepcopy(base)\n'
     '      glow.filename = m.glow\n'
     '      glow.blend_mode = "additive"\n'
     '      glow.tint = m.tints[variant]\n'
     '      lava.pictures[i] = {layers = {base, glow}}\n'
     '    else\n'
     '      data_util.replace_filenames_recursive(pic, "|color|", variant)\n'
     '    end\n'
     '  end\n'),
    # --- Reforged data-stage additions (economy atlas, ...) --------------------------
    ("append", "data.lua", 'require("prototypes/reforged/data")\n'),
    # --- Reforged control stage: geology remote interface for the resource generator ---
    ("append", "control.lua", 'require("scripts/reforged-geology")\n'),
]
