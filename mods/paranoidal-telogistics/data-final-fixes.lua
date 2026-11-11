-- Factorissimo floors have ceiling 0: a teleporter inside a factory building would bypass its ports.
local tiers = require("shared.tiers")

if data.raw["surface-property"] and data.raw["surface-property"]["ceiling"] then
	for _, name in ipairs(tiers.names) do
		local container = data.raw.container[name]
		if container then
			container.surface_conditions = container.surface_conditions or {}
			table.insert(container.surface_conditions, {property = "ceiling", min = 1})
		end
	end
end
