local rpath = (...):match("(.-)[^%.]+$")
local util = require(rpath .. "util")
local create_steam = util.create_steam


-- adds the steam entity to the cooling tower when it is build
local function add_cooling_tower(entity)
	-- the steam entity makes happy clouds when the tower is active
	-- this is needed because the cooling tower is an electric furnace, and only burner furnaces can produce smoke
	--logging("---------------------------------------------------------------")
	--logging("Adding new cooling tower with ID: " .. entity.unit_number)
	local steam = create_steam(entity.surface, {
		name = STEAM_ENTITY_NAME,
		position = entity.position,
		force = entity.force,
	})
	steam.active = false -- start inactive
	local tower = {
		id = entity.unit_number,
		entity = entity,
		steam = steam,
	}
	global.towers[tower.id] = tower
	--logging("-> tower successfully added")
	--logging("")
	return tower
end

-- removes the steam entity when its cooling tower is removed
local function remove_cooling_tower(entity)
	--logging("---------------------------------------------------------------")
	--logging("Removing cooling tower ID: " .. entity.unit_number)
	local tower = global.towers[entity.unit_number]
	if tower then
		--logging("-> found tower, removing it and all its parts")
		if tower.steam and tower.steam.valid then tower.steam.destroy() end -- remove happy cloud maker
		global.towers[tower.id] = nil -- remove table entry so we stop trying to update this tower
	end
	--logging("-> tower successfully removed")
	--logging("")
end


local function update_cooling_tower(tower)
	if not (tower.entity.valid and tower.steam.valid) then return end
	-- enable or disable steamer
	if tower.entity.is_crafting() then
		tower.steam.active = true
		-- reset steam puff crafting progress so it never actually finishes
		tower.steam.crafting_progress = 0.1
	else
		tower.steam.active = false
	end

	-- if tower and tower.entity.valid then
		-- -- only show steam puffs if cooling tower is actively working and not backed up
		-- tower.steam.active = tower.entity.is_crafting() and tower.entity.crafting_progress < 1 and tower.name == TOWER_ENTITY_NAME
		-- -- reset steam puff crafting progress so it never actually finishes
		-- tower.steam.crafting_progress = 0.1
	-- end
end


local function on_tick(tick)
	-- cooling towers
	if (tick-4) % 5 == 0 then
		for _,tower in pairs(global.towers) do
			update_cooling_tower(tower)
		end
	end
end


return { -- exports
	tick = on_tick,
	add    = add_cooling_tower,
	remove = remove_cooling_tower,
}


