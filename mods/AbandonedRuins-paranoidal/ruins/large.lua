-- Large ruins (32x32 tiles, tile coordinates -16..15).
local lib = require("ruins.lib")
local R, Q, ANY, DMG = lib.R, lib.Q, lib.ANY, lib.DMG

local def, list = lib.collector("large")

local POLES = ANY({ "small-electric-pole", "small-iron-electric-pole" })

def("pd-steelworks", function(b)
  b:tiles_rect("stone-path", -15, -15, 14, 0, 0.6)
  b:put("angels-blast-furnace", -14, -14, { dmg = DMG(100, 400) })
  b:put("angels-blast-furnace", -8, -14, { dead = 0.4 })
  b:put("angels-induction-furnace", -2, -14, { dmg = DMG(100, 400) })
  b:put("angels-casting-machine", 4, -14, { dead = 0.3 })
  b:put("angels-casting-machine", 8, -14, { dmg = DMG(50, 200) })
  b:put("iron-chest", -14, -7, { items = { ["angels-ingot-iron"] = R(40, 120), ["angels-ingot-steel"] = R(10, 40) } })
  b:put("iron-chest", -13, -7, { items = { ["steel-plate"] = R(10, 50), ["angels-solid-coke"] = R(20, 60) } })
  b:scatter("wooden-chest", 10, { items = { ["angels-slag"] = R(40, 150) }, dmg = DMG(10, 60) }, { -16, 2, 16, 16 })
  b:scatter("huge-rock", 3, nil, { -16, 2, 16, 16 })
  b:ring("stone-wall", -16, -16, 15, 15, { gap = 0.45, dead = 0.4 })
end)

def("pd-bio-estate", function(b)
  b:put("bi-bio-farm", -15, -15, { dmg = DMG(100, 400) })
  b:put("bi-bio-farm", -4, -15, { dead = 0.5 })
  b:put("bi-bio-greenhouse", 7, -15, { dmg = DMG(20, 100) })
  b:put("bi-bio-greenhouse", 11, -15, { dead = 0.4 })
  b:put("angels-composter", 7, -10, { dmg = DMG(20, 100) })
  b:put("bi-wooden-chest-large", 11, -10, { items = { seedling = R(10, 40), ["bi-seed"] = R(20, 60), ["angels-solid-compost"] = R(20, 60) } })
  b:ring("bi-wooden-fence", -16, -16, 15, 15, { gap = 0.3, dead = 0.3 })
  b:tiles_rect("grass-1", -15, -5, 14, 14, 0.5)
  b:scatter_deco(lib.TREE, 20, nil, { -15, -4, 15, 15 })
end)

def("pd-defect-graveyard", function(b)
  -- An entire workshop of rejected production. Good for parts, bad for pride.
  b:ring("stone-wall", -16, -16, 15, 15, { gap = 0.25, dead = 0.3, door = { { -1, 15 }, { 0, 15 } } })
  b:put("burner-assembling-machine", -14, -14, { quality = "ic-defect-5", dmg = DMG(50, 200) })
  b:put("burner-assembling-machine", -10, -14, { quality = "ic-defect-4", dead = 0.4 })
  b:put("burner-assembling-machine", -6, -14, { quality = "ic-defect-5" })
  b:put("burner-lab", -2, -14, { quality = "ic-defect-3", dmg = DMG(20, 100) })
  b:put("burner-mining-drill", 3, -14, { quality = "ic-defect-5" })
  b:put("burner-mining-drill", 6, -14, { quality = "ic-defect-4", dead = 0.3 })
  b:scatter("stone-furnace", 6, { quality = "ic-defect-5", dmg = DMG(10, 60) }, { -15, -9, 15, -2 })
  b:scatter("wooden-chest", 8, { items = { ["burner-inserter"] = Q(R(5, 20), "ic-defect-5"), ["bob-basic-transport-belt"] = Q(R(10, 40), "ic-defect-5") } }, { -15, -1, 15, 10 })
  b:put("ic-control-post", -2, 11, { dmg = DMG(20, 80) })
  b:put("iron-chest", 2, 12, { items = {
    ["stone-furnace"] = Q(R(2, 4), "normal"), ["burner-inserter"] = Q(R(5, 10), "normal"),
    ["burner-mining-drill"] = Q(R(1, 3), "normal"), ["burner-assembling-machine"] = Q(R(0, 1), "normal") } })
end):weight(0.7)

