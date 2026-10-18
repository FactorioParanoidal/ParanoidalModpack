-- The single balance table of the start crash. Edit the numbers here; the code only reads them.
-- Read by the data stage (wreck mining loot of the prototypes, used everywhere incl. ruins:
-- always these "medium" amounts, normal quality) and by control.lua (the start crash only).
--
-- Entry forms: {"item", count}, {"item", min, max}; optional p = chance (0..1) for mining loot.
-- Missing optional items are skipped with a log line.

local config = {}

config.setting = "zzzparanoidal-shipwreck-start" -- startup setting with the level name
config.default_level = "rich"

-- amount: multiplier for every count of the start crash (both range ends, rounded up, at least 1).
-- defects: finished items that the defect system can make defective get a random defect.
-- bonus: every finished item (also defect-exempt ones) gets a random positive quality.
-- Materials and intermediate products are always normal. One roll per item type per map,
-- so all stacks of one item from the ship, debris and mining loot have the same quality.
config.levels = {
    minimum = {amount = 0.5, defects = true},
    medium = {amount = 1},
    rich = {amount = 1, bonus = true},
}
config.level_order = {"minimum", "medium", "rich"}
config.quality_steps = 5 -- random 1..5 steps: defects ic-defect-1..5, bonus along normal.next
config.defect_prefix = "ic-defect-"
config.classification = "ic-defects-classification" -- mod-data of ic-more-qualities
-- Items placing these entity types get defects on the minimum level even when the defect system
-- exempts them (user decision 2026-10-18: all electric poles).
config.always_defect_place_types = {["electric-pole"] = true}

config.mining_time = 1.5 -- every wreck and the ship
config.target_prefix = "paranoidal-shipwreck-mining-" -- invisible pickaxe targets
config.ship = "crash-site-spaceship"
config.ship_inventory_size = 80
config.ship_position = {-5, -6} -- freeplay crash site
config.crash_radius = 64 -- freeplay places parts at most 48 tiles from the ship

-- Freeplay start: the player starts empty (created items are cleared), respawn items stay.
config.ship_items = {
    {"salvaged-assembling-machine", 2, 3},
    {"salvaged-lab", 1},
    {"burner-assembling-machine", 1},
    {"burner-mining-drill", 5, 7},
    {"assembling-machine-2", 1},
    {"stone-furnace", 1},
    {"angels-burner-ore-crusher", 1},
    {"radar", 1, 3},
    {"steel-chest", 1, 2},
    {"inserter", 15, 75},
    {"long-handed-inserter", 5, 35},
    {"fast-inserter", 5, 35},
    {"bob-basic-transport-belt", 50, 150},
    {"bob-basic-underground-belt", 10},
    {"bob-basic-splitter", 5, 15},
    {"medium-electric-pole", 5, 35},
    {"big-electric-pole", 2, 9},
    {"pipe-to-ground", 5, 15},
    {"repair-pack", 102, 209},
    {"pistol", 1},
    {"firearm-magazine", 23, 37},
    {"copper-plate", 50, 150},
    {"bob-basic-circuit-board", 20, 40},
    {"bob-integrated-electronics", 5, 35},
    {"battery", 2, 19},
    {"bob-battery-3", 2, 9},
    {"angels-slag", 5, 35},
    {"angels-stone-crushed", 5, 35},
    {"stone", 5, 35},
    {"wood", 6, 36},
}

-- Whole stacks into random start wreck containers (crash site and AAI wrecks); the rest goes
-- into the ship, then onto the ground next to it.
config.debris_items = {
    {"iron-plate", 41},
    {"copper-plate", 20},
    {"transport-belt", 84},
    {"motor", 24},
    {"bob-titanium-bearing-ball", 2},
    {"intelligent-io", 1},
}

-- Mining loot of the ship.
config.ship_loot = {
    {"steel-plate", 5, 25},
    {"iron-gear-wheel", 5, 20},
    {"electronic-circuit", 4, 12},
    {"concrete", 25, 85},
    {"pipe", 5, 45},
    {"bob-aluminium-plate", 5, 85},
    {"bob-titanium-plate", 5, 85},
    {"condensator3", 5, 35},
    {"bob-processing-electronics", 1, 5},
    {"bob-insulated-cable", 11, 39},
    {"bob-basic-circuit-board", 8},
    {"salvaged-generator", 1},
}

