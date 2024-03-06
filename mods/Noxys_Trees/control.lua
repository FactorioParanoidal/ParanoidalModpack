-- luacheck: globals game global settings script defines, ignore 631
local noxy_trees = {}

local mathfloor = math.floor
local mathceil = math.ceil
local config = {}


noxy_trees.disabled = { -- Disables the spreading of these specific entities.
	["dead-dry-hairy-tree"] = true,
	["dead-grey-trunk"]     = true,
	["dead-tree"]           = true,
	["dead-tree-desert"]    = true,
	["dry-hairy-tree"]      = true,
	["dry-tree"]            = true,
	["green-coral"]         = true,
	-- Angels Bio Processings special trees.
	["temperate-tree"]      = true,
	["swamp-tree"]          = true,
	["desert-tree"]         = true,
	["temperate-garden"]    = true,
	["swamp-garden"]        = true,
	["desert-garden"]       = true,
	["puffer-nest"]         = true,
}
noxy_trees.disabled_match = {
	["[-]planted"]         = true,
	["sapling[-]stage[-]"] = true,
}
noxy_trees.degradable = { -- The floor tiles that can be degraded and into what.
	-- Vanilla tiles
	["concrete"]              = "stone-path",
	["stone-path"]            = true,
	["hazard-concrete-left"]  = "stone-path",
	["hazard-concrete-right"] = "stone-path",
	["lab-dark-1"]            = "concrete",
	["lab-dark-2"]            = "concrete",
	-- More Floors 0.15
	["alien-metal"]                = "circuit-floor",
	["express-arrow-grate"]        = "concrete",
	["express-arrow-grate-right"]  = "concrete",
	["express-arrow-grate-down"]   = "concrete",
	["express-arrow-grate-left"]   = "concrete",
	["fast-arrow-grate"]           = "concrete",
	["fast-arrow-grate-right"]     = "concrete",
	["fast-arrow-grate-down"]      = "concrete",
	["fast-arrow-grate-left"]      = "concrete",
	["nitinol-arrow-grate"]        = "concrete",
	["nitinol-arrow-grate-right"]  = "concrete",
	["nitinol-arrow-grate-down"]   = "concrete",
	["nitinol-arrow-grate-left"]   = "concrete",
	["titanium-arrow-grate"]       = "concrete",
	["titanium-arrow-grate-right"] = "concrete",
	["titanium-arrow-grate-down"]  = "concrete",
	["titanium-arrow-grate-left"]  = "concrete",
	["arrow-grate"]                = "concrete",
	["arrow-grate-right"]          = "concrete",
	["arrow-grate-down"]           = "concrete",
	["arrow-grate-left"]           = "concrete",
	["asphalt"]                    = "concrete",
	["checkerboard"]               = "stone-path",
	["circuit-floor"]              = "concrete",
	["mf-concrete-blue"]           = "concrete",
	["mf-concrete-darkgrey"]       = "concrete",
	["mf-concrete-gold"]           = "concrete",
	["mf-concrete-green"]          = "concrete",
	["mf-concrete-limegreen"]      = "concrete",
	["mf-concrete-magenta"]        = "concrete",
	["mf-concrete-orange"]         = "concrete",
	["mf-concrete-pink"]           = "concrete",
	["mf-concrete-purple"]         = "concrete",
	["mf-concrete-red"]            = "concrete",
	["mf-concrete-skyblue"]        = "concrete",
	["mf-concrete-white"]          = "concrete",
	["mf-concrete-yellow"]         = "concrete",
	["mf-concrete-black"]          = "concrete",
	["cobblestone"]                = true,
	["decal1"]                     = "stone-path",
	["decal2"]                     = "stone-path",
	["decal3"]                     = "stone-path",
	["decal4"]                     = "stone-path",
	["diamond-plate"]              = "concrete",
	["mf_dirt_dark"]               = true,
	["mf_dirt"]                    = true,
	["dirt_dark_blueprint"]        = true,
	["dirt_blueprint"]             = true,
	["experiment"]                 = "stone-path",
	["mf_green_grass"]             = true,
	["mf_grass_dry"]               = true,
	["mf_grass_dry_blueprint"]     = true,
	["mf_green_grass_blueprint"]   = true,
	["gravel"]                     = true,
	["hexagonb"]                   = "metal-scraps",
	["lava"]                       = true,
	["metal-scraps"]               = true,
	["redbrick"]                   = true,
	["reinforced-concrete"]        = "concrete",
	["road-line"]                  = "asphalt",
	["road-line-right"]            = "asphalt",
	["road-line-down"]             = "asphalt",
	["road-line-left"]             = "asphalt",
	["rusty-metal"]                = "metal-scraps",
	["rusty-grate"]                = "metal-scraps",
	["mf_sand_dark"]               = true,
	["mf_sand_light"]              = true,
	["sand_dark_blueprint"]        = true,
	["sand_light_blueprint"]       = true,
	["smooth-concrete"]            = "stone-path",
	["snow"]                       = true,
	-- ["tar"]                     = true, -- Makes this stuff look weird (incorrect edges everywhere)
	-- ["toxic"]                   = true, -- Makes this stuff look weird (incorrect edges everywhere)
	["wood-floor"]                 = true,
	["darkwood"]                   = true,
	["herringbone"]                = true,
	["yellowbrick"]                = true,
	-- Asphalt Roads
	["Arci-asphalt"]                               = true,
	["Arci-asphalt-zebra-crossing-horizontal"]     = "Arci-asphalt",
	["Arci-asphalt-zebra-crossing-vertical"]       = "Arci-asphalt",
	["Arci-asphalt-triangle-white-up"]             = "Arci-asphalt",
	["Arci-asphalt-triangle-white-right"]          = "Arci-asphalt",
	["Arci-asphalt-triangle-white-down"]           = "Arci-asphalt",
	["Arci-asphalt-triangle-white-left"]           = "Arci-asphalt",
	["Arci-asphalt-hazard-white-right"]            = "Arci-asphalt",
	["Arci-asphalt-hazard-white-left"]             = "Arci-asphalt",
	["Arci-asphalt-hazard-yellow-right"]           = "Arci-asphalt",
	["Arci-asphalt-hazard-yellow-left"]            = "Arci-asphalt",
	["Arci-asphalt-hazard-red-right"]              = "Arci-asphalt",
	["Arci-asphalt-hazard-red-left"]               = "Arci-asphalt",
	["Arci-asphalt-hazard-blue-right"]             = "Arci-asphalt",
	["Arci-asphalt-hazard-blue-left"]              = "Arci-asphalt",
	["Arci-asphalt-hazard-green-right"]            = "Arci-asphalt",
	["Arci-asphalt-hazard-green-left"]             = "Arci-asphalt",
	["Arci-marking-white-straight-horizontal"]     = "Arci-asphalt",
	["Arci-marking-white-straight-vertical"]       = "Arci-asphalt",
	["Arci-marking-white-diagonal-left"]           = "Arci-asphalt",
	["Arci-marking-white-diagonal-right"]          = "Arci-asphalt",
	["Arci-marking-white-right-turn-up"]           = "Arci-asphalt",
	["Arci-marking-white-right-turn-right"]        = "Arci-asphalt",
	["Arci-marking-white-right-turn-down"]         = "Arci-asphalt",
	["Arci-marking-white-right-turn-left"]         = "Arci-asphalt",
	["Arci-marking-white-left-turn-up"]            = "Arci-asphalt",
	["Arci-marking-white-left-turn-right"]         = "Arci-asphalt",
	["Arci-marking-white-left-turn-down"]          = "Arci-asphalt",
	["Arci-marking-white-left-turn-left"]          = "Arci-asphalt",
	["Arci-marking-white-dl-straight-horizontal"]  = "Arci-asphalt",
	["Arci-marking-white-dl-straight-vertical"]    = "Arci-asphalt",
	["Arci-marking-white-dl-diagonal-left"]        = "Arci-asphalt",
	["Arci-marking-white-dl-diagonal-right"]       = "Arci-asphalt",
	["Arci-marking-white-dl-right-turn-up"]        = "Arci-asphalt",
	["Arci-marking-white-dl-right-turn-right"]     = "Arci-asphalt",
	["Arci-marking-white-dl-right-turn-down"]      = "Arci-asphalt",
	["Arci-marking-white-dl-right-turn-left"]      = "Arci-asphalt",
	["Arci-marking-white-dl-left-turn-up"]         = "Arci-asphalt",
	["Arci-marking-white-dl-left-turn-right"]      = "Arci-asphalt",
	["Arci-marking-white-dl-left-turn-down"]       = "Arci-asphalt",
	["Arci-marking-white-dl-left-turn-left"]       = "Arci-asphalt",
	["Arci-marking-yellow-straight-horizontal"]    = "Arci-asphalt",
	["Arci-marking-yellow-straight-vertical"]      = "Arci-asphalt",
	["Arci-marking-yellow-diagonal-left"]          = "Arci-asphalt",
	["Arci-marking-yellow-diagonal-right"]         = "Arci-asphalt",
	["Arci-marking-yellow-right-turn-up"]          = "Arci-asphalt",
	["Arci-marking-yellow-right-turn-right"]       = "Arci-asphalt",
	["Arci-marking-yellow-right-turn-down"]        = "Arci-asphalt",
	["Arci-marking-yellow-right-turn-left"]        = "Arci-asphalt",
	["Arci-marking-yellow-left-turn-up"]           = "Arci-asphalt",
	["Arci-marking-yellow-left-turn-right"]        = "Arci-asphalt",
	["Arci-marking-yellow-left-turn-down"]         = "Arci-asphalt",
	["Arci-marking-yellow-left-turn-left"]         = "Arci-asphalt",
	["Arci-marking-yellow-dl-straight-horizontal"] = "Arci-asphalt",
	["Arci-marking-yellow-dl-straight-vertical"]   = "Arci-asphalt",
	["Arci-marking-yellow-dl-diagonal-left"]       = "Arci-asphalt",
	["Arci-marking-yellow-dl-diagonal-right"]      = "Arci-asphalt",
	["Arci-marking-yellow-dl-right-turn-up"]       = "Arci-asphalt",
	["Arci-marking-yellow-dl-right-turn-right"]    = "Arci-asphalt",
	["Arci-marking-yellow-dl-right-turn-down"]     = "Arci-asphalt",
	["Arci-marking-yellow-dl-right-turn-left"]     = "Arci-asphalt",
	["Arci-marking-yellow-dl-left-turn-up"]        = "Arci-asphalt",
	["Arci-marking-yellow-dl-left-turn-right"]     = "Arci-asphalt",
	["Arci-marking-yellow-dl-left-turn-down"]      = "Arci-asphalt",
	["Arci-marking-yellow-dl-left-turn-left"]      = "Arci-asphalt",
	-- Dectorio
	["dect-wood-floor"]             = true,
	["dect-concrete-grid"]          = true,
	["dect-stone-gravel"]           = true,
	["dect-iron-ore-gravel"]        = true,
	["dect-copper-ore-gravel"]      = true,
	["dect-coal-gravel"]            = true,
	["dect-paint-danger-left"]      = "stone-path",
	["dect-paint-danger-right"]     = "stone-path",
	["dect-paint-emergency-left"]   = "stone-path",
	["dect-paint-emergency-right"]  = "stone-path",
	["dect-paint-caution-left"]     = "stone-path",
	["dect-paint-caution-right"]    = "stone-path",
	["dect-paint-radiation-left"]   = "stone-path",
	["dect-paint-radiation-right"]  = "stone-path",
	["dect-paint-defect-left"]      = "stone-path",
	["dect-paint-defect-right"]     = "stone-path",
	["dect-paint-operations-left"]  = "stone-path",
	["dect-paint-operations-right"] = "stone-path",
	["dect-paint-safety-left"]      = "stone-path",
	["dect-paint-safety-right"]     = "stone-path",
	-- Other mods
	["wood floors_brick speed"] = true,
}

