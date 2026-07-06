-- third-party/config

-- Configuration overrides for supporting various third-party mods

-- Function to remove items from config
local function removeIndexByName(tbl, name)
	local index = nil
	for i, v in ipairs(tbl) do
		if (v.name == name) then
			index = i
		end
	end
	if index == nil then
		log("Index not found for item named '" .. name .. "'")
	else
		log("Removing item named '" .. name .. "' at index " .. index)
		table.remove(tbl, index)
	end
end

-- ALIEN BIOMES
-- ---------------------------------
if mods["alien-biomes"] then
	-- Only supports blue water tiles
	DECT.CONFIG.WATERFILL_TILES = {
		["all"] = {"water", "deepwater"},
		["shallow"] = {"water"},
		["deep"] = {"deepwater"}
	}
	DECT.CONFIG.BASE_TILES = {}
	DECT.CONFIG.BASE_WATER_TILES = DECT.CONFIG.WATERFILL_TILES[DECT.CONFIG.SETTINGS["waterfill_tiles"]]
	DECT.CONFIG.BASE_ROCKS = {}
	DECT.CONFIG.BASE_TREES = {}
end

-- ARBORIUM and ARBORIUM RENEWED
-- ---------------------------------
if mods["Arborium"] or mods["Arborium_Renewed"] then
	-- Disable tree crafting (as Arborium handles this)
	DECT.CONFIG.BASE_TREES = {}
end

-- KS POWER
-- ---------------------------------
if mods["KS_Power"] then
	-- Add signal support for Diesel fuel fluid
	table.insert(
		DECT.CONFIG.SIGNALS,
		{type = "fluid", name = "diesel-fuel", color = {r = 0.70, g = 0.70, b = 0.00, a = 0.68}}
	)
end

