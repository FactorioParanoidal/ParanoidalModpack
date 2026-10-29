local C = require("shared.config")
local V = require("shared.vehicles")

local function set_resistance(armor, damage_type, percent)
	armor.resistances = armor.resistances or {}
	for _, resistance in pairs(armor.resistances) do
		if resistance.type == damage_type then
			resistance.decrease = 0
			resistance.percent = percent
			return
		end
	end
	table.insert(armor.resistances, { type = damage_type, decrease = 0, percent = percent })
end

local function toxin_percent(armor)
	for _, resistance in pairs(armor.resistances or {}) do
		if resistance.type == C.RESIST_TYPE then
			return resistance.percent or 0
		end
	end
	return 0
end

-- 1. Armor filtration (= toxin resistance) and filter resource (= durability).
local armors = data.raw.armor
local applied = {}
for name, spec in pairs(C.ARMORS) do
	local armor = armors[name]
	if armor then
		set_resistance(armor, C.RESIST_TYPE, spec.filtration)
		armor.infinite = false
		armor.durability = spec.durability
		if spec.stack_size then
			armor.stack_size = spec.stack_size
		end
		applied[#applied + 1] = name .. " " .. spec.filtration .. "%/" .. spec.durability
	end
end
-- Every armor that filters must have a resource; in this build armor durability means nothing else,
-- so it is shown as the filter resource on all non-infinite armors.
for name, armor in pairs(armors) do
	if toxin_percent(armor) > 0 and (armor.infinite or not armor.durability) then
		armor.infinite = false
		armor.durability = C.DEFAULT_DURABILITY
		applied[#applied + 1] = name .. " " .. toxin_percent(armor) .. "%/" .. C.DEFAULT_DURABILITY .. " (default)"
	end
	if armor.infinite == false and armor.durability then
		armor.durability_description_key = "description.tpr-filter-resource-key"
		armor.durability_description_value = "description.tpr-filter-resource-value"
		armor.factoriopedia_durability_description_key = "description.tpr-filter-resource-key"
	end
end

-- 2. The respirator is the first step of the armor chain (as aai-industry did in 1.1).
local light = data.raw.recipe["light-armor"]
if light and light.ingredients then
	local present = false
	for _, ingredient in pairs(light.ingredients) do
		if (ingredient.name or ingredient[1]) == C.RESPIRATOR then
			present = true
		end
	end
	if not present then
		table.insert(light.ingredients, { type = "item", name = C.RESPIRATOR, amount = 1 })
	end
end

-- 3. Gas mask visor: Bob's glass where the build has it (early: ore crushing).
local mask = data.raw.recipe[C.GAS_MASK]
if mask and data.raw.item["bob-glass"] then
	for _, ingredient in pairs(mask.ingredients) do
		if ingredient.name == "iron-plate" then
			ingredient.name = "bob-glass"
		end
	end
end

-- 4. Cabin filtration on every vehicle the player can sit in.
local cabins = 0
for _, vehicle_type in ipairs(V.TYPES) do
	for name, vehicle in pairs(data.raw[vehicle_type] or {}) do
		local share = V.filtration(vehicle_type, name)
		if share > 0 then
			vehicle.custom_tooltip_fields = vehicle.custom_tooltip_fields or {}
			table.insert(vehicle.custom_tooltip_fields, {
				name = { "tpr-tooltip.cabin" },
				value = { "tpr-tooltip.percent", tostring(math.floor(share * 100 + 0.5)) },
			})
			cabins = cabins + 1
		end
	end
end

-- 5. Clean-air zones: crafting machines whose energy source absorbs pollution (air filters, farms,
-- greenhouses). Read at runtime from mod-data.
local clean = {}
for _, machine_type in ipairs({ "assembling-machine", "furnace" }) do
	for name, machine in pairs(data.raw[machine_type] or {}) do
		local source = machine.energy_source
		local emissions = source and source.emissions_per_minute
		if emissions and (emissions.pollution or 0) < 0 then
			clean[#clean + 1] = name
		end
	end
end
table.sort(clean)
data:extend({ { type = "mod-data", name = C.CLEAN_AIR_DATA, data = { names = clean } } })

table.sort(applied)
log("ToxicPollution2-reforged: armor filtration/resource: " .. table.concat(applied, ", "))
log("ToxicPollution2-reforged: vehicles with cabin filtration: " .. cabins .. "; clean-air machines: " .. #clean)
