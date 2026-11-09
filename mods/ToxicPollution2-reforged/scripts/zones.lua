-- A working assembler/furnace with a pollution-absorbing energy source doubles recovery nearby.
-- Derive names from final runtime prototypes, including patches after this mod's data-final-fixes.
local C = require("shared.config")

local Z = {}
local names -- prototype-only cache; rebuilt after load/configuration
local sources = { "electric_energy_source_prototype", "burner_prototype", "heat_energy_source_prototype",
	"fluid_energy_source_prototype", "void_energy_source_prototype" }

function Z.reset()
	names = nil
end

local function clean_names(pollutant)
	if not names then
		names = {}
		for name, prototype in pairs(prototypes.get_entity_filtered({
			{ filter = "type", type = "assembling-machine" }, { filter = "type", type = "furnace" },
		})) do
			for _, field in ipairs(sources) do
				local source = prototype[field]
				if source then
					for kind, amount in pairs(source.emissions_per_joule) do
						if amount < 0 then
							names[kind] = names[kind] or {}
							names[kind][name] = true
						end
					end
				end
			end
		end
		for kind, set in pairs(names) do
			local list = {}
			for name in pairs(set) do list[#list + 1] = name end
			table.sort(list)
			names[kind] = list
		end
	end
	return names[pollutant] or {}
end

function Z.near_clean_air(surface, position)
	local pollutant = surface.pollutant_type
	if not pollutant then return false end
	local list = clean_names(pollutant.name)
	if #list == 0 then return false end
	local found = surface.find_entities_filtered({ position = position, radius = C.MODEL.zone_radius, name = list })
	local working = defines.entity_status.working
	for _, entity in pairs(found) do
		if entity.status == working then
			return true
		end
	end
	return false
end

return Z
