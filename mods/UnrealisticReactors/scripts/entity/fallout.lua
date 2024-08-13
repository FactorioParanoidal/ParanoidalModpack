local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local Setting = require(rroot .. "setting")
local remove_reactor_ruin = require(rpath .. "ruin").remove
local next_delay = require(rpath .. "util").next_delay
local fx = require(rroot .. "fx")
local periodic_pollution = fx.periodic_pollution
local circular_radiation = fx.circular_radiation


-- FIXME merge with code from TrueNukes for fallout
-- TODO add radiation damage in diverse form


local function create_cloud(surface, position) -- create fallout cloud
	return surface.create_entity{
		name = "fallout-cloud",
		position = position,
		force = "radioactivity-strong",
	}
end

local function create_radiation(cloud)
    -- FIXME use created_effect in data from entity  to trigger script to create periodic_pollution
	periodic_pollution(cloud, 0.05)
	cloud.surface.create_entity{
		name = "permanent-radiation",
		position = cloud.position,
		force = "radioactivity",
	}
end

local function create_fallout(surface, position, tick)
	local fallout_size = 4
	local id = surface.index
	local fallout = global.fallout[id]
	if not fallout then
		fallout = {id=id, surface=surface, clouds={}, positions={}}
		global.fallout[id] = fallout
	end
	fallout.positions[tick] = position
	table.insert(fallout.clouds, create_cloud(surface, position))

	--create delayed event for fallout around the dead_reactor_core
	local delay = next_delay(tick, 2)
	global.delayed_fallout[tick+delay] = {
		surface = surface,
		position = position,
		min_radius = 0,
		fallout_size = math.floor(fallout_size/2),
	}

	local delay = next_delay(tick, 180)
	global.delayed_fallout[tick+delay] = {
		surface = surface,
		position = position,
		min_radius = 0,
		fallout_size = fallout_size,
	}
end

local function is_generating_clouds(tick)
	return tick + 60 * Setting.startup("clouds-generation") > game.tick
end

local function on_tick(tick)

	-- TODO ruins should have 100% radioactivity resistance
	-- using optimized-particle regular_trigger_effect could help creating clouds over time

	-- radiation around reactor ruin
	if game.tick % 180 == 0 then -- max 2x radiation
		for _,ruin in pairs(global.ruins) do
			local entity = ruin.entity
			if entity and entity.valid then
				periodic_pollution(entity,0.1)
				if ruin.tick + (Setting.protoduration("fallout")*30) < game.tick then

					ruin.tick = game.tick
					ruin.spread = ruin.spread + 1
					circular_radiation(entity.surface,entity.position,0,math.min(16,ruin.spread))
				end
			end
		end
	end

	-- radioactive cloud
	if tick % 600 == 0 then

	-- FIXME TODO create clouds with trigger effects

		for _,ruin in pairs(global.ruins) do
			if is_generating_clouds(ruin.meltdown_tick) then
				-- create fallout cloud
				local fallout = ruin.entity.valid and global.fallout[ruin.entity.surface.index]
				if fallout then
					table.insert(fallout.clouds, create_cloud(ruin.entity.surface, ruin.entity.position))
				end
			else
				-- disable steamer entity of ruin
				ruin.steam.active = false
			end
		end

		for _,fallout in pairs(global.fallout) do
			if fallout.surface.valid then
				local remove = {}
				for tick,position in pairs(fallout.positions) do
					if is_generating_clouds(tick) then
						table.insert(fallout.clouds, create_cloud(fallout.surface, position))
					else
						table.insert(remove, tick)
					end
				end
				--remove cloud creating entry
				for _,tick in ipairs(remove) do
					fallout.positions[tick] = nil
				end
			end
		end

	end

	-- fallout radiation (from clouds)
	if tick % 79 == 0 then
		local remove = {}
		for id,fallout in pairs(global.fallout) do
			if not fallout.surface.valid or #fallout.clouds + table_size(fallout.positions) == 0 then
				table.insert(remove, id)
			else
				local index = global.random(1,#fallout.clouds)
				local cloud = fallout.clouds[index]
				if cloud and cloud.valid then
					create_radiation(cloud)
				else
					table.remove(fallout.clouds, index)
					if #fallout.clouds + table_size(fallout.positions) == 0 then
						table.insert(remove, id)
					end
				end
			end
		end
		for _,id in ipairs(remove) do
			global.fallout[id] = nil
		end
	end

	-- FIXME this can be possibly merged with projectile logic of TrueNukes

	-- delayed fallout
	local delay = global.delayed_fallout[tick]
	if delay then
		circular_radiation(delay.surface, delay.position, delay.min_radius or 0, delay.fallout_size)
		global.delayed_fallout[tick] = nil
	end
end


return { -- exports
	tick = on_tick,
	create = create_fallout,
	cloud = create_cloud,
}
