-- Качественные семена и саженцы BI становятся обычными (anti-exploit.lua п. 9).
local names = {["bi-seed"] = true, ["seedling"] = true}
local converted, failed, machines = 0, 0, 0

local function convert(stack)
	if not (stack and stack.valid_for_read and names[stack.name] and stack.quality.name ~= "normal") then return end
	local count = stack.count
	if stack.set_stack({name = stack.name, count = count, quality = "normal"}) then
		converted = converted + count
	else
		failed = failed + count
	end
end

local function convert_inventory(inventory)
	if not inventory then return end
	for slot = 1, #inventory do convert(inventory[slot]) end
end

local function convert_line(line)
	for _, item in pairs(line.get_detailed_contents()) do
		local stack = item.stack
		if stack.valid_for_read and names[stack.name] and stack.quality.name ~= "normal" then
			local name, count, quality = stack.name, stack.count, stack.quality.name
			if stack.set_stack({name = name, count = count, quality = "normal"}) then
				converted = converted + count
			else
				local removed = line.remove_item({name = name, count = count, quality = quality})
				if removed > 0 and line.force_insert_at(item.position, {name = name, count = removed, quality = "normal"}) then
					converted = converted + removed
				else
					failed = failed + count - removed
				end
			end
		end
	end
end

local function consumes(recipe)
	for _, ingredient in pairs(recipe.ingredients) do
		if ingredient.type == "item" and names[ingredient.name] then return true end
	end
	return false
end

local wanted = {
	"container", "logistic-container", "linked-container", "infinity-container", "temporary-container",
	"proxy-container", "cargo-wagon", "locomotive", "artillery-wagon", "car", "spider-vehicle", "character",
	"character-corpse", "assembling-machine", "furnace", "rocket-silo", "lab", "inserter", "item-entity",
	"transport-belt", "underground-belt", "splitter", "loader", "loader-1x1", "linked-belt", "lane-splitter",
	"construction-robot", "logistic-robot", "roboport", "boiler", "burner-generator", "reactor", "mining-drill",
	"ammo-turret", "artillery-turret", "beacon", "market", "agricultural-tower", "cargo-landing-pad",
}
local present = {}
for _, prototype in pairs(prototypes.entity) do present[prototype.type] = true end
local types = {}
for _, kind in ipairs(wanted) do
	if present[kind] then types[#types + 1] = kind end
end
local belts = {["transport-belt"] = true, ["underground-belt"] = true, ["splitter"] = true, ["loader"] = true,
	["loader-1x1"] = true, ["linked-belt"] = true, ["lane-splitter"] = true}

for _, surface in pairs(game.surfaces) do
	for _, entity in pairs(surface.find_entities_filtered({type = types})) do
		if entity.valid then
			local kind = entity.type
			if kind == "assembling-machine" then
				local recipe, quality = entity.get_recipe()
				if recipe and quality and quality.name ~= "normal" and consumes(recipe) then
					local removed = entity.set_recipe(recipe, "normal")
					for _, item in pairs(removed) do
						local quality_name = item.quality or "normal"
						if names[item.name] and quality_name ~= "normal" then
							converted = converted + item.count
							quality_name = "normal"
						end
						surface.spill_item_stack({position = entity.position,
							stack = {name = item.name, count = item.count, quality = quality_name},
							force = entity.force, allow_belts = false})
					end
					machines = machines + 1
				end
			end
			if kind == "item-entity" then
				convert(entity.stack)
			elseif kind == "inserter" then
				convert(entity.held_stack)
			elseif belts[kind] then
				for index = 1, entity.get_max_transport_line_index() do convert_line(entity.get_transport_line(index)) end
			end
			for index = 1, entity.get_max_inventory_index() do convert_inventory(entity.get_inventory(index)) end
		end
	end
end

for _, player in pairs(game.players) do
	convert(player.cursor_stack)
	if not player.character then convert_inventory(player.get_main_inventory()) end
end

log("zzzparanoidal migration normal-seeds: seeds and seedlings made normal " .. converted
	.. ", not converted " .. failed .. ", machines switched to normal recipe quality " .. machines)
