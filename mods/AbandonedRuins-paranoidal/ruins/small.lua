-- Small ruins (8x8 tiles, tile coordinates -4..3).
local lib = require("ruins.lib")
local R, Q, ANY, DMG = lib.R, lib.Q, lib.ANY, lib.DMG

local def, list = lib.collector("small")

-- Junk and by-products -------------------------------------------------------------------

def("pd-slag-heap", function(b)
  b:tiles_blob("dirt-4", 0, 0, 3.5, 0.8)
  b:put("wooden-chest", -1, -1, { items = { ["angels-slag"] = R(20, 80), ["angels-stone-crushed"] = R(10, 40) }, dmg = DMG(10, 40) })
  b:put("wooden-chest", 1, 0, { items = { ["angels-slag"] = R(10, 50) }, dead = 0.3 })
  b:scatter(lib.ROCKS, 3)
end)

def("pd-ash-pit", function(b)
  b:tiles_blob("dirt-6", 0, 0, 3, 0.9)
  b:put("wooden-chest", 0, 0, { items = { ["bi-ash"] = R(30, 120), wood = R(0, 6) } })
  b:scatter_deco(lib.SCORCH, 4)
  b:scatter_deco(lib.DEAD_TREES, 4)
end)

def("pd-defect-dump", function(b)
  -- A heap of rejected parts from someone else's "-5" start.
  b:put("wooden-chest", -2, -1, { items = { ["burner-inserter"] = Q(R(3, 10), "ic-defect-5"), ["stone-furnace"] = Q(R(1, 3), "ic-defect-5") } })
  b:put("wooden-chest", 1, -1, { items = { ["small-electric-pole"] = Q(R(5, 15), "ic-defect-4"), ["bob-basic-transport-belt"] = Q(R(5, 25), "ic-defect-5") } })
  b:put("stone-furnace", -1, 1, { quality = "ic-defect-5", dmg = DMG(20, 80) })
  b:scatter("wooden-chest", 1, { dead = 1 })
end)

def("pd-qc-crate", function(b)
  -- A crate that passed quality control: normal (white) items.
  b:tiles_rect("stone-path", -2, -2, 1, 1)
  b:put("iron-chest", -1, -1, { items = { ["burner-inserter"] = Q(R(4, 8), "normal"), ["bob-basic-transport-belt"] = Q(R(10, 30), "normal") } })
  b:put("wooden-chest", 0, -1, { items = { ["small-electric-pole"] = Q(R(4, 10), "normal") }, dmg = DMG(10, 50) })
  b:scatter("small-electric-pole", 2, { dead = 0.7 })
end):weight(0.8)

def("pd-sand-bags", function(b)
  b:tiles_blob("sand-2", 0, 0, 4, 0.9)
  b:put("wooden-chest", -2, 0, { items = { ["angels-solid-sand"] = R(20, 60) } })
  b:put("wooden-chest", 1, -2, { items = { ["angels-solid-mud"] = R(10, 40) }, dead = 0.4 })
  b:scatter("big-sand-rock", 2)
end)

def("pd-compost-heap", function(b)
  b:tiles_blob("dirt-2", 0, 0, 3.5)
  b:put("wooden-chest", -1, -1, { items = { ["angels-solid-compost"] = R(15, 60), ["angels-solid-soil"] = R(5, 30) } })
  b:put("wooden-chest", 1, 1, { items = { seedling = R(2, 10), ["bi-seed"] = R(5, 25) } })
  b:scatter_deco(lib.STUMPS, 3)
end)

def("pd-sawdust", function(b)
  b:put("wooden-chest", 0, 0, { items = { wood = R(10, 40), ["angels-solid-saw"] = R(0, 3), ["bi-woodpulp"] = R(10, 50) } })
  b:put("wooden-chest", -3, 2, { items = { ["angels-cellulose-fiber"] = R(10, 40) }, dmg = DMG(10, 50) })
  b:scatter_deco(lib.STUMPS, 7)
end)

def("pd-barrel-stash", function(b)
  b:put("wooden-chest", -1, 0, { items = { barrel = R(2, 10), ["crude-oil-barrel"] = R(0, 3), ["water-barrel"] = R(0, 4) } })
  b:put("wooden-chest", 1, 0, { items = { ["lubricant-barrel"] = R(0, 2), ["sulfuric-acid-barrel"] = R(0, 2), barrel = R(0, 5) }, dead = 0.25 })
  b:scatter_deco(lib.SCORCH, 2)
end)

