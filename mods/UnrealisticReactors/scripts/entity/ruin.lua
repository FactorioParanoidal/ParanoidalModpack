local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local Setting = require(rroot .. "setting")
local create_steam = require(rpath .. "util").create_steam



local function add_reactor_ruin(dead_reactor_name, dead_reactor_core)
	local surface = dead_reactor_core.surface

	-- create reactor ruin
	local entity = surface.create_entity{
		name = RUIN_NAME[dead_reactor_name],
		position = dead_reactor_core.position,
		force = dead_reactor_core.force,
		create_build_effect_smoke = false,
	}
	entity.destructible = false

	-- create steam producing entity
	local p = dead_reactor_core.position
	local steam = create_steam(surface, {
		name = RUIN_SMOKE_NAME,
		position = {p.x,p.y+0.3},
		force = dead_reactor_core.force,
	})
	steam.active = true -- start active - it's always active
	local glow = surface.create_entity{
			name = "rr-ruin-glow",
			position = dead_reactor_core.position,
			force = dead_reactor_core.force,
		}

	-- reactor ruin is saved in global table
	local ruin = {
		id = entity.unit_number, --same id as reactor
		entity = entity,
		steam = steam,
		glow = glow,
		tick = game.tick,--changes during radiation creation
		meltdown_tick = game.tick,
		spread = 6,
	}
	global.ruins[ruin.id] = ruin
	return ruin
end

-- remove reactor ruin
local function remove_reactor_ruin(entity)
	--when the reactor ruin was replaced by a sarcophagus, the steam creator entity needs to be removed
	--logging("---------------------------------------------------------------")
	--logging("Removing reactor ruin ID: " .. entity.unit_number)
	local ruin = global.ruins[entity.unit_number]
	if ruin then
		--logging("-> found matching entry")
		if ruin.steam and ruin.steam.valid then ruin.steam.destroy() end
		if ruin.glow and ruin.glow.valid then ruin.glow.destroy() end
		global.ruins[ruin.id] = nil
	end
end


local function update_reactor_ruin(ruin)
	if ruin and ruin.entity.valid and ruin.steam and ruin.steam.valid then
		-- reset steam puff crafting progress so it never actually finishes
		ruin.steam.crafting_progress = 0.1
	end
end


local function on_tick(tick)
	--sarcophagus healing
	if tick % 180 == 0 then
		for key, entity in pairs(global.sarcophagus) do
			entity.health = entity.health + 1000/math.max(1,Setting.protoduration("sarcophagus")) * 3
			if entity.health == 1000 then
				entity.minable = true
				entity.destructible = true
				global.sarcophagus[key] = nil
			end
		end
	end
	-- reactor ruins
	if (tick-7) % (TICKS_PER_UPDATE*4) == 0 then
		for _,ruin in pairs(global.ruins) do
			update_reactor_ruin(ruin)
		end
	end
end



return { -- exports
	tick = on_tick,
	add    =    add_reactor_ruin,
	remove = remove_reactor_ruin,
}