noxy_trees.reinforced_degradable = {
	-- Vanilla tiles 0.18
	["refined-concrete"]              = "concrete",
	["refined-hazard-concrete-left"]  = "refined-concrete",
	["refined-hazard-concrete-right"] = "refined-concrete",
	["red-refined-concrete"]          = "refined-concrete",
	["green-refined-concrete"]        = "refined-concrete",
	["blue-refined-concrete"]         = "refined-concrete",
	["orange-refined-concrete"]       = "refined-concrete",
	["yellow-refined-concrete"]       = "refined-concrete",
	["pink-refined-concrete"]         = "refined-concrete",
	["purple-refined-concrete"]       = "refined-concrete",
	["black-refined-concrete"]        = "refined-concrete",
	["brown-refined-concrete"]        = "refined-concrete",
	["cyan-refined-concrete"]         = "refined-concrete",
	["acid-refined-concrete"]         = "refined-concrete",
}

-- Create a list for use in a filter function based of the degradable tiles.
noxy_trees.tilefilter = {}
for k,_ in pairs(noxy_trees.degradable) do
	noxy_trees.tilefilter[#noxy_trees.tilefilter + 1] = k
end
for k,_ in pairs(noxy_trees.reinforced_degradable) do
	noxy_trees.tilefilter[#noxy_trees.tilefilter + 1] = k
end

noxy_trees.fertility = { -- Tiles not listed here are considered non fertile (no spreading at all).
	-- Vanilla 0.16
	["dirt-1"]       = 0.1,
	["dirt-2"]       = 0.15,
	["dirt-3"]       = 0.2,
	["dirt-4"]       = 0.3,
	["dirt-5"]       = 0.35,
	["dirt-6"]       = 0.4,
	["dirt-7"]       = 0.45,
	["dry-dirt"]     = 0.1,
	["grass-1"]      = 0.9,
	["grass-2"]      = 1,
	["grass-3"]      = 0.95,
	["grass-4"]      = 0.75,
	["red-desert-0"] = 0.6,
	["red-desert-1"] = 0.3,
	["red-desert-2"] = 0.2,
	["red-desert-3"] = 0.1,
	["sand-1"]       = 0.05,
	["sand-2"]       = 0.1,
	["sand-3"]       = 0.05,
	["sand-4"]       = 0.15, -- Seems to not be used / defined
	-- Vanilla 0.15
	["grass-medium"]    = 1, -- The most fertile
	["grass"]           = 0.9,
	["grass-dry"]       = 0.75,
	["dirt-dark"]       = 0.45,
	["dirt"]            = 0.35,
	["red-desert"]      = 0.2,
	["red-desert-dark"] = 0.15,
	["sand-dark"]       = 0.15,
	["sand"]            = 0.1,
	["landfill"]        = 0, -- Not fertile
	-- Alien biomes 0.15
	["grass-red"]         = 1,
	["grass-orange"]      = 1,
	["grass-yellow"]      = 1,
	["grass-yellow-fade"] = 0.9,
	["grass-purple-fade"] = 0.9,
	["grass-purple"]      = 1,
	["dirt-red-dark"]     = 0.45,
	["dirt-brown-dark"]   = 0.45,
	["grass-blue-fade"]   = 0.9,
	["grass-blue"]        = 1,
	["dirt-red"]          = 0.35,
	["dirt-brown"]        = 0.35,
	["dirt-tan-dark"]     = 0.45,
	["dirt-dull-dark"]    = 0.45,
	["dirt-grey-dark"]    = 0.45,
	["dirt-tan"]          = 0.25,
	["dirt-dull"]         = 0.25,
	["dirt-grey"]         = 0.25,
	["sand-red-dark"]     = 0.15,
	["sand-orange-dark"]  = 0.15,
	["sand-gold-dark"]    = 0.15,
	["sand-dull-dark"]    = 0.1,
	["sand-grey-dark"]    = 0.1,
	["sand-red"]          = 0.1,
	["sand-orange"]       = 0.1,
	["sand-gold"]         = 0.1,
	["sand-dull"]         = 0.075,
	["sand-grey"]         = 0.075,
	["snow"]              = 0.25,
	["volcanic-cool"]     = 0.1,
	-- Alien biomes 0.16
	["mineral-purple-dirt-1"]        = 0.45,
	["mineral-purple-dirt-2"]        = 0.45,
	["mineral-purple-dirt-3"]        = 0.45,
	["mineral-purple-dirt-4"]        = 0.45,
	["mineral-purple-dirt-5"]        = 0.45,
	["mineral-purple-dirt-6"]        = 0.45,
	["mineral-purple-sand-1"]        = 0.15,
	["mineral-purple-sand-2"]        = 0.15,
	["mineral-purple-sand-3"]        = 0.15,
	["mineral-violet-dirt-1"]        = 0.45,
	["mineral-violet-dirt-2"]        = 0.45,
	["mineral-violet-dirt-3"]        = 0.45,
	["mineral-violet-dirt-4"]        = 0.45,
	["mineral-violet-dirt-5"]        = 0.45,
	["mineral-violet-dirt-6"]        = 0.45,
	["mineral-violet-sand-1"]        = 0.15,
	["mineral-violet-sand-2"]        = 0.15,
	["mineral-violet-sand-3"]        = 0.15,
	["mineral-red-dirt-1"]           = 0.45,
	["mineral-red-dirt-2"]           = 0.45,
	["mineral-red-dirt-3"]           = 0.45,
	["mineral-red-dirt-4"]           = 0.45,
	["mineral-red-dirt-5"]           = 0.45,
	["mineral-red-dirt-6"]           = 0.45,
	["mineral-red-sand-1"]           = 0.15,
	["mineral-red-sand-2"]           = 0.15,
	["mineral-red-sand-3"]           = 0.15,
	["mineral-brown-dirt-1"]         = 0.45,
	["mineral-brown-dirt-2"]         = 0.45,
	["mineral-brown-dirt-3"]         = 0.45,
	["mineral-brown-dirt-4"]         = 0.45,
	["mineral-brown-dirt-5"]         = 0.45,
	["mineral-brown-dirt-6"]         = 0.45,
	["mineral-brown-sand-1"]         = 0.15,
	["mineral-brown-sand-2"]         = 0.15,
	["mineral-brown-sand-3"]         = 0.15,
	["mineral-tan-dirt-1"]           = 0.45,
	["mineral-tan-dirt-2"]           = 0.45,
	["mineral-tan-dirt-3"]           = 0.45,
	["mineral-tan-dirt-4"]           = 0.45,
	["mineral-tan-dirt-5"]           = 0.45,
	["mineral-tan-dirt-6"]           = 0.45,
	["mineral-tan-sand-1"]           = 0.15,
	["mineral-tan-sand-2"]           = 0.15,
	["mineral-tan-sand-3"]           = 0.15,
	["mineral-aubergine-dirt-1"]     = 0.45,
	["mineral-aubergine-dirt-2"]     = 0.45,
	["mineral-aubergine-dirt-3"]     = 0.45,
	["mineral-aubergine-dirt-4"]     = 0.45,
	["mineral-aubergine-dirt-5"]     = 0.45,
	["mineral-aubergine-dirt-6"]     = 0.45,
	["mineral-aubergine-sand-1"]     = 0.15,
	["mineral-aubergine-sand-2"]     = 0.15,
	["mineral-aubergine-sand-3"]     = 0.15,
	["mineral-dustyrose-dirt-1"]     = 0.45,
	["mineral-dustyrose-dirt-2"]     = 0.45,
	["mineral-dustyrose-dirt-3"]     = 0.45,
	["mineral-dustyrose-dirt-4"]     = 0.45,
	["mineral-dustyrose-dirt-5"]     = 0.45,
	["mineral-dustyrose-dirt-6"]     = 0.45,
	["mineral-dustyrose-sand-1"]     = 0.15,
	["mineral-dustyrose-sand-2"]     = 0.15,
	["mineral-dustyrose-sand-3"]     = 0.15,
	["mineral-beige-dirt-1"]         = 0.45,
	["mineral-beige-dirt-2"]         = 0.45,
	["mineral-beige-dirt-3"]         = 0.45,
	["mineral-beige-dirt-4"]         = 0.45,
	["mineral-beige-dirt-5"]         = 0.45,
	["mineral-beige-dirt-6"]         = 0.45,
	["mineral-beige-sand-1"]         = 0.15,
	["mineral-beige-sand-2"]         = 0.15,
	["mineral-beige-sand-3"]         = 0.15,
	["mineral-cream-dirt-1"]         = 0.45,
	["mineral-cream-dirt-2"]         = 0.45,
	["mineral-cream-dirt-3"]         = 0.45,
	["mineral-cream-dirt-4"]         = 0.45,
	["mineral-cream-dirt-5"]         = 0.45,
	["mineral-cream-dirt-6"]         = 0.45,
	["mineral-cream-sand-1"]         = 0.15,
	["mineral-cream-sand-2"]         = 0.15,
	["mineral-cream-sand-3"]         = 0.15,
	["mineral-black-dirt-1"]         = 0.45,
	["mineral-black-dirt-2"]         = 0.45,
	["mineral-black-dirt-3"]         = 0.45,
	["mineral-black-dirt-4"]         = 0.45,
	["mineral-black-dirt-5"]         = 0.45,
	["mineral-black-dirt-6"]         = 0.45,
	["mineral-black-sand-1"]         = 0.15,
	["mineral-black-sand-2"]         = 0.15,
	["mineral-black-sand-3"]         = 0.15,
	["mineral-grey-dirt-1"]          = 0.45,
	["mineral-grey-dirt-2"]          = 0.45,
	["mineral-grey-dirt-3"]          = 0.45,
	["mineral-grey-dirt-4"]          = 0.45,
	["mineral-grey-dirt-5"]          = 0.45,
	["mineral-grey-dirt-6"]          = 0.45,
	["mineral-grey-sand-1"]          = 0.15,
	["mineral-grey-sand-2"]          = 0.15,
	["mineral-grey-sand-3"]          = 0.15,
	["mineral-white-dirt-1"]         = 0.45,
	["mineral-white-dirt-2"]         = 0.45,
	["mineral-white-dirt-3"]         = 0.45,
	["mineral-white-dirt-4"]         = 0.45,
	["mineral-white-dirt-5"]         = 0.45,
	["mineral-white-dirt-6"]         = 0.45,
	["mineral-white-sand-1"]         = 0.15,
	["mineral-white-sand-2"]         = 0.15,
	["mineral-white-sand-3"]         = 0.15,
	["vegetation-turquoise-grass-1"] = 0.95,
	["vegetation-turquoise-grass-2"] = 0.95,
	["vegetation-green-grass-1"]     = 1,
	["vegetation-green-grass-2"]     = 1,
	["vegetation-green-grass-3"]     = 1,
	["vegetation-green-grass-4"]     = 1,
	["vegetation-olive-grass-1"]     = 1,
	["vegetation-olive-grass-2"]     = 1,
	["vegetation-yellow-grass-1"]    = 0.85,
	["vegetation-yellow-grass-2"]    = 0.85,
	["vegetation-orange-grass-1"]    = 0.85,
	["vegetation-orange-grass-2"]    = 0.85,
	["vegetation-red-grass-1"]       = 0.85,
	["vegetation-red-grass-2"]       = 0.85,
	["vegetation-violet-grass-1"]    = 0.95,
	["vegetation-violet-grass-2"]    = 0.95,
	["vegetation-purple-grass-1"]    = 0.95,
	["vegetation-purple-grass-2"]    = 0.95,
	["vegetation-mauve-grass-1"]     = 0.95,
	["vegetation-mauve-grass-2"]     = 0.95,
	["vegetation-blue-grass-1"]      = 0.95,
	["vegetation-blue-grass-2"]      = 0.95,
	["volcanic-orange-heat-1"]       = 0.05,
	["volcanic-orange-heat-2"]       = 0.05,
	["volcanic-orange-heat-3"]       = 0.05,
	["volcanic-orange-heat-4"]       = 0.05,
	["volcanic-green-heat-1"]        = 0.15,
	["volcanic-green-heat-2"]        = 0.15,
	["volcanic-green-heat-3"]        = 0.15,
	["volcanic-green-heat-4"]        = 0.15,
	["volcanic-blue-heat-1"]         = 0.05,
	["volcanic-blue-heat-2"]         = 0.05,
	["volcanic-blue-heat-3"]         = 0.05,
	["volcanic-blue-heat-4"]         = 0.05,
	["volcanic-purple-heat-1"]       = 0.05,
	["volcanic-purple-heat-2"]       = 0.05,
	["volcanic-purple-heat-3"]       = 0.05,
	["volcanic-purple-heat-4"]       = 0.05,
	["frozen-snow-0"]                = 0.5,
	["frozen-snow-1"]                = 0.5,
	["frozen-snow-2"]                = 0.5,
	["frozen-snow-3"]                = 0.5,
	["frozen-snow-4"]                = 0.5,
	["frozen-snow-5"]                = 0.5,
	["frozen-snow-6"]                = 0.5,
	["frozen-snow-7"]                = 0.5,
	["frozen-snow-8"]                = 0.5,
	["frozen-snow-9"]                = 0.5,
}

noxy_trees.deathselector = {
	"dead-grey-trunk",
	"dry-hairy-tree",
	"dead-tree-desert"
}
noxy_trees.dead = {
	["dry-tree"]            = true,
	["dry-hairy-tree"]      = "dead-dry-hairy-tree",
	["dead-grey-trunk"]     = "dry-tree",
	["dead-dry-hairy-tree"] = true,
	["dead-tree-desert"]    = "dry-tree",
}
noxy_trees.alive = {
	"tree-01",
	"tree-01",
	"tree-02-red",
	"tree-03",
	"tree-04",
	"tree-05",
	"tree-06",
	"tree-06-brown",
	"tree-07",
	"tree-08",
	"tree-08-brown",
	"tree-08-red",
	"tree-09",
	"tree-09-brown",
	"tree-09-red",
	-- Alien Biomes
	"tree-wetland-a",
	"tree-wetland-b",
	"tree-wetland-c",
	"tree-wetland-d",
	"tree-wetland-e",
	"tree-wetland-f",
	"tree-wetland-g",
	"tree-wetland-h",
	"tree-wetland-i",
	"tree-wetland-j",
	"tree-wetland-k",
	"tree-wetland-l",
	"tree-wetland-m",
	"tree-wetland-n",
	"tree-wetland-o",
	"tree-grassland-a",
	"tree-grassland-b",
	"tree-grassland-c",
	"tree-grassland-d",
	"tree-grassland-e",
	"tree-grassland-f",
	"tree-grassland-g",
	"tree-grassland-h",
	"tree-grassland-h2",
	"tree-grassland-h3",
	"tree-grassland-i",
	"tree-grassland-k",
	"tree-grassland-l",
	"tree-grassland-m",
	"tree-grassland-n",
	"tree-grassland-0",
	"tree-grassland-p",
	"tree-grassland-q",
	"tree-dryland-a",
	"tree-dryland-b",
	"tree-dryland-c",
	"tree-dryland-d",
	"tree-dryland-e",
	"tree-dryland-f",
	"tree-dryland-g",
	"tree-dryland-h",
	"tree-dryland-i",
	"tree-dryland-j",
	"tree-dryland-k",
	"tree-dryland-l",
	"tree-dryland-m",
	"tree-dryland-n",
	"tree-dryland-o",
	"tree-desert-a",
	"tree-desert-b",
	"tree-desert-c",
	"tree-desert-d",
	"tree-desert-e",
	"tree-desert-f",
	"tree-desert-g",
	"tree-desert-h",
	"tree-desert-i",
	"tree-desert-j",
	"tree-desert-k",
	"tree-desert-l",
	"tree-desert-m",
	"tree-desert-n",
	"tree-snow-a",
	"tree-volcanic-a"
}

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return mathfloor(num * mult + 0.5) / mult
end

local function cache_forces()
	for _, force in pairs(game.forces) do
		if #force.players > 0 then
			global.forces[#global.forces + 1] = force.name
		end
	end
end

local function cache_surfaces()
	if game then
		global.surfaces = {}
		for s in string.gmatch(config.surfaces, '([^,;]+)') do
			local su = game.get_surface(s)
			if not su then
				if tonumber(s) then
					su = game.get_surface(tonumber(s))
				end
			end
			if su and su.valid then
				table.insert(global.surfaces, su.index)
			end
		end
		if (#global.surfaces < 1) then
			global.surfaces = {1}
		end
	end
end

local function initialize()
	global.chunks           = {}
	global.chunkindex       = 0
	global.surfaces         = {}
	global.last_surface     = nil
	global.forces           = {}
	global.tick             = 0
	global.rng              = game.create_random_generator()
	global.chunkcycles      = 0
	global.spawnedcount     = 0
	global.deadedcount      = 0
	global.killedcount      = 0
	global.degradedcount    = 0
	global.resurrected      = 0
	global.lastdebugmessage = 0
	global.lasttotalchunks  = 0

	cache_surfaces()

	cache_forces()
end

local function cache_settings()
	config.enabled                             = settings.global["Noxys_Trees-enabled"].value
	config.debug                               = settings.global["Noxys_Trees-debug"].value
	config.debug_interval                      = settings.global["Noxys_Trees-debug-interval"].value
	config.degrade_tiles                       = settings.global["Noxys_Trees-degrade-tiles"].value
	config.do_not_degrade_reinforced_tiles     = settings.global["Noxys_Trees-do-not-degrade-reinforced-tiles"].value
	config.overpopulation_kills_trees          = settings.global["Noxys_Trees-overpopulation-kills-trees"].value
	config.kill_trees_near_unwanted            = settings.global["Noxys_Trees-kill-trees-near-unwanted"].value
	config.ticks_between_operations            = settings.global["Noxys_Trees-ticks-between-operations"].value
	config.chunks_per_operation                = settings.global["Noxys_Trees-chunks-per-operation"].value
	config.chunks_per_operation_enable_scaling = settings.global["Noxys_Trees-chunks-per-operation-enable-scaling"].value
	config.chunks_per_operation_scaling_bias   = settings.global["Noxys_Trees-chunks-per-operation-scaling-bias"].value
	config.minimum_distance_between_tree       = settings.global["Noxys_Trees-minimum-distance-between-tree"].value
	config.minimum_distance_to_enemies         = settings.global["Noxys_Trees-minimum-distance-to-enemies"].value
	config.minimum_distance_to_uranium         = settings.global["Noxys_Trees-minimum-distance-to-uranium"].value
	config.minimum_distance_to_player_entities = settings.global["Noxys_Trees-minimum-distance-to-player-entities"].value
	config.minimum_distance_to_degradetiles    = settings.global["Noxys_Trees-minimum-distance-to-degradeable-tiles"].value
	config.deaths_by_lack_of_fertility_minimum = settings.global["Noxys_Trees-deaths-by-lack-of-fertility-minimum"].value
	config.deaths_by_pollution_bias            = settings.global["Noxys_Trees-deaths-by-pollution-bias"].value
	config.trees_to_grow_per_chunk_percentage  = settings.global["Noxys_Trees-trees-to-grow-per-chunk-percentage"].value
	config.maximum_trees_per_chunk             = settings.global["Noxys_Trees-maximum-trees-per-chunk"].value
	config.expansion_distance                  = settings.global["Noxys_Trees-expansion-distance"].value
	config.surfaces                            = settings.global["Noxys_Trees-surfaces"].value
	config.trees_grow_on_landfill              = settings.global["Noxys_Trees-trees-grow-on-landfill"].value

	if config.trees_grow_on_landfill then
		noxy_trees.fertility["landfill"] = 0.5
	end

	cache_surfaces()
end

cache_settings()

local function nx_debug(message)
	if config.debug then
		game.print("NX Debug: " .. message)
	end
end

local function get_trees_in_chunk(surface, chunk)
	return surface.find_entities_filtered{area = {{ chunk.x * 32, chunk.y * 32}, {chunk.x * 32 + 32, chunk.y * 32 + 32}}, type = "tree"}
end

local function deadening_tree(surface, tree)
	if noxy_trees.dead[tree.name] and noxy_trees.dead[tree.name] == true then
		tree.die()
		global.killedcount = global.killedcount + 1
		return
	end

	-- Remove tree if a player entity is near it instead of spawning a dead tree.
	local rp = config.minimum_distance_to_player_entities
	if rp > 0 then
		for _, force in pairs(game.forces) do
			if #force.players > 0 then
				if surface.count_entities_filtered{position = tree.position, radius = rp, force = force, limit = 1} > 0 then
					tree.die()
					global.deadedcount = global.deadedcount + 1
					return
				end
			end
		end
	end

	if noxy_trees.dead[tree.name] then
		if noxy_trees.dead[tree.name] ~= true then
			surface.create_entity{name = noxy_trees.dead[tree.name], position = tree.position}
			tree.die()
			global.deadedcount = global.deadedcount + 1
		end
	else
		local deadtree = noxy_trees.deathselector[global.rng(1, #noxy_trees.deathselector)]
		surface.create_entity{name = deadtree, position = tree.position}
		tree.die()
		global.deadedcount = global.deadedcount + 1
	end
end

local function spawn_trees(surface, parent, tilestoupdate, newpos)
	if noxy_trees.disabled[parent.name] then return end
	if not newpos then
		local distance = config.expansion_distance
		newpos = {
			parent.position.x + global.rng(distance * 2) - distance + (global.rng() - 0.5),
			parent.position.y + global.rng(distance * 2) - distance + (global.rng() - 0.5),
		}
	end
	local tile = surface.get_tile(newpos[1], newpos[2])
	if tile and tile.valid == true then
		-- Tile degradation
		local degrade_to = nil
		if config.degrade_tiles and noxy_trees.degradable[tile.name] then
			degrade_to = noxy_trees.degradable[tile.name]
		end
		if not config.do_not_degrade_reinforced_tiles and noxy_trees.reinforced_degradable[tile.name] then
			degrade_to = noxy_trees.reinforced_degradable[tile.name]
		end
		if degrade_to ~= nil then
			if degrade_to == true then
				if tile.hidden_tile then
					tilestoupdate[#tilestoupdate + 1] = {["name"] = tile.hidden_tile, ["position"] = tile.position}
				else
					nx_debug("ERROR: Can't degrade tile because no hidden_tile: " .. tile.name)
				end
			else
				if
					game.tile_prototypes[degrade_to]
				then
					tilestoupdate[#tilestoupdate + 1] = {["name"] = degrade_to, ["position"] = tile.position}
				else
					nx_debug("ERROR: Invalid tile?: " .. degrade_to .. " Tried to convert from: " .. tile.name)
				end
			end
		elseif -- Tree spreading
			(noxy_trees.fertility[tile.name] or 0) > 0 and
			not noxy_trees.dead[parent.name] and -- Stop dead trees from spreading.
			noxy_trees.fertility[tile.name] > global.rng() and
			surface.can_place_entity{name = parent.name, position = newpos}
		then
			local r = config.minimum_distance_between_tree / noxy_trees.fertility[tile.name]
			if surface.count_entities_filtered{position = newpos, radius = r, type = "tree", limit = 1} > 0 then
				return
			end
			local rp = config.minimum_distance_to_player_entities
			if rp > 0 then
				for _, force in pairs(game.forces) do
					if #force.players > 0 then
						if surface.count_entities_filtered{position = newpos, radius = rp, force = force, limit = 1} > 0 then
							return
						end
					end
				end
			end
			local er = config.minimum_distance_to_enemies
			if surface.count_entities_filtered{position = newpos, radius = er, type = "unit-spawner", force = "enemy", limit = 1} > 0 or
				surface.count_entities_filtered{position = newpos, radius = er, type = "turret", force = "enemy", limit = 1} > 0 then
				return
			end
			local ur = config.minimum_distance_to_uranium
			if surface.count_entities_filtered{position = newpos, radius = ur, type = "resource", name = "uranium-ore", limit = 1} > 0 then
				return
			end
			local tr = config.minimum_distance_to_degradetiles
			if tr > 0 then
				if surface.count_tiles_filtered{position = newpos, radius = tr, name = noxy_trees.tilefilter, limit = 1, has_hidden_tile = true} > 0 then
					return
				end
			end
			surface.create_entity{name = parent.name, position = newpos}
			global.spawnedcount = global.spawnedcount + 1
		elseif -- Tree resurrections
			(noxy_trees.fertility[tile.name] or 0) > 0 and
			noxy_trees.dead[parent.name] and
			noxy_trees.fertility[tile.name] > global.rng()
		then
			-- Only if polution is low enough we do a resurrect (which can also be seen as a mutation)
			if surface.get_pollution{parent.position.x, parent.position.y} / config.deaths_by_pollution_bias < 1 + global.rng() then
				-- We can skip the distance checks here since the parent tree already exists and we are just going to replace that one.
				local newname = noxy_trees.combined[global.rng(#noxy_trees.combined)]
				newpos = parent.position
				parent.destroy()
				surface.create_entity{name = newname, position = newpos}
				global.resurrected = global.resurrected + 1
			end
		end
	end
end

local function process_chunk(surface, chunk)
	if not chunk then return end
	local tilestoupdate = {}
	local trees = get_trees_in_chunk(surface, chunk)
	local trees_count = #trees
	if trees_count >= config.maximum_trees_per_chunk then
		if config.overpopulation_kills_trees then
			local tokill = 1 + (trees_count / config.maximum_trees_per_chunk)
			repeat
				local tree = trees[global.rng(1, trees_count)]
				if tree and tree.valid == true then
					deadening_tree(surface, tree)
				end
				tokill = tokill - 1
			until tokill < 1
		end
	elseif trees_count > 0 then
		-- Grow new trees
		local togen = 1 + mathceil(trees_count * config.trees_to_grow_per_chunk_percentage)
		repeat
			local parent = trees[global.rng(1, trees_count)]
			if parent.valid then
				spawn_trees(surface, parent, tilestoupdate)
			end
			togen = togen - 1
		until togen <= 0
	end
	if trees_count < 1 then return end
	-- Check random trees for things that would kill them nearby (enemies / uranium / players / fertility)
	if config.kill_trees_near_unwanted then
		local tokill = 1 + mathceil(trees_count * config.trees_to_grow_per_chunk_percentage)
		if config.deaths_by_pollution_bias > 0 then
			tokill = tokill + mathceil(surface.get_pollution{chunk.x * 32 + 16, chunk.y * 32 + 16} / config.deaths_by_pollution_bias)
		end
		repeat
			local treetocheck = trees[global.rng(1, trees_count)]
			if treetocheck and treetocheck.valid == true then
				local er = config.minimum_distance_to_enemies
				local ur = config.minimum_distance_to_uranium
				if surface.count_entities_filtered{position = treetocheck.position, radius = er, type = "unit-spawner", force = "enemy", limit = 1} > 0 or
					surface.count_entities_filtered{position = treetocheck.position, radius = er, type = "turret", force = "enemy", limit = 1} > 0 then
					deadening_tree(surface, treetocheck)
				elseif surface.count_entities_filtered{position = treetocheck.position, radius = ur, type = "resource", name = "uranium-ore", limit = 1} > 0 then
					deadening_tree(surface, treetocheck)
				else
					local rp = config.minimum_distance_to_player_entities
					if rp > 0 then
						for _, force in pairs(game.forces) do
							if #force.players > 0 then
								if surface.count_entities_filtered{position = treetocheck.position, radius = rp, force = force, limit = 1} > 0 then
									deadening_tree(surface, treetocheck)
									break
								end
							end
						end
					end
				end
			end
			if treetocheck and treetocheck.valid == true then
				local tile = surface.get_tile(treetocheck.position.x, treetocheck.position.y)
				if tile and tile.valid == true then
					local fertility = 0
					if noxy_trees.fertility[tile.name] then
						fertility = noxy_trees.fertility[tile.name]
					end
					if fertility < config.deaths_by_lack_of_fertility_minimum and fertility < global.rng() then
						if trees_count / config.maximum_trees_per_chunk > global.rng() then
							deadening_tree(surface, treetocheck)
						end
					end
				end
			end
			if config.deaths_by_pollution_bias > 0 then
				if treetocheck and treetocheck.valid == true then
					if surface.get_pollution{treetocheck.position.x, treetocheck.position.y} / config.deaths_by_pollution_bias > 1 + global.rng() then
						deadening_tree(surface, treetocheck)
					end
				end
			end
			tokill = tokill - 1
		until tokill <= 0
	end
	if #tilestoupdate > 0 then
		surface.set_tiles(tilestoupdate)
		global.degradedcount = global.degradedcount + #tilestoupdate
	end
end

script.on_configuration_changed(function()
	if global.noxy_trees then
		for k,v in pairs(global.noxy_trees) do
			global[k] = v
		end
		global.noxy_trees = nil
	end
	initialize()
end)

script.on_init(function ()
	initialize()
end)

script.on_event({defines.events.on_runtime_mod_setting_changed}, cache_settings)

script.on_event({defines.events.on_forces_merging, defines.events.on_player_changed_force}, cache_forces)

script.on_event({defines.events.on_tick}, function(event)
	local global = global
	if config.enabled then
		global.tick = global.tick - 1
		-- Check alive trees this should only run once
		if not noxy_trees.combined then
			noxy_trees.combined = {}
			for _, tree in pairs(noxy_trees.alive) do
				if game.entity_prototypes[tree] then
					noxy_trees.combined[#noxy_trees.combined + 1] = tree
				end
			end
		end
		-- Add disabled prototypes
		if next(noxy_trees.disabled_match) then
			for e,_ in pairs(game.entity_prototypes) do
				for k,_ in pairs(noxy_trees.disabled_match) do
					if e:find(k) then
						noxy_trees.disabled[e] = true
					end
				end
			end
			-- Clear so we don't do this again.
			noxy_trees.disabled_match = {}
		end
		-- Debug
		if config.debug then
			if global.lastdebugmessage + config.debug_interval < event.tick then
				local timegap = (event.tick - global.lastdebugmessage) / 60
				if not global.chunkcycles then global.chunkcycles = 0 end
				nx_debug("Chunks: " .. global.chunkindex .. "/" .. #global.chunks .. "(" .. global.lasttotalchunks .. ")."
						.. " Grown: " .. global.spawnedcount .. " (" .. round(global.spawnedcount / timegap, 2) .. "/s)."
						.. " Deaded: " .. global.deadedcount .. " (" .. round(global.deadedcount / timegap, 2) .. "/s)."
						.. " Killed: " .. global.killedcount .. " (" .. round(global.killedcount / timegap, 2) .. "/s)."
						.. " Degrade: " .. global.degradedcount .. " (" .. round(global.degradedcount / timegap, 2) .. "/s)."
						.. " Rezzed: " .. global.resurrected .. " (" .. round(global.resurrected / timegap, 2) .. "/s)."
						.. " Chunk Cycle: " .. global.chunkcycles .. "."
					)
				global.lastdebugmessage = event.tick
				global.spawnedcount     = 0
				global.deadedcount      = 0
				global.killedcount      = 0
				global.degradedcount    = 0
				global.resurrected      = 0
			end
		end
		if global.tick <= 0 or global.tick == nil then
			global.tick = config.ticks_between_operations
			-- Do the stuff
			local last_surface, surface_index = next(global.surfaces, global.last_surface)
			if surface_index then
				local surface = game.get_surface(surface_index)
				if surface and surface.valid then
					local chunksdone = 0
					local chunkstodo = config.chunks_per_operation
					if config.chunks_per_operation_enable_scaling then --todo: Add cap on number of chunks per operation; maybe change the scaling so that it increases how often it runs instead of how many chunks
						chunkstodo = mathfloor(chunkstodo * (global.lasttotalchunks / config.chunks_per_operation_scaling_bias))
					end
					if chunkstodo < 1 then chunkstodo = 1 end
					repeat
						if #global.chunks < 1 then
							-- populate our chunk array
							for chunk in surface.get_chunks() do
								global.chunks[#global.chunks + 1] = chunk
							end
							global.chunkcycles = global.chunkcycles + 1
							global.lasttotalchunks = #global.chunks
						end
						if #global.chunks < 1 then nx_debug("Bailing because no chunks!") break end
						-- Select a chunk
						global.chunkindex = global.chunkindex + 1
						if global.chunkindex > #global.chunks then
							global.chunkindex = 0
							global.chunks = {}
							break
						end
						process_chunk(surface, global.chunks[global.chunkindex])
						-- Done
						chunksdone = chunksdone + 1
					until chunksdone >= chunkstodo
				end
			end
			global.last_surface = last_surface
		end
		if global.tick > config.ticks_between_operations then
			global.tick = config.ticks_between_operations
		end
	end
end)