def("pd-rusty-gears", function(b)
  b:put("iron-chest", 0, 0, { items = { ["iron-gear-wheel"] = R(10, 50), ["iron-stick"] = R(10, 40), ["iron-plate"] = R(0, 20) }, dmg = DMG(20, 80) })
  b:scatter("iron-chest", 2, { dead = 1 })
  b:scatter(lib.ROCKS, 1)
end)

def("pd-trash-bin", function(b)
  b:tiles_rect("dirt-7", -3, -3, 2, 2, 0.7)
  b:put("wooden-chest", -1, -1, { items = { ["zcs-trash-landfill"] = R(1, 5), stone = R(5, 30), ["bi-ash"] = R(5, 20) } })
  b:put("wooden-chest", 0, 1, { items = { ["angels-slag"] = R(5, 30), wood = R(1, 5) }, dead = 0.5 })
end)

def("pd-seed-store", function(b)
  b:tiles_rect("grass-2", -3, -3, 2, 2, 0.8)
  b:put("wooden-chest", -1, -1, { items = { ["angels-temperate-1-seed"] = R(5, 20), ["angels-swamp-1-seed"] = R(0, 10), ["angels-desert-1-seed"] = R(0, 10) } })
  b:put("wooden-chest", 0, -1, { items = { ["angels-tree-seed"] = R(5, 20), ["bi-seed"] = R(5, 20) } })
  b:scatter_deco(lib.TREE, 4)
end)

def("pd-algae-puddle", function(b)
  b:tiles_blob("water-green", 1, 1, 2.2)
  b:reserve(-1, -1, 3, 3)
  b:put("wooden-chest", -3, -3, { items = { ["angels-algae-green"] = R(10, 50), ["angels-algae-brown"] = R(5, 30) } })
  b:scatter_deco(lib.DEAD_TREES, 2, nil, { -4, -4, -1, 3 })
end)

def("pd-campfire", function(b)
  b:put("torch", 0, 0, { items = { wood = R(1, 5) } })
  b:put("wooden-chest", -3, -2, { items = { ["raw-fish"] = R(1, 6), wood = R(5, 15), ["bi-ash"] = R(1, 10) } })
  b:scatter_deco(lib.STUMPS, 3)
end)

def("pd-nomad-camp", function(b)
  b:put("torch", -1, 0)
  b:put("torch", 1, 0)
  b:put("wooden-chest", 0, -2, { items = { pistol = R(0, 1), ["firearm-magazine"] = R(2, 10), respirator = R(0, 2), ["raw-fish"] = R(0, 5) } })
  b:ring("bi-wooden-fence", -3, -3, 3, 2, { gap = 0.35, dead = 0.3 })
end)

def("pd-broken-windmill", function(b)
  b:put("texugo-wind-turbine", -1, -1, { dmg = DMG(30, 150) })
  b:put("wooden-chest", 2, 1, { items = { ["copper-cable"] = R(10, 40), ["small-electric-pole"] = R(1, 4) } })
  b:scatter("small-electric-pole", 2, { dead = 0.6 })
end)

def("pd-wrecked-glider", function(b)
  b:put("aai-medium-ship-wreck-1", -2, -1, { items = { ["sci-component-1"] = R(2, 10), ["copper-cable"] = R(5, 20) } })
  b:put("aai-medium-ship-wreck-2", 1, 1, { items = { ["bob-basic-circuit-board"] = R(1, 4) } })
  b:put("aai-small-ship-wreck", -1, 2)
  b:scatter_deco(lib.SCORCH, 3)
end)

def("pd-drop-pod", function(b)
  b:put("aai-big-ship-wreck-3", -1, -1, { items = { ["bob-alien-artifact"] = R(1, 3), ["sci-component-2"] = R(0, 3) } })
  b:scatter_deco({ "medium-scorchmark", "big-scorchmark" }, 2)
end):weight(0.6)

def("pd-geologist-box", function(b)
  b:put("wooden-chest", 0, 0, { items = {
    ["angels-ore1"] = R(1, 8), ["angels-ore3"] = R(1, 8), ["angels-ore5"] = R(0, 5), ["angels-ore6"] = R(0, 5),
    ["bob-tin-ore"] = R(0, 6), ["bob-lead-ore"] = R(0, 6), ["mining-drill-bit-mk0"] = R(0, 2) } })
  b:scatter(lib.ROCKS, 3)
end)

