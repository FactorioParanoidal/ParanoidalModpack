-- All build stack-size choices live here. Algorithms do not own balance numbers.
-- Initial item definitions in their owning mods remain valid standalone prototype defaults.
local C = {}

-- Constructors keep valid required fields, but their configurable defaults are chosen here too.
-- Set size explicitly to override a saved startup setting; nil keeps its existing value.
C.initial = {
    components = {setting = "angels-components-stack-size"},
    pavement = {setting = "angels-pavement-stack-size"},
}
function C.initial_size(key, startup)
    local spec = assert(C.initial[key], "Unknown initial stack policy: " .. key)
    local size = spec.size or assert(startup[spec.setting], "Missing stack setting: " .. spec.setting).value
    assert(type(size) == "number" and size >= 1 and size % 1 == 0, "Invalid initial stack policy: " .. key)
    return size
end

C.categories = {
  ores = 200, plates = 400, ["rocket-parts"] = 10, ["science-pack"] = 200,
  ["fuel-category-nuclear"] = 5, uranium = 100, wood = 200, ["solid-fuel"] = 100,
  ["nuclear-fuel"] = 10, tiles = 500,
  belt = 100, pipe = 100, container = 0, inserter = 50, ["electric-pole"] = 50,
  roboport = 20, robot = 0, rail = 200, ["rail-signal"] = 0, ["train-stop"] = 0,
  ["train-carriage"] = 0, car = 0, combinator = 50, wire = 400,
  reactor = 10, ["crafting-machine"] = 20, furnace = 20, beacon = 20,
  ["mining-drill"] = 20, boiler = 20, generator = 20, modules = 0,
  wall = 0, turret = 0,
  ["ammo-bullet"] = 200, ["ammo-shotgun"] = 200, ["ammo-flamethrower"] = 100,
  ["ammo-rocket"] = 200, ["ammo-cannon"] = 200, ["ammo-artillery"] = 10,
  ["barrel-stack"] = 5, ["barrel-fill"] = 100,
}

C.pre = {
    {source = "bobores", mod = "bobores", size = 200, names = {"copper-ore", "iron-ore", "stone", "coal", "uranium-ore", "sulfur"}},
    {source = "bobelectronics", mod = "bobelectronics", size = 200, names = {"wood"}},
    {source = "bobplates", mod = "bobplates", size = 200, names = {"processing-unit", "iron-plate", "copper-plate", "steel-plate", "coal", "uranium-ore", "sulfur", "wood"}},
    {source = "bobplates-nuclear", mod = "bobplates", size = 2, names = {"nuclear-fuel"}},
    {source = "boblogistics-roboport", mod = "boblogistics", size = 10, names = {"roboport"}},
    {source = "boblogistics-trains", mod = "boblogistics", setting = "bobmods-logistics-trains", kind = "item-with-entity-data", size = 10, names = {"locomotive", "cargo-wagon", "fluid-wagon"}},
    {source = "bobwarfare-tank", mod = "bobwarfare", kind = "item-with-entity-data", size = 10, names = {"tank"}},
    {source = "bobwarfare-artillery", mod = "bobwarfare", kind = "ammo", size = 20, names = {"artillery-shell"}},
    {source = "bobassembly", mod = "bobassembly", setting = "bobmods-assembly-chemicalplants", size = 50, names = {"chemical-plant"}},
    {source = "angels-pavement", mod = "angelsrefining", initial = "pavement", names = {"stone-brick", "concrete", "hazard-concrete", "refined-concrete", "refined-hazard-concrete", "landfill"}},
    {source = "angels-iron-stick", mod = "angelssmelting", size = 200, names = {"iron-stick"}},
    {source = "angels-base-minimum", mod = "angelssmelting", action = "minimum", size = 200, names = {"coal", "uranium-ore", "stone"}},
    {source = "angels-iron-ore-minimum", mod = "angelssmelting", trigger = "ore:iron", action = "minimum", size = 200, names = {"iron-ore"}},
    {source = "angels-copper-ore-minimum", mod = "angelssmelting", trigger = "ore:copper", action = "minimum", size = 200, names = {"copper-ore"}},
    {source = "angels-iron-plate-minimum", mod = "angelssmelting", trigger = "plate:iron", action = "minimum", size = 200, names = {"iron-plate"}},
    {source = "angels-copper-plate-minimum", mod = "angelssmelting", trigger = "plate:copper", action = "minimum", size = 200, names = {"copper-plate"}},
    {source = "angels-steel-plate-minimum", mod = "angelssmelting", trigger = "plate:steel", action = "minimum", size = 200, names = {"steel-plate"}},
    {source = "angels-silicon-minimum", mod = "angelssmelting", trigger = "powder:silicon", also_mod = "bobplates", action = "minimum", size = 200, names = {"bob-silicon-powder"}},
    -- Space Age branch: as in Bio Industries' own code, only when it sees Space Age (paranoidal-space-age-filter hides it).
    {source = "bi-tree-seed", mod = "Bio_Industries_2", also_mod = "space-age", size = 200, names = {"tree-seed"}},
    {source = "factorissimo-robot", mod = "factorissimo-2-notnotmelon", size = 1000, names = {"factory-hidden-construction-robot"}},
    {source = "factorissimo-efficient-smelting", mod = "factorissimo-2-notnotmelon", also_mod = "EfficientSmelting", size = 1, names = {"factory-connection-indicator-settings", "factory-overlay-controller-settings"}},
    {source = "toxic-armor", mod = "ToxicPollution2-reforged", kind = "armor", size = 10, names = {"light-armor", "heavy-armor"}},
    {source = "yuoki-repair", mod = "Yuoki", kind = "repair-tool", size = 100, names = {"y-repair-durotal", "y-repair-krakon"}},
    {source = "yuoki-repair-top", mod = "Yuoki", kind = "repair-tool", size = 50, names = {"y_repair_quantrinum"}},
}