def("pd-dart-stronghold", function(b)
  b:ring("bi-wooden-fence", -15, -15, 14, 14, { door = { { -1, 14 }, { 0, 14 } }, dead = 0.1 })
  b:ring("bi-wooden-fence", -10, -10, 9, 9, { door = { { -1, -10 }, { 0, -10 } }, dead = 0.1 })
  for _, p in ipairs({ { -13, -13 }, { 12, -13 }, { -13, 12 }, { 12, 12 }, { -8, -8 }, { 7, -8 }, { -8, 7 }, { 7, 7 } }) do
    b:put("bi-dart-turret", p[1], p[2], { force = "enemy", items = { ["bi-dart-magazine-standard"] = R(5, 15) } })
  end
  b:put("bi-wooden-chest-large", -1, -1, { items = {
    ["bi-dart-magazine-enhanced"] = R(10, 30), ["bi-dart-turret"] = R(1, 4), ["bi-dart-rifle"] = R(0, 1),
    ["iron-gear-wheel"] = R(30, 80), ["light-armor"] = Q(1, "normal") } })
end):far(900):tag("danger")

def("pd-mg-fortress", function(b)
  b:ring("stone-wall", -15, -15, 14, 14, { gap = 0.05, door = { { -1, 14 }, { 0, 14 } } })
  for _, p in ipairs({ { -13, -13 }, { 11, -13 }, { -13, 11 }, { 11, 11 }, { -1, -13 }, { -13, -1 } }) do
    b:put("gun-turret", p[1], p[2], { force = "enemy", items = { ["firearm-magazine"] = R(5, 20) } })
  end
  b:put("steel-chest", -2, -2, { items = { ["piercing-rounds-magazine"] = R(20, 60), ["gun-turret"] = R(1, 3), ["heavy-armor"] = Q(R(0, 1), "normal") } })
  b:put("steel-chest", 1, -2, { items = { ["steel-plate"] = R(30, 80), ["electronic-circuit"] = R(10, 30), ["repair-pack"] = R(10, 20) } })
  b:put("steel-chest", -2, 1, { items = { ["submachine-gun"] = R(0, 1), ["military-science-pack"] = R(0, 10) } })
  b:tiles_rect("stone-path", -14, -14, 13, 13, 0.5)
end):weight(0.8):far(1500):tag("danger")

def("pd-great-worm-pit", function(b)
  for _, p in ipairs({ { -13, -13 }, { 11, -13 }, { -13, 11 }, { 11, 11 }, { -1, -14 }, { -14, -1 }, { 12, -1 }, { -1, 12 } }) do
    b:put("small-worm-turret", p[1], p[2], { force = "enemy" })
  end
  for _, p in ipairs({ { -6, -6 }, { 4, -6 }, { -6, 4 }, { 4, 4 } }) do
    b:put("medium-worm-turret", p[1], p[2], { force = "enemy" })
  end
  b:put("big-worm-turret", -1, -1, { force = "enemy" })
  b:put("iron-chest", -1, 3, { items = { ["bob-alien-artifact"] = R(5, 15), ["bob-alien-artifact-red"] = R(1, 4), ["bob-alien-artifact-blue"] = R(1, 4) } })
  b:scatter_deco({ "small-biter-corpse", "medium-biter-corpse", "big-biter-corpse", "medium-spitter-corpse" }, 25)
  b:tiles_blob("red-desert-2", 0, 0, 15, 0.6)
end):weight(0.6):far(2000):tag("danger")