def("pd-shed-lab", function(b)
  b:put("burner-lab", -2, -2, { dmg = DMG(20, 120), items = { ["automation-science-pack"] = R(0, 5) } })
  b:put("wooden-chest", 2, -2, { items = { ["sci-component-1"] = R(3, 12), ["automation-science-pack"] = R(0, 4) } })
  b:ring("bi-wooden-fence", -4, -4, 3, 3, { gap = 0.5, dead = 0.4 })
end)

def("pd-pop-up-smelter", function(b)
  b:put("stone-furnace", -2, -1, { items = { wood = R(1, 8), ["iron-plate"] = R(0, 10) }, dmg = DMG(10, 60) })
  b:put("stone-furnace", 0, -1, { items = { ["copper-plate"] = R(0, 10) }, dead = 0.3 })
  b:put("wooden-chest", -1, 2, { items = { ["iron-ore"] = R(5, 30), ["copper-ore"] = R(5, 30) } })
end)

def("pd-mini-mine", function(b)
  b:put("burner-mining-drill", -2, -2, { dmg = DMG(20, 100) })
  b:put("wooden-chest", 0, -2, { items = { ["iron-ore"] = R(10, 50) } })
  b:put("burner-mining-drill", -2, 1, { dead = 0.6 })
  b:scatter(lib.ROCKS, 1)
end)

def("pd-crusher-hut", function(b)
  b:put("angels-burner-ore-crusher", -2, -2, { dmg = DMG(30, 160) })
  b:put("wooden-chest", 2, -1, { items = { ["angels-ore1-crushed"] = R(10, 40), ["angels-stone-crushed"] = R(10, 40) } })
  b:put("wooden-chest", 2, 1, { items = { ["angels-ore3-crushed"] = R(0, 30) }, dead = 0.4 })
end)

def("pd-broken-assembler", function(b)
  b:put("burner-assembling-machine", -2, -2, { recipe = "iron-gear-wheel", dmg = DMG(40, 160) })
  b:put("wooden-chest", 2, -1, { items = { ["iron-gear-wheel"] = R(5, 20), ["iron-plate"] = R(0, 20) } })
end)

def("pd-pole-line", function(b)
  for i = -3, 3, 2 do b:put(ANY({ "small-electric-pole", "small-iron-electric-pole" }), i, i < 0 and -1 or 0, { dead = 0.4 }) end
  b:put("wooden-chest", 0, 2, { items = { ["copper-cable"] = R(10, 30), ["bob-tinned-copper-cable"] = R(0, 10) } })
end)

def("pd-fenced-pen", function(b)
  b:ring("bi-wooden-fence", -4, -4, 3, 3, { door = { { 0, 3 }, { -1, 3 } }, dead = 0.15 })
  b:put("wooden-chest", -1, -1, { items = { ["raw-fish"] = R(0, 4), ["angels-solid-compost"] = R(5, 15) } })
  b:scatter_deco(lib.TREE, 2, nil, { -3, -3, 3, 3 })
end)

def("pd-old-well", function(b)
  b:tiles_rect("water", -1, -1, 0, 0)
  b:reserve(-1, -1, 0, 0)
  b:ring("stone-wall", -2, -2, 1, 1, { gap = 0.2, dead = 0.2 })
  b:put("wooden-chest", 2, 2, { items = { ["water-barrel"] = R(0, 3), barrel = R(1, 4) } })
end)

def("pd-masonry", function(b)
  b:tiles_rect("stone-path", -3, -3, 2, 2, 0.6)
  b:put("wooden-chest", -1, 0, { items = { ["stone-brick"] = R(10, 50), ["angels-clay-brick"] = R(0, 20) } })
  b:ring("stone-wall", -3, -3, 2, 2, { gap = 0.55, dead = 0.5 })
end)

def("pd-clay-pit", function(b)
  b:tiles_blob("dirt-3", 0, 0, 3.8)
  b:put("wooden-chest", -1, -1, { items = { ["angels-solid-clay"] = R(10, 50), ["angels-clay-brick-raw"] = R(0, 20) } })
  b:scatter_deco(lib.SCORCH, 1)
end)

def("pd-lamp-store", function(b)
  b:put("deadlock-copper-lamp", -2, -2, { dmg = DMG(10, 40) })
  b:put("small-lamp", 1, -2, { dead = 0.5 })
  b:put("wooden-chest", 0, 1, { items = { ["deadlock-copper-lamp"] = R(1, 4), ["small-lamp"] = R(0, 3), ["copper-cable"] = R(5, 15) } })
end)

