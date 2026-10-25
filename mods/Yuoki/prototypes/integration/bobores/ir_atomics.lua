if mods["bobores"] then
	-- Ores
	if settings.startup["bobmods-ores-enablebauxite"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-bauxite-ore", 32, 20, 1) -- Bauxite
	end

	if settings.startup["bobmods-ores-enablecobaltore"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-cobalt-ore", 32, 10, 1) -- Cobalt ore
	end

	if settings.startup["bobmods-ores-enablegoldore"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-gold-ore", 32, 10, 1) -- Gold ore
	end

	if settings.startup["bobmods-ores-enableleadore"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-lead-ore", 32, 20, 1) -- Lead ore
	end

	if settings.startup["bobmods-ores-enablenickelore"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-nickel-ore", 32, 20, 1) -- Nickel ore
	end

	if settings.startup["bobmods-ores-enablequartz"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-quartz", 32, 20, 1) -- Quartz
	end

	if settings.startup["bobmods-ores-enablerutile"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-rutile-ore", 32, 20, 1) -- Rutile ore
	end

	if settings.startup["bobmods-ores-enablesilverore"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-silver-ore", 32, 20, 1) -- Silver ore
	end

	if settings.startup["bobmods-ores-enabletinore"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-tin-ore", 32, 20, 1) -- Tin ore
	end

	if settings.startup["bobmods-ores-enabletungstenore"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("tungsten-ore", 32, 10, 1) -- Tungsten ore
	end

	if settings.startup["bobmods-ores-enablezincore"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-zinc-ore", 32, 20, 1) -- Zinc ore
	end

	if settings.startup["bobmods-ores-enablethoriumore"].value == true then
		yi.lib.recipe.atomics.recipes_make_item("bob-thorium-ore", 32, 10, 1) -- Thorium ore
	end

	-- Fluids
	if settings.startup["bobmods-ores-enablewaterores"].value == true then
		yi.lib.recipe.atomics.recipes_make_fluid("bob-lithia-water", 32, 80, 1) -- Lithia water
	end

	if mods["angelsrefining"] then
		-- Ores
		yi.lib.recipe.atomics.recipes_make_item("bob-bauxite-ore", 32, 20, 1) -- Bauxite
		yi.lib.recipe.atomics.recipes_make_item("bob-cobalt-ore", 32, 10, 1) -- Cobalt ore
		yi.lib.recipe.atomics.recipes_make_item("bob-gold-ore", 32, 10, 1) -- Gold ore
		yi.lib.recipe.atomics.recipes_make_item("bob-lead-ore", 32, 20, 1) -- Lead ore
		yi.lib.recipe.atomics.recipes_make_item("bob-nickel-ore", 32, 20, 1) -- Nickel ore
		yi.lib.recipe.atomics.recipes_make_item("bob-quartz", 32, 20, 1) -- Quartz
		yi.lib.recipe.atomics.recipes_make_item("bob-rutile-ore", 32, 20, 1) -- Rutile ore
		yi.lib.recipe.atomics.recipes_make_item("bob-silver-ore", 32, 20, 1) -- Silver ore
		yi.lib.recipe.atomics.recipes_make_item("bob-tin-ore", 32, 20, 1) -- Tin ore
		yi.lib.recipe.atomics.recipes_make_item("tungsten-ore", 32, 10, 1) -- Tungsten ore
		yi.lib.recipe.atomics.recipes_make_item("bob-zinc-ore", 32, 20, 1) -- Zinc ore
		yi.lib.recipe.atomics.recipes_make_item("bob-thorium-ore", 32, 10, 1) -- Thorium ore
	end
end