C.bi = {
    tweaks = {
        wood = {minimum = 400, se_limit = 200}, stone = {minimum = 400, se_limit = 50},
        ["stone-crushed"] = {minimum = 800, se_limit = 200}, concrete = {minimum = 400, se_limit = 200},
        slag = {minimum = 800, se_limit = 200},
    },
    se_size = 200,
    se_items = {"bi-solar-mat", "bi-seed", "tree-seed", "seedling", "bi-woodpulp", "bi-ash", "wood-charcoal", "pellet-coke", "stone-crushed"},
    se_ammo = {"bi-dart-magazine-basic", "bi-dart-magazine-standard", "bi-dart-magazine-enhanced", "bi-dart-magazine-poison"},
}

C.early = {
    {source = "zzz-materials", size = 400, names = {"angels-slag", "angels-stone-crushed", "stone-brick"}},
    {source = "zzz-gears", size = 200, names = {"iron-gear-wheel"}},
    {source = "marathon", size = 400, names = {"bob-basic-electronic-components", "iron-plate", "copper-plate", "copper-cable"}},
}

-- These replace the stack fields of the imported Beta 8 module snapshot, including new tools.
C.module_items = {
    ["beacon"] = 20, -- item
    ["bob-beacon-2"] = 20, -- item
    ["bob-beacon-3"] = 20, -- item
    ["efficiency-module"] = 100, -- module
    ["efficiency-module-2"] = 100, -- module
    ["efficiency-module-3"] = 100, -- module
    ["bob-efficiency-module-4"] = 100, -- module
    ["bob-efficiency-module-5"] = 100, -- module
    ["bob-efficiency-module-6"] = 100, -- module
    ["bob-efficiency-module-7"] = 100, -- module
    ["bob-efficiency-module-8"] = 100, -- module
    ["bob-efficiency-processor"] = 200, -- tool
    ["bob-efficiency-processor-2"] = 100, -- item
    ["bob-efficiency-processor-3"] = 100, -- item
    ["god-module-1"] = 100, -- module
    ["god-module-2"] = 100, -- module
    ["god-module-3"] = 100, -- module
    ["god-module-4"] = 100, -- module
    ["god-module-5"] = 100, -- module
    ["green-module-1"] = 100, -- module
    ["green-module-2"] = 100, -- module
    ["green-module-3"] = 100, -- module
    ["green-module-4"] = 100, -- module
    ["green-module-5"] = 100, -- module
    ["green-module-6"] = 100, -- module
    ["green-module-7"] = 100, -- module
    ["green-module-8"] = 100, -- module
    ["lab-module"] = 10, -- item
    ["bob-module-case"] = 200, -- tool
    ["bob-module-circuit-board"] = 200, -- tool
    ["module-combining-case"] = 200, -- tool
    ["module-combining-solder"] = 200, -- item
    ["bob-module-contact"] = 200, -- item
    ["bob-module-processor-board"] = 200, -- item
    ["bob-module-processor-board-2"] = 200, -- item
    ["bob-module-processor-board-3"] = 200, -- item
    ["bob-pollution-clean-module-1"] = 100, -- module
    ["bob-pollution-clean-module-2"] = 100, -- module
    ["bob-pollution-clean-module-3"] = 100, -- module
    ["bob-pollution-clean-module-4"] = 100, -- module
    ["bob-pollution-clean-module-5"] = 100, -- module
    ["bob-pollution-clean-module-6"] = 100, -- module
    ["bob-pollution-clean-module-7"] = 100, -- module
    ["bob-pollution-clean-module-8"] = 100, -- module
    ["bob-pollution-clean-processor"] = 200, -- tool
    ["bob-pollution-clean-processor-2"] = 100, -- item
    ["bob-pollution-clean-processor-3"] = 100, -- item
    ["bob-pollution-create-module-1"] = 100, -- module
    ["bob-pollution-create-module-2"] = 100, -- module
    ["bob-pollution-create-module-3"] = 100, -- module
    ["bob-pollution-create-module-4"] = 100, -- module
    ["bob-pollution-create-module-5"] = 100, -- module
    ["bob-pollution-create-module-6"] = 100, -- module
    ["bob-pollution-create-module-7"] = 100, -- module
    ["bob-pollution-create-module-8"] = 100, -- module
    ["bob-pollution-create-processor"] = 200, -- tool
    ["bob-pollution-create-processor-2"] = 100, -- item
    ["bob-pollution-create-processor-3"] = 100, -- item
    ["productivity-module"] = 100, -- module
    ["productivity-module-2"] = 100, -- module
    ["productivity-module-3"] = 100, -- module
    ["bob-productivity-module-4"] = 100, -- module
    ["bob-productivity-module-5"] = 100, -- module
    ["bob-productivity-module-6"] = 100, -- module
    ["bob-productivity-module-7"] = 100, -- module
    ["bob-productivity-module-8"] = 100, -- module
    ["bob-productivity-processor"] = 200, -- tool
    ["bob-productivity-processor-2"] = 100, -- item
    ["bob-productivity-processor-3"] = 100, -- item
    ["raw-productivity-module-1"] = 100, -- module
    ["raw-productivity-module-2"] = 100, -- module
    ["raw-productivity-module-3"] = 100, -- module
    ["raw-productivity-module-4"] = 100, -- module
    ["raw-productivity-module-5"] = 100, -- module
    ["raw-productivity-module-6"] = 100, -- module
    ["raw-productivity-module-7"] = 100, -- module
    ["raw-productivity-module-8"] = 100, -- module
    ["raw-speed-module-1"] = 100, -- module
    ["raw-speed-module-2"] = 100, -- module
    ["raw-speed-module-3"] = 100, -- module
    ["raw-speed-module-4"] = 100, -- module
    ["raw-speed-module-5"] = 100, -- module
    ["raw-speed-module-6"] = 100, -- module
    ["raw-speed-module-7"] = 100, -- module
    ["raw-speed-module-8"] = 100, -- module
    ["speed-module"] = 100, -- module
    ["speed-module-2"] = 100, -- module
    ["speed-module-3"] = 100, -- module
    ["bob-speed-module-4"] = 100, -- module
    ["bob-speed-module-5"] = 100, -- module
    ["bob-speed-module-6"] = 100, -- module
    ["bob-speed-module-7"] = 100, -- module
    ["bob-speed-module-8"] = 100, -- module
    ["bob-speed-processor"] = 200, -- tool
    ["bob-speed-processor-2"] = 100, -- item
    ["bob-speed-processor-3"] = 100, -- item
}