def("pd-repair-kit", function(b)
  b:put("iron-chest", 0, 0, { items = { ["repair-pack"] = R(3, 12), ["bob-repair-pack-2"] = R(0, 3), ["iron-gear-wheel"] = R(2, 10) } })
  b:scatter_deco(lib.SCORCH, 2)
end)

def("pd-respirator-cache", function(b)
  b:put("wooden-chest", -1, -1, { items = { respirator = R(1, 4) } })
  b:put("wooden-chest", 1, 1, { items = { ["CW-empty-air-filter"] = R(0, 5), ["angels-air-filter"] = R(0, 2) }, dead = 0.3 })
  b:scatter_deco(lib.DEAD_TREES, 3)
end)

def("pd-empty-barrels", function(b)
  b:put("wooden-chest", -2, 0, { items = { barrel = R(5, 20) } })
  b:put("wooden-chest", 1, 0, { items = { barrel = R(2, 10) }, dead = 0.5 })
  b:put("wooden-chest", -1, 2, { items = { barrel = R(1, 5) }, dead = 0.5 })
end)

def("pd-oil-tank", function(b)
  b:put("bob-small-storage-tank", 0, 0, { fluids = { ["crude-oil"] = R(100, 1500) }, dmg = DMG(10, 60) })
  b:put("bob-small-storage-tank", 2, 0, { dead = 0.6 })
  b:tiles_blob("dirt-6", 1, 1, 2.5, 0.7)
end)

def("pd-chemist-box", function(b)
  b:put("iron-chest", 0, 0, { items = { sulfur = R(5, 25), ["angels-solid-lime"] = R(5, 20), ["angels-solid-sodium-carbonate"] = R(0, 15), barrel = R(1, 5) } })
  b:tiles_blob("nuclear-ground", 0, 0, 2, 0.4)
end)

def("pd-strange-stones", function(b)
  b:put("huge-rock", -2, -2)
  b:put("wooden-chest", 2, 1, { items = {
    ["bob-alien-artifact-red"] = R(0, 2), ["bob-alien-artifact-blue"] = R(0, 2), ["bob-alien-artifact-green"] = R(0, 2),
    ["bob-alien-artifact-orange"] = R(0, 2), ["bob-alien-artifact-purple"] = R(0, 2), ["bob-alien-artifact-yellow"] = R(0, 2) } })
end):weight(0.6)

def("pd-burnt-truck", function(b)
  b:put("car", -1, -1, { dead = 0.8, dmg = DMG(100, 300) })
  b:scatter_deco({ "medium-scorchmark", "big-scorchmark" }, 3)
  b:put("wooden-chest", 2, 2, { items = { ["engine-unit"] = R(0, 1), ["iron-gear-wheel"] = R(2, 8) }, dead = 0.3 })
end)

def("pd-qc-post", function(b)
  b:put("ic-control-post", -2, -2, { dmg = DMG(20, 80) })
  b:put("wooden-chest", 2, 0, { items = { ["burner-inserter"] = Q(R(1, 3), "ic-defect-2"), ["burner-mining-drill"] = Q(R(0, 1), "ic-defect-3") } })
end):weight(0.5)

def("pd-refine-workshop", function(b)
  -- The workshop from the Paranoidal quality-control system, found long before research.
  b:put("ic-refine-workshop", -2, -2, { dmg = DMG(40, 140) })
  b:put("wooden-chest", 2, -2, { items = { ["stone-furnace"] = Q(R(1, 2), "ic-defect-5"), ["iron-gear-wheel"] = R(10, 20) } })
end):weight(0.3):far(600):tag("rare")

def("pd-useless-boards", function(b)
  b:put("steel-chest", 0, 0, { items = { ["advanced-circuit"] = R(1, 5), ["processing-unit"] = R(0, 2) } })
  b:scatter("steel-chest", 2, { dead = 1 })
end):weight(0.5):far(500)

def("pd-module-crate", function(b)
  b:put("steel-chest", -1, -1, { items = { ["speed-module"] = R(0, 1), ["efficiency-module"] = R(0, 1), ["productivity-module"] = R(0, 1) } })
  b:tiles_rect("refined-concrete", -2, -2, 1, 1)
end):weight(0.3):far(900):tag("rare")

def("pd-rail-scrap", function(b)
  b:put("straight-rail", -2, -2, { dir = "east", dead = 0.5 })
  b:put("straight-rail", 0, -2, { dir = "east", dead = 0.5 })
  b:put("wooden-chest", -1, 2, { items = { rail = R(0, 6), ["iron-stick"] = R(5, 20), stone = R(5, 20) } })
end)

