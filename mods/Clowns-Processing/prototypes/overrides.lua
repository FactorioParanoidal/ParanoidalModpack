--[[OPTIONAL REMOVE BOB'S BULLETS
if settings.startup["bob-bullet-override"].value and mods["bobwarfare"] then
	--DO THINGS SOME DAY :o
end]] --

--REPLACE URANIUM-238 WITH DEPLETED URANIUM FOR MILITARY APPLICATIONS

angelsmods.functions.OV.patch_recipes({
	{
		name = "uranium-rounds-magazine",
		ingredients = {
			{ name = "clowns-plate-depleted-uranium", amount = "uranium-238" },
		},
	},
	{
		name = "uranium-bullet-projectile",
		ingredients = {
			{ name = "clowns-plate-depleted-uranium", amount = "uranium-238" },
		},
	},
	{
		name = "shotgun-uranium-shell",
		ingredients = {
			{ name = "clowns-plate-depleted-uranium", amount = "uranium-238" },
		},
	},
	{
		name = "uranium-cannon-shell",
		ingredients = {
			{ name = "clowns-plate-depleted-uranium", amount = "uranium-238" },
		},
	},
	{
		name = "explosive-uranium-cannon-shell",
		ingredients = {
			{ name = "clowns-plate-depleted-uranium", amount = "uranium-238" },
		},
	},
})

--OPTIONAL SPACEMOD CLEANUP
--[[if mods["SpaceMod"] then
	data.raw.item["assembly-robot"].subgroup = "spacex"
	data.raw.item["drydock-assembly"].subgroup = "spacex"
	data.raw.item["drydock-structural"].subgroup = "spacex"
	data.raw.item["fusion-reactor"].subgroup = "spacex"
	data.raw.item["hull-component"].subgroup = "spacex"
	data.raw.item["protection-field"].subgroup = "spacex"
	data.raw.item["space-thruster"].subgroup = "spacex"
	data.raw.item["fuel-cell"].subgroup = "spacex"
	data.raw.item["habitation"].subgroup = "spacex"
	data.raw.item["life-support"].subgroup = "spacex"
	data.raw.item["command"].subgroup = "spacex"
	data.raw.item["astrometrics"].subgroup = "spacex"
	data.raw.item["command"].subgroup = "spacex"
	data.raw.item["ftl-drive"].subgroup = "spacex"
end]]
--centrifuge updates
if settings.startup["MCP_enable_centrifuges"].value then
	data.raw.item["centrifuge"].localised_name = { "centrifuge", "MK1" }
	data.raw.item["centrifuge"].order = "a-a"
	data.raw["assembling-machine"]["centrifuge"].fast_replaceable_group = "centrifuge"
end

if settings.startup["fluid-cleanup"].value == true and data.raw["item-group"]["bob-fluid-products"] then
	data.raw["item-subgroup"]["bob-fluid"].group = "bob-resource-products"
	if data.raw["item-subgroup"]["bob-fluid-electrolysis"] then
		data.raw["item-subgroup"]["bob-fluid-electrolysis"].group = "bob-resource-products"
	end
	if data.raw["item-subgroup"]["bob-fluid-pump"] then
		data.raw["item-subgroup"]["bob-fluid-pump"].group = "bob-resource-products"
	end
end

--update aluminium
if angelsmods.trigger.smelting_products["aluminium"].plate then
	data.raw.recipe["angels-liquid-molten-aluminium-3"].order = "i[liquid-molten-aluminium]-d"
end
--update titanium sponge
if angelsmods.trigger.smelting_products["titanium"].plate then
	data.raw.recipe["angels-sponge-titanium"].icons = angelsmods.functions.add_number_icon_layer(
		angelsmods.functions.get_object_icons("angels-sponge-titanium"),
		1, angelsmods.smelting.number_tint)
	data.raw.recipe["angels-sponge-magnesium-titanium-smelting"].icons = angelsmods.functions.add_number_icon_layer(
		angelsmods.functions.get_object_icons("angels-sponge-titanium"),
		2, angelsmods.smelting.number_tint)
end

if clowns.trigger.smelting_products["magnesium"].plate then
else
	angelsmods.functions.OV.disable_recipe({
		"clowns-molten-magnesium-smelting",
		"clowns-plate-magnesium",
	})
	angelsmods.functions.hide({
		"clowns-liquid-molten-magnesium",
		"clowns-plate-magnesium",
	})
end
