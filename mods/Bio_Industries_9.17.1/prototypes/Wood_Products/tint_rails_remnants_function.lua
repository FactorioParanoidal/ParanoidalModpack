
function find_ties (table_name, table, entity_type)
	if not (type(table) == "table") then 
		return
	end
	-- only tables
	if table_name == "ties" then
		-- we have found ties
		return true
	end
	for i, v in pairs (table) do
		-- probably lower can be ties
		local cash = find_ties(i, v, entity_type)
		-- if we have found ties then 
		if cash then 
			local new_name = string.gsub(table_name, '_', '-') -- ohh! All names have '-' in the name
			global[entity_type][#global[entity_type]+1] = {name = new_name, table = v}
		end
	end
end


------------------------------------ 
------------------------------------ rails
------------------------------------ 


function set_tint_to_rails (rails_entities, tint) 
-- two tables:
-- first table is a list of elements
-- second is a tint
--local wood_tint = {r = 183/255, g = 125/255, b = 62/255, a = 1}
--local concrete_tint = {r = 183/255, g = 183/255, b = 183/255, a = 1}
local tint = tint
local sheet_path_ties = "__Bio_Industries__/graphics/entities/wood_products/rails/ties/"
local rails_entities = rails_entities or  -- or vanilla
	{
	data.raw["straight-rail"]["straight-rail"],
	data.raw["curved-rail"]["curved-rail"]
	}
global = global or {}
global["rails"] = {}
log("Start rails") 	---------------------
for i, v in pairs (rails_entities) do
	local r_table = serpent.block(find_ties(i, v, "rails"))
end
log ("global table of rails is complete :" .. #global.rails)
for i, handler in pairs (global.rails) do
	--handler.name = "straight_rail_horizontal"
	local was_filename = handler.table.filename
	handler.table.filename = sheet_path_ties .. handler.name .. "-ties.png"
	handler.table.hr_version.filename = sheet_path_ties .. "hr-" .. handler.name .. "-ties.png"
	log ('Replaced: ' .. was_filename .. ' ===>>> ' .. handler.table.filename)
	handler.table.tint = tint
	handler.table.hr_version.tint = tint -- oops, i'mm forgot it, added in 0.0.3
end
log("End rails") 		---------------------
end


------------------------------------ 
------------------------------------ remnants
------------------------------------ 

function set_tint_to_remnants (remnants_entities, tint)  -- tha same function, actually
local tint = tint
local sheet_path_ties = "__Bio_Industries__/graphics/entities/wood_products/rails/ties/"
local remnants_entities = remnants_entities or -- or vanilla
	{
	data.raw["rail-remnants"]["straight-rail-remnants"],
	data.raw["rail-remnants"]["curved-rail-remnants"]
	}
global = global or {}
global["remnants"] = {}
log("Start remnants") 	---------------------
for i, v in pairs (remnants_entities) do
	local r_table = serpent.block(find_ties(i, v, "remnants"))
end
log ("global table of remnants is complete :" .. #global.remnants)
for i, handler in pairs (global.remnants) do
	--remnants.name = "straight_rail_horizontal"
	local was_filename = handler.table.filename
	handler.table.filename = sheet_path_ties .. handler.name .. "-ties-remnants.png"
	handler.table.hr_version.filename = sheet_path_ties .. "hr-" .. handler.name .. "-ties-remnants.png"
	log ('Replaced: ' .. was_filename .. ' ===>>> ' .. handler.table.filename)
	handler.table.tint = tint
	handler.table.hr_version.tint = tint -- oops, i'mm forgot it, added in 0.0.3
end
log("End remnants") 		---------------------
end
