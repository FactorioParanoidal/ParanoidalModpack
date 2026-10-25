-- Recipes created below are Yuoki-owned as well (atomics for Bob/Angels ores, chunk hand-in, blood export).
local before = {}
for name in pairs(data.raw.recipe) do
	before[name] = true
end

require("prototypes.paranoidal.chunks") -- N4/F7 chunk items (declared late, see the file)

require("prototypes.integration.bobores._all") -- Integration - Bob's Ores (atomics)
require("prototypes.integration.angels._all") -- Integration - Angel's (atomics icons, Angels ores atomics)

require("prototypes.paranoidal.atomics")
require("prototypes.paranoidal.build-links")

for name in pairs(data.raw.recipe) do
	if not before[name] then
		YUOKI_PARANOIDAL.owned_recipes[name] = true
	end
end

require("prototypes.paranoidal.energy-quality") -- quality machines: more power, not more efficiency
require("prototypes.paranoidal.quality")
require("prototypes.paranoidal.technology")
require("prototypes.paranoidal.verify")
