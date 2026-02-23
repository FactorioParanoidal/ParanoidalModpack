-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.plates.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "plates",
	type = "technology",
	flat_icon = true,
}

---
---Gets the technology light layer for a file with the given `name` in the given `folder`.
---
---### Returns
---@return data.IconData[] # The light layer for the technology icon.
---
---### Parameters
---@param name string # The name of the technology. Matches a file under the given `folder` with the format `{name}-technology-lights.png`
---@param folder? string # The folder under `"__reskins-bobs__/graphics/technology/plates/"` to seach for the image file, defaults to `name`.
local function get_technology_light_layer(name, folder)
	folder = folder or name

	---@type data.IconData[]
	local light_layer = {
		{
			icon = "__reskins-bobs__/graphics/technology/plates/" .. folder .. "/" .. name .. "-technology-lights.png",
			icon_size = 256,
			tint = { 1, 1, 1, 0 },
		},
	}

	return light_layer
end

---@type CreateIconsFromListTable
local technologies = {
	-- Nuclear
	-- ["uranium-processing"] = {}, -- uranium proc, centri t3
	["bob-deuterium-fuel-reprocessing"] = { subgroup = "nuclear", image = "bob-deuterium-fuel-reprocessing-pink" },
	["bob-thorium-fuel-reprocessing"] = { subgroup = "nuclear" },
	["bob-thorium-processing"] = {
		subgroup = "nuclear",
		technology_icon_size = 256,
	},
	["bobingabout-enrichment-process"] = {
		subgroup = "nuclear",
		technology_icon_size = 256,
	},

	["bob-plutonium-fuel-cell"] = { subgroup = "nuclear" },
	["bob-thorium-plutonium-fuel-cell"] = { subgroup = "nuclear" },
	["bob-deuterium-fuel-cell-2"] = { subgroup = "nuclear" },

	-- Furnaces
	["bob-alloy-processing"] = { subgroup = "smelting" },
	["bob-chemical-processing-1"] = { subgroup = "smelting" },
	["advanced-material-processing"] = { subgroup = "smelting" },
	["bob-steel-mixing-furnace"] = { subgroup = "smelting" },
	["bob-fluid-mixing-furnace"] = { subgroup = "smelting" },
	["bob-steel-chemical-furnace"] = { subgroup = "smelting" },
	["bob-fluid-chemical-furnace"] = { subgroup = "smelting" },

	["advanced-material-processing-2"] = {
		technology_icon_size = 256,
		flat_icon = false,
		tint = util.color("#ffb700"),
		icon_name = "advanced-material-processing",
		technology_icon_extras = get_technology_light_layer("advanced-material-processing"),
	},
	["advanced-material-processing-3"] = {
		technology_icon_size = 256,
		flat_icon = false,
		tier = 4,
		icon_name = "advanced-material-processing",
		technology_icon_extras = get_technology_light_layer("advanced-material-processing"),
	},
	["advanced-material-processing-4"] = {
		technology_icon_size = 256,
		flat_icon = false,
		tier = 5,
		icon_name = "advanced-material-processing",
		technology_icon_extras = get_technology_light_layer("advanced-material-processing"),
	},

	["bob-electric-chemical-furnace"] = {
		technology_icon_size = 256,
		flat_icon = false,
		tint = util.color("#e50000"),
		icon_name = "electric-chemical-furnace",
		technology_icon_extras = get_technology_light_layer("electric-chemical-furnace"),
	},

	["bob-electric-mixing-furnace"] = {
		technology_icon_size = 256,
		flat_icon = false,
		tint = util.color("#00bfff"),
		icon_name = "electric-mixing-furnace",
		technology_icon_extras = get_technology_light_layer("electric-mixing-furnace"),
	},

	["bob-multi-purpose-furnace-1"] = {
		technology_icon_size = 256,
		flat_icon = false,
		tier = 4,
		icon_name = "multi-purpose-furnace",
		technology_icon_extras = get_technology_light_layer("multi-purpose-furnace"),
	},
	["bob-multi-purpose-furnace-2"] = {
		technology_icon_size = 256,
		flat_icon = false,
		tier = 5,
		icon_name = "multi-purpose-furnace",
		technology_icon_extras = get_technology_light_layer("multi-purpose-furnace"),
	},

	-- Barreling pumps
	["bob-water-bore-1"] = {
		flat_icon = false,
		tier = 1,
		prog_tier = 2,
		icon_name = "water-bore",
	},
	["bob-water-bore-2"] = {
		flat_icon = false,
		tier = 2,
		prog_tier = 3,
		icon_name = "water-bore",
	},
	["bob-water-bore-3"] = {
		flat_icon = false,
		tier = 3,
		prog_tier = 4,
		icon_name = "water-bore",
	},
	["bob-water-bore-4"] = {
		flat_icon = false,
		tier = 4,
		prog_tier = 5,
		icon_name = "water-bore",
	},

	-- Air compressors
	["bob-air-compressor-1"] = {
		flat_icon = false,
		tier = 1,
		prog_tier = 2,
		icon_name = "air-compressor",
	},
	["bob-air-compressor-2"] = {
		flat_icon = false,
		tier = 2,
		prog_tier = 3,
		icon_name = "air-compressor",
	},
	["bob-air-compressor-3"] = {
		flat_icon = false,
		tier = 3,
		prog_tier = 4,
		icon_name = "air-compressor",
	},
	["bob-air-compressor-4"] = {
		flat_icon = false,
		tier = 4,
		prog_tier = 5,
		icon_name = "air-compressor",
	},

	-- Assorted processes
	-- ["plastics"] = {}, -- Plastic, plastic pipes
	-- ["advanced-oil-processing"] = {}, -- oil recipes
	["bob-grinding"] = {
		subgroup = "processing-steps",
		technology_icon_size = 256,
	},

	["bob-polishing"] = {
		subgroup = "processing-steps",
		technology_icon_size = 256,
	},

	["bob-electrolysis-1"] = {
		subgroup = "processing-steps",
		image = "electrolysis",
		technology_icon_size = 256,
	},
	["bob-electrolysis-2"] = {
		subgroup = "processing-steps",
		image = "electrolysis",
		technology_icon_size = 256,
	},

	["bob-void-fluid"] = {
		subgroup = "processing-steps",
		technology_icon_size = 256,
	},

	-- raw gems
	["bob-gem-processing-1"] = {
		subgroup = "processing-steps",
		technology_icon_size = 256,
	},

	-- cut gems
	["bob-gem-processing-2"] = {
		subgroup = "processing-steps",
		technology_icon_size = 256,
	},

	-- polished gems
	["bob-gem-processing-3"] = {
		subgroup = "processing-steps",
		technology_icon_size = 256,
	},

	-- Plate processing
	-- alumina, aluminium plate
	["bob-aluminium-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- gold plate
	["bob-gold-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- zinc plate, brass, gunmetal, brass gear, brass pipes, brass chest
	["bob-zinc-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- nickel plate
	["bob-nickel-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- vanilla fine as is
	["steel-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- silicon boule, wager, powder
	["bob-silicon-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- invar plate
	["bob-invar-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- lead plate, lead oxide
	["bob-lead-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- cobalt oxide, cobalt plate, copper plate from cobalt, cobalt steel plate, gear, bearing, ball bearing
	["bob-cobalt-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- copper-tungsten, tungsten carbide, c-tun-pipes
	["bob-tungsten-alloy-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- nitinol plate, gear, bearing, ball,. pipes
	["bob-nitinol-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- titanium plate, gear, ball, bearing, pipes, chest
	["bob-titanium-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- tungsten plate, gear, pipe, acid, oxide, powdered
	["bob-tungsten-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	["bob-alloy-processing"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- silicon nitride, ceramic bearing, ball bearing, pipes
	["bob-ceramics"] = {
		subgroup = "plates",
		technology_icon_size = 256,
	},

	-- Chemicals and fluids processing

	-- hydro chloride, calcium, ferric chloride, limestone, carbon dioxide,
	["bob-chemical-processing-2"] = {
		subgroup = "chemical-processing",
		technology_icon_size = 256,
	},

	-- lithium, lithium chloride, perchlorate, sodium chlorate, perchlorate, (Bob's revamp does something to this?)
	["bob-lithium-processing"] = {
		subgroup = "chemical-processing",
		technology_icon_size = 256,
	},

	-- gas cans
	["bob-gas-canisters"] = {
		subgroup = "chemical-processing",
		technology_icon_size = 256,
	},

	-- fluids: nitrogen, nitrogen-dioxide, nitric acid, ammonia, nitric oxide, hydrogen peroxide
	-- ["nitrogen-processing"] = {}, -- Molecule.

	-- heavy water
	-- ["heavy-water-processing"] = {}, -- Molecule.

	-- heavy water electrolysis
	-- ["deuterium-processing"] = {}, -- Molecule.

	-- sulfur, sulfuric acid, sulfur-dioxide, hydrogen-sulfide, hydrogen-peroxide, petroleum-gas
	-- ["sulfur-processing"] = {}, -- Leave as is.

	-- glycerol, nitroglycerin, sulfuric and nitric acid
	-- ["nitroglycerin-processing"] = {}, -- Part of warfare.

	-- Alien plates
	["bob-alien-blue-research"] = {
		subgroup = "alien",
		technology_icon_size = 256,
	},
	["bob-alien-orange-research"] = {
		subgroup = "alien",
		technology_icon_size = 256,
	},
	["bob-alien-purple-research"] = {
		subgroup = "alien",
		technology_icon_size = 256,
	},
	["bob-alien-yellow-research"] = {
		subgroup = "alien",
		technology_icon_size = 256,
	},
	["bob-alien-green-research"] = {
		subgroup = "alien",
		technology_icon_size = 256,
	},
	["bob-alien-red-research"] = {
		subgroup = "alien",
		technology_icon_size = 256,
	},

	-- Fluid Handling
	["fluid-handling"] = {
		flat_icon = false,
		tier = 1,
		prog_tier = 2,
		icon_name = "fluid-handling",
		technology_icon_size = 256,
	},
	["bob-fluid-handling-2"] = {
		flat_icon = false,
		tier = 2,
		prog_tier = 3,
		icon_name = "fluid-handling",
		technology_icon_size = 256,
	},
	["bob-fluid-handling-3"] = {
		flat_icon = false,
		tier = 3,
		prog_tier = 4,
		icon_name = "fluid-handling",
		technology_icon_size = 256,
	},
	["bob-fluid-handling-4"] = {
		flat_icon = false,
		tier = 4,
		prog_tier = 5,
		icon_name = "fluid-handling",
		technology_icon_size = 256,
	},
}

-- Prefer the technology icon added for bobselectronics
if not mods["bobelectronics"] then
	technologies["bob-advanced-processing-unit"] = {
		subgroup = "processing-steps",
		technology_icon_size = 256,
	}
end

-- Handle nuclear update
if reskins.lib.settings.get_value("bobmods-plates-nuclearupdate") == true then
	technologies["nuclear-fuel-reprocessing"] = {
		subgroup = "nuclear",
		defer_to_data_updates = true,
	}

	-- Handle deuterium's default process color
	if reskins.lib.settings.get_value("bobmods-plates-bluedeuterium") == true then
		technologies["bob-deuterium-fuel-reprocessing"].image = "bob-deuterium-fuel-reprocessing-blue"
	end
else
	technologies["bob-thorium-fuel-reprocessing"].image = "bob-thorium-fuel-reprocessing-alternate"

	-- Handle deuterium's alternate process color
	if reskins.lib.settings.get_value("bobmods-plates-bluedeuterium") == true then
		technologies["bob-deuterium-fuel-reprocessing"].image = "bob-deuterium-fuel-reprocessing-alternate-blue"
	else
		technologies["bob-deuterium-fuel-reprocessing"].image = "bob-deuterium-fuel-reprocessing-alternate-pink"
	end
end

-- Angel's Compatibility
if mods["angelssmelting"] then
	-- Use metal-mixing sprites to be consistent with new "Filtering Furnace" progression
	technologies["bob-multi-purpose-furnace-1"].icon_name = "electric-mixing-furnace"
	technologies["bob-multi-purpose-furnace-1"].technology_icon_extras = get_technology_light_layer("electric-mixing-furnace")

	technologies["bob-multi-purpose-furnace-2"].icon_name = "electric-mixing-furnace"
	technologies["bob-multi-purpose-furnace-2"].technology_icon_extras = get_technology_light_layer("electric-mixing-furnace")
end

reskins.internal.create_icons_from_list(technologies, inputs)