def("pd-smugglers-cache", function(b)
  b:scatter_deco(lib.TREE, 7)
  b:put("wooden-chest", 0, 0, { items = { ["piercing-rounds-magazine"] = R(2, 10), ["submachine-gun"] = R(0, 1), ["firearm-magazine"] = R(0, 20) } })
end):far(400)

def("pd-armor-rack", function(b)
  b:put("iron-chest", -1, 0, { items = { ["light-armor"] = Q(1, "normal") } })
  b:put("iron-chest", 1, 0, { items = { ["heavy-armor"] = Q(R(0, 1), "ic-defect-4") }, dmg = DMG(20, 90) })
end):weight(0.6)

def("pd-fishing-spot", function(b)
  b:tiles_blob("water", 1, 1, 2.6)
  b:reserve(-2, -2, 3, 3)
  b:deco("fish", 1.5, 1.5)
  b:deco("fish", 2.2, 0.4)
  b:put("wooden-chest", -4, -4, { items = { ["raw-fish"] = R(2, 10), wood = R(1, 4) } })
end)

def("pd-hollow-tree", function(b)
  b:scatter_deco(lib.TREE, 6)
  b:put("wooden-chest", -1, -1, { items = { resin = R(2, 10), wood = R(2, 8), ["bi-seed"] = R(0, 5) } })
end)

def("pd-airship-debris", function(b)
  b:put("aai-small-ship-wreck", -3, -3)
  b:put("aai-medium-ship-wreck-1", 2, -2, { items = { ["steel-plate"] = R(2, 10) } })
  b:put("aai-medium-ship-wreck-2", -2, 2, { items = { ["copper-cable"] = R(5, 20), ["electric-motor"] = R(0, 2) } })
  b:scatter_deco(lib.SCORCH, 3)
end)

def("pd-coke-oven", function(b)
  b:put("bi-cokery", -2, -2, { dmg = DMG(30, 150) })
  b:put("wooden-chest", 2, 0, { items = { ["angels-solid-coke"] = R(5, 25), ["angels-solid-carbon"] = R(0, 10), ["bi-ash"] = R(5, 20) } })
end)

def("pd-stone-crusher", function(b)
  b:put("bi-stone-crusher", -1, -1, { dmg = DMG(20, 80) })
  b:put("wooden-chest", 2, -1, { items = { ["angels-stone-crushed"] = R(20, 60), stone = R(5, 25) } })
  b:scatter(lib.ROCKS, 2)
end)

def("pd-glass-kiln", function(b)
  b:put("bob-stone-mixing-furnace", -1, -1, { dmg = DMG(10, 60) })
  b:put("wooden-chest", 2, -1, { items = { ["bob-glass"] = R(5, 30), ["angels-solid-sand"] = R(5, 20) } })
end)

def("pd-garage-electronics", function(b)
  b:put("bob-electronics-machine-1", -2, -1, { dmg = DMG(10, 60) })
  b:put("wooden-chest", 1, -1, { items = { ["bob-basic-electronic-components"] = R(5, 20), ["bob-basic-circuit-board"] = R(2, 10), ["bob-solder"] = R(0, 10) } })
end)

def("pd-toolbox", function(b)
  b:put("iron-chest", 0, 0, { items = { ["mining-drill-bit-mk1"] = R(0, 3), ["mining-drill-bit-mk2"] = R(0, 2), ["mining-drill-bit-mk0"] = R(1, 5) } })
  b:scatter(lib.ROCKS, 2)
end)

def("pd-homemade-generator", function(b)
  b:put("bob-burner-generator", -2, -2, { dmg = DMG(30, 120) })
  b:put("wooden-chest", 2, -2, { items = { wood = R(10, 30), ["small-electric-pole"] = R(1, 3) } })
  b:put("small-electric-pole", 2, 1, { dead = 0.3 })
end)

def("pd-torch-circle", function(b)
  for _, p in ipairs({ { -3, -3 }, { 2, -3 }, { -3, 2 }, { 2, 2 }, { -1, -4 }, { 0, 3 } }) do
    b:put("torch", p[1], p[2], { dead = 0.3 })
  end
  b:put("wooden-chest", -1, -1, { items = { wood = R(5, 20), ["bi-ash"] = R(2, 10) } })
end)