def("pd-mined-warehouse", function(b)
  b:tiles_rect("hazard-concrete-left", -16, -16, 15, -16)
  b:tiles_rect("hazard-concrete-left", -16, 15, 15, 15)
  b:tiles_rect("hazard-concrete-left", -16, -15, -16, 14)
  b:tiles_rect("hazard-concrete-left", 15, -15, 15, 14)
  b:ring("stone-wall", -5, -5, 4, 4, { door = { { -1, 4 }, { 0, 4 } } })
  b:put("bi-wooden-chest-large", -3, -3, { items = { ["iron-plate"] = R(50, 150), ["copper-plate"] = R(50, 150), ["steel-plate"] = R(10, 40) } })
  b:put("bi-wooden-chest-large", 1, -3, { items = { ["iron-gear-wheel"] = R(30, 100), ["electronic-circuit"] = R(5, 30), ["bob-basic-circuit-board"] = R(10, 40) } })
  b:scatter(ANY({ "land-mine", "land-mine", "bob-poison-mine", "bob-slowdown-mine" }), 40, { force = "enemy" }, { -14, -14, 14, 14 })
end):far(1200):tag("danger")

def("pd-flame-citadel", function(b)
  b:ring("stone-wall", -15, -15, 14, 14, { gap = 0.1, door = { { 0, 14 } } })
  for _, p in ipairs({ { -13, -13 }, { 11, -13 }, { -13, 10 }, { 11, 10 } }) do
    b:put("flamethrower-turret", p[1], p[2], { force = "enemy", fluids = { ["crude-oil"] = R(60, 100) } })
  end
  b:put("storage-tank", -2, -2, { fluids = { ["crude-oil"] = R(5000, 25000) } })
  b:put("gun-turret", 4, -2, { force = "enemy", items = { ["firearm-magazine"] = R(5, 15) } })
  b:put("steel-chest", -2, 3, { items = { ["engine-unit"] = R(2, 8), ["crude-oil-barrel"] = R(5, 15), ["steel-plate"] = R(20, 60) } })
  b:scatter_deco({ "big-scorchmark", "huge-scorchmark", "medium-scorchmark" }, 15)
end):weight(0.5):far(2200):tag("danger")

def("pd-mining-camp", function(b)
  b:put("bob-mining-drill-1", -14, -14, { dmg = DMG(50, 200) })
  b:put("bob-mining-drill-1", -10, -14, { dead = 0.4 })
  b:put("burner-mining-drill", -6, -14, { dmg = DMG(20, 100) })
  b:put("burner-mining-drill", -3, -14, { dead = 0.4 })
  b:put("bi-wooden-chest-large", -14, -9, { items = { ["iron-ore"] = R(40, 150), ["copper-ore"] = R(30, 100) } })
  b:put("bi-wooden-chest-large", -11, -9, { items = { ["bob-tin-ore"] = R(20, 60), ["bob-lead-ore"] = R(20, 60), coal = R(20, 80) } })
  b:put("straight-rail", 2, -16, { dead = 0.3 })
  b:put("straight-rail", 2, -14, { dead = 0.3 })
  b:put("straight-rail", 2, -12, { dead = 0.3 })
  b:ring("bi-wooden-fence", 4, -4, 14, 8, { gap = 0.3, door = { { 9, -4 } } })
  b:put("torch", 6, -2)
  b:put("torch", 12, -2)
  b:put("wooden-chest", 9, 2, { items = { ["mining-drill-bit-mk1"] = R(1, 4), ["raw-fish"] = R(2, 8), respirator = R(0, 2) } })
  b:scatter(lib.ROCKS, 6, nil, { -16, 0, 4, 16 })
end)

def("pd-steam-plant", function(b)
  b:put("boiler", -14, -14, { dmg = DMG(50, 150) })
  b:put("boiler", -14, -6, { dead = 0.5 })
  b:put("steam-engine", -14, -12, { dmg = DMG(50, 300) })
  b:put("steam-engine", -11, -12, { dead = 0.5 })
  b:put("steam-engine", -8, -12, { dmg = DMG(50, 300) })
  b:put("bi-wooden-chest-large", -4, -14, { items = { coal = R(50, 200), wood = R(20, 60) } })
  b:scatter(POLES, 8, { dead = 0.3 })
  b:ring("stone-wall", -16, -16, 15, 15, { gap = 0.5, dead = 0.5 })
  b:tiles_rect("stone-path", -15, -15, 0, 0, 0.5)
end)

