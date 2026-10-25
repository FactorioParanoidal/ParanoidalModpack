--automatically generated file | fMT-Export (c)YT v0.04-216Mrz03
--export-date: 2020-Feb-06

data:extend({

	--YI-Engines/Experiments
	{
		type = "item-group",
		name = "yi_engines",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/yi-engines-icon.png",
		inventory_order = "y",
		order = "yi-e1",
	},
	--YI-Agronomie
	{
		type = "item-group",
		name = "yie_harvest",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/yi_engines_harvest.png",
		inventory_order = "y",
		order = "yi-e2",
	},

	{ type = "item-subgroup", group = "yi_engines", order = "e", name = "yie-engines" }, --Engines
	{ type = "item-subgroup", group = "yi_engines", order = "y", name = "yie-exp" }, --temporary experimental stuff
	{ type = "item-subgroup", group = "yi_engines", order = "f", name = "yie-fluids" }, --all fluids (MF)
	{ type = "item-subgroup", group = "yi_engines", order = "a", name = "yie-parts" }, --building parts
	{ type = "item-subgroup", group = "yi_engines", order = "p", name = "yie-processed" }, --products
	{ type = "item-subgroup", group = "yi_engines", order = "q", name = "yie_engines_import_a" }, --import materials
	{ type = "item-subgroup", group = "yi_engines", order = "h", name = "yie_machinery" }, --machinery
	{ type = "item-subgroup", group = "yi_engines", order = "k", name = "yie_machinery2" }, --machinery2
	{ type = "item-subgroup", group = "yi_engines", order = "c", name = "yie_tubes" }, --vacumatic tubes & pipes
	{ type = "item-subgroup", group = "yuoki_liquids", order = "g", name = "yie_fluid_handle" }, --fluid handling
	{ type = "item-subgroup", group = "yie_harvest", order = "mc", name = "yie_agromachinery" }, --agriculture machinery
	{ type = "item-subgroup", group = "yie_harvest", order = "mb1", name = "yie_agroproducts" }, --agriculture products
	{ type = "item-subgroup", group = "yie_harvest", order = "mb3", name = "yie_agroproducts_crafted" }, --cooked, smoked, etc
	{ type = "item-subgroup", group = "yie_harvest", order = "mb2", name = "yie_agroproducts_packages" }, --empty packages
	{ type = "item-subgroup", group = "yie_harvest", order = "md", name = "yie_agro_package" }, --agriculture packages
	{ type = "item-subgroup", group = "yie_harvest", order = "me", name = "yie_agro_package_l2" }, --line 2 - fish
	{ type = "item-subgroup", group = "yie_harvest", order = "n", name = "yie_animals" }, --ranch stuff
	{ type = "item-subgroup", group = "yie_harvest", order = "dna", name = "yie_dnaline" }, --DNA-Line
	{ type = "item-subgroup", group = "yie_harvest", order = "m2", name = "yie_farming" }, --farming stuff
	{ type = "item-subgroup", group = "yie_harvest", order = "o", name = "yie_fish" }, --fish-stuff
	{ type = "item-subgroup", group = "yie_harvest", order = "m1", name = "yie_trades_import_line1" }, --trades-import
	{ type = "item-subgroup", group = "yie_harvest", order = "la", name = "yie_trades_line1" }, --trade stuff
	{ type = "item-subgroup", group = "yie_harvest", order = "lb", name = "yie_trades_line2" }, --trades-line 2

	{ type = "recipe-category", name = "yrcat-eg1" }, --c
	{ type = "recipe-category", name = "yrcat-eg2" }, --c
	{ type = "recipe-category", name = "yrcat-eg3" }, --c
	{ type = "recipe-category", name = "yrcat-eg4" }, --stirlings
	{ type = "recipe-category", name = "yrcat-farm" }, --farm itself
	{ type = "recipe-category", name = "yrcat-fish" }, --fishing things
	{ type = "recipe-category", name = "yrcat-heater" }, --overheater for steam
	{ type = "recipe-category", name = "yrcat-mf1a" }, --mechanical force primary - sfe
	{ type = "recipe-category", name = "yrcat-mf1b" }, --mechanical force primary - ffe
	{ type = "recipe-category", name = "yrcat-mf1c" }, --mechanical force primary - stirling
	{ type = "recipe-category", name = "yrcat-mf1gm" }, --mechanical force primary - gasmotor
	{ type = "recipe-category", name = "yrcat-mf1q" }, --mechanical force quantrinum-reactor
	{ type = "recipe-category", name = "yrcat-mf2" }, --gearbox
	{ type = "recipe-category", name = "yrcat-mf2b" }, --hp-gearbox
	{ type = "recipe-category", name = "yrcat-pump" }, --water-pump
	{ type = "recipe-category", name = "yrcat_dna" }, --DNA-Line
	{ type = "recipe-category", name = "yrcat_fluidhandle" }, --fluid handling
	{ type = "recipe-category", name = "yrcat_icemaker" }, --Ice-Maker
	{ type = "recipe-category", name = "yrcat_meat" }, --meat-category
	{ type = "recipe-category", name = "yrcat_mfheatmotor_m" }, --electrical mf heater/erzeuger
	{ type = "recipe-category", name = "yrcat_motor" }, --medium motor
	{ type = "recipe-category", name = "yrcat_pump_2" }, --Medium Pump
	{ type = "recipe-category", name = "yrcat_science" }, --Science-Way
	{ type = "recipe-category", name = "yrcat_smoker" }, --smoker
	{ type = "recipe-category", name = "yrcat_transform" }, --heat transformer
	{ type = "recipe-category", name = "yrcat_turbine" }, --steam to mechanical power

	--27.4.2022
	{ type = "recipe-category", name = "yrcat_rheinsberg" }, --für rheinsberg-reactor
})
