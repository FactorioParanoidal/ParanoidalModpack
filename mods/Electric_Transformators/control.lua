local events = {
	entity = {
		added = {
			defines.events.on_robot_built_entity,
			defines.events.on_built_entity,
			defines.events.on_script_raised_built,
		},
		removed = {
			defines.events.on_pre_player_mined_item,
			defines.events.on_robot_pre_mined,
			defines.events.on_entity_died,
			defines.events.on_script_raised_destroy,
		},
	},
}


local transformator_names = {
	"trafo-1-displayer",
	"trafo-2-displayer",
	"trafo-3-displayer",
	"trafo-4-displayer",
	"trafo-5-displayer",
	"trafo-1-unit",
	"trafo-2-unit",
	"trafo-3-unit",
	"trafo-4-unit",
	"trafo-5-unit",
}


local function is_transformator(name)
	for _, unit in ipairs(transformator_names) do
		if (name == unit) then return true end
	end
	return false 
end


local function vecadd(vec, dir)
	return { x = vec.x + dir.x, y = vec.y + dir.y }
end


local function calc_src_dir(direction)
	if     direction == 0 then return {x =  0, y =  1}  -- north
	elseif direction == 2 then return {x = -1, y =  0}  -- ost
	elseif direction == 4 then return {x =  0, y = -1}  -- south
	else                       return {x =  1, y =  0}  -- west
	end
end


local function calc_tgt_dir(direction)
	if     direction == 0 then return {x =  0, y = -1}  -- north
	elseif direction == 2 then return {x =  1, y =  0}  -- ost
	elseif direction == 4 then return {x =  0, y =  1}  -- south
	else                       return {x = -1, y =  0}  -- west
	end
end


local function calc_con_pos(pa, pb)
	local  pos = {
		x = 2 * pa.x + pb.x, 
		y = 2 * pa.y + pb.y,
	}
	return pos
end


local function check_connections()
	for _, tbl in pairs(global.transformators) do
		if tbl.target_pole.valid then
			for _, neighbour in pairs(tbl.target_pole.neighbours.copper) do
				if string.sub(neighbour.name, 1, 21) == "trafo-connection_src_" then
					tbl.target_pole.disconnect_neighbour(neighbour)
				end
			end
		end

		if tbl.source_pole.valid then
			for _, neighbour in pairs(tbl.source_pole.neighbours.copper) do
				if string.sub(neighbour.name, 1, 21) == "trafo-connection_tar_" then
					tbl.source_pole.disconnect_neighbour(neighbour)
				end
			end
		end
	end

	for _, tbl in pairs(global.transformators) do
		if tbl.source_pole.valid and tbl.target_pole.valid then
			if tbl.source_pole.electric_network_id == tbl.target_pole.electric_network_id then
--				log("electric short on network "..tbl.source_pole.electric_network_id)
				for _, player in pairs(game.players) do
					player.add_custom_alert(
						tbl.entity, 
						{type="virtual", name="electric-transformators-short-circuit"}, 
						{"electric-transformators-short-circuit-msg", tbl.source_pole.electric_network_id}, 
						true
					)
				end
			end
		end
	end
end

local function add_trafo_pipe(surface, position, direction, force, tier)
	local fluid_src_pos
	local fluid_pipe_name

	if     direction == 0 then
		fluid_src_pos = {x = position.x+0.5, y = position.y+0.5}
		fluid_pipe_name = "trafo-pump-n-"..tier
	elseif direction == 2 then
		fluid_src_pos = {x = position.x-0.5, y = position.y+0.5}
		fluid_pipe_name = "trafo-pump-e-"..tier
	elseif direction == 4 then
		fluid_src_pos = {x = position.x-0.5, y = position.y-0.5}
		fluid_pipe_name = "trafo-pump-s-"..tier
	elseif direction == 6 then
		fluid_src_pos = {x = position.x+0.5, y = position.y-0.5}
		fluid_pipe_name = "trafo-pump-w-"..tier
	end

	local fluid_src = surface.create_entity{
		name = fluid_pipe_name, 
		position = fluid_src_pos,
		force = force, 
	}

	fluid_src.set_infinity_pipe_filter({
		name = "trafo-water-"..tier, 
		percentage = 0.79, 
--		mode = "exactly",
	})
	return fluid_src
