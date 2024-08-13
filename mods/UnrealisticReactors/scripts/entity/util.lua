

local function next_delay(tick, delay)
	while global.delayed_fallout[tick + delay] do
		delay = delay + 1
	end
	return delay
end


local function find_nuclear_entity(surface, position, name)
	return surface.find_entity(name, position)
end

local function find_nuclear_ghost(surface, position, name)
	return surface.find_entities_filtered({
		ghost_name = name,
		position = position,
		limit = 1,
	})[1]
end


local function get_reactor_core_power(entity)
	if string.sub(entity.name,1,18) ~= "realistic-reactor-" then return nil end
	return tonumber(string.sub(entity.name, 19))
end


local function create_warning(entity,kind)
	local warning = entity.surface.create_entity{
		name = "rr-" .. kind .. "-warning",
		position = entity.position,
		force = entity.force,
	}
	warning.destructible = false
	return warning
end

local function create_steam(surface, options)
	local steam = surface.create_entity(options)
	steam.operable = false -- disable opening the happy cloud maker's GUI
	steam.destructible = false -- it can't be destroyed (we remove it when the cooling tower dies)
	steam.get_fuel_inventory().insert{name="solid-fuel", count=50} -- at 1 watt, this is enough fuel to run for 39 years, should suffice
	steam.fluidbox[1] = {name="water", amount=1} -- water for dummy steam puff recipe
	steam.active = false -- start inactive
	return steam
end



return { -- exports
	create_steam = create_steam,
	create_warning = create_warning,
	get_reactor_core_power = get_reactor_core_power,
	next_delay = next_delay,
	find_nuclear_entity = find_nuclear_entity,
	find_nuclear_ghost  = find_nuclear_ghost,
}
