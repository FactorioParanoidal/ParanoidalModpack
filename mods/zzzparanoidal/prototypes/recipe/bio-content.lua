data:extend({
	{
		type = "recipe-category",
		name = "biofarm-mod-farm-2",
	},
	{
		type = "recipe-category",
		name = "biofarm-mod-farm-3",
	},
	{
		type = "recipe-category",
		name = "biofarm-mod-greenhouse-2",
	},
	{
		type = "recipe-category",
		name = "biofarm-mod-greenhouse-3",
	},
	{
		type = "recipe-category",
		name = "biofarm-mod-bioreactor-2",
	},
	{
		type = "recipe-category",
		name = "biofarm-mod-bioreactor-3",
	},
})

data:extend({ -- Greenhouse
	{
		type = "recipe",
		name = "bi-bio-greenhouse-2",
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 10},
			{ type = "item", name = "concrete", amount = 10},
			{ type = "item", name = "deadlock-large-lamp", amount = 5},
			{
				"bi-bio-greenhouse",
				2,
			},
		},
		enabled = false,
		energy_required = 5,
		results = { { type = "item", name = "bi-bio-greenhouse-2", amount = 1 } },
		subgroup = "bio-bio-farm-fluid-entity",
		order = "aa[bi]",
	},
	{
		type = "recipe",
		name = "bi-bio-greenhouse-3",
		ingredients = {
			{ type = "item", name = "plastic-bar", amount = 10},
			{ type = "item", name = "refined-concrete", amount = 10},
			{ type = "item", name = "deadlock-large-lamp", amount = 5},
			{ type = "item", name = "bi-bio-greenhouse-2", amount = 2},
		},
		enabled = false,
		energy_required = 5,
		results = { { type = "item", name = "bi-bio-greenhouse-3", amount = 1 } },
		subgroup = "bio-bio-farm-fluid-entity",
		order = "aaa[bi]",
	}, -- BioFarm
	{
		type = "recipe",
		name = "bi-bio-farm-2",
		ingredients = {
			{ type = "item", name = "bi-bio-farm", amount = 2},
			{ type = "item", name = "bi-bio-greenhouse-2", amount = 4},
			{ type = "item", name = "concrete", amount = 40},
			{ type = "item", name = "wood", amount = 50},
			{ type = "item", name = "bob-steel-pipe", amount = 30},
		},
		enabled = false,
		energy_required = 5,
		results ={{type="item", name= "bi-bio-farm-2", amount=1}},
		subgroup = "bio-bio-farm-fluid-entity",
		order = "bb[bi]",
	},
	{
		type = "recipe",
		name = "bi-bio-farm-3",
		ingredients = {
			{ type = "item", name = "bi-bio-farm-2", amount = 2},
			{ type = "item", name = "bi-bio-greenhouse-3", amount = 4},
			{ type = "item", name = "refined-concrete", amount = 40},
			{ type = "item", name = "wood", amount = 100},
			{ type = "item", name = "bob-brass-pipe", amount = 30},
		},
		enabled = false,
		energy_required = 5,
		results ={{type="item", name= "bi-bio-farm-3", amount=1}},
		subgroup = "bio-bio-farm-fluid-entity",
		order = "bbb[bi]",
	}, -- BIOREACTOR
	{
		type = "recipe",
		name = "bi-bio-reactor-2",
		ingredients = { { type = "item", name = "bi-bio-reactor", amount = 2}, { type = "item", name = "bob-aluminium-plate", amount = 20}, { type = "item", name = "electronic-circuit", amount = 5} },
		enabled = false,
		energy_required = 5,
		results ={{type="item", name= "bi-bio-reactor-2", amount=1}},
		subgroup = "bio-bio-fuel-fluid",
		order = "aa",
	},
	{
		type = "recipe",
		name = "bi-bio-reactor-3",
		ingredients = { { type = "item", name = "bi-bio-reactor-2", amount = 2}, { type = "item", name = "plastic-bar", amount = 20}, { type = "item", name = "advanced-circuit", amount = 5} },
		enabled = false,
		energy_required = 5,
		results ={{type="item", name= "bi-bio-reactor-3", amount=1}},
		subgroup = "bio-bio-fuel-fluid",
		order = "aaa",
	},

	{
		type = "recipe",
		name = "bi-bio-garden",
		localised_name = { "entity-name.bi-bio-garden" },
		localised_description = { "entity-description.bi-bio-garden" },
		enabled = false,
		energy_required = 10,
		ingredients = {
			{type="item", name= "concrete", amount=50 },
			{type="item", name= "stone-crushed", amount=100 },
			{type="item", name= "seedling", amount=30 },
		},
		results = {{type="item", name = "bi-bio-garden", amount=1}},
		subgroup = "bio-bio-gardens-fluid",
		order = "a[bi]-1",
		allow_as_intermediate = true,
		always_show_made_in = false,
		allow_decomposition = true,
	},
	--###############################################################################################
	-- Large garden
	{
		type = "recipe",
		name = "bi-bio-garden-large",
		localised_name = { "entity-name.bi-bio-garden-large" },
		--localised_description = {"entity-description.bi-bio-garden-large"},
		enabled = false,
		energy_required = 25,
		ingredients = {
			{type="item", name= "bi-bio-garden", amount=10 },
			{type="item", name= "seedling", amount=100 },
			{type="item", name= "angels-reinforced-concrete-brick", amount=100 },
		},
		results = {{type="item", name = "bi-bio-garden-large", amount=1}},
		subgroup = "bio-bio-gardens-fluid",
		order = "a[bi]-2",
		allow_as_intermediate = true,
		always_show_made_in = false,
		allow_decomposition = true,
	},
	--###############################################################################################
	-- Huge garden
	{
		type = "recipe",
		name = "bi-bio-garden-huge",
		localised_name = { "entity-name.bi-bio-garden-huge" },
		--localised_description = {"entity-description.bi-bio-garden-huge"},
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type="item", name= "bi-bio-garden-large", amount=10 },
			{type="item", name= "iron-plate", amount=50 },
			{type="item", name= "angels-titanium-concrete-brick", amount=500 },
			{type="item", name= "seedling", amount=200 },
		},
		results = {{type="item", name = "bi-bio-garden-huge", amount=1}},
		subgroup = "bio-bio-gardens-fluid",
		order = "a[bi]-3",
		allow_as_intermediate = true,
		always_show_made_in = false,
		allow_decomposition = true,
	},
	--###############################################################################################
	-- Clean Air 1
	{
		type = "recipe",
		name = "bi-purified-air-1",
		icons = {
			{
				icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_recycle.png",
				icon_size = 64,
				icon_mipmaps = 4,
			},
			{
				icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_pollution_particle.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.3,
			},
			{
				icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fertilizer.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.25,
				shift = { -8, 8 },
			},
		},
		category = "clean-air",
		subgroup = "bio-bio-gardens-fluid",
		order = "bi-purified-air-1",
		enabled = false,
		hide_from_player_crafting = true,
		always_show_products = false,
		always_show_made_in = true,
		allow_decomposition = false,
		show_amount_in_title = false,
		emissions_multiplier = 0.5,
		energy_required = 40,
		ingredients = {
			{ type = "fluid", name = "water", amount = 50 },
			{ type = "item", name = "fertilizer", amount = 1 },
		},
		results = { { type = "item", name = "bi-purified-air", amount = 1, probability = 0 } },
		crafting_machine_tint = {
			primary = { r = 0.43, g = 0.73, b = 0.37, a = 0.60 },
			secondary = { r = 0, g = 0, b = 0, a = 0 },
			tertiary = { r = 0, g = 0, b = 0, a = 0 },
			quaternary = { r = 0, g = 0, b = 0, a = 0 },
		},
	},
	--###############################################################################################
	--- Clean Air 2
	{
		type = "recipe",
		name = "bi-purified-air-2",
		icons = {
			{
				icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_recycle.png",
				icon_size = 64,
				icon_mipmaps = 4,
			},
			{
				icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_pollution_particle.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.3,
			},
			{
				icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fertilizer_advanced.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.25,
				shift = { -8, 8 },
			},
		},
		category = "clean-air",
		subgroup = "bio-bio-gardens-fluid",
		order = "bi-purified-air-2",
		enabled = false,
		hide_from_player_crafting = true,
		always_show_products = false,
		always_show_made_in = true,
		allow_decomposition = false,
		show_amount_in_title = false,
		emissions_multiplier = 1.0,
		energy_required = 100,
		ingredients = {
			{ type = "fluid", name = "water", amount = 50 },
			{ type = "item", name = "bi-adv-fertilizer", amount = 1 },
		},
		results = { { type = "item", name = "bi-purified-air", amount = 1, probability = 0 } },
		crafting_machine_tint = {
			primary = { r = 0.73, g = 0.37, b = 0.52, a = 0.60 },
			secondary = { r = 0, g = 0, b = 0, a = 0 },
			tertiary = { r = 0, g = 0, b = 0, a = 0 },
			quaternary = { r = 0, g = 0, b = 0, a = 0 },
		},
	},
	--###############################################################################################
	-- Clean Air 0
	{
		type = "recipe",
		name = "bi-purified-air-0",
		icons = {
			{
				icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_recycle.png",
				icon_size = 64,
				icon_mipmaps = 4,
			},
			{
				icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_pollution_particle.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.3,
			},
		},
		category = "clean-air",
		subgroup = "bio-bio-gardens-fluid",
		order = "bi-purified-air-0",
		enabled = false,
		hide_from_player_crafting = true,
		always_show_products = false,
		always_show_made_in = true,
		allow_decomposition = false,
		show_amount_in_title = false,
		energy_required = 10,
		emissions_multiplier = 0.25,
		ingredients = {
			{ type = "fluid", name = "water", amount = 50 },
			--{type = "item", name = "fertilizer", amount = 1}
		},
		results = { { type = "item", name = "bi-purified-air", amount = 1, probability = 0 } },
		crafting_machine_tint = {
			primary = { r = 255, g = 255, b = 255, a = 0.60 },
			secondary = { r = 0, g = 0, b = 0, a = 0 },
			tertiary = { r = 0, g = 0, b = 0, a = 0 },
			quaternary = { r = 0, g = 0, b = 0, a = 0 },
		},
	},
})
