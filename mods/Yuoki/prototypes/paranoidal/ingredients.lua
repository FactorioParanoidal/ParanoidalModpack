-- Paranoidal fork: Yuoki continues the technology chain of the build (user decision 2026-10-24). Entry machines are
-- built only from the build's late products; Yuoki components additionally consume one late product each; machines
-- that used removed content get build replacements. Starting numbers, to be balanced later.
local P = require("prototypes.paranoidal.lib")

local R = {
	-- Yuoki fabricators (fabrication.lua) — C1 is the first Yuoki machine
	ye_fassembly1 = { { "bob-assembling-machine-4", 1 }, { "processing-unit", 10 }, { "bob-titanium-gear-wheel", 20 },
		{ "bob-titanium-bearing", 10 }, { "low-density-structure", 4 } },
	ye_fassembly2 = { { "ye_fassembly1", 1 }, { "bob-advanced-processing-unit", 10 }, { "y_structure_element", 20 },
		{ "y-basic-t1-mf", 4 }, { "bob-nitinol-gear-wheel", 10 } },
	ye_fassembly_sp = { { "ye_fassembly2", 1 }, { "bob-assembling-machine-5", 1 }, { "y-basic-t2-mf", 6 },
		{ "y-chip-2", 10 }, { "ye_science_blue", 5 } },

	-- material processing
	y_crusher2 = { { "bob-assembling-machine-4", 1 }, { "bob-titanium-gear-wheel", 20 }, { "bob-titanium-bearing", 10 },
		{ "processing-unit", 4 } },
	y_formpress2 = { { "bob-electric-furnace-2", 1 }, { "bob-titanium-plate", 10 }, { "bob-titanium-gear-wheel", 10 },
		{ "processing-unit", 4 } },
	["y-atomic-constructor"] = { { "bob-assembling-machine-4", 1 }, { "y_crusher2", 1 }, { "y_formpress2", 1 },
		{ "y-fuel-reactor", 3 }, { "bob-advanced-processing-unit", 10 }, { "y-basic-t1-mf", 4 } },
	["y-atomic-quantum-composer"] = { { "y_compensator_25", 2 }, { "y-basic-t2-mf", 3 }, { "y_structure_element", 8 },
		{ "bob-advanced-processing-unit", 10 }, { "y_rwtechsign", 3 } },
	["y-alien-infuser"] = { { "y-atomic-quantum-composer", 1 }, { "y-atomic-constructor", 1 }, { "y_formpress2", 1 },
		{ "y-fuel-reactor", 2 }, { "angels-plate-platinum", 20 }, { "y_rwtechsign", 5 } },
	["y-dirtwasher"] = { { "angels-washing-plant-3", 1 }, { "y_structure_element", 10 }, { "y-basic-t1-mf", 4 } },
	["y-underground-drill"] = { { "bob-mining-drill-3", 1 }, { "y_structure_vessel", 3 }, { "y-basic-t1-mf", 1 },
		{ "bob-titanium-bearing", 4 } },
	y_maintance_workshop = { { "bob-assembling-machine-4", 1 }, { "y_formpress2", 1 }, { "y-basic-t2-mf", 2 },
		{ "bob-repair-pack-4", 4 } },
	y_smelter = { { "bob-electric-furnace-2", 2 }, { "y-basic-t2-mf", 2 }, { "y_structure_vessel", 4 }, { "y-chip-2", 2 },
		{ "y_rwtechsign", 300 } },
	y_charger = { { "bob-heat-exchanger-3", 2 }, { "y-basic-t1-mf", 1 }, { "y-crystal2", 40 },
		{ "y_structure_vessel", 8 }, { "y_gauge", 8 } },
	y_moxmixer = { { "bob-assembling-machine-4", 1 }, { "bob-heat-exchanger-3", 2 }, { "y_structure_vessel", 4 },
		{ "y-basic-t2-mf", 2 } },

	-- crystallisation line (expensive by user decision 2026-10-24)
	y_mixer_emu = { { "angels-filtration-unit-3", 1 }, { "bob-storage-tank-3", 2 }, { "y-basic-t2-mf", 4 },
		{ "y_structure_vessel", 10 }, { "y-chip-2", 5 } },
	y_hppump = { { "bob-pump-3", 2 }, { "bob-mining-drill-3", 1 }, { "bob-tungsten-pipe", 10 }, { "y-basic-t2-mf", 4 },
		{ "y_structure_vessel", 10 } },
	y_trockner = { { "bob-electric-furnace-2", 1 }, { "angels-crystallizer-3", 1 }, { "y-basic-t2-mf", 4 },
		{ "y_structure_element", 10 }, { "y-chip-2", 5 } },
	y_crystalizer = { { "angels-crystallizer-3", 1 }, { "bob-heat-exchanger-3", 2 }, { "y-basic-t2-mf", 6 },
		{ "y_dotzetron", 10 }, { "y-chip-2", 4 } },

	-- energy (late Yuoki part)
	["y-obninsk-reactor"] = { { "nuclear-reactor", 1 }, { "y-basic-t2-mf", 13 }, { "y_structure_element", 82 },
		{ "y_structure_vessel", 34 }, { "bob-tungsten-pipe", 40 }, { "refined-concrete", 50 }, { "y-orange-stuff", 20 },
		{ "y_rwtechsign", 200 } },
	y_compensator_25 = { { "y-conductive-wire-1", 4 }, { "y-chip-2", 2 }, { "y_blocked_capa", 3 },
		{ "y_structure_electric", 2 }, { "y_rwtechsign", 2 } },
	["y-substation-h"] = { { "bob-substation-4", 1 }, { "y-conductive-wire-1", 8 }, { "y-chip-2", 4 },
		{ "y_quantrinum_infused", 1 }, { "y_rwtechsign", 3 } },
	yie_science_blue_gen = { { "bob-lab-2", 1 }, { "ye_fassembly1", 1 }, { "yie_hard_metals", 10 },
		{ "bob-advanced-processing-unit", 10 }, { "y_rwtechsign", 20 } },

	-- agronomy machines
	ye_farm = { { "angels-crop-farm", 1 }, { "refined-concrete", 20 }, { "y-iron-case", 4 }, { "y-chip-1", 4 } },
	ye_meatfarm = { { "refined-concrete", 20 }, { "steel-plate", 20 }, { "y-iron-case", 6 }, { "y-chip-1", 4 },
		{ "bob-pump-3", 1 } },
	ye_pool = { { "angels-bio-refugium-fish", 1 }, { "refined-concrete", 20 }, { "bob-pump-3", 2 }, { "y-chip-1", 4 } },
	ye_canmachine = { { "bob-assembling-machine-4", 1 }, { "y-iron-case", 4 }, { "bob-pump-3", 2 }, { "y-chip-1", 4 } },
	["y-electric-air-heater"] = { { "angels-air-filter-3", 2 }, { "y-heat-pipe", 4 }, { "y-basic-t1-mf", 2 },
		{ "copper-cable", 7 } },

	-- Yuoki components: one late product of the build each
	y_chip_plate = { { "y-refined-yres2", 1 }, { "y-richdust", 3 }, { "bob-fibreglass-board", 1 } },
	["y-chip-1"] = { { "y_chip_plate", 2 }, { "y-orange-stuff", 4 }, { "processing-unit", 1 } },
	["y-chip-2"] = { { "y_chip_plate", 2 }, { "y_dotzetron", 2 }, { "y-orange-stuff", 4 },
		{ "bob-advanced-processing-unit", 1 } },
	["y-conductive-wire-1"] = { { "y-orange-stuff", 1 }, { "bob-gilded-copper-cable", 2 } },
	["y-conductive-coil-1"] = { { "y-orange-stuff", 4 }, { "y-refined-yres2", 2 }, { "angels-wire-coil-insulated", 1 } },
	y_structure_element = { { "bob-titanium-plate", 2 }, { "y-unicomp-raw", 2 } },
	y_structure_vessel = { { "bob-nitinol-alloy", 1 }, { "steel-plate", 1 }, { "y-unicomp-raw", 1 } },
	["y-bluegear"] = { { "bob-titanium-gear-wheel", 1 }, { "y-refined-yres1", 1 } },
	["y-heat-pipe"] = { { "bob-heat-pipe-3", 1 }, { "copper-plate", 4 } },
	yi_magnetron = { { "y-pure-copper", 2 }, { "y-heat-pipe", 1 }, { "y-richdust", 3 }, { "angels-wire-coil-insulated", 1 } },
	["y-basic-t1-mf"] = { { "y-conductive-wire-1", 3 }, { "y-bluegear", 3 }, { "y_structure_element", 2 },
		{ "electric-engine-unit", 1 }, { "bob-titanium-bearing", 2 } },
	["y-basic-t2-mf"] = { { "y-conductive-coil-1", 2 }, { "y_structure_electric", 3 }, { "y-bluegear", 4 },
		{ "bob-cobalt-steel-bearing", 2 }, { "electric-engine-unit", 1 } },
	y_blocked_capa = { { "y-battery-single-use3", 3 }, { "y-pure-copper", 3 }, { "y-chip-1", 1 }, { "bob-battery-2", 1 } },
	y_dotzetron = { { "y-refined-yres2", 1 }, { "y-crush-yres1", 3 }, { "bob-silicon-wafer", 1 } },
	y_drillhead = { { "y_structure_element", 5 }, { "y_structure_vessel", 3 }, { "bob-copper-tungsten-alloy", 1 } },
	y_toolhead = { { "y_structure_element", 5 }, { "y_structure_vessel", 3 }, { "bob-copper-tungsten-alloy", 1 } },
	ye_center = { { "y-infused-uca2", 1 }, { "y-unicomp-raw", 10 }, { "yie_hard_metals", 16 },
		{ "angels-plate-platinum", 2 } },
	["y-fuel-reactor"] = { { "y-raw-fuelnium", 3 }, { "y-unicomp-raw", 3 }, { "bob-copper-tungsten-alloy", 1 } },
}

for name, ingredients in pairs(R) do
	P.ingredients(name, ingredients)
end

P.upsert_ingredient("y-obninsk-turbine", { "bob-steam-turbine-2", 2 })
P.upsert_ingredient("ye_sturbine", { "bob-steam-turbine-2", 2 })
P.upsert_ingredient("ye_overheater", { "bob-heat-exchanger-3", 1 })
P.upsert_ingredient("ye_trade_node", { "bob-advanced-processing-unit", 10 })