C.created_ammo = {
    ["paranoidal-w93-light-cannon-shell"] = 200,
    ["paranoidal-w93-light-uranium-cannon-shell"] = 200,
    ["paranoidal-w93-cannon-shell"] = 200,
    ["paranoidal-w93-uranium-cannon-shell"] = 200,
    ["paranoidal-w93-slowdown-cannon-shell"] = 200,
    ["paranoidal-w93-rocket-pack"] = 200,
    ["paranoidal-w93-explosive-rocket-pack"] = 200,
    ["paranoidal-schall-explosive-rocket-pack"] = 50,
    ["paranoidal-schall-napalm-bomb"] = 200,
    ["paranoidal-schall-poison-bomb"] = 200,
}

C.ammo = {
	[10] = {
		["artillery-shell"] = true,
		["bob-atomic-artillery-shell"] = true,
		["bob-distractor-artillery-shell"] = true,
		["bob-explosive-artillery-shell"] = true,
		["bob-fire-artillery-shell"] = true,
		["bob-poison-artillery-shell"] = true,
	},
	[200] = {
		["atomic-bomb"] = true,
		["bob-acid-bullet-magazine"] = true,
		["bob-acid-rocket"] = true,
		["bob-ap-bullet-magazine"] = true,
		["bob-better-shotgun-shell"] = true,
		["bob-bullet-magazine"] = true,
		["bob-electric-bullet-magazine"] = true,
		["bob-electric-rocket"] = true,
		["bob-explosive-rocket"] = true,
		["bob-flame-bullet-magazine"] = true,
		["bob-flame-rocket"] = true,
		["bob-he-bullet-magazine"] = true,
		["bob-laser-rifle-battery"] = true,
		["bob-laser-rifle-battery-amethyst"] = true,
		["bob-laser-rifle-battery-diamond"] = true,
		["bob-laser-rifle-battery-emerald"] = true,
		["bob-laser-rifle-battery-ruby"] = true,
		["bob-laser-rifle-battery-sapphire"] = true,
		["bob-laser-rifle-battery-topaz"] = true,
		["bob-piercing-rocket"] = true,
		["bob-plasma-bullet-magazine"] = true,
		["bob-plasma-rocket"] = true,
		["bob-poison-bullet-magazine"] = true,
		["bob-poison-rocket"] = true,
		["bob-rocket"] = true,
		["bob-scatter-cannon-shell"] = true,
		["bob-shotgun-acid-shell"] = true,
		["bob-shotgun-ap-shell"] = true,
		["bob-shotgun-electric-shell"] = true,
		["bob-shotgun-explosive-shell"] = true,
		["bob-shotgun-flame-shell"] = true,
		["bob-shotgun-plasma-shell"] = true,
		["bob-shotgun-poison-shell"] = true,
		["bob-shotgun-uranium-shell"] = true,
		["cannon-shell"] = true,
		["clowns-osmium-rounds-magazine"] = true,
		["explosive-cannon-shell"] = true,
		["explosive-rocket"] = true,
		["explosive-uranium-cannon-shell"] = true,
		["firearm-magazine"] = true,
		["maf-small-atomic-rocket"] = true,
		["piercing-rounds-magazine"] = true,
		["piercing-shotgun-shell"] = true,
		["rocket"] = true,
		["shotgun-shell"] = true,
		["uranium-cannon-shell"] = true,
		["uranium-rounds-magazine"] = true,
		["w93-fragmentation-cannon-shell"] = true,
		["w93-slowdown-magazine"] = true,
		["w93-turret-slowdown-rocket"] = true,
		["w93-uranium-shotgun-shell"] = true,
	},
}

