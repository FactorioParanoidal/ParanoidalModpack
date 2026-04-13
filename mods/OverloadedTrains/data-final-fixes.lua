local extend = {}
local blacklist = {
	["minigun-platform-mk1"] = true,
	["minigun-platform-mk2"] = true,
	["shotgun-platform-mk1"] = true,
	["cannon-platform-mk1"] = true,
	["rocket-platform-mk1"] = true,
	["rocket-platform-mk2"] = true,
	["flamethrower-wagon-mk1"] = true,
	["radar-platform-mk1"] = true,
	["searchlight-platform-mk1"] = true,
	["repair-platform-mk1"] = true,
	["accumulator-wagon"] = true,
}

for name, prototype in pairs(data.raw["fluid-wagon"]) do --23.4t
	if not blacklist[name] then
		for i = 1, 20 do
			local new_wagon = table.deepcopy(prototype)
			new_wagon.name = "OT_level-" .. i .. "-" .. new_wagon.name
			new_wagon.localised_name = { "entity-name." .. name }
			new_wagon.weight = new_wagon.weight * 0.9 + 1000 * i
			new_wagon.braking_force = new_wagon.braking_force * ((new_wagon.weight / prototype.weight - 1) / 10 + 1) -- +100% weight, +10% braking force
			-- braking force seems to be stronger than you might think
			for _, cat in pairs({ "item", "item-with-entity-data" }) do
				for a, b in pairs(data.raw[cat]) do
					if b.place_result == name then
						new_wagon.placeable_by = { item = a, count = 1 }
					end
				end
			end
			table.insert(extend, new_wagon)
		end
		prototype.weight = prototype.weight * 0.9
	end
end

for name, prototype in pairs(data.raw["cargo-wagon"]) do --26t
	if not blacklist[name] then
		for i = 1, 20 do
			local new_wagon = table.deepcopy(prototype)
			new_wagon.name = "OT_level-" .. i .. "-" .. new_wagon.name
			new_wagon.localised_name = { "entity-name." .. name }
			new_wagon.weight = new_wagon.weight + 1000 * i
			new_wagon.braking_force = new_wagon.braking_force * ((new_wagon.weight / prototype.weight - 1) / 10 + 1) -- +100% weight, +10% braking force
			for _, cat in pairs({ "item", "item-with-entity-data" }) do
				for a, b in pairs(data.raw[cat]) do
					if b.place_result == name then
						new_wagon.placeable_by = { item = a, count = 1 }
					end
				end
			end
			table.insert(extend, new_wagon)
		end
	end
end

data:extend(extend)
