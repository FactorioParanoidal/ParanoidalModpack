local name_1 = "micromario-platform"
local name_2 = "micromario-immortal-platform"
local water = "water"
local flag = "placeable-off-grid"
local rail = "curved-rail"

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
	local entity = event.created_entity
	--We have to filter out entities that aren't square or that move
	if entity.has_flag(flag) or entity.type == rail then return nil end
	local position = entity.position
	local surface = entity.surface
	local tiles = {}
	local selection_box = entity.selection_box
	--This array contains all the positions in an easily read box
	local area = {selection_box.left_top.x, selection_box.left_top.y, selection_box.right_bottom.x, selection_box.right_bottom.y}
	for k, _ in pairs(area) do
		area[k] = (math.ceil(area[k] * 2)) / 2
	end
	--This loops through all the tiles under a placed building
	if not (area[1] == area[3] and area[2] == area[4]) then
		for _, tile in pairs(surface.find_tiles_filtered{
		area = {{area[1], area[2]}, {area[3], area[4]}},
		name = name_1,
		}) do
			--We use the positions to make an array of tiles
			tiles[#tiles + 1] = {name = name_2, position = tile.position}
		end
		--I try to call this function as sparely as possible because it's expensive
		surface.set_tiles(tiles)
	end
end)

script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity, defines.events.on_entity_died}, function(event)
	local entity = event.entity
	if entity.has_flag(flag) or entity.type == rail then return nil end
	local position = entity.position
	local surface = entity.surface
	--If we define tiles as {{},{}}, lua doesn't have to change the size of the array later on, saving performance
	local tiles = {{}, {}}
	local selection_box = entity.selection_box
	local area = {selection_box.left_top.x, selection_box.left_top.y, selection_box.right_bottom.x, selection_box.right_bottom.y}
	for k, _ in pairs(area) do
		area[k] = (math.ceil(area[k] * 2)) / 2
	end
	if not (area[1] == area[3] and area[2] == area[4]) then
		for _, tile in pairs(surface.find_tiles_filtered{
		area = {{area[1], area[2]}, {area[3], area[4]}},
		name = name_2,
		}) do
			local tile_position = tile.position
			tiles[1][#tiles[1] + 1] = {name = water, position = tile_position}
			tiles[2][#tiles[2] + 1] = {name = name_1, position = tile_position}
		end
		--I set water tiles first so that I can make sure the other tiles can be placed (platforms can only float on water)
		surface.set_tiles(tiles[1])
		surface.set_tiles(tiles[2])
	end
end)