def("pd-mud-hole", function(b)
  b:tiles_blob("water-mud", 0, 0, 3)
  b:reserve(-3, -3, 2, 2)
  b:scatter_deco(lib.DEAD_TREES, 3)
  b:put("wooden-chest", 3, 3, { items = { ["angels-solid-mud"] = R(10, 40) } })
end)

def("pd-red-sand", function(b)
  b:tiles_blob("red-desert-1", 0, 0, 4)
  b:put("wooden-chest", 0, 0, { items = { ["bob-quartz"] = R(5, 25), ["angels-solid-sand"] = R(5, 25) } })
  b:scatter("big-sand-rock", 2)
end)

def("pd-pipe-dump", function(b)
  b:scatter({ "bi-wood-pipe", "bob-copper-pipe", "pipe" }, 8, { dmg = DMG(5, 40) })
  b:put("wooden-chest", 0, 0, { items = { pipe = R(2, 10), ["bob-copper-pipe"] = R(2, 10), ["bi-wood-pipe"] = R(2, 10) } })
end)

def("pd-defect-science", function(b)
  b:put("burner-lab", -2, -2, { quality = "ic-defect-3", dmg = DMG(20, 60) })
  b:put("wooden-chest", 2, -1, { items = { ["automation-science-pack"] = Q(R(5, 20), "ic-defect-3") } })
end)

def("pd-starter-kit", function(b)
  -- Clean, normal-quality starter buildings: a real help during the "-5" defect phase.
  b:tiles_rect("stone-path", -3, -2, 2, 1)
  b:put("iron-chest", -1, -1, { items = {
    ["stone-furnace"] = Q(R(1, 2), "normal"), ["burner-inserter"] = Q(R(2, 4), "normal"),
    ["burner-mining-drill"] = Q(R(0, 1), "normal"), ["small-electric-pole"] = Q(R(2, 6), "normal") } })
  b:ring("stone-wall", -3, -2, 2, 1, { gap = 0.4, dead = 0.3 })
end):weight(0.4):far(500):tag("rare")

def("pd-bait-trap", function(b)
  b:tiles_rect("hazard-concrete-left", -4, -4, 3, -4)
  b:put("wooden-chest", -1, -1, { items = { ["bob-alien-artifact"] = R(1, 2) } })
  for _, p in ipairs({ { -3, -2 }, { 2, -2 }, { -3, 1 }, { 2, 1 }, { 0, -3 }, { -1, 2 } }) do
    b:put(ANY({ "bob-poison-mine", "bob-slowdown-mine" }), p[1], p[2], { force = "enemy" })
  end
end):far(500):tag("danger")

def("pd-already-looted", function(b)
  b:put("wooden-chest", 0, 0, { items = { stone = R(1, 3), wood = R(0, 1) } })
  b:scatter("wooden-chest", 3, { dead = 1 })
  b:scatter_deco(lib.SCORCH, 2)
end)

def("pd-sinkhole", function(b)
  b:tiles_blob("water-shallow", 0, 0, 2)
  b:tiles_blob("dirt-5", 0, 0, 3.8, 0.6)
  b:reserve(-2, -2, 1, 1)
  b:scatter(lib.ROCKS, 3)
end)

def("pd-uranium-spill", function(b)
  b:tiles_blob("nuclear-ground", 0, 0, 3.6)
  b:put("steel-chest", 0, 0, { items = { ["uranium-ore"] = R(2, 15), barrel = R(0, 3) }, dmg = DMG(20, 90) })
  b:scatter_deco(lib.DEAD_TREES, 3)
end):far(700)

-- Dangerous small ruins -------------------------------------------------------------------

def("pd-mined-crate", function(b)
  b:tiles_rect("hazard-concrete-right", -4, 3, 3, 3)
  b:put("iron-chest", -1, -1, { items = { ["piercing-rounds-magazine"] = R(5, 20), ["iron-gear-wheel"] = R(10, 30) } })
  for _, p in ipairs({ { -3, -3 }, { 1, -3 }, { -3, 0 }, { 2, 0 }, { -1, 2 }, { 1, 1 } }) do
    b:put("land-mine", p[1], p[2], { force = "enemy" })
  end
end):far(700):tag("danger")

def("pd-lone-worm", function(b)
  b:put("small-worm-turret", 1, -2, { force = "enemy" })
  b:put("wooden-chest", -3, 2, { items = { ["bob-alien-artifact"] = R(1, 3), ["iron-plate"] = R(10, 30) } })
  b:scatter_deco({ "small-biter-corpse", "medium-biter-corpse" }, 3)
end):far(600):tag("danger")

