data.raw.technology["kovarex-enrichment-process"].enabled = false
bobmods.lib.tech.remove_prerequisite("bobingabout-enrichment-process", "kovarex-enrichment-process")
--data.raw.technology["nuclear-fuel-reprocessing"].enabled = false
data.raw.recipe["advanced-uranium-processing"].hidden=true-- = nil

--set-up default tech names
local centri_1="nuclear-power"
local centri_2="nuclear-power"
if settings.startup["MCP_enable_centrifuges"].value then
	centri_1="centrifuging-1"
	centri_2="centrifuging-2"
elseif mods["bobassembly"] and settings.startup["bobmods-assembly-centrifuge"].value then
	centri_1="centrifuge-2"
	centri_2="centrifuge-3"
end
table.insert(data.raw["technology"][centri_1].effects, {type = "unlock-recipe", recipe = "depleted-uranium-reprocessing"})
table.insert(data.raw["technology"][centri_1].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-45%"})
table.insert(data.raw["technology"][centri_1].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-55%"})
table.insert(data.raw["technology"][centri_2].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-65%"})
table.insert(data.raw["technology"][centri_2].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-70%"})
table.insert(data.raw["technology"][centri_2].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-75%"})
table.insert(data.raw["technology"][centri_2].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-80%"})

table.insert(data.raw["technology"]["water-treatment-4"].effects, {type = "unlock-recipe", recipe = "radioactive-waste-water-purification"})


--Add ingredients to thermonuclear bomb
data.raw["recipe"]["thermonuclear-bomb"].ingredients = {}

if mods["bobmodules"] then
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"speed-module-6", 3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"productivity-module-6", 3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"effectivity-module-6", 3})
else
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"speed-module-3", 3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"productivity-module-3", 3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"effectivity-module-3", 3})
end

if data.raw.item["fusion-reactor-equipment-2"] then
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"fusion-reactor-equipment-2", 1})
else
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"fusion-reactor-equipment", 1})
end

table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"rocket-control-unit", 200})
if data.raw.item["electronic-logic-board"] then
	bobmods.lib.recipe.replace_ingredient("plutonium-atomic-bomb","electronic-logic-board","rocket-control-unit")
elseif data.raw.item["processing-unit"] then
	bobmods.lib.recipe.replace_ingredient("plutonium-atomic-bomb","processing-unit","rocket-control-unit")
end

data.raw.recipe["nuclear-fuel-reprocessing"].results=
{ -- A direct copy of bobs recipe, it is better balanced
	{type="item", name="plutonium-239", amount=3,probability=0.1},
	{type="item", name="uranium-238", amount=3},
	{type="item", name="lead-plate", amount=5}
}
if data.raw.recipe["thorium-plutonium-fuel-cell"] then
data.raw.recipe["thorium-plutonium-fuel-cell"].ingredients=
{
	{type="item", name="plutonium-239", amount=6},
	{type="item", name="lead-plate", amount=2},
	{type="item", name="thorium-232", amount=6}
}
end
if settings.startup["reprocessing-overhaul"].value then
	local rec_chance= 1
	if data.raw.recipe["angels-roll-lead-converting"] then -- assuming full modules, assembly and coils
		rec_chance= 0.215
	elseif mods["bobmodules"] and mods["bobassembly"] then
		rec_chance= 0.4
	elseif mods["bobmodules"] and not mods["bobassembly"] then -- im sure someone is crazy enough...
		rec_chance= 0.52 -- balanced based on pure prod MK8 modules and vanilla MK3 AM
	elseif not mods["bobmodules"] and mods["bobassembly"] then -- highly possible, especially with space-exploration, not sure how to account for earendels modules yet
		rec_chance= 1.28 -- balanced based on vanilla modules in bobs MK6 AM
	else -- bare minimum mods (no modules, no assembly)
		rec_chance= 1.45 -- balanced based on vanilla modules and vanilla MK3 AM
	end
	--uranium updates
	bobmods.lib.recipe.remove_result("nuclear-fuel-reprocessing","lead-plate")
	bobmods.lib.recipe.add_result("nuclear-fuel-reprocessing", {type="item",name="lead-oxide",amount= 2,probability=rec_chance})
	bobmods.lib.recipe.add_result("advanced-nuclear-fuel-reprocessing", {type="item",name="lead-oxide",amount= 2,probability=rec_chance})
	--thorium updates
	if data.raw.item["thorium-ore"] then
		bobmods.lib.recipe.add_result("advanced-thorium-nuclear-fuel-reprocessing", {type="item",name="lead-oxide",amount= 2,probability=rec_chance})
		bobmods.lib.recipe.add_result("advanced-thorium-nuclear-fuel-reprocessing|b", {type="item",name="lead-oxide",amount= 2,probability=rec_chance})
		angelsmods.functions.allow_productivity("mixed-oxide")
		angelsmods.functions.allow_productivity("thorium-mixed-oxide")
		bobmods.lib.recipe.remove_result("thorium-fuel-reprocessing","lead-plate")
		bobmods.lib.recipe.add_result("thorium-fuel-reprocessing", {type="item",name="lead-oxide",amount= 2,probability=rec_chance})
	else
		bobmods.lib.recipe.add_result("advanced-nuclear-fuel-reprocessing-2", {type="item",name="lead-oxide",amount= 2,probability=rec_chance})
	end
end
if mods["angelsindustries"] then
	data.raw["item-subgroup"]["clowns-uranium-centrifuging"].group = "angels-power"
	data.raw["item-subgroup"]["clowns-uranium-centrifuging"].order = "d[clowns]-ac[centrifuging]"
	data.raw["item-subgroup"]["clowns-nuclear-fuels"].group = "angels-power"
	data.raw["item-subgroup"]["clowns-nuclear-fuels"].order = "d[clowns]-ad[fuels]"
	data.raw["item-subgroup"]["clowns-nuclear-cells"].group = "angels-power"
	data.raw["item-subgroup"]["clowns-nuclear-cells"].order = "d[clowns]-ab[cells]"
end
