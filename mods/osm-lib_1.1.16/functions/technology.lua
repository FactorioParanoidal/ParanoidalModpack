------------------
---- data.lua ----
------------------

-- Get local functions
local OSM_local = require("utils.local-functions")

-- Setup function host
if not OSM.lib.technology then OSM.lib.technology = {} end

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

-- Recipe unlock ADD
function OSM.lib.technology.add_unlock(recipe_name, technology_name)

	-- Check if recipe and technology exist
	if data.raw.technology[technology_name] and data.raw.recipe[recipe_name] then
	
		-- Add recipe
		table.insert(data.raw.technology[technology_name].effects,{type = "unlock-recipe", recipe = recipe_name})
	end
end

-- Recipe unlock REMOVE [technology_name is optional]
function OSM.lib.technology.remove_unlock(recipe_name, technology_name)

	-- Check if recipe exists
	if data.raw.recipe[recipe_name] then

		-- If technology name is not specified scans all techs and removes specified recipe unlock from all techs
		if technology_name == nil then
			for _, technology in pairs(data.raw.technology) do
			
				local effects = technology.effects
				
				if effects then
					for i, effect in pairs(effects) do
						if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
							table.remove(effects, i)
						end
					end
				end
			end

		-- If technology name is specified removes specified recipe unlock for specified tech
		elseif technology_name ~= nil then
			if data.raw.technology[technology_name] then

				local effects = data.raw.technology[technology_name].effects
				
				if effects then
					for i, effect in pairs(effects) do
						if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
							table.remove(effects, i)
						end
					end
				end
			end
		end
	end
end

-- Recipe unlock REPLACE [technology_name is optional]
function OSM.lib.technology.replace_unlock(old_recipe, new_recipe, technology_name)

	-- Check if both recipes exist
	if data.raw.recipe[old_recipe] and data.raw.recipe[new_recipe] then

		-- If technology name is not specified scans all techs replaces old recipe in all techs
		if technology_name == nil then
			for _, technology in pairs(data.raw.technology) do
			
				local effects = technology.effects
				
				if effects then
					for _, effect in pairs(effects) do
						if effect.type == "unlock-recipe" and effect.recipe == new_recipe then
							for i, effect in pairs(effects) do
								if effect.type == "unlock-recipe" and effect.recipe == old_recipe then
									table.remove(effects, i)
								end
							end
						elseif effect.type == "unlock-recipe" and effect.recipe == old_recipe then
							for i, effect in pairs(effects) do
								if effect.type == "unlock-recipe" and effect.recipe ~= new_recipe then
									effect.recipe = new_recipe
								end
							end
						end
					end
				end
			end

		-- If technology name is specified replaces old recipe in specified tech
		elseif technology_name ~= nil then
			if data.raw.technology[technology_name] then

				local effects = data.raw.technology[technology_name].effects
				
				if effects then
					for _, effect in pairs(effects) do
						if effect.type == "unlock-recipe" and effect.recipe == new_recipe then
							for i, effect in pairs(effects) do
								if effect.type == "unlock-recipe" and effect.recipe == old_recipe then
									table.remove(effects, i)
								end
							end
						elseif effect.type == "unlock-recipe" and effect.recipe == old_recipe then
							for i, effect in pairs(effects) do
								if effect.type == "unlock-recipe" and effect.recipe ~= new_recipe then
									effect.recipe = new_recipe
								end
							end
						end
					end
				end
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

-- Prerequisite ADD
function OSM.lib.technology.add_prerequisite(prerequisite, technology_name)
	if data.raw.technology[technology_name] then
		table.insert(data.raw.technology[technology_name].prerequisites, prerequisite)
	end
end

-- Prerequisite REMOVE
function OSM.lib.technology.remove_prerequisite(prerequisite, technology_name)
	if data.raw.technology[technology_name] then
		table.remove(data.raw.technology[technology_name].prerequisites, prerequisite)
	end
end

-- Prerequisite REPLACE [technology_name is optional]
function OSM.lib.technology.replace_prerequisite(old_prerequisite, new_prerequisite, technology_name)
	if technology_name == nil then
		for _, technology in pairs(data.raw.technology) do
			for _, prerequisite in pairs(technology.prerequisites) do
				if prerequisite == old_prerequisite then
					prerequisite = new_prerequisite
				end
			end
		end
	elseif technology_name ~= nil then
		if data.raw.technology[technology_name] then
			table.remove(data.raw.technology[technology_name].prerequisites, old_prerequisite)
			table.insert(data.raw.technology[technology_name].prerequisites, new_prerequisite)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------