C.energy = {
    {source = "energy-fuels", size = 200, names = {"angels-wood-bricks", "angels-wood-charcoal"}},
    {source = "energy-coke", size = 400, names = {"angels-pellet-coke", "coal"}},
}

-- Late clones used to inherit already-tuned parents; do not turn that dependency into magic constants.
C.inherited_defaults = {
    {kind = "armor", name = "heavy-armor-2", parent = "heavy-armor"},
    {kind = "armor", name = "heavy-armor-3", parent = "heavy-armor"},
    {kind = "item", name = "angels-electro-whinning-cell-3", parent = "angels-electro-whinning-cell-2"},
    -- Space Age branch: planet items that copy a home stack size in their data stage get the final home size here
    -- (factor = the planet's own multiplier), as before the centralization moved home sizes to the final pass.
    {kind = "item", name = "alumina", parent = "iron-ore"}, -- planet-muluna: iron ore x1
    {kind = "item", name = "alumina-crushed", parent = "iron-ore", factor = 2},
    {kind = "item", name = "aluminum-crushed", parent = "iron-ore", factor = 2},
    {kind = "item", name = "cellulose", parent = "iron-ore", factor = 4},
    {kind = "armor", name = "light-armor-maraxsis-swimming", parent = "light-armor"}, -- Maraxsis: copy of the armor
    {kind = "armor", name = "heavy-armor-maraxsis-swimming", parent = "heavy-armor"},
}

C.exceptions = {
    {source = "approved-15", size = 10, names = {"y_alien_solar2", "bi-wooden-chest-giga"}},
    {source = "approved-15", size = 20, names = {"y_alien_solar"}},
    {source = "approved-15", size = 25, names = {"bi-wooden-chest-huge"}},
    {source = "approved-15", size = 50, names = {"y-winding", "bi-wooden-chest-large", "torch"}},
    {source = "approved-15", size = 100, names = {"y_toolhead", "y_toolhead_broken", "ye_package_fish2"}},
    {source = "approved-15", size = 300, names = {"y_catalyst_bp", "y_catalyst_ft", "y-fuel-reactor"}},
    {source = "approved-15", size = 600, names = {"y-infused-mud"}},
    {source = "approved-15", size = 1000, names = {"ye_rawmeat"}},
}

C.empty_barrels = {barrel = true, ["bob-gas-canister"] = true, ["bob-empty-canister"] = true}
return C
