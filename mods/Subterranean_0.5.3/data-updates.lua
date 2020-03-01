local entity = data.raw["underground-belt"]["green-underground-belt"]
if entity ~= nil then --bob's logistics is installed
	local entity = data.raw["underground-belt"]["green-underground-belt"]
	entity.max_distance = 250
	table.insert(entity.flags, "not-deconstructable")
end

entity = data.raw["underground-belt"]["purple-underground-belt"]
if entity ~= nil then --bob's logistics is installed
	entity.max_distance = 250
	table.insert(entity.flags, "not-deconstructable")
end

entity = data.raw["pipe-to-ground"]["nitinol-pipe-to-ground"]
if entity ~= nil then --bob's logistics is installed
	entity.fluid_box.pipe_connections = {{position = {0, -1}}, {position = {0, 1}, max_underground_distance = 250}}
	table.insert(entity.flags, "not-deconstructable")
end

entity = data.raw["pipe-to-ground"]["copper-tungsten-pipe-to-ground"]
if entity ~= nil then --bob's logistics is installed
	entity.fluid_box.pipe_connections = {{position = {0, -1}}, {position = {0, 1}, max_underground_distance = 250}}
	table.insert(entity.flags, "not-deconstructable")
end

entity = data.raw["pipe-to-ground"]["plastic-pipe-to-ground"]
if entity ~= nil then --bob's logistics is installed
	entity.fluid_box.pipe_connections = {{position = {0, -1}}, {position = {0, 1}, max_underground_distance = 100}}
	table.insert(entity.flags, "not-deconstructable")

end