end


local function make_transformator_struct()
return {
		entity = nil, 
		fluid_src = nil, 
		source = nil, 
		target = nil, 
		source_pole = nil, 
		target_pole = nil,
	}
end

local function add_transformator(entity)
	local direction = entity.direction
	local position = entity.position
	local surface = entity.surface
	local force = entity.force
	local tier = string.sub(entity.name, 7, 7)

	entity.destroy() --remove trafo-tier-displayer, add trafo-tier-unit entity
	local ent = surface.create_entity{
		name = "trafo-"..tier.."-unit", 
		position = position, 
		force = force, 
		direction = direction}

	global.transformators[ent.unit_number] = make_transformator_struct()
	global.transformators[ent.unit_number].entity = ent

	local src_dir = calc_src_dir(direction)
	local tgt_dir = calc_tgt_dir(direction)

	local src_direction = 0
	local tgt_direction = direction
	local target

	if tgt_direction >= 4 then
		src_direction = direction - 4
		target = surface.create_entity{
			name = "trafo-target-"..tier.."-ne", 
			position = vecadd(tgt_dir, position),
			force = force, 
			direction =  tgt_direction}
	else
		src_direction = direction + 4
		target = surface.create_entity{
			name = "trafo-target-"..tier.."-sw", 
			position = vecadd(tgt_dir, position),
			force = force, 
			direction = tgt_direction}
	end

	local source = surface.create_entity{
		name = "trafo-source-"..tier, 
		position = vecadd(src_dir, position),
		force = force, 
		direction = src_direction}


	local fluid_src = add_trafo_pipe(surface, position, src_direction, force, tier)

	local target_pole = surface.create_entity{
		name = "trafo-connection_tar_"..direction, 
		position = calc_con_pos(tgt_dir, position), 
		force = force}

	local source_pole = surface.create_entity{
		name = "trafo-connection_src_"..direction, 
		position = calc_con_pos(src_dir, position), 
		force = force}

	global.transformators[ent.unit_number].fluid_src = fluid_src
	global.transformators[ent.unit_number].target = target
	global.transformators[ent.unit_number].source = source
	global.transformators[ent.unit_number].source_pole = source_pole
	global.transformators[ent.unit_number].target_pole = target_pole

	check_connections()
end


local function remove_transformator(id)
	if global.transformators[id] then 
		global.transformators[id].fluid_src.destroy()
		global.transformators[id].source.destroy()
		global.transformators[id].target.destroy()
		global.transformators[id].target_pole.destroy()
		global.transformators[id].source_pole.destroy()
		global.transformators[id] = nil
	else
		log("transformator id "..id.."not found")
	end
end


local function do_takeover()
	local count = 0
	-- check for old transformers mod remnants
	local entities = {}
	for _, force in pairs(game.forces) do
		for _, surface in pairs(game.surfaces) do
			for _, entity in pairs(surface.find_entities_filtered{force = force.name}) do
				if string.sub(entity.name,1,16) == "trafo-connection" or 
				   string.sub(entity.name,1,12) == "trafo-source" or 
				   string.sub(entity.name,1,10) == "trafo-pump" or
				   string.sub(entity.name,1,12) == "trafo-target" then
					entity.destroy()
				elseif is_transformator(entity.name) then
					entities[entity.unit_number] = entity
				end
			end
		end
	end

	for _, t in pairs(entities) do
		--readd, like v3 before
		add_transformator(t)
		count = count + 1
	end

	return count
end


local function do_init()
	global.transformators = {}
	global.version = 5
	if not global.takeover then
		global.takeover = do_takeover()
		log("took "..global.takeover.." legacy transformers over")
	end
end


script.on_init(function()
	do_init()
end)


script.on_event(events.entity.added, function(event) 
	local entity = event.created_entity or event.entity
	if is_transformator(entity.name) then
		add_transformator(entity)
	end
end)


script.on_event(events.entity.removed, function(event)
	if is_transformator(event.entity.name) then
		remove_transformator(event.entity.unit_number)
	end
end)


local check_interval = settings.startup["trafos-periodic-check"].value
if check_interval > 0 then
	script.on_nth_tick(check_interval, function(event) check_connections() end)
end