def("pd-wind-park", function(b)
  for _, p in ipairs({ { -14, -14 }, { -7, -14 }, { 0, -14 }, { 7, -14 }, { -14, -6 }, { -7, -6 }, { 0, -6 }, { 7, -6 }, { -14, 2 }, { 0, 2 }, { 7, 2 }, { -7, 10 }, { 7, 10 } }) do
    b:put("texugo-wind-turbine", p[1], p[2], { dead = 0.3, dmg = DMG(10, 120) })
  end
  b:scatter(POLES, 10, { dead = 0.3 })
  b:put("wooden-chest", -1, 10, { items = { ["copper-cable"] = R(20, 60), ["texugo-wind-turbine"] = Q(R(0, 2), "ic-defect-2") } })
end)

def("pd-tank-farm", function(b)
  b:put("storage-tank", -14, -14, { fluids = { ["crude-oil"] = R(2000, 20000) }, dmg = DMG(50, 300) })
  b:put("storage-tank", -10, -14, { dead = 0.4 })
  b:put("storage-tank", -6, -14, { fluids = { water = R(1000, 10000) } })
  b:put("angels-flare-stack", 0, -14, { dmg = DMG(20, 100) })
  b:put("angels-storage-tank-3", 4, -14, { dead = 0.5 })
  b:put("bi-wooden-chest-large", -14, -8, { items = { ["crude-oil-barrel"] = R(5, 20), barrel = R(5, 20), ["lubricant-barrel"] = R(0, 3) } })
  b:scatter({ "pipe", "bob-steel-pipe", "pipe-to-ground" }, 20, { dead = 0.4 })
  b:tiles_blob("dirt-6", 0, 0, 15, 0.5)
end)

def("pd-chemical-complex", function(b)
  b:put("chemical-plant", -14, -14, { dmg = DMG(50, 200) })
  b:put("chemical-plant", -10, -14, { dead = 0.4 })
  b:put("chemical-plant", -6, -14, { dmg = DMG(50, 200) })
  b:put("angels-electrolyser", -2, -14, { dead = 0.3 })
  b:put("storage-tank", 4, -14, { fluids = { water = R(1000, 8000) } })
  b:put("iron-chest", -14, -9, { items = { sulfur = R(20, 80), ["sulfuric-acid-barrel"] = R(2, 8), ["angels-gas-chlorine-barrel"] = R(0, 4) } })
  b:put("iron-chest", -13, -9, { items = { ["plastic-bar"] = R(0, 20), ["bob-rubber"] = R(0, 20), ["angels-solid-lime"] = R(10, 40) } })
  b:tiles_blob("nuclear-ground", 4, 6, 8, 0.5)
  b:scatter({ "pipe", "bob-copper-pipe" }, 15, { dead = 0.5 })
end):far(800)

def("pd-angels-refinery", function(b)
  b:put("angels-ore-crusher", -14, -14, { dmg = DMG(50, 200) })
  b:put("angels-ore-crusher", -10, -14, { dead = 0.4 })
  b:put("angels-ore-sorting-facility", -6, -15, { dmg = DMG(100, 400) })
  b:put("angels-washing-plant", 3, -15, { dead = 0.3 })
  b:put("angels-clarifier", 9, -15, { dmg = DMG(50, 200) })
  b:put("bi-wooden-chest-large", -14, -9, { items = { ["angels-ore1-crushed"] = R(40, 120), ["angels-ore3-crushed"] = R(30, 100), ["angels-slag"] = R(30, 100) } })
  b:put("bi-wooden-chest-large", -11, -9, { items = { ["angels-ore2-crushed"] = R(0, 60), ["angels-ore4-crushed"] = R(0, 60), ["angels-solid-mud"] = R(20, 60) } })
  b:scatter(lib.ROCKS, 6, nil, { -16, 0, 16, 16 })
  b:tiles_rect("concrete", -15, -15, 14, -7, 0.4)
end):far(600)

