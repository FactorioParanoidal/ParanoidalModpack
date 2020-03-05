-- technology
table.insert(data.raw["technology"]["railway"].effects, {type = "unlock-recipe", recipe = "bbr-rail-wood"})
table.insert(data.raw["technology"]["railway"].effects, {type = "unlock-recipe", recipe = "bbr-rail-iron"})
table.insert(data.raw["technology"]["railway"].effects, {type = "unlock-recipe", recipe = "bbr-rail-brick"})

-- change default entity to placeable on water
data.raw["rail-signal"]["rail-signal"].collision_mask = { "object-layer" }
data.raw["rail-chain-signal"]["rail-chain-signal"].collision_mask = { "object-layer" }

-- change big electric pole including other mods (bobs etc.)
local poles = data.raw["electric-pole"]
for key, value in pairs(poles) do
	if (string.find(key, "big-electric-pole",1,true)) then
		data.raw["electric-pole"][key].collision_mask = { "object-layer" }
	end
end

-- RailPowerSystem support
if data.raw["technology"]["rail-power-system"] then
	local bridges = { wood = "a[train-system]-az-d", iron = "a[train-system]-az-e", brick = "a[train-system]-az-f" }
	for id, order in pairs(bridges) do
		local ptype = {
	        type = "recipe",
	        name = "bbr-rail-electric-"..id,
	        enabled = false,
	        ingredients = { { "bbr-rail-"..id, 1 }, { "copper-cable", 3 } },
	        result ="bbr-rail-electric-"..id,
	        result_count = 1,
    	}
		data:extend{ptype}

		ptype = table.deepcopy(data.raw["rail-planner"]["bbr-rail-"..id])
		ptype.name = "bbr-rail-electric-"..id
		ptype.localised_name = {"entity-name."..ptype.name}
		ptype.order = string.format("%s[%s]", order, ptype.name)
		table.insert(ptype.icons, {
			icon = "__beautiful_bridge_railway__/graphics/icons/electric.png",
			scale = 0.7,
			shift = {-6, -6},
		})
		ptype.place_result = "bbr-straight-rail-electric-"..id
		ptype.straight_rail = "bbr-straight-rail-electric-"..id
		ptype.curved_rail = "bbr-curved-rail-electric-"..id
		data:extend{ptype}

-- straight-rail
		ptype = table.deepcopy(data.raw["straight-rail"]["bbr-straight-rail-"..id])
		ptype.name = "bbr-straight-rail-electric-"..id
		ptype.minable.result = "bbr-rail-electric-"..id
		table.insert(ptype.icons, {
			icon = "__beautiful_bridge_railway__/graphics/icons/electric.png",
			scale = 0.7,
			shift = {-6, -6},
		})
		data:extend{ptype}

-- curved-rail
		ptype = table.deepcopy(data.raw["curved-rail"]["bbr-curved-rail-"..id])
		ptype.name = "bbr-curved-rail-electric-"..id
		ptype.minable.result = "bbr-rail-electric-"..id
		ptype.placeable_by.item="bbr-rail-electric-"..id
		table.insert(ptype.icons, {
			icon = "__beautiful_bridge_railway__/graphics/icons/electric.png",
			scale = 0.7,
			shift = {-6, -6},
		})
		data:extend{ptype}

-- add technology effect
		table.insert(data.raw["technology"]["rail-power-system"].effects, {type = "unlock-recipe", recipe = "bbr-rail-electric-"..id})
	end
end



