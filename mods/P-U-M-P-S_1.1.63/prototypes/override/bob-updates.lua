--------------------------
---- data-updates.lua ----
--------------------------

-- Water pumpjack 1
OSM.lib.recipe_replace_ingredient("electronic-circuit", "basic-circuit-board", "water-pumpjack-1")
OSM.lib.recipe_replace_ingredient("pipe", "copper-pipe", "water-pumpjack-1")

-- Water pumpjack 2
OSM.lib.recipe_replace_ingredient("iron-gear-wheel", "steel-gear-wheel", "water-pumpjack-2")

if OSM.utils.prototype_valid("item", "bronze-pipe") then
	OSM.lib.recipe_replace_ingredient("pipe", "bronze-pipe", "water-pumpjack-2")
	OSM.lib.technology_add_prerequisite("alloy-processing", "water-pumpjack-2")

elseif OSM.utils.prototype_valid("item", "steel-pipe") then
	OSM.lib.recipe_replace_ingredient("pipe", "steel-pipe", "water-pumpjack-3")
end

-- Water pumpjack 3
if OSM.utils.prototype_valid("item","aluminium-plate") then
	OSM.lib.recipe_replace_ingredient("steel-plate", "aluminium-plate", "water-pumpjack-3")
	OSM.lib.technology_add_prerequisite("aluminium-processing", "water-pumpjack-3")

elseif OSM.utils.prototype_valid("item", "brass-alloy") then
	OSM.lib.recipe_replace_ingredient("steel-plate", "brass-alloy", "water-pumpjack-3")
	OSM.lib.technology_add_prerequisite("zinc-processing", "water-pumpjack-3")
end

if OSM.utils.prototype_valid("item", "brass-gear-wheel") then
	OSM.lib.recipe_replace_ingredient("iron-gear-wheel", "brass-gear-wheel", "water-pumpjack-3")
	OSM.lib.technology_add_prerequisite("zinc-processing", "water-pumpjack-3")

elseif OSM.utils.prototype_valid("item", "steel-gear-wheel") then
	OSM.lib.recipe_replace_ingredient("iron-gear-wheel", "steel-gear-wheel", "water-pumpjack-3")
end

if OSM.utils.prototype_valid("item", "brass-pipe") then
	OSM.lib.recipe_replace_ingredient("pipe", "brass-pipe", "water-pumpjack-3")
	OSM.lib.technology_add_prerequisite("zinc-processing", "water-pumpjack-3")

elseif OSM.utils.prototype_valid("item", "plastic-pipe") then
	OSM.lib.recipe_replace_ingredient("pipe", "plastic-pipe", "water-pumpjack-3")
	OSM.lib.technology_add_prerequisite("plastics", "water-pumpjack-3")
end

-- Water pumpjack 4
OSM.lib.technology_replace_science_pack("production-science-pack", "advanced-logistic-science-pack", "offshore-pump-4")
if OSM.utils.prototype_valid("item", "titanium-plate") then
	OSM.lib.recipe_replace_ingredient("steel-plate", "titanium-plate", "water-pumpjack-4")
	OSM.lib.technology_add_prerequisite("titanium-processing", "water-pumpjack-4")

elseif OSM.utils.prototype_valid("item", "tungsten-plate") then
	OSM.lib.recipe_replace_ingredient("steel-plate", "tungsten-plate", "water-pumpjack-4")
	OSM.lib.technology_add_prerequisite("tungsten-processing", "water-pumpjack-4")
end

if OSM.utils.prototype_valid("item", "titanium-gear-wheel") then
	OSM.lib.recipe_replace_ingredient("iron-gear-wheel", "titanium-gear-wheel", "water-pumpjack-4")
	OSM.lib.technology_add_prerequisite("titanium-processing", "water-pumpjack-4")

elseif OSM.utils.prototype_valid("item", "tungsten-gear-wheel") then
	OSM.lib.recipe_replace_ingredient("iron-gear-wheel", "tungsten-gear-wheel", "water-pumpjack-4")
	OSM.lib.technology_add_prerequisite("tungsten-processing", "water-pumpjack-4")
end

if OSM.utils.prototype_valid("item", "titanium-pipe") then
	OSM.lib.recipe_replace_ingredient("pipe", "titanium-pipe", "water-pumpjack-4")

elseif OSM.utils.prototype_valid("item", "plastic-pipe") then
	OSM.lib.recipe_replace_ingredient("pipe", "plastic-pipe", "water-pumpjack-4")
	OSM.lib.technology_add_prerequisite("plastics", "water-pumpjack-4")
end

-- Water pumpjack 5
if OSM.utils.prototype_valid("item", "nitinol-alloy") then
	OSM.lib.recipe_replace_ingredient("steel-plate", "nitinol-alloy", "water-pumpjack-5")
	OSM.lib.technology_add_prerequisite("nitinol-processing", "water-pumpjack-5")

elseif OSM.utils.prototype_valid("item", "copper-tungsten-alloy") then
	OSM.lib.recipe_replace_ingredient("steel-plate", "copper-tungsten-alloy", "water-pumpjack-5")
	OSM.lib.technology_add_prerequisite("tungsten-alloy-processing", "water-pumpjack-5")
end

if OSM.utils.prototype_valid("item", "nitinol-gear-wheel") then
	OSM.lib.recipe_replace_ingredient("iron-gear-wheel", "nitinol-gear-wheel", "water-pumpjack-5")
	OSM.lib.technology_add_prerequisite("nitinol-processing", "water-pumpjack-5")

elseif OSM.utils.prototype_valid("item", "tungsten-gear-wheel") then
	OSM.lib.recipe_replace_ingredient("iron-gear-wheel", "tungsten-gear-wheel", "water-pumpjack-5")
	OSM.lib.technology_add_prerequisite("tungsten-processing", "water-pumpjack-5")
end

if OSM.utils.prototype_valid("item", "advanced-processing-unit") then
	OSM.lib.recipe_replace_ingredient("processing-unit", "advanced-processing-unit", "water-pumpjack-5")
	OSM.lib.technology_add_prerequisite("advanced-electronics-3", "water-pumpjack-5")
end
	
if OSM.utils.prototype_valid("item", "nitinol-pipe") then
	OSM.lib.recipe_replace_ingredient("pipe", "nitinol-pipe", "water-pumpjack-5")
	OSM.lib.technology_add_prerequisite("nitinol-processing", "water-pumpjack-5")

elseif OSM.utils.prototype_valid("item", "tungsten-pipe") then
	OSM.lib.recipe_replace_ingredient("pipe", "tungsten-pipe", "water-pumpjack-5")
	OSM.lib.technology_add_prerequisite("tungsten-processing", "water-pumpjack-5")
end