-- ANGEL'S REFINING
-- ---------------------------------
if mods["angelsrefining"] then
	-- Add signal support for Angel's ores
	local angelsrefining_items = {
		-- Saphirite
		{type = "item", name = "angels-ore1", color = {r = 0.21, g = 0.37, b = 0.53, a = 0.86}},
		{type = "item", name = "angels-ore1-crushed", color = {r = 0.21, g = 0.37, b = 0.53, a = 0.86}},
		{type = "item", name = "angels-ore1-chunk", color = {r = 0.21, g = 0.37, b = 0.53, a = 0.86}},
		{type = "item", name = "angels-ore1-crystal", color = {r = 0.21, g = 0.37, b = 0.53, a = 0.86}},
		{type = "item", name = "angels-ore1-pure", color = {r = 0.21, g = 0.37, b = 0.53, a = 0.86}},
		-- Jivolite
		{type = "item", name = "angels-ore2", color = {r = 0.71, g = 0.66, b = 0.22, a = 0.86}},
		{type = "item", name = "angels-ore2-crushed", color = {r = 0.71, g = 0.66, b = 0.22, a = 0.86}},
		{type = "item", name = "angels-ore2-chunk", color = {r = 0.71, g = 0.66, b = 0.22, a = 0.86}},
		{type = "item", name = "angels-ore2-crystal", color = {r = 0.71, g = 0.66, b = 0.22, a = 0.86}},
		{type = "item", name = "angels-ore2-pure", color = {r = 0.71, g = 0.66, b = 0.22, a = 0.86}},
		-- Stiratite
		{type = "item", name = "angels-ore3", color = {r = 0.41, g = 0.58, b = 0.70, a = 0.86}},
		{type = "item", name = "angels-ore3-crushed", color = {r = 0.41, g = 0.58, b = 0.70, a = 0.86}},
		{type = "item", name = "angels-ore3-chunk", color = {r = 0.41, g = 0.58, b = 0.70, a = 0.86}},
		{type = "item", name = "angels-ore3-crystal", color = {r = 0.41, g = 0.58, b = 0.70, a = 0.86}},
		{type = "item", name = "angels-ore3-pure", color = {r = 0.41, g = 0.58, b = 0.70, a = 0.86}},
		-- Crotinnium
		{type = "item", name = "angels-ore4", color = {r = 0.75, g = 0.75, b = 0.75, a = 0.86}},
		{type = "item", name = "angels-ore4-crushed", color = {r = 0.75, g = 0.75, b = 0.75, a = 0.86}},
		{type = "item", name = "angels-ore4-chunk", color = {r = 0.75, g = 0.75, b = 0.75, a = 0.86}},
		{type = "item", name = "angels-ore4-crystal", color = {r = 0.75, g = 0.75, b = 0.75, a = 0.86}},
		{type = "item", name = "angels-ore4-pure", color = {r = 0.75, g = 0.75, b = 0.75, a = 0.86}},
		-- Rubyte
		{type = "item", name = "angels-ore5", color = {r = 0.68, g = 0.18, b = 0.16, a = 0.86}},
		{type = "item", name = "angels-ore5-crushed", color = {r = 0.68, g = 0.18, b = 0.16, a = 0.86}},
		{type = "item", name = "angels-ore5-chunk", color = {r = 0.68, g = 0.18, b = 0.16, a = 0.86}},
		{type = "item", name = "angels-ore5-crystal", color = {r = 0.68, g = 0.18, b = 0.16, a = 0.86}},
		{type = "item", name = "angels-ore5-pure", color = {r = 0.68, g = 0.18, b = 0.16, a = 0.86}},
		-- Bobmonium
		{type = "item", name = "angels-ore6", color = {r = 0.53, g = 0.37, b = 0.17, a = 0.86}},
		{type = "item", name = "angels-ore6-crushed", color = {r = 0.53, g = 0.37, b = 0.17, a = 0.86}},
		{type = "item", name = "angels-ore6-chunk", color = {r = 0.53, g = 0.37, b = 0.17, a = 0.86}},
		{type = "item", name = "angels-ore6-crystal", color = {r = 0.53, g = 0.37, b = 0.17, a = 0.86}},
		{type = "item", name = "angels-ore6-pure", color = {r = 0.53, g = 0.37, b = 0.17, a = 0.86}},
		-- Ferrous
		{type = "item", name = "angels-ore8-crushed", color = {r = 0.51, g = 0.74, b = 0.21, a = 0.86}},
		{type = "item", name = "angels-ore8-powder", color = {r = 0.51, g = 0.74, b = 0.21, a = 0.86}},
		{type = "item", name = "angels-ore8-dust", color = {r = 0.51, g = 0.74, b = 0.21, a = 0.86}},
		{type = "item", name = "angels-ore8-crystal", color = {r = 0.51, g = 0.74, b = 0.21, a = 0.86}},
		-- Cupric
		{type = "item", name = "angels-ore9-crushed", color = {r = 0.93, g = 0.43, b = 0.01, a = 0.86}},
		{type = "item", name = "angels-ore9-powder", color = {r = 0.93, g = 0.43, b = 0.01, a = 0.86}},
		{type = "item", name = "angels-ore9-dust", color = {r = 0.93, g = 0.43, b = 0.01, a = 0.86}},
		{type = "item", name = "angels-ore9-crystal", color = {r = 0.93, g = 0.43, b = 0.01, a = 0.86}},
		-- Stone & Slag
		{type = "item", name = "stone-crushed", color = {r = 0.61, g = 0.61, b = 0.61, a = 0.86}},
		{type = "item", name = "slag", color = {r = 0.39, g = 0.33, b = 0.34, a = 0.86}},
		-- Catalyst
		{type = "item", name = "catalysator-brown", color = {r = 0.43, g = 0.27, b = 0.00, a = 0.92}},
		{type = "item", name = "catalysator-green", color = {r = 0.39, g = 0.52, b = 0.04, a = 0.92}},
		{type = "item", name = "catalysator-orange", color = {r = 0.92, g = 0.42, b = 0.08, a = 0.92}},
		-- Geodes
		{type = "item", name = "crystal-dust", color = {r = 0.32, g = 0.65, b = 0.38, a = 0.86}},
		{type = "item", name = "geode-blue", color = {r = 0.17, g = 0.55, b = 0.86, a = 0.86}},
		{type = "item", name = "geode-cyan", color = {r = 0.14, g = 0.86, b = 0.72, a = 0.86}},
		{type = "item", name = "geode-lightgreen", color = {r = 0.63, g = 0.83, b = 0.17, a = 0.86}},
		{type = "item", name = "geode-purple", color = {r = 0.87, g = 0.14, b = 0.80, a = 0.86}},
		{type = "item", name = "geode-red", color = {r = 0.67, g = 0.22, b = 0.16, a = 0.86}},
		{type = "item", name = "geode-yellow", color = {r = 0.81, g = 0.57, b = 0.10, a = 0.86}}
	}
	for _, item in pairs(angelsrefining_items) do
		table.insert(DECT.CONFIG.SIGNALS, item)
	end