def("pd-crash-site", function(b)
  b:put("aai-big-ship-wreck-1", -6, -6, { items = { ["steel-plate"] = R(20, 60), ["sci-component-2"] = R(2, 10) } })
  b:put("aai-big-ship-wreck-2", 4, -10, { items = { ["electronic-circuit"] = R(10, 30) } })
  b:put("aai-big-ship-wreck-3", -12, 4, { items = { ["bob-alien-artifact"] = R(1, 5) } })
  b:put("crash-site-spaceship-wreck-big-1", 8, 2)
  b:put("crash-site-spaceship-wreck-big-2", -2, 8)
  b:scatter({ "aai-medium-ship-wreck-1", "aai-medium-ship-wreck-2" }, 8, { items = { ["copper-cable"] = R(5, 20), motor = R(0, 3) } })
  b:scatter("aai-small-ship-wreck", 12)
  b:scatter_deco({ "big-scorchmark", "huge-scorchmark", "medium-scorchmark" }, 18)
  b:put("small-worm-turret", 12, -14, { force = "enemy" })
end):weight(0.6):far(1000):tag("danger")

def("pd-ghost-town", function(b)
  local houses = { { -15, -15 }, { -5, -15 }, { 5, -15 }, { -15, -3 }, { 5, -3 }, { -15, 8 }, { -5, 8 }, { 5, 8 } }
  for i, h in ipairs(houses) do
    local x, y = h[1], h[2]
    b:ring("stone-wall", x, y, x + 7, y + 6, { gap = 0.25, dead = 0.3, door = { { x + 3, y + 6 } } })
    b:tiles_rect("stone-path", x + 1, y + 1, x + 6, y + 5)
    b:put(i % 2 == 0 and "iron-chest" or "wooden-chest", x + 2, y + 2, { items = {
      ["raw-fish"] = R(0, 3), wood = R(0, 10), ["iron-gear-wheel"] = R(0, 6), ["copper-cable"] = R(0, 10),
      ["repair-pack"] = R(0, 2), respirator = R(0, 1) } })
    b:put("small-lamp", x + 5, y + 2, { dead = 0.4 })
  end
  b:put("deadlock-large-lamp", -2, -1)
  b:put("wooden-chest", 1, 0, { items = { torch = R(1, 4), pistol = R(0, 1), ["firearm-magazine"] = R(0, 10) } })
end)

def("pd-vehicle-graveyard", function(b)
  b:scatter("car", 5, { dead = 0.7, dmg = DMG(100, 300) })
  b:scatter_deco({ "car-remnants", "tank-remnants", "medium-scorchmark" }, 10)
  b:scatter("iron-chest", 6, { items = { ["iron-plate"] = R(10, 40), ["iron-gear-wheel"] = R(5, 20), ["engine-unit"] = R(0, 1) }, dmg = DMG(10, 80) })
  b:tiles_blob("dirt-7", 0, 0, 15, 0.6)
end):far(800)

def("pd-research-center", function(b)
  b:tiles_rect("refined-concrete", -15, -15, 14, 14, 0.8)
  b:put("big-lab", -15, -15, { dmg = DMG(200, 800) })
  b:put("lab", 2, -15, { dead = 0.4 })
  b:put("lab", 6, -15, { dmg = DMG(40, 150) })
  b:put("burner-lab", 10, -15, { dead = 0.3 })
  b:put("steel-chest", 3, -10, { items = { ["automation-science-pack"] = R(10, 40), ["logistic-science-pack"] = R(5, 20) } })
  b:put("steel-chest", 5, -10, { items = { ["sci-component-1"] = R(10, 40), ["sci-component-2"] = R(5, 20), ["chemical-science-pack"] = R(0, 3) } })
  b:ring("stone-wall", -16, -16, 15, 15, { gap = 0.3, dead = 0.4 })
end):weight(0.4):far(1500):tag("rare")

def("pd-stonehenge", function(b)
  for i = 0, 11 do
    local a = i * math.pi / 6
    b:try_put("huge-rock", math.floor(11 * math.cos(a)) - 1, math.floor(11 * math.sin(a)) - 1)
  end
  for i = 0, 5 do
    local a = i * math.pi / 3 + 0.5
    b:try_put("huge-rock", math.floor(5 * math.cos(a)) - 1, math.floor(5 * math.sin(a)) - 1)
  end
  b:put("steel-chest", -1, -1, { items = {
    ["bob-alien-artifact"] = R(3, 10), ["bob-alien-artifact-purple"] = R(1, 3), ["bob-alien-artifact-orange"] = R(1, 3),
    ["bob-alien-artifact-yellow"] = R(1, 3), ["angels-crystal-dust"] = R(10, 30) } })
  b:tiles_blob("rough-stone-path", 0, 0, 3)
end):weight(0.4):far(1200):tag("rare")

