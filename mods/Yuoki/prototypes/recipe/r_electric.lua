data:extend({

	{
		type = "recipe",
		name = "y-conductive-coil-1",
		energy_required = 3.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-orange-stuff", amount = 4 },
			{ type = "item", name = "y-refined-yres2", amount = 2 },
		},
		results = {
			{ type = "item", name = "y-conductive-coil-1", amount = 3 },
		},
		main_product = "y-conductive-coil-1",
		order = "p-w-b",
		subgroup = "y_parts_e",
	},

	{
		type = "recipe",
		name = "y_dotzetron",
		energy_required = 4.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-refined-yres2", amount = 1 },
			{ type = "item", name = "y-crush-yres1", amount = 3 },
		},
		results = {
			{ type = "item", name = "y_dotzetron", amount = 3 },
		},
		main_product = "y_dotzetron",
		order = "p-c-6",
		subgroup = "y_parts_e",
	},

	{
		type = "recipe",
		name = "y_chip_plate",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-refined-yres2", amount = 1 },
			{ type = "item", name = "y-richdust", amount = 3 },
		},
		results = {
			{ type = "item", name = "y_chip_plate", amount = 1 },
		},
		main_product = "y_chip_plate",
		order = "p-c-0",
		subgroup = "y_parts_e",
	},

	{
		type = "recipe",
		name = "y-chip-1",
		energy_required = 3.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_chip_plate", amount = 2 },
			{ type = "item", name = "y-orange-stuff", amount = 4 },
		},
		results = {
			{ type = "item", name = "y-chip-1", amount = 2 },
		},
		main_product = "y-chip-1",
		order = "p-c-a",
		subgroup = "y_parts_e",
	},

	{
		type = "recipe",
		name = "y-chip-2",
		icon_size = 96,
		icon = "__Yuoki__/graphics/icons/chip2-icon.png",
		energy_required = 3,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_chip_plate", amount = 2 },
			{ type = "item", name = "y_dotzetron", amount = 2 },
			{ type = "item", name = "y-orange-stuff", amount = 4 },
		},
		results = {
			{ type = "item", name = "y-chip-2", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y-chip-2",
		order = "p-c-b",
		subgroup = "y_parts_e",
	},

	{
		type = "recipe",
		name = "yi_magnetron",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/magnetron_icon.png",
		energy_required = 1.5,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-pure-copper", amount = 2 },
			{ type = "item", name = "y-heat-pipe", amount = 1 },
			{ type = "item", name = "y-richdust", amount = 3 },
		},
		results = {
			{ type = "item", name = "yi_magnetron", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "yi_magnetron",
		order = "p-c-b",
		subgroup = "y_parts_e",
	},

	-- new battery-concept from 215-0101
	-- basic-cell + combine cells
	-- basic cell empty
	{
		type = "recipe",
		name = "y-battery-single-use1",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-crush-yres2", amount = 5 },
			{ type = "item", name = "y-coal-dust", amount = 2 },
			{ type = "item", name = "iron-plate", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-battery-single-use1", amount = 3 },
		},
		main_product = "y-battery-single-use1",
		order = "p-b-a",
	},

	-- loaded cell
	{
		type = "recipe",
		name = "y-battery-single-use2",
		energy_required = 4.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-battery-single-use1", amount = 4 },
		},
		results = {
			{ type = "item", name = "y-battery-single-use2", amount = 4 },
		},
		main_product = "y-battery-single-use2",
		order = "p-b-b",
	},

	-- block loaded cells
	{
		type = "recipe",
		name = "y-battery-single-use3",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/battery_3.png",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-battery-single-use2", amount = 3 },
			{ type = "item", name = "y-conductive-wire-1", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-battery-single-use3", amount = 1 },
		},
		main_product = "y-battery-single-use3",
		order = "p-b-c",
		subgroup = "y-electric",
	},

	--single-use-mod-batterys to standard-batterys
	{
		type = "recipe",
		name = "y-battery-rip1",
		energy_required = 2.0,
		enabled = true,
		auto_recycle = false,
		ingredients = {
			{ type = "item", name = "y-battery-single-use1", amount = 10 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		results = {
			{ type = "item", name = "battery", amount = 5 },
		},
		main_product = "battery",
	},

	-- blocked capaciter
	{
		type = "recipe",
		name = "y_blocked_capa",
		icon_size = 96,
		icon = "__Yuoki__/graphics/icons/scd-icon.png",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-battery-single-use3", amount = 3 },
			{ type = "item", name = "y-pure-copper", amount = 3 },
			{ type = "item", name = "y-chip-1", amount = 1 },
		},
		results = {
			{ type = "item", name = "y_blocked_capa", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y_blocked_capa",
		order = "p-b-d",
		subgroup = "y-electric",
	},

	{
		type = "recipe",
		name = "y-substation-m",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/substation-icon.png",
		energy_required = 3.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 8 },
			{ type = "item", name = "y-conductive-wire-1", amount = 6 },
			{ type = "item", name = "y-chip-1", amount = 1 },
			{ type = "item", name = "y_structure_electric", amount = 3 },
		},
		results = {
			{ type = "item", name = "y-substation-m", amount = 1 },
		},
		main_product = "y-substation-m",
		order = "e-e-a",
		subgroup = "y-electric",
	},

	{
		type = "recipe",
		name = "y-substation-h",
		energy_required = 3.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-substation-m", amount = 1 },
			{ type = "item", name = "y-conductive-wire-1", amount = 8 },
			{ type = "item", name = "y-chip-2", amount = 4 },
			{ type = "item", name = "y_quantrinum_infused", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 3 },
		},
		results = {
			{ type = "item", name = "y-substation-h", amount = 1 },
		},
		main_product = "y-substation-h",
		order = "e-e-b",
		subgroup = "y-electric",
	},

	-- Tier 1 - Accumulators
	{
		type = "recipe",
		name = "y-accumulator-m",
		energy_required = 6.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_blocked_capa", amount = 3 },
			{ type = "item", name = "y-conductive-coil-1", amount = 4 },
		},
		results = {
			{ type = "item", name = "y-accumulator-m", amount = 1 },
		},
		main_product = "y-accumulator-m",
		order = "ac-1",
		subgroup = "y-energy-2",
	},

	-- Big Advanced Accum
	{
		type = "recipe",
		name = "y-accumulator-b",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/accu_b_icon.png",
		energy_required = 8.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_blocked_capa", amount = 5 },
			{ type = "item", name = "y_structure_electric", amount = 3 },
			{ type = "item", name = "y-conductive-coil-1", amount = 4 },
			{ type = "item", name = "y-heat-pipe", amount = 8 },
		},
		results = {
			{ type = "item", name = "y-accumulator-b", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 3 },
		},
		main_product = "y-accumulator-b",
		order = "ac-3",
		subgroup = "y-energy-2",
	},

	-- Tier 2 - Accumulators
	-- Medium T2
	{
		type = "recipe",
		name = "y-accumulator-m-t2",
		energy_required = 6.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-accumulator-m", amount = 1 },
			{ type = "item", name = "y-chip-2", amount = 2 },
			{ type = "item", name = "y-crystal-cnd", amount = 2 },
			{ type = "item", name = "y_rwtechsign", amount = 2 },
		},
		results = {
			{ type = "item", name = "y-accumulator-m-t2", amount = 1 },
			{ type = "item", name = "y_greensign", amount = 1 },
		},
		main_product = "y-accumulator-m-t2",
		order = "ac-2",
		subgroup = "y-energy-2",
	},

	{
		type = "recipe",
		name = "y-accumulator-b-t2",
		energy_required = 8.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-accumulator-b", amount = 1 },
			{ type = "item", name = "y-chip-2", amount = 4 },
			{ type = "item", name = "y-crystal-cnd", amount = 3 },
			{ type = "item", name = "y_rwtechsign", amount = 5 },
		},
		results = {
			{ type = "item", name = "y-accumulator-b-t2", amount = 1 },
			{ type = "item", name = "y_greensign", amount = 3 },
		},
		main_product = "y-accumulator-b-t2",
		order = "ac-4",
		subgroup = "y-energy-2",
	},

	-- Tier 3 - Accumulators - AQE
	{
		type = "recipe",
		name = "y-accumulator-b-tx",
		category = "yuoki-wonder",
		energy_required = 12.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 8 },
			{ type = "item", name = "y-chip-2", amount = 4 },
			{ type = "item", name = "y-raw-fuelnium", amount = 10 },
			{ type = "item", name = "y-quantrinum", amount = 2 },
			{ type = "item", name = "y-infused-uca2", amount = 2 },
			{ type = "item", name = "y_rwtechsign", amount = 10 },
		},
		results = {
			{ type = "item", name = "y-accumulator-b-tx", amount = 1 },
			{ type = "item", name = "ye_science_blue", amount = 3 },
		},
		main_product = "y-accumulator-b-tx",
		order = "ac-5",
		subgroup = "y-energy-2",
	},

	-- Tier 4 - Accumulators - Crystal
	{
		type = "recipe",
		name = "y-accumulator-crystal-m",
		category = "yuoki-wonder",
		energy_required = 20.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 12 },
			{ type = "item", name = "y_quantrinum_infused", amount = 2 },
			{ type = "item", name = "y_crystal2_combined", amount = 20 },
			{ type = "item", name = "y_compensator_25", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 50 },
		},
		results = {
			{ type = "item", name = "y-accumulator-crystal-m", amount = 1 },
			{ type = "item", name = "ye_science_blue", amount = 5 },
		},
		main_product = "y-accumulator-crystal-m",
		order = "ac-6",
		subgroup = "y-energy-2",
	},

	-- Tier 1.5 - Accumulators
	{
		type = "recipe",
		name = "y-ups-flywheel-b",
		icon_size = 96,
		icon = "__Yuoki__/graphics/icons/accflywheel_icon.png",
		energy_required = 12.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_blocked_capa", amount = 4 },
			{ type = "item", name = "y-conductive-coil-1", amount = 4 },
			{ type = "item", name = "y-basic-t1-mf", amount = 2 },
			{ type = "item", name = "y-chip-1", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-ups-flywheel-b", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y-ups-flywheel-b",
		order = "ac-7",
		subgroup = "y-energy-2",
	},

	-- Compensator 2.5 MW
	{
		type = "recipe",
		name = "y_compensator_25",
		energy_required = 5.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-substation-m", amount = 1 },
			{ type = "item", name = "y-conductive-wire-1", amount = 4 },
			{ type = "item", name = "y-chip-2", amount = 2 },
			{ type = "item", name = "y_blocked_capa", amount = 2 },
			{ type = "item", name = "y_rwtechsign", amount = 2 },
		},
		results = {
			{ type = "item", name = "y_compensator_25", amount = 1 },
		},
		main_product = "y_compensator_25",
		order = "ac-8",
		subgroup = "y-energy-2",
	},
})
