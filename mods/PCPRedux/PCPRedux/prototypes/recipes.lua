local function create_icon(name, number_icon_layer)
	return angelsmods.functions.add_icon_layer(angelsmods.functions.get_object_icons(name), number_icon_layer)
end

data:extend({
	{ --
		type = "recipe",
		name = "liquid-plastic-pvc",
		category = "chemistry",
		subgroup = "angels-petrochem-solids",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-naphtha", amount = 5 },
			{ type = "fluid", name = "gas-vinyl-chloride",    amount = 30 },
		},
		results =
		{
			{ type = "fluid", name = "angels-liquid-plastic", amount = 20 }
		},
		order = "a[plastic]-a[liquid]-bz",
		icons = {
			{
				icon = "__PCPRedux__/graphics/icons/solid-polyvinyl-chloride.png",
				icon_size = 32.
			},
			{
				icon = "__angelsrefininggraphics__/graphics/icons/num_2.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			}
		},
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-plastic"),
		icon_size = 32,
	},
	{ --
		type = "recipe",
		name = "pmma-synthesis",
		category = "chemistry",
		subgroup = "angels-petrochem-solids",
		energy_required = 1,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "liquid-methyl-methacrylate", amount = 20 },
		},
		results =
		{
			{ type = "item", name = "solid-pmma", amount = 1 }
		},
		icon = "__PCPRedux__/graphics/icons/solid-polymethyl-methacrylate.png",
		icon_size = 32,
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-methyl-methacrylate"),
		order = "i[pmma-synthesis]",
	},
	{ --
		type = "recipe",
		name = "acrylonitrile-synthesis",
		category = "chemistry",
		subgroup = "angels-petrochem-nitrogen",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-gas-propene",  amount = 100 },
			{ type = "fluid", name = "angels-gas-ammonia",  amount = 100 },
			{ type = "item",  name = "catalyst-metal-cyan", amount = 1 }
		},
		results =
		{
			{ type = "fluid", name = "liquid-acrylonitrile",          amount = 100 },
			{ type = "item",  name = "angels-catalyst-metal-carrier", amount = 1 }
		},
		icons = angelsmods.functions.create_liquid_recipe_icon(
			{ { icon = "__PCPRedux__/graphics/icons/raw/acrylonitrile.png", icon_size = 72 } }, "CNH"),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-acrylonitrile"),
		order = "j[acryllonitrile-synthesis]",
	},
	{ --
		type = "recipe",
		name = "vinyl-chloride-synthesis",
		category = "chemistry",
		subgroup = "angels-petrochem-chlorine",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-gas-ethylene",        amount = 150 },
			{ type = "fluid", name = "angels-gas-chlorine",        amount = 75 },
			{ type = "item",  name = "angels-catalyst-metal-red",  amount = 1 },
			{ type = "item",  name = "angels-catalyst-metal-blue", amount = 1 }
		},
		results =
		{
			{ type = "fluid", name = "gas-vinyl-chloride",            amount = 75 },
			{ type = "item",  name = "angels-catalyst-metal-carrier", amount = 2 }
		},
		icons = angelsmods.functions.create_gas_recipe_icon(
			{ { icon = "__PCPRedux__/graphics/icons/raw/vinyl-chloride.png", icon_size = 72 } }, "CClH"),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("gas-vinyl-chloride"),
		order = "j",
	},
	{ --
		type = "recipe",
		name = "acetone-cyanohydrin-synthesis",
		category = "chemistry",
		subgroup = "angels-petrochem-nitrogen",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-gas-acetone",   amount = 50 },
			{ type = "fluid", name = "gas-hydrogen-cyanide", amount = 50 },
		},
		results =
		{
			{ type = "fluid", name = "liquid-acetone-cyanohydrin", amount = 100 }
		},
		icons = angelsmods.functions.create_liquid_recipe_icon(
			{ { icon = "__PCPRedux__/graphics/icons/raw/acetone-cyanohydrin.png", icon_size = 72 } }, "CON"),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-acetone-cyanohydrin"),
		order = "m[acetone-cyanohydrin-synthesis]",
	},
	{ --
		type = "recipe",
		name = "methyl-methacrylate-synthesis",
		category = "angels-advanced-chemistry",
		subgroup = "angels-petrochem-chemistry",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "liquid-acetone-cyanohydrin",  amount = 50 },
			{ type = "fluid", name = "angels-gas-methanol",         amount = 100 },
			{ type = "fluid", name = "angels-liquid-sulfuric-acid", amount = 50 }
		},
		results =
		{
			{ type = "fluid", name = "liquid-methyl-methacrylate", amount = 50 },
			{ type = "item",  name = "solid-ammonium-sulphate",    amount = 5 }
		},
		icons = angelsmods.functions.create_liquid_recipe_icon(
			{ { icon = "__PCPRedux__/graphics/icons/raw/methyl-methacrylate.png", icon_size = 72 } }, "CHO"),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-methyl-methacrylate"),
		order = "f",
	},
	{ --alt already exists
		type = "recipe",
		name = "phosgene-synthesis",
		category = "chemistry",
		subgroup = "angels-petrochem-chlorine",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-gas-carbon-monoxide", amount = 50 },
			{ type = "fluid", name = "angels-gas-chlorine",        amount = 50 },
		},
		results =
		{
			{ type = "fluid", name = "gas-phosgene", amount = 100 }
		},
		icons = angelsmods.functions.create_gas_recipe_icon(
			{ { "__angelspetrochemgraphics__/graphics/icons/molecules/phosgene.png", 72 } }, "CClO"),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("gas-phosgene"),
		order = "k[phosgene-synthesis]",
	},
	{ --
		type = "recipe",
		name = "nitrous-oxide-synthesis-1",
		category = "angels-advanced-chemistry",
		subgroup = "angels-petrochem-nitrogen",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-gas-urea",             amount = 50 },
			{ type = "fluid", name = "angels-liquid-nitric-acid",   amount = 20 },
			{ type = "fluid", name = "angels-liquid-sulfuric-acid", amount = 30 }
		},
		results =
		{
			{ type = "item",  name = "solid-ammonium-sulphate", amount = 4 },
			{ type = "fluid", name = "gas-nitrous-oxide",       amount = 60 }
		},
		--[[icon = "__PCPRedux__/graphics/icons/recipe-nitrous-oxide-1.png",
		icon_size = 32,]]
		icons = angelsmods.functions.create_gas_recipe_icon(
			{ { icon = "__PCPRedux__/graphics/icons/raw/nitrous-oxide.png", icon_size = 72 }, "solid-ammonium-sulphate" },
			"NNO"),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("gas-nitrous-oxide"),
		order = "k[nitrous-oxide-synthesis-1]",
	},
	{ --
		type = "recipe",
		name = "nitrous-oxide-synthesis-2",
		category = "chemistry",
		subgroup = "angels-petrochem-nitrogen",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "item", name = "solid-ammonium-sulphate", amount = 5 },
			{ type = "item", name = "solid-sodium-nitrate",    amount = 5 },
		},
		results =
		{
			{ type = "fluid", name = "gas-nitrous-oxide", amount = 100 }
		},
		icons = angelsmods.functions.create_gas_recipe_icon(
			{ { icon = "__PCPRedux__/graphics/icons/raw/nitrous-oxide.png", icon_size = 72 } }, "NNO"),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("gas-nitrous-oxide"),
		order = "l[nitrous-oxide-synthesis-2]",
	},
	{ --
		type = "recipe",
		name = "sodium-nitrate-synthesis",
		category = "angels-liquifying",
		subgroup = "angels-petrochem-basics",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "item",  name = "angels-solid-sodium-hydroxide", amount = 5 },
			{ type = "fluid", name = "angels-liquid-nitric-acid",     amount = 50 },
		},
		results =
		{
			{ type = "item", name = "solid-sodium-nitrate", amount = 10 }
		},
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint(
			"solid-sodium-nitrate" --[[ or "angels-liquid-nitric-acid"]]),
		order = "i[sodium-nitrate-synthesis]",
	},
	{ --
		type = "recipe",
		name = "hydrogen-cyanide-synthesis",
		category = "angels-advanced-chemistry",
		subgroup = "angels-petrochem-nitrogen",
		energy_required = 1,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-gas-methane",          amount = 20 },
			{ type = "fluid", name = "angels-gas-ammonia",          amount = 20 },
			{ type = "fluid", name = "angels-gas-oxygen",           amount = 30 },
			{ type = "item",  name = "angels-catalyst-metal-green", amount = 1 }
		},
		results = {
			{ type = "fluid", name = "gas-hydrogen-cyanide",          amount = 20 },
			{ type = "item",  name = "angels-catalyst-metal-carrier", amount = 1 }
		},
		icons = angelsmods.functions.create_gas_recipe_icon(
			{ { icon = "__PCPRedux__/graphics/icons/raw/hydrogen-cyanide.png", icon_size = 72 } }, "CNH"),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("gas-hydrogen-cyanide"),
		order = "l"
	},
	{ --
		type = "recipe",
		name = "liquid-plastic-pmma",
		category = "chemistry",
		subgroup = "angels-petrochem-solids",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "item", name = "solid-pmma", amount = 1 },
		},
		results =
		{
			{ type = "fluid", name = "angels-liquid-plastic", amount = 30 }, --10
		},
		order = "a[plastic]-a[liquid]-cz",
		icons = {
			{
				icon = "__PCPRedux__/graphics/icons/solid-polymethyl-methacrylate.png",
				icon_size = 32,
			},
			{
				icon = "__angelsrefininggraphics__/graphics/icons/num_3.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			}
		},
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-plastic"),
		icon_size = 32,
	},
	{ --
		type = "recipe",
		name = "catalyst-metal-cyan",
		category = "crafting",
		subgroup = "angels-petrochem-catalysts",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "item", name = "iron-plate",   amount = 1 },
			{ type = "item", name = "copper-plate", amount = 1 },
		},
		results =
		{
			{ type = "item", name = "catalyst-metal-cyan", amount = 10 },
		},
		icon = "__PCPRedux__/graphics/icons/catalyst-metal-cyan.png",
		icon_size = 32,
		order = "e[catalyst-metal-cyan]",
	},
	{ --
		type = "recipe",
		name = "liquid-fuel-oil-catalyst",
		category = "angels-advanced-chemistry",
		subgroup = "angels-petrochem-carbon-oil-feed",
		energy_required = 6,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "gas-nitrous-oxide",                      amount = 20 },
			{ type = "fluid", name = "angels-liquid-cupric-chloride-solution", amount = 30 },
			{ type = "fluid", name = "angels-gas-synthesis",                   amount = 90 },
			{ type = "item",  name = "angels-catalyst-metal-blue",             amount = 1 },
		},
		results =
		{
			{ type = "fluid", name = "angels-liquid-fuel-oil",        amount = 80 },
			{ type = "item",  name = "angels-catalyst-metal-carrier", amount = 1 },
		},
		icons = angelsmods.functions.create_liquid_recipe_icon({ "angels-liquid-fuel-oil" },
			{ { r = 233 / 255, g = 254 / 255, b = 127 / 255 }, { r = 233 / 255, g = 254 / 255, b = 127 / 255 }, { r = 255, g = 105, b = 180 } }),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-fuel-oil"),
		order = "f"
	},
	{
		type = "recipe",
		name = "gas-phosgene",
		category = "chemistry",
		subgroup = "angels-petrochem-chlorine-2",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "item",  name = "angels-solid-carbon",        amount = 1 },
			{ type = "fluid", name = "angels-gas-carbon-monoxide", amount = 60 },
			{ type = "fluid", name = "angels-gas-chlorine",        amount = 40 },
		},
		results = {
			{ type = "fluid", name = "gas-phosgene", amount = 100 },
		},
		always_show_products = true,
		icons = angelsmods.functions.create_gas_recipe_icon({
			{ "__angelspetrochemgraphics__/graphics/icons/molecules/phosgene.png", 72 },
		}, "CClC"),
		crafting_machine_tint = angelsmods.functions.get_recipe_tints({
			"gas-phosgene",
			"angels-gas-carbon-monoxide",
			"angels-gas-chlorine",
			angelsmods.functions.fluid_color("Cb"), --[[C]]
		}),
		order = "l",
	},
	{ --
		type = "recipe",
		name = "pc-synthesis",
		category = "chemistry",
		subgroup = "angels-petrochem-solids",
		energy_required = 1,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-bisphenol-a", amount = 10 },
			{ type = "fluid", name = "gas-phosgene",              amount = 10 },
		},
		results =
		{
			{ type = "item", name = "solid-pc", amount = 1 }
		},
		icon = "__PCPRedux__/graphics/icons/solid-polycarbonate.png",
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-plastic"),
		icon_size = 32,
		order = "j[pc-synthesis]",
	},
	{ --
		type = "recipe",
		name = "liquid-plastic-pc",
		category = "chemistry",
		subgroup = "angels-petrochem-solids",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "item", name = "solid-pc", amount = 1 },
		},
		results =
		{
			{ type = "fluid", name = "angels-liquid-plastic", amount = 20 }, --10
		},
		order = "a[plastic]-a[liquid]-az",
		icons = create_icon("angels-liquid-plastic", {
			icon = "__angelsrefininggraphics__/graphics/icons/num_1.png",
			icon_size = 32,
			tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
			scale = 0.32,
			shift = { -12, -12 },
		}),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-plastic"),
	},
	{ --
		type = "recipe",
		name = "liquid-plastic-abs",
		category = "angels-advanced-chemistry",
		subgroup = "angels-petrochem-solids",
		energy_required = 3,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-gas-butadiene",  amount = 20 },
			{ type = "fluid", name = "angels-liquid-styrene", amount = 50 },
			{ type = "fluid", name = "liquid-acrylonitrile",  amount = 30 }
		},
		results =
		{
			{ type = "fluid", name = "angels-liquid-plastic", amount = 100 }
		},
		icons = {
			{
				icon = "__PCPRedux__/graphics/icons/solid-acrylonitrile-butadiene-styrene.png",
				icon_size = 32,
			},
			{
				icon = "__angelsrefininggraphics__/graphics/icons/num_4.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			}
		},
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-plastic"),
		icon_size = 32,
		order = "a[plastic]-a[liquid]-da",
	},
})
if mods.bobplates or mods.apm_resource_pack_ldinc and (data.raw.item["angels-solid-rubber"] or data.raw.item["bob-rubber"]) then
	data:extend({
		{
			type = "recipe",
			name = "PF-resin",
			category = "chemistry",
			subgroup = "angels-petrochem-solids",
			energy_required = 3,
			enabled = false,
			ingredients = {
				{ type = "fluid", name = "angels-gas-formaldehyde", amount = 20 },
				{ type = "fluid", name = "angels-liquid-phenol",    amount = 20 },
			},
			results = { { type = "fluid", name = "angels-liquid-resin", amount = 40 } },
			icons = create_icon("angels-liquid-resin", {
				icon = "__angelsrefininggraphics__/graphics/icons/num_4.png",
				icon_size = 32,
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			}),
			order = "b[resin]-a[liquid]-d",
			crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-resin"),
		},
	})
end
