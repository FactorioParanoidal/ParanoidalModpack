-- Paranoidal fork: quality of Yuoki energy machines. A crafting machine of higher quality crafts faster, but by default
-- draws the same energy (CraftingMachinePrototype::quality_affects_energy_usage is false), so a quality engine,
-- reactor or boiler made more hot MF/steam than it burned: with the build's qualities up to 40x speed. Machines that
-- make hot MF or steam get an energy multiplier equal to their speed multiplier for every quality that exists now
-- (normal and positive ones from ic-more-qualities data-updates): a better machine is more powerful, not more efficient.
-- The defect qualities are created later by ic-more-qualities, which then adds its own energy penalty to this table.
local owned = YUOKI_PARANOIDAL.owned_recipes
local hot = {}
for name in pairs(owned) do
	local recipe = data.raw.recipe[name]
	for _, r in pairs(recipe and recipe.results or {}) do
		local fluid = r.type == "fluid" and data.raw.fluid[r.name]
		if fluid and (r.name == "steam" or (r.name == "y-mechanical-force"
				and (r.temperature or fluid.default_temperature) > fluid.default_temperature)) then
			hot[recipe.category or "crafting"] = true
		end
	end
end

local changed = {}
for _, kind in pairs({ "assembling-machine", "furnace" }) do
	for name, machine in pairs(data.raw[kind] or {}) do
		local makes_heat = false
		for _, category in pairs(machine.crafting_categories or {}) do
			if hot[category] then
				makes_heat = true
			end
		end
		if makes_heat then
			machine.quality_affects_energy_usage = true
			machine.crafting_speed_quality_multiplier = machine.crafting_speed_quality_multiplier or {}
			machine.energy_usage_quality_multiplier = machine.energy_usage_quality_multiplier or {}
			for quality_name, quality in pairs(data.raw.quality or {}) do
				local speed = machine.crafting_speed_quality_multiplier[quality_name]
					or quality.crafting_machine_speed_multiplier or quality.default_multiplier
					or (1 + 0.3 * (quality.level or 0))
				machine.crafting_speed_quality_multiplier[quality_name] = speed
				machine.energy_usage_quality_multiplier[quality_name] =
					math.max(speed, quality.crafting_machine_energy_usage_multiplier or 1)
			end
			changed[#changed + 1] = name
		end
	end
end
table.sort(changed)
log("Yuoki (Paranoidal): quality scales energy with speed for " .. #changed .. " MF/steam machines: "
	.. table.concat(changed, ", "))
