------------------------------------------------------------------------------------------------------
-------------------------------- SHAMELESSLY STOLEN FROM BOB'S MINING --------------------------------
------------------------------------------------------------------------------------------------------

-- SORRY BOB :(

if not mods ["boblibrary"] then return end
	
-- Water pumpjack 1
if data.raw.item["basic-circuit-board"] then
	bobmods.lib.recipe.replace_ingredient("water-pumpjack-1", "electronic-circuit", "basic-circuit-board")
end

if data.raw.item["copper-pipe"] then
	bobmods.lib.recipe.replace_ingredient("water-pumpjack-1", "pipe", "copper-pipe")
end


-- Make recipes for bobmining
local setting = settings.startup["bobmods-mining-waterminers"]

if setting and setting.value == true then

	-- Water pumpjack 2
	if data.raw.item["steel-gear-wheel"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-2", "iron-gear-wheel", "steel-gear-wheel")
	end
	
	if data.raw.item["bronze-pipe"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-2", "pipe", "bronze-pipe")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-2", "alloy-processing")
	else
		if data.raw.item["steel-pipe"] then
			bobmods.lib.recipe.replace_ingredient("water-pumpjack-3", "pipe", "steel-pipe")
		end
	end

	-- Water pumpjack 3
	if data.raw.item["aluminium-plate"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-3", "steel-plate", "aluminium-plate")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-3", "aluminium-processing")
	else
		if data.raw.item["brass-alloy"] then
			bobmods.lib.recipe.replace_ingredient("water-pumpjack-3", "steel-plate", "brass-plate")
			bobmods.lib.tech.add_prerequisite("water-pumpjack-3", "zinc-processing")
		end
	end
	
	if data.raw.item["brass-gear-wheel"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-3", "iron-gear-wheel", "brass-gear-wheel")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-3", "zinc-processing")
	else
		if data.raw.item["steel-gear-wheel"] then
			bobmods.lib.recipe.replace_ingredient("water-pumpjack-3", "iron-gear-wheel", "steel-gear-wheel")
		end
	end
	
	if data.raw.item["brass-pipe"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-3", "pipe", "brass-pipe")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-3", "zinc-processing")
	else
		if data.raw.item["plastic-pipe"] then
			bobmods.lib.recipe.replace_ingredient("water-pumpjack-3", "pipe", "plastic-pipe")
			bobmods.lib.tech.add_prerequisite("water-pumpjack-3", "plastics")
		end
	end

	-- Water pumpjack 4
	if data.raw.item["titanium-plate"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-4", "steel-plate", "titanium-plate")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-4", "titanium-processing")
	else
		if data.raw.item["tungsten-plate"] then
			bobmods.lib.recipe.replace_ingredient("water-pumpjack-4", "steel-plate", "tungsten-plate")
			bobmods.lib.tech.add_prerequisite("water-pumpjack-4", "tungsten-processing")
		end
	end
	
	if data.raw.item["titanium-gear-wheel"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-4", "iron-gear-wheel", "titanium-gear-wheel")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-4", "titanium-processing")
	else
		if data.raw.item["tungsten-gear-wheel"] then
			bobmods.lib.recipe.replace_ingredient("water-pumpjack-4", "iron-gear-wheel", "tungsten-gear-wheel")
			bobmods.lib.tech.add_prerequisite("water-pumpjack-4", "tungsten-processing")
		end
	end
	
	if data.raw.item["titanium-pipe"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-4", "pipe", "titanium-pipe")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-4", "titanium-processing")
	else
		if data.raw.item["plastic-pipe"] then
			bobmods.lib.recipe.replace_ingredient("water-pumpjack-4", "pipe", "plastic-pipe")
			bobmods.lib.tech.add_prerequisite("water-pumpjack-4", "plastics")
		end
	end

	-- Water pumpjack 5
	if data.raw.item["nitinol-alloy"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-5", "steel-plate", "nitinol-alloy")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-5", "nitinol-processing")
	else
		if data.raw.item["copper-tungsten-alloy"] then
			bobmods.lib.recipe.replace_ingredient("water-pumpjack-5", "steel-plate", "copper-tungsten-alloy")
			bobmods.lib.tech.add_prerequisite("water-pumpjack-5", "tungsten-alloy-processing")
		end
	end
	
	if data.raw.item["nitinol-gear-wheel"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-5", "iron-gear-wheel", "nitinol-gear-wheel")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-5", "nitinol-processing")
	else
		if data.raw.item["tungsten-gear-wheel"] then
			bobmods.lib.recipe.replace_ingredient("water-pumpjack-5", "iron-gear-wheel", "tungsten-gear-wheel")
			bobmods.lib.tech.add_prerequisite("water-pumpjack-5", "tungsten-processing")
		end
	end
	
	if data.raw.item["advanced-processing-unit"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-5", "processing-unit", "advanced-processing-unit")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-5", "advanced-electronics-3")
	end
	
	if data.raw.item["nitinol-pipe"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-5", "pipe", "nitinol-pipe")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-5", "nitinol-processing")
	elseif data.raw.item["tungsten-pipe"] then
		bobmods.lib.recipe.replace_ingredient("water-pumpjack-5", "pipe", "tungsten-pipe")
		bobmods.lib.tech.add_prerequisite("water-pumpjack-5", "tungsten-processing")
	end
end