def("pd-dart-sentry", function(b)
  b:put("bi-dart-turret", 0, 0, { force = "enemy", items = { ["bi-dart-magazine-basic"] = R(5, 15) } })
  b:put("wooden-chest", -3, -3, { items = { ["bi-dart-magazine-standard"] = R(5, 20), ["bi-dart-rifle"] = R(0, 1) } })
  b:ring("bi-wooden-fence", -2, -2, 2, 2, { gap = 0.3, door = { { 0, 2 } } })
end):far(400):tag("danger")

def("pd-mg-nest", function(b)
  b:put("gun-turret", -1, -1, { force = "enemy", items = { ["firearm-magazine"] = R(3, 12) } })
  b:ring("stone-wall", -3, -3, 2, 2, { gap = 0.25 })
  b:put("wooden-chest", 3, 3, { items = { ["firearm-magazine"] = R(10, 30), ["gun-turret"] = R(0, 1) } })
end):far(800):tag("danger")

def("pd-flame-post", function(b)
  b:put("flamethrower-turret", -1, -2, { force = "enemy", fluids = { ["crude-oil"] = R(20, 100) } })
  b:put("bob-small-storage-tank", 2, 2, { fluids = { ["crude-oil"] = R(200, 1000) } })
  b:scatter_deco({ "medium-scorchmark", "big-scorchmark" }, 3)
end):weight(0.6):far(1400):tag("danger")

def("pd-worm-burrow", function(b)
  b:put("small-worm-turret", -3, -3, { force = "enemy" })
  b:put("small-worm-turret", 1, -3, { force = "enemy" })
  b:put("medium-worm-turret", -1, 1, { force = "enemy" })
  b:scatter_deco({ "small-biter-corpse", "small-spitter-corpse" }, 3)
end):weight(0.6):far(1200):tag("danger")

-- More curiosities ------------------------------------------------------------------------

def("pd-crystal-shard", function(b)
  b:put("angels-crystal-rock", -2, -2)
  b:put("wooden-chest", 2, 1, { items = { ["angels-crystal-dust"] = R(5, 25) } })
end):weight(0.7)

def("pd-bile-blob", function(b)
  b:put("bob-hardened-bile", -1, -1)
  b:scatter_deco({ "small-biter-corpse", "small-spitter-corpse" }, 4)
end)

def("pd-ingot-cache", function(b)
  b:put("iron-chest", -1, 0, { items = { ["angels-ingot-iron"] = R(5, 30), ["angels-ingot-copper"] = R(0, 20) } })
  b:put("iron-chest", 1, 0, { items = { ["angels-ingot-tin"] = R(0, 15), ["angels-ingot-lead"] = R(0, 15) }, dead = 0.3 })
end)

def("pd-catalyst-jar", function(b)
  b:put("iron-chest", 0, 0, { items = { ["angels-catalyst-metal-carrier"] = R(5, 20), ["angels-catalyst-metal-red"] = R(0, 10) } })
  b:tiles_blob("nuclear-ground", 0, 0, 1.5, 0.5)
end)

def("pd-paper-mill", function(b)
  b:put("wooden-chest", -1, -1, { items = { ["angels-solid-paper"] = R(10, 40), ["angels-solid-wood-pulp"] = R(5, 20) } })
  b:put("wooden-chest", 1, 1, { items = { ["bob-wooden-board"] = R(2, 10) }, dead = 0.4 })
  b:scatter_deco(lib.STUMPS, 4)
end)

def("pd-phosphorus-glow", function(b)
  b:tiles_blob("dirt-1", 0, 0, 3)
  b:put("steel-chest", 0, 0, { items = { ["clowns-phosphorus-ore"] = R(5, 20), ["clowns-solid-white-phosphorus"] = R(0, 5) } })
  b:put("small-lamp", -3, -3, { dead = 0.4 })
end):weight(0.6)

def("pd-osmium-sample", function(b)
  b:put("steel-chest", 0, 0, { items = { ["clowns-osmium-ore"] = R(3, 15), ["angels-platinum-ore"] = R(0, 8), ["angels-manganese-ore"] = R(0, 10) } })
  b:scatter("huge-rock", 1)
end):weight(0.6)

def("pd-wind-relay", function(b)
  b:put("texugo-wind-turbine", -3, -3, { dead = 0.5 })
  b:put("texugo-wind-turbine", 1, 1, { dmg = DMG(20, 100) })
  b:put("small-iron-electric-pole", -1, 2, { dead = 0.3 })
end)