end

-- ANGEL'S SMELTING
-- ---------------------------------
if mods["angelssmelting"] then
	-- Add signal support for Angel's ingots, coils, plates, etc.
	local angelssmelting_items = {
		-- Steel
		{type = "item", name = "ingot-steel", color = {r = 0.83, g = 0.86, b = 0.89, a = 0.92}},
		{type = "item", name = "powder-steel", color = {r = 0.83, g = 0.86, b = 0.89, a = 0.92}},
		{type = "item", name = "angels-plate-steel", color = {r = 0.83, g = 0.86, b = 0.89, a = 0.92}},
		{type = "item", name = "angels-roll-steel", color = {r = 0.83, g = 0.86, b = 0.89, a = 0.92}},
		{type = "item", name = "angels-rod-steel", color = {r = 0.83, g = 0.86, b = 0.89, a = 0.92}},
		{type = "item", name = "angels-rod-rack-steel", color = {r = 0.83, g = 0.86, b = 0.89, a = 0.92}},
		{type = "fluid", name = "liquid-molten-steel", color = {r = 0.83, g = 0.86, b = 0.89, a = 0.68}},
		-- Solder
		{type = "item", name = "angels-solder", color = {r = 0.33, g = 0.39, b = 0.39, a = 0.92}},
		{type = "item", name = "angels-roll-solder", color = {r = 0.33, g = 0.39, b = 0.39, a = 0.92}},
		{type = "fluid", name = "liquid-molten-solder", color = {r = 0.33, g = 0.39, b = 0.39, a = 0.68}},
		-- Aluminium
		{type = "item", name = "bauxite-ore", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.92}},
		{type = "item", name = "processed-aluminium", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.92}},
		{type = "item", name = "pellet-aluminium", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.92}},
		{type = "item", name = "solid-sodium-aluminate", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.92}},
		{type = "item", name = "solid-aluminium-hydroxide", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.92}},
		{type = "item", name = "solid-aluminium-oxide", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.92}},
		{type = "item", name = "ingot-aluminium", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.92}},
		{type = "item", name = "powder-aluminium", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.92}},
		{type = "item", name = "angels-plate-aluminium", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.92}},
		{type = "item", name = "angels-roll-aluminium", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.92}},
		{type = "fluid", name = "liquid-molten-aluminium", color = {r = 0.65, g = 0.61, b = 0.32, a = 0.68}},
		-- Nickel
		{type = "item", name = "nickel-ore", color = {r = 0.22, g = 0.47, b = 0.44, a = 0.92}},
		{type = "item", name = "processed-nickel", color = {r = 0.22, g = 0.47, b = 0.44, a = 0.92}},
		{type = "item", name = "pellet-nickel", color = {r = 0.22, g = 0.47, b = 0.44, a = 0.92}},
		{type = "item", name = "cathode-nickel", color = {r = 0.22, g = 0.47, b = 0.44, a = 0.92}},
		{type = "item", name = "solid-nickel-carbonyl", color = {r = 0.22, g = 0.47, b = 0.44, a = 0.92}},
		{type = "item", name = "ingot-nickel", color = {r = 0.22, g = 0.47, b = 0.44, a = 0.92}},
		{type = "item", name = "powder-nickel", color = {r = 0.22, g = 0.47, b = 0.44, a = 0.92}},
		{type = "item", name = "angels-plate-nickel", color = {r = 0.22, g = 0.47, b = 0.44, a = 0.92}},
		{type = "item", name = "angels-roll-nickel", color = {r = 0.22, g = 0.47, b = 0.44, a = 0.92}},
		{type = "fluid", name = "liquid-molten-nickel", color = {r = 0.22, g = 0.47, b = 0.44, a = 0.68}},
		-- Chrome
		{type = "item", name = "chrome-ore", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.92}},
		{type = "item", name = "processed-chrome", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.92}},
		{type = "item", name = "pellet-chrome", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.92}},
		{type = "item", name = "solid-chromate", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.92}},
		{type = "item", name = "solid-dichromate", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.92}},
		{type = "item", name = "solid-chrome-oxide", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.92}},
		{type = "item", name = "ingot-chrome", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.92}},
		{type = "item", name = "angels-plate-chrome", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.92}},
		{type = "item", name = "powder-chrome", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.92}},
		{type = "item", name = "angels-roll-chrome", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.92}},
		{type = "fluid", name = "liquid-molten-chrome", color = {r = 0.61, g = 0.57, b = 0.76, a = 0.68}},
		-- Cobalt
		{type = "item", name = "cobalt-ore", color = {r = 0.20, g = 0.28, b = 0.38, a = 0.92}},
		{type = "item", name = "processed-cobalt", color = {r = 0.20, g = 0.28, b = 0.38, a = 0.92}},
		{type = "item", name = "pellet-cobalt", color = {r = 0.20, g = 0.28, b = 0.38, a = 0.92}},
		{type = "item", name = "solid-cobalt-hydroxide", color = {r = 0.20, g = 0.28, b = 0.38, a = 0.92}},
		{type = "item", name = "solid-cobalt-oxide", color = {r = 0.20, g = 0.28, b = 0.38, a = 0.92}},
		{type = "item", name = "ingot-cobalt", color = {r = 0.20, g = 0.28, b = 0.38, a = 0.92}},
		{type = "item", name = "powder-cobalt", color = {r = 0.20, g = 0.28, b = 0.38, a = 0.92}},
		{type = "item", name = "angels-plate-cobalt", color = {r = 0.20, g = 0.28, b = 0.38, a = 0.92}},
		{type = "item", name = "angels-roll-cobalt", color = {r = 0.20, g = 0.28, b = 0.38, a = 0.92}},
		{type = "fluid", name = "liquid-molten-cobalt", color = {r = 0.20, g = 0.28, b = 0.38, a = 0.68}},
		-- Manganese
		{type = "item", name = "manganese-ore", color = {r = 0.79, g = 0.32, b = 0.33, a = 0.92}},
		{type = "item", name = "processed-manganese", color = {r = 0.79, g = 0.32, b = 0.33, a = 0.92}},
		{type = "item", name = "pellet-manganese", color = {r = 0.79, g = 0.32, b = 0.33, a = 0.92}},
		{type = "item", name = "solid-manganese-oxide", color = {r = 0.79, g = 0.32, b = 0.33, a = 0.92}},
		{type = "item", name = "cathode-manganese", color = {r = 0.79, g = 0.32, b = 0.33, a = 0.92}},
		{type = "item", name = "ingot-manganese", color = {r = 0.79, g = 0.32, b = 0.33, a = 0.92}},
		{type = "item", name = "angels-plate-manganese", color = {r = 0.79, g = 0.32, b = 0.33, a = 0.92}},
		{type = "item", name = "angels-roll-manganese", color = {r = 0.79, g = 0.32, b = 0.33, a = 0.92}},
		{type = "fluid", name = "liquid-molten-manganese", color = {r = 0.79, g = 0.32, b = 0.33, a = 0.68}},
		-- Lead
		{type = "item", name = "lead-ore", color = {r = 0.28, g = 0.28, b = 0.32, a = 0.92}},
		{type = "item", name = "processed-lead", color = {r = 0.28, g = 0.28, b = 0.32, a = 0.92}},
		{type = "item", name = "pellet-lead", color = {r = 0.28, g = 0.28, b = 0.32, a = 0.92}},
		{type = "item", name = "solid-lead-oxide", color = {r = 0.28, g = 0.28, b = 0.32, a = 0.92}},
		{type = "item", name = "anode-lead", color = {r = 0.28, g = 0.28, b = 0.32, a = 0.92}},
		{type = "item", name = "ingot-lead", color = {r = 0.28, g = 0.28, b = 0.32, a = 0.92}},
		{type = "item", name = "angels-plate-lead", color = {r = 0.28, g = 0.28, b = 0.32, a = 0.92}},
		{type = "fluid", name = "liquid-molten-lead", color = {r = 0.28, g = 0.28, b = 0.32, a = 0.68}},
		{type = "fluid", name = "liquid-hexafluorosilicic-acid", color = {r = 0.79, g = 0.90, b = 0.24, a = 0.68}},
		-- Iron
		{type = "item", name = "processed-iron", color = {r = 0.64, g = 0.69, b = 0.74, a = 0.92}},
		{type = "item", name = "pellet-iron", color = {r = 0.64, g = 0.69, b = 0.74, a = 0.92}},
		{type = "item", name = "solid-iron-hydroxide", color = {r = 0.64, g = 0.69, b = 0.74, a = 0.92}},
		{type = "item", name = "ingot-iron", color = {r = 0.64, g = 0.69, b = 0.74, a = 0.92}},
		{type = "item", name = "powder-iron", color = {r = 0.64, g = 0.69, b = 0.74, a = 0.92}},
		{type = "item", name = "angels-plate-iron", color = {r = 0.64, g = 0.69, b = 0.74, a = 0.92}},
		{type = "item", name = "angels-roll-iron", color = {r = 0.64, g = 0.69, b = 0.74, a = 0.92}},
		{type = "item", name = "angels-rod-iron", color = {r = 0.64, g = 0.69, b = 0.74, a = 0.92}},
		{type = "item", name = "angels-rod-stack-iron", color = {r = 0.64, g = 0.69, b = 0.74, a = 0.92}},
		{type = "fluid", name = "liquid-molten-iron", color = {r = 0.64, g = 0.69, b = 0.74, a = 0.68}},
		-- Gold
		{type = "item", name = "gold-ore", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.92}},
		{type = "item", name = "processed-gold", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.92}},
		{type = "item", name = "pellet-gold", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.92}},
		{type = "item", name = "cathode-gold", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.92}},
		{type = "item", name = "solid-sodium-gold-cyanide", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.92}},
		{type = "item", name = "ingot-gold", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.92}},
		{type = "item", name = "angels-plate-gold", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.92}},
		{type = "item", name = "angels-roll-gold", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.92}},
		{type = "item", name = "angels-wire-coil-gold", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.92}},
		{type = "item", name = "angels-wire-gold", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.92}},
		{type = "fluid", name = "liquid-molten-gold", color = {r = 0.88, g = 0.71, b = 0.10, a = 0.68}},
		{type = "fluid", name = "liquid-chlorauric-acid", color = {r = 0.58, g = 0.61, b = 0.09, a = 0.68}},
		-- Glass
		{type = "item", name = "solid-glass-mixture", color = {r = 0.44, g = 0.40, b = 0.40, a = 0.92}},
		{type = "item", name = "angels-plate-glass", color = {r = 0.44, g = 0.40, b = 0.40, a = 0.92}},
		{type = "item", name = "angels-coil-glass-fiber", color = {r = 0.44, g = 0.40, b = 0.40, a = 0.92}},
		{type = "fluid", name = "liquid-molten-glass", color = {r = 0.44, g = 0.40, b = 0.40, a = 0.92}},
		-- Copper
		{type = "item", name = "processed-copper", color = {r = 0.57, g = 0.37, b = 0.32, a = 0.92}},
		{type = "item", name = "pellet-copper", color = {r = 0.57, g = 0.37, b = 0.32, a = 0.92}},
		{type = "item", name = "anode-copper", color = {r = 0.57, g = 0.37, b = 0.32, a = 0.92}},
		{type = "item", name = "ingot-copper", color = {r = 0.57, g = 0.37, b = 0.32, a = 0.92}},
		{type = "item", name = "powder-copper", color = {r = 0.57, g = 0.37, b = 0.32, a = 0.92}},
		{type = "item", name = "angels-plate-copper", color = {r = 0.57, g = 0.37, b = 0.32, a = 0.92}},
		{type = "item", name = "angels-roll-copper", color = {r = 0.57, g = 0.37, b = 0.32, a = 0.92}},
		{type = "item", name = "angels-wire-coil-copper", color = {r = 0.57, g = 0.37, b = 0.32, a = 0.92}},
		{type = "item", name = "angels-wire-copper", color = {r = 0.57, g = 0.37, b = 0.32, a = 0.92}},
		{type = "fluid", name = "liquid-molten-copper", color = {r = 0.57, g = 0.37, b = 0.32, a = 0.68}},
		-- Silicon
		{type = "item", name = "quartz", color = {r = 0.83, g = 0.83, b = 0.83, a = 0.92}},
		{type = "item", name = "processed-silica", color = {r = 0.83, g = 0.83, b = 0.83, a = 0.92}},
		{type = "item", name = "pellet-silica", color = {r = 0.83, g = 0.83, b = 0.83, a = 0.92}},
		{type = "item", name = "ingot-silicon", color = {r = 0.83, g = 0.83, b = 0.83, a = 0.92}},
		{type = "item", name = "angels-mono-silicon-seed", color = {r = 0.83, g = 0.83, b = 0.83, a = 0.92}},
		{type = "item", name = "angels-mono-silicon", color = {r = 0.83, g = 0.83, b = 0.83, a = 0.92}},
		{type = "item", name = "angels-quartz-crucible", color = {r = 0.83, g = 0.83, b = 0.83, a = 0.68}},
		{type = "fluid", name = "liquid-molten-silicon", color = {r = 0.83, g = 0.83, b = 0.83, a = 0.68}},
		{type = "fluid", name = "liquid-trichlorosilane", color = {r = 0.83, g = 0.83, b = 0.83, a = 0.68}},
		{type = "fluid", name = "gas-silane", color = {r = 0.83, g = 0.83, b = 0.83, a = 0.92}},
		-- Silver
		{type = "item", name = "silver-ore", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "item", name = "processed-silver", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "item", name = "pellet-silver", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "item", name = "solid-silver-nitrate", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "item", name = "solid-sodium-silver-cyanide", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "item", name = "cathode-silver", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "item", name = "ingot-silver", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "item", name = "angels-plate-silver", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "item", name = "angels-roll-silver", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "item", name = "angels-wire-coil-silver", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "item", name = "angels-wire-silver", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.92}},
		{type = "fluid", name = "liquid-molten-silver", color = {r = 0.57, g = 0.65, b = 0.70, a = 0.68}},
		-- Stone
		{type = "item", name = "solid-lime", color = {r = 0.90, g = 0.78, b = 0.67, a = 0.92}},
		{type = "item", name = "solid-cement", color = {r = 0.45, g = 0.43, b = 0.42, a = 0.92}},
		{type = "fluid", name = "liquid-concrete", color = {r = 0.45, g = 0.43, b = 0.42, a = 0.68}},
		{type = "item", name = "clay-brick-raw", color = {r = 0.58, g = 0.30, b = 0.10, a = 0.92}},
		{type = "item", name = "clay-brick", color = {r = 0.39, g = 0.28, b = 0.18, a = 0.92}},
		{type = "item", name = "concrete-brick", color = {r = 0.39, g = 0.38, b = 0.37, a = 0.92}},
		{type = "item", name = "reinforced-concrete-brick", color = {r = 0.39, g = 0.38, b = 0.37, a = 0.92}},
		-- Tin
		{type = "item", name = "tin-ore", color = {r = 0.34, g = 0.51, b = 0.38, a = 0.92}},
		{type = "item", name = "processed-tin", color = {r = 0.34, g = 0.51, b = 0.38, a = 0.92}},
		{type = "item", name = "pellet-tin", color = {r = 0.34, g = 0.51, b = 0.38, a = 0.92}},
		{type = "item", name = "ingot-tin", color = {r = 0.34, g = 0.51, b = 0.38, a = 0.92}},
		{type = "item", name = "angels-plate-tin", color = {r = 0.34, g = 0.51, b = 0.38, a = 0.92}},
		{type = "item", name = "angels-wire-coil-tin", color = {r = 0.34, g = 0.51, b = 0.38, a = 0.92}},
		{type = "item", name = "angels-wire-tin", color = {r = 0.34, g = 0.51, b = 0.38, a = 0.92}},
		{type = "fluid", name = "liquid-molten-tin", color = {r = 0.34, g = 0.51, b = 0.38, a = 0.92}},
		-- Titanium
		{type = "item", name = "rutile-ore", color = {r = 0.49, g = 0.38, b = 0.48, a = 0.92}},
		{type = "item", name = "processed-titanium", color = {r = 0.49, g = 0.38, b = 0.48, a = 0.92}},
		{type = "item", name = "pellet-titanium", color = {r = 0.49, g = 0.38, b = 0.48, a = 0.92}},
		{type = "item", name = "sponge-titanium", color = {r = 0.49, g = 0.38, b = 0.48, a = 0.92}},
		{type = "item", name = "ingot-titanium", color = {r = 0.49, g = 0.38, b = 0.48, a = 0.92}},
		{type = "item", name = "angels-plate-titanium", color = {r = 0.49, g = 0.38, b = 0.48, a = 0.92}},
		{type = "item", name = "angels-roll-titanium", color = {r = 0.49, g = 0.38, b = 0.48, a = 0.92}},
		{type = "fluid", name = "liquid-molten-titanium", color = {r = 0.49, g = 0.38, b = 0.48, a = 0.68}},
		{type = "fluid", name = "liquid-titanium-tetrachloride", color = {r = 0.49, g = 0.38, b = 0.48, a = 0.68}},
		-- Tungsten
		{type = "item", name = "tungsten-ore", color = {r = 0.53, g = 0.37, b = 0.23, a = 0.92}},
		{type = "item", name = "processed-tungsten", color = {r = 0.53, g = 0.37, b = 0.23, a = 0.92}},
		{type = "item", name = "pellet-tungsten", color = {r = 0.53, g = 0.37, b = 0.23, a = 0.92}},
		{type = "item", name = "solid-ammonium-paratungstate", color = {r = 0.53, g = 0.37, b = 0.23, a = 0.92}},
		{type = "item", name = "solid-tungsten-oxide", color = {r = 0.53, g = 0.37, b = 0.23, a = 0.92}},
		{type = "item", name = "powder-tungsten", color = {r = 0.53, g = 0.37, b = 0.23, a = 0.92}},
		{type = "item", name = "casting-powder-tungsten", color = {r = 0.53, g = 0.37, b = 0.23, a = 0.92}},
		{type = "item", name = "angels-plate-tungsten", color = {r = 0.53, g = 0.37, b = 0.23, a = 0.92}},
		{type = "fluid", name = "liquid-tungstic-acid", color = {r = 0.53, g = 0.37, b = 0.23, a = 0.68}},
		{type = "fluid", name = "gas-tungsten-hexafluoride", color = {r = 0.53, g = 0.37, b = 0.23, a = 0.68}},
		-- Zinc
		{type = "item", name = "zinc-ore", color = {r = 0.37, g = 0.69, b = 0.67, a = 0.92}},
		{type = "item", name = "processed-zinc", color = {r = 0.37, g = 0.69, b = 0.67, a = 0.92}},
		{type = "item", name = "pellet-zinc", color = {r = 0.37, g = 0.69, b = 0.67, a = 0.92}},
		{type = "item", name = "solid-zinc-oxide", color = {r = 0.37, g = 0.69, b = 0.67, a = 0.92}},
		{type = "item", name = "cathode-zinc", color = {r = 0.37, g = 0.69, b = 0.67, a = 0.92}},
		{type = "item", name = "ingot-zinc", color = {r = 0.37, g = 0.69, b = 0.67, a = 0.92}},
		{type = "item", name = "angels-plate-zinc", color = {r = 0.37, g = 0.69, b = 0.67, a = 0.92}},
		{type = "item", name = "angels-roll-zinc", color = {r = 0.37, g = 0.69, b = 0.67, a = 0.92}},
		{type = "fluid", name = "liquid-molten-zinc", color = {r = 0.37, g = 0.69, b = 0.67, a = 0.68}},
		-- Coolant
		{type = "fluid", name = "liquid-coolant", color = {r = 0.37, g = 0.47, b = 0.63, a = 0.68}},
		{type = "fluid", name = "liquid-coolant-used", color = {r = 0.24, g = 0.27, b = 0.34, a = 0.68}},
		-- Molds
		{type = "item", name = "mold-expendable", color = {r = 0.59, g = 0.48, b = 0.40, a = 0.92}},
		{type = "item", name = "mold-non-expendable", color = {r = 0.30, g = 0.30, b = 0.30, a = 0.92}}
	}
	for _, item in pairs(angelssmelting_items) do
		table.insert(DECT.CONFIG.SIGNALS, item)
	end