-- Every wreck: mining loot and (AAI only) start contents.
config.wrecks = {
    ["crash-site-spaceship-wreck-small-1"] = {loot = {{"iron-plate", 2, 30}, {"bob-basic-circuit-board", 1, 2}}},
    ["crash-site-spaceship-wreck-small-2"] = {loot = {{"copper-plate", 2, 30}, {"bob-basic-circuit-board", 1, 2}}},
    ["crash-site-spaceship-wreck-small-3"] = {loot = {{"pipe", 2, 30}, {"bob-basic-circuit-board", 1, 2}}},
    ["crash-site-spaceship-wreck-small-4"] = {loot = {{"steel-plate", 2, 30}, {"bob-basic-circuit-board", 1, 2}}},
    ["crash-site-spaceship-wreck-small-5"] = {loot = {{"iron-plate", 2, 30}, {"bob-basic-circuit-board", 1, 2}}},
    ["crash-site-spaceship-wreck-small-6"] = {loot = {{"copper-plate", 2, 30}, {"bob-basic-circuit-board", 1, 2}}},
    ["crash-site-spaceship-wreck-medium-1"] = {loot = {
        {"sci-component-1", 1, 10},
        {"sci-component-2", 1, 4},
        {"copper-cable", 25, 55},
        {"CW-air-filter", 5, 15},
        {"bob-basic-circuit-board", 2, 4},
    }},
    ["crash-site-spaceship-wreck-medium-2"] = {loot = {
        {"electronic-circuit", 1, 2},
        {"rocket-fuel", 1, 4},
        {"pipe", 2, 5},
        {"bob-titanium-plate", 1, 4},
        {"bob-basic-circuit-board", 2, 4},
    }},
    ["crash-site-spaceship-wreck-medium-3"] = {loot = {
        {"steel-plate", 2, 6},
        {"iron-plate", 5, 25},
        {"bob-aluminium-plate", 1, 10},
        {"bob-titanium-plate", 1, 5},
        {"bob-basic-circuit-board", 2, 4},
    }},
    ["crash-site-spaceship-wreck-big-1"] = {loot = {
        {"steel-plate", 2, 8},
        {"iron-plate", 15, 35},
        {"bob-aluminium-plate", 5, 25},
        {"bob-titanium-plate", 5, 10},
        {"bob-basic-circuit-board", 4, 8},
    }},
    ["crash-site-spaceship-wreck-big-2"] = {loot = {
        {"electronic-circuit", 1, 5},
        {"rocket-fuel", 2, 10},
        {"pipe", 5, 15},
        {"bob-titanium-plate", 5, 10},
        {"bob-basic-circuit-board", 4, 8},
    }},
    ["aai-big-ship-wreck-1"] = {
        items = {{"burner-assembling-machine", 1}},
        loot = {{"iron-plate", 62}, {"copper-plate", 38}, {"steel-plate", 7}, {"iron-gear-wheel", 9}, {"electronic-circuit", 2}},
    },
    ["aai-big-ship-wreck-2"] = {
        items = {{"iron-plate", 6}},
        loot = {{"iron-plate", 58}, {"copper-plate", 36}, {"steel-plate", 3}, {"iron-gear-wheel", 7}, {"electronic-circuit", 1}},
    },
    ["aai-big-ship-wreck-3"] = {
        items = {{"motor", 1}},
        loot = {{"iron-plate", 38}, {"copper-plate", 44}, {"steel-plate", 2}, {"iron-gear-wheel", 5}, {"electronic-circuit", 1}},
    },
    ["aai-medium-ship-wreck-1"] = {loot = {{"iron-plate", 24}, {"iron-gear-wheel", 3}}},
    ["aai-medium-ship-wreck-2"] = {loot = {{"copper-plate", 18}, {"iron-gear-wheel", 2}}},
    ["aai-small-ship-wreck"] = {loot = {
        {"iron-plate", 5, 25, p = 0.75},
        {"copper-plate", 5, 25, p = 0.25},
        {"iron-gear-wheel", 2, 5, p = 0.5},
    }},
}

-- AAI crash scene around {0, 0} on a new map (from the old AAI Industry crash sequence).
config.aai_crash = {
    tree_clear_range = 20,
    parts = {
        {names = {"big-remnants"}, count = 5, radius = 15},
        {names = {"medium-remnants"}, count = 10, radius = 25},
        {names = {"small-remnants"}, count = 15, radius = 50},
        {names = {"aai-big-ship-wreck-1", "massive-explosion"}, count = 1, radius = 10},
        {names = {"aai-big-ship-wreck-2", "big-explosion"}, count = 1, radius = 10},
        {names = {"aai-big-ship-wreck-3"}, count = 3, radius = 10},
        {names = {"aai-medium-ship-wreck-1", "medium-explosion"}, count = 3, radius = 25},
        {names = {"aai-medium-ship-wreck-2"}, count = 3, radius = 25},
        {names = {"aai-small-ship-wreck"}, count = 30, radius = 50},
        {names = {"fire-flame-on-tree"}, count = 25, radius = 15, min_radius = 5},
        {names = {"dead-dry-hairy-tree", "fire-flame-on-tree", "fire-flame-on-tree"}, count = 10, radius = 20, min_radius = 5},
    },
}

-- Salvaged ship generator: quality scales production (QualityPrototype::default_multiplier) and
-- buffer (accumulator_capacity_multiplier); the output limit is output_ratio x production of
-- the best start quality (normal + quality_steps).
config.generator = {
    name = "salvaged-generator",
    production_kw = 750,
    buffer_mj = 15,
    output_ratio = 2,
}

return config