def("pd-oasis", function(b)
  b:tiles_blob("water", 0, 0, 7)
  b:tiles_blob("grass-1", 0, 0, 14, 0.7)
  b:reserve(-8, -8, 7, 7)
  b:deco("fish", 0.5, 0.5)
  b:deco("fish", -2.5, 2)
  b:deco("fish", 3, -2)
  b:scatter_deco(lib.TREE, 24, nil, { -16, -16, 16, -9 })
  b:scatter_deco(lib.TREE, 12, nil, { -16, 9, 16, 16 })
  b:put("wooden-chest", 10, 10, { items = { ["raw-fish"] = R(5, 20), wood = R(5, 20), ["angels-temperate-3-seed"] = R(0, 10) } })
  b:put("torch", 12, 10)
end)

def("pd-swamp-village", function(b)
  -- Wooden platforms first: the first tile written to a position wins.
  b:tiles_rect("bi-wood-floor", -12, -12, -5, -6)
  b:tiles_rect("bi-wood-floor", 4, -12, 11, -6)
  b:tiles_rect("bi-wood-floor", -4, 5, 3, 11)
  b:tiles_blob("water-mud", 0, 0, 14, 0.85)
  b:put("wooden-chest", -10, -10, { items = { ["angels-solid-mud"] = R(10, 40), ["angels-swamp-1-seed"] = R(5, 20) } })
  b:put("wooden-chest", 6, -10, { items = { ["angels-algae-brown"] = R(10, 40), ["raw-fish"] = R(2, 10) } })
  b:put("wooden-chest", -1, 7, { items = { wood = R(20, 60), ["bi-ash"] = R(5, 20), ["angels-swamp-3-seed"] = R(0, 10) } })
  b:put("torch", -8, -8)
  b:put("torch", 8, -8)
  b:put("torch", 1, 9)
  b:scatter_deco(lib.DEAD_TREES, 15)
end)

def("pd-blast-site", function(b)
  b:scatter_deco({ "huge-scorchmark", "big-scorchmark", "medium-scorchmark" }, 30)
  b:tiles_blob("dirt-7", 0, 0, 15, 0.7)
  b:put("steel-chest", -1, -1, { items = { explosives = R(5, 20), ["cliff-explosives"] = R(0, 3), grenade = R(2, 10) } })
  b:scatter(ANY({ "land-mine", "bob-distractor-mine" }), 20, { force = "enemy" }, { -14, -14, 14, 14 })
  b:tiles_rect("hazard-concrete-right", -16, -16, 15, -16)
end):weight(0.7):far(1400):tag("danger")

def("pd-museum", function(b)
  -- A museum of the future: exhibits from technologies this colony never reached.
  b:tiles_rect("refined-concrete", -10, -10, 9, 9)
  b:ring("stone-wall", -11, -11, 10, 10, { door = { { -1, 10 }, { 0, 10 } } })
  local exhibits = {
    { "rocket-fuel", R(1, 3) }, { "low-density-structure", R(1, 2) }, { "nuclear-fuel", R(0, 1) },
    { "processing-unit", R(2, 5) }, { "speed-module", R(0, 1) }, { "productivity-module", R(0, 1) },
    { "flying-robot-frame", R(1, 3) }, { "exoskeleton-equipment", R(0, 1) }, { "night-vision-equipment", R(0, 1) },
    { "uranium-235", R(0, 2) }, { "bob-titanium-plate", R(5, 20) }, { "bob-gold-plate", R(5, 20) },
  }
  for i, ex in ipairs(exhibits) do
    local col, row = (i - 1) % 4, math.floor((i - 1) / 4)
    b:put("steel-chest", -8 + col * 5, -8 + row * 6, { items = { [ex[1]] = ex[2] } })
    b:put("small-lamp", -7 + col * 5, -8 + row * 6)
  end
end):weight(0.2):far(2500):tag("rare")