end

-- REALISTIC ORES
-- ---------------------------------
if mods["RealisticOres"] then
	-- Switch out iron, copper and uranium ore colors
	log("Realistic Ores detected, updating signal colors.")
	removeIndexByName(DECT.CONFIG.SIGNALS, "iron-ore")
	table.insert(DECT.CONFIG.SIGNALS, {type = "item", name = "iron-ore", color = {r = 0.61, g = 0.32, b = 0.25, a = 0.68}})
	removeIndexByName(DECT.CONFIG.SIGNALS, "copper-ore")
	table.insert(
		DECT.CONFIG.SIGNALS,
		{type = "item", name = "copper-ore", color = {r = 0.36, g = 0.61, b = 0.53, a = 0.68}}
	)
	removeIndexByName(DECT.CONFIG.SIGNALS, "uranium-ore")
	table.insert(
		DECT.CONFIG.SIGNALS,
		{type = "item", name = "uranium-ore", color = {r = 0.72, g = 0.76, b = 0.20, a = 0.68}}
	)
end

-- SPACE EXPLORATION
-- ---------------------------------
if mods["space-exploration"] then
	-- Remove space science pack
	log("Space Exploration detected, updating signal colors.")
	removeIndexByName(DECT.CONFIG.SIGNALS, "space-science-pack")
end
