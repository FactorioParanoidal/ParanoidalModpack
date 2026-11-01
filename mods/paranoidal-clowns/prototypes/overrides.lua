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

-- Magnesium plates only when another mod asks for them (clowns.trigger.smelting_products.magnesium.plate).
if not clowns.trigger.smelting_products["magnesium"].plate then
	angelsmods.functions.OV.disable_recipe({
		"clowns-molten-magnesium-smelting",
		"clowns-plate-magnesium",
	})
	angelsmods.functions.hide({
		"clowns-liquid-molten-magnesium",
		"clowns-plate-magnesium",
	})
end