def("pd-algae-plantation", function(b)
  b:tiles_rect("water-green", -15, 2, 14, 14)
  b:reserve(-16, 2, 15, 15)
  b:put("angels-algae-farm", -15, -15, { dmg = DMG(100, 400) })
  b:put("angels-algae-farm", -7, -15, { dead = 0.4 })
  b:put("angels-hydro-plant", 1, -15, { dmg = DMG(50, 200) })
  b:put("bi-wooden-chest-large", 8, -14, { items = { ["angels-algae-green"] = R(40, 120), ["angels-algae-brown"] = R(20, 80), ["angels-cellulose-fiber"] = R(20, 80) } })
end)

def("pd-quarry", function(b)
  b:tiles_blob("dirt-4", 0, 0, 15, 0.8)
  b:put("angels-burner-ore-crusher", -2, -2, { dmg = DMG(50, 200) })
  b:put("bi-stone-crusher", 3, -2, { dead = 0.4 })
  b:put("bi-wooden-chest-large", -2, 3, { items = { stone = R(50, 200), ["angels-stone-crushed"] = R(50, 150), ["stone-brick"] = R(10, 40) } })
  b:scatter("huge-rock", 8)
  b:scatter(lib.ROCKS, 14)
end)

-- Oil trap (Flammable Oils): three connected tanks and a long pipeline. The fire starts at the far
-- end of the pipeline when a player comes close and reaches the tanks one after another.
-- Pipe tiles follow the storage-tank connection geometry: west inlet = (x - 1, y), east outlet = (x + 3, y + 2).
def("pd-flo-trap-tank-farm", function(b)
  local OIL = { ["crude-oil"] = R(40, 90) }
  for _, x in ipairs({ -15, -11, -7 }) do
    b:put("storage-tank", x, -15, { fluids = { ["crude-oil"] = R(12000, 24000) }, dmg = DMG(20, 150) })
  end
  for _, x in ipairs({ -12, -8 }) do
    for y = -15, -13 do b:put("pipe", x, y, { fluids = OIL }) end
  end
  for x = -4, 12 do b:put("bob-steel-pipe", x, -13, { fluids = OIL }) end
  for y = -12, 10 do b:put("bob-steel-pipe", 12, y, { fluids = OIL }) end
  b:put("iron-chest", -15, -10, { items = { ["artillery-shell"] = R(2, 8), ["explosive-cannon-shell"] = R(10, 40) } })
  b:put("iron-chest", -14, -10, { items = { rocket = R(10, 40), ["explosive-rocket"] = R(0, 20) } })
  b:put("iron-chest", -13, -10, { items = { explosives = R(20, 60), ["rocket-fuel"] = R(2, 10) } })
  b:put("iron-chest", 10, 11, { items = { ["electric-engine-unit"] = R(4, 16), ["advanced-circuit"] = R(10, 30) } })
  b:put("iron-chest", 13, 11, { items = { ["plastic-bar"] = R(40, 120), ["steel-plate"] = R(40, 120), ["solid-fuel"] = R(20, 60) } })
  b:scatter_deco(lib.DEAD_TREES, 8, nil, { -16, -4, 8, 16 })
  b:scatter_deco({ "medium-scorchmark", "big-scorchmark" }, 5, nil, { -16, -4, 8, 16 })
  b:tiles_blob("dirt-6", -4, -6, 12, 0.5)
end):weight(0.5):far(1200)

def("pd-landfill-earthworks", function(b)
  -- Abandoned earthworks: heaps of dirt, the landfill stock in the middle.
  b:tiles_blob("dirt-6", 0, 0, 12, 0.6)
  b:tiles_blob("dirt-4", -8, -6, 5, 0.8)
  b:tiles_blob("dirt-4", 7, 6, 5, 0.8)
  b:put("iron-chest", 0, 0, { items = { landfill = R(30, 100) } })
  b:put("wooden-chest", 1, 0, { items = { stone = R(20, 60), wood = R(0, 10) }, dead = 0.3 })
  b:put("burner-mining-drill", -10, 8, { dmg = DMG(30, 120) })
  b:put("burner-mining-drill", 8, -10, { dead = 0.6 })
  b:scatter(lib.ROCKS, 8)
  b:scatter_deco(lib.STUMPS, 6)
  b:scatter("wooden-chest", 3, { dead = 1 })
end)

return list
