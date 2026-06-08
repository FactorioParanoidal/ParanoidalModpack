local api = require("prototypes.api")

if not (mods["space-age"] or mods["TurboBelt"]) then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belts = {
	["turbo-transport-belt"] = {
		preset = api.defines.belt_presets.turbo,
		logistics_technology_name = "turbo-transport-belt",
	},
}

api.transform_belts_and_related_connectables(transport_belts)
