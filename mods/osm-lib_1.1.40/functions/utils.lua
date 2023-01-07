local utils = {}

-- Returns table length
function utils.get_table_length(array)
	local count = 0
	for _ in pairs(array) do
		count = count+1
	end
	return count
end

-- Mod presence checker
function utils.mod_installed(mod_name)
	if OSM.control_stage then
		if game.active_mods[mod_name] then return true end
	elseif OSM.data_stage then
		if mods[mod_name] then return true end
	end
end

-- Returns true if prototype exists
function utils.prototype_valid(prototype_type, prototype_name)

	local function prototype_valid (prototype_type, prototype_name)
		if prototype_type == "entity" then
			for entity_type, _ in pairs(OSM.dictionary.entity) do
				if data.raw[entity_type][prototype_name] then return true end
			end
	
		elseif prototype_type == "recipe" then
			if data.raw.recipe[prototype_name] then return true end
	
		elseif prototype_type == "item" then
			for item_type, _ in pairs(OSM.dictionary.item) do
				if data.raw[item_type][prototype_name] then return true end
			end
	
		elseif prototype_type == "fluid" then
			if data.raw.fluid[prototype_name] then return true end
	
		elseif prototype_type == "technology" then
			if data.raw.technology[prototype_name] then return true end

		elseif prototype_type == "resource" then
			if data.raw.resource[prototype_name] then return true end
		end
	end

	if type(prototype_type) == "string" then
		return prototype_valid(prototype_type, prototype_name)
	elseif type(prototype_type) == "table" then
		for _, sub_type in pairs(prototype_type) do
			return prototype_valid(sub_type, prototype_name)
		end
	end
end

return utils