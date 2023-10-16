require "tech"
--[[
for name,tech in pairs(data.raw.technology) do
	if not tech.upgrade and tech.max_level ~= "infinite" then
		if techUsesPack(tech, "space-science-pack") then
			if not techHasDependencyRecursive(tech, "space-science-pack") then
				if not tech.prerequisites then tech.prerequisites = {} end
				table.insert(tech.prerequisites, "space-science-pack")
			end
		elseif techUsesPack(tech, "utility-science-pack") then
			if not techHasDependencyRecursive(tech, "utility-science-pack") then
				if not tech.prerequisites then tech.prerequisites = {} end
				table.insert(tech.prerequisites, "utility-science-pack")
			end
		elseif techUsesPack(tech, "production-science-pack") then
			if not techHasDependencyRecursive(tech, "production-science-pack") then
				if not tech.prerequisites then tech.prerequisites = {} end
				table.insert(tech.prerequisites, "production-science-pack")
			end
		elseif techUsesPack(tech, "chemical-science-pack") then
			if not techHasDependencyRecursive(tech, "chemical-science-pack") then
				if not tech.prerequisites then tech.prerequisites = {} end
				table.insert(tech.prerequisites, "chemical-science-pack")
			end
		elseif techUsesPack(tech, "logistic-science-pack") then
			if not techHasDependencyRecursive(tech, "logistic-science-pack") then
				if not tech.prerequisites then tech.prerequisites = {} end
				table.insert(tech.prerequisites, "logistic-science-pack")
			end
		end
	end
end
--]]

--[[
for name,recipe in pairs(data.raw.recipe) do
	if recipe.category == "chemistry" and recipe.ingredients and #recipe.ingredients >= 3 then
		local fluids = {}
		for _,item in pairs(recipe.ingredients) do
			if item.type == "fluid" then
				table.insert(fluids, {name = item.name, amount = item.amount})
			end
		end
		if #fluids > 2 then
			log("Chemistry recipe " .. name .. " has too many fluid inputs to function in the chemplant! Adding support for use of barelled ingredients")
			local barrels = {}
			for _,entry in pairs(fluids) do
				local fluid = entry.name
				--if data.raw.fluid.auto_barrel then
					local item = data.raw.item[fluid .. "-barrel"]
					if item then
						local amt = 50 --barrels store 50 units of fluid by default
						local recipe = data.raw.recipe["fill-" .. item.name]
						for _,ing in pairs(recipe.ingredients) do
							if ing.type == "fluid" then
								amt = ing.amount
								break
							end
						end
						barrels[fluid] = {item = item.name, capacity = amt, used = entry.amount} 
					end
				--end
			end
			log("Found relevant barrels: " .. serpent.block(barrels))
			for fluid,barrel in pairs(barrels) do
				local rec = table.deepcopy(recipe)
				log("Adding recipe with " .. fluid .. " in barrel form")
				local factor = 1
				for _,ing in pairs(rec.ingredients) do
					if ing.type == "fluid" and ing.name == fluid then
						local count = ing.amount/barrel.capacity --how many barrels worth
						if count ~= math.floor(count) then
							if count < 1 then
								factor = 1/count
							else --eg 75 = 1.5 barrels
								while count ~= math.floor(count) do
									count = count*10
								end
								local test = count/2
								while test == math.floor(test) do
									count = test
									test = count/2
								end
							end
							log("Need to multiply all amounts by " .. factor .. " to prevent decimals, as the recipe only uses " .. ing.amount .. ", aka " .. count .. " barrels' worth.")
						end
						ing.type = "item"
						ing.name = barrel.item
						ing.amount = count
						break
					end
				end
				if factor ~= 1 then
					rec.energy_required = rec.energy_required*factor
					for _,ing in pairs(rec.ingredients) do
						ing.amount = ing.amount*factor
					end
				end
				rec.name = recipe.name .. "-barrel-" .. fluid
				data:extend({rec})
			end
		end
	end
end
--]]