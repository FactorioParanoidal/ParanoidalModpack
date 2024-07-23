local function calc_src_dir(direction)
	if     direction == 0 then return {x =  0, y =  1}  -- north
	elseif direction == 2 then return {x = -1, y =  0}  -- ost
	elseif direction == 4 then return {x =  0, y = -1}  -- south
	else                       return {x =  1, y =  0}  -- west
	end
end

local function vecadd(vec, dir)
	return { x = vec.x + dir.x, y = vec.y + dir.y }
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


if global.version < 5 then
	local transformators = {}
	local global_trafos = global.trafos or global.transformators

	for _, force in pairs(game.forces) do
		for _, surface in pairs(game.surfaces) do
			for _, entity in pairs(surface.find_entities_filtered{force = force.name}) do
				if string.len(entity.name) == 12 and 
				   string.sub(entity.name, 1, 6) == "trafo-" and 
				   tonumber(string.sub(entity.name, 7, 7)) >= 1 and 
				   tonumber(string.sub(entity.name, 7, 7)) <= 5
				then
					entity.destroy()
				end
			end
		end
	end

	for _, t in pairs(global_trafos) do
		if t.target and t.target.valid then

			local direction = tonumber(string.sub(t.target_pole.name, 22, 22))
			local surface = t.target.surface
			local force = t.target.force
			local tier = string.sub(t.target.name, 14, 14)

			local src_dir = calc_src_dir(direction)
			local position = vecadd(src_dir, t.target.position)

			local src_direction = 0
			if direction >= 4 then
				src_direction = direction - 4
			else
				src_direction = direction + 4
			end

			t.entity.destroy()
			local ent = surface.create_entity{
				name = "trafo-"..tier.."-unit", 
				position = position, 
				force = force, 
				direction = direction}

			t.entity = ent
			t.fluid_src = t.fluid_src or 
				add_trafo_pipe(surface, position, src_direction, force, tier)
			transformators[ent.unit_number] = t
		end
	end
	global.transformators = transformators
	global.version = 5
end