def("pd-stash-of-motors", function(b)
  b:put("iron-chest", 0, 0, { items = { motor = R(2, 8), ["electric-motor"] = R(0, 4), ["basic-structure-components"] = R(0, 4) } })
  b:scatter("iron-chest", 1, { dead = 1 })
end)

def("pd-kids-sandbox", function(b)
  b:tiles_rect("sand-1", -2, -2, 1, 1)
  b:ring("bi-wooden-fence", -3, -3, 2, 2, { gap = 0.2 })
  b:put("wooden-chest", 3, 3, { items = { ["angels-solid-sand"] = R(1, 10), ["iron-gear-wheel"] = R(0, 3), ["raw-fish"] = R(0, 1) } })
end)

def("pd-rocket-curio", function(b)
  b:put("steel-chest", 0, 0, { items = { ["rocket-fuel"] = R(0, 2), ["low-density-structure"] = R(0, 1), ["nuclear-fuel"] = R(0, 1) } })
  b:tiles_rect("hazard-concrete-left", -1, -1, 1, 1)
end):weight(0.25):far(1500):tag("rare")

def("pd-nightwatch", function(b)
  b:put("deadlock-copper-lamp", -1, -1)
  b:put("wooden-chest", 2, -2, { items = { torch = R(1, 4), wood = R(5, 10), pistol = R(0, 1) } })
  b:put("torch", -3, 2, { dead = 0.4 })
end)

def("pd-belt-coil", function(b)
  b:put("wooden-chest", -1, -1, { items = { ["bob-basic-transport-belt"] = R(10, 40), ["bob-basic-underground-belt"] = R(0, 4), ["bob-basic-splitter"] = R(0, 2) } })
  for x = -4, 3 do b:try_put("bob-basic-transport-belt", x, 2, { dir = "east", dead = 0.5 }) end
end)

def("pd-inserter-bin", function(b)
  b:put("wooden-chest", 0, 0, { items = { ["burner-inserter"] = Q(R(2, 8), "ic-defect-3"), inserter = Q(R(0, 2), "ic-defect-1") } })
  b:scatter("burner-inserter", 4, { dead = 0.7 })
end)

def("pd-bronze-workshop", function(b)
  b:put("stone-furnace", -2, -2, { dmg = DMG(10, 50) })
  b:put("wooden-chest", 1, -2, { items = { ["bob-bronze-alloy"] = R(5, 20), ["bob-tin-plate"] = R(5, 20), ["copper-plate"] = R(5, 20) } })
  b:put("wooden-chest", 1, 1, { items = { ["bob-bronze-pipe"] = R(0, 6) }, dead = 0.4 })
end)

def("pd-salt-flats", function(b)
  b:tiles_blob("sand-3", 0, 0, 4)
  b:put("wooden-chest", 0, 0, { items = { ["angels-solid-salt"] = R(10, 40), ["angels-water-saline-barrel"] = R(0, 3) } })
end)

def("pd-dead-robot", function(b)
  b:deco("construction-robot-remnants", -1.2, -0.7)
  b:deco("logistic-robot-remnants", 1.3, 0.8)
  b:put("iron-chest", -3, 2, { items = { ["flying-robot-frame"] = R(0, 1), ["electronic-circuit"] = R(1, 6), battery = R(0, 2) } })
end):far(600)

def("pd-gem-pouch", function(b)
  b:put("mini-steel-chest", 0, 0, { items = { ["bob-ruby-3"] = R(0, 3), ["bob-sapphire-5"] = R(0, 1), ["bob-emerald-5"] = R(0, 1), ["bob-topaz-5"] = R(0, 1) } })
  b:scatter(lib.ROCKS, 3)
end):weight(0.4):far(800):tag("rare")

def("pd-uncommon-find", function(b)
  -- Rare: one uncommon item from a quality line nobody here has yet.
  b:put("iron-chest", 0, 0, { items = { ["burner-inserter"] = Q(R(1, 2), "uncommon"), ["stone-furnace"] = Q(R(0, 1), "uncommon") } })
  b:tiles_rect("refined-concrete", -1, -1, 1, 1)
end):weight(0.2):far(1000):tag("rare")

def("pd-landfill-cache", function(b)
  -- Early landfill for the small holes under wide blueprints.
  b:tiles_blob("dirt-4", 0, 0, 3.5, 0.8)
  b:put("wooden-chest", 0, 0, { items = { landfill = R(30, 100) } })
  b:scatter(lib.ROCKS, 2)
end)

return list
