local max, min = math.max, math.min
local floor, ceil = math.floor, math.ceil
local builder  = require("mpp.builder")
local mpp_util = require("mpp.mpp_util")
local EAST, NORTH, SOUTH, WEST, ROTATION = mpp_util.directions()
local coord_convert, coord_revert = mpp_util.coord_convert, mpp_util.coord_revert

---@class BeltinatorState : TaskState
---@field x_start number
---@field belt_x number
---@field belt_y number
---@field belt_specification BeltPlannerSpecification
---@field belt_choice string
---@field belt_direction defines.direction
---@field player LuaPlayer
---@field surface LuaSurface
---@field coords Coords
---@field direction_choice DirectionString

---@class BeltOutputPosition
---@field x number
---@field y number
---@field index number
---@field direction defines.direction

local function coord_transformer(direction)
	direction = direction % ROTATION
	if direction == EAST then
		return
		function(x, y) return -x, -y end,
		function(x, y) return -x, -y end
	elseif direction == NORTH then
		return
		function(x, y) return y, -x end,
		function(x, y) return -y, x	end
	elseif direction == SOUTH then
		return
		function(x, y) return -y, x end,
		function(x, y) return y, -x end
	else
		return
		function(x, y) return x, y end,
		function(x, y) return x, y end
	end
end

local belt_planner = {}

---@alias BeltinatorSegmentType
---| "elbow"

---@class BeltinatorSegmentSpecification
---@field belt_choice string
---field type BeltinatorSegmentType
---@field start_direction defines.direction
---@field end_direction defines.direction
---@field x1 number
---@field y1 number
---@field x2 number
---@field y2 number

---@class BeltinatorVerticalSegmentSpecification
---@field belt_choice string
---@field direction defines.direction
---@field x number
---@field y1 number
---@field y2 number

---@class BeltinatorHorizontalSegmentSpecification
---@field belt_choice string
---@field direction defines.direction
---@field x1 number
---@field x2 number
---@field y number

---@param player_data PlayerData
function belt_planner.clear_belt_planner_stack(player_data)
	for _, state in pairs(player_data.belt_planner_stack) do
		for _, r in pairs(state._renderables) do
			if r.valid then
				r.destroy()
			end
		end
	end
	player_data.belt_planner_stack = {}
end

---@param player LuaPlayer|integer
---@param spec BeltPlannerSpecification
function belt_planner.push_belt_planner_step(player, spec)
	player = type(player) == "number" and player or player.index
	
	---@type PlayerData
	local player_data = storage.players[player]
	local belt_planner_stack = player_data.belt_planner_stack
	table.insert(belt_planner_stack, spec)
end

---@param state SimpleState
---@param spec BeltPlannerSpecification
function belt_planner.give_blueprint(state, spec)
	local ply = state.player
	local stack = ply.cursor_stack --[[@as LuaItemStack]]
	stack.set_stack("mpp-blueprint-belt-planner")
	
	---@type BlueprintEntity[]
	local ents = {}
	
	for i = 1, spec.count do
		local tags = {mpp_belt_planner = "delete"}
		if i == 1 then
			tags.mpp_belt_planner = "main"
		end
		ents[i] = {
			name = state.belt_choice,
			position = {i, 1},
			direction = defines.direction.north,
			entity_number = i,
			tags = tags,
		}
	end
	
	stack.set_blueprint_entities(ents)
	ply.cursor_stack_temporary = true
	-- storage.players[state.player.index].belt_planner_blueprint = stack.item
	
	return stack
end

---@param state BeltinatorState
function belt_planner.layout(state)
	local belt_specification = state.belt_specification
	local count = belt_specification.count
	local tx, ty = state.belt_x, state.belt_y
	local world_direction = state.belt_direction
	local belt_choice = state.belt_choice
	local belt_start_x = state.x_start
	
	local conv = coord_convert[state.direction_choice]
	-- local rot = mpp_util.bp_direction[state.direction_choice][direction]
	-- local bump = state.direction_choice == "north" or state.direction_choice EAST
	-- local belt_direction = mpp_util.clamped_rotation(((-defines.direction[state.direction_choice]) % ROTATION)-EAST, world_direction)
	local belt_direction = world_direction
	
	local create_entity = builder.create_entity_builder(state, {do_deconstruction=true})
	
	-- rendering.clear()

	local plan_east, plan_vertical, plan_west
	
	---@param op_x number
	---@param op_y number
	---@return List<BeltOutputPosition>
	function plan_west(op_x, op_y)
		local output_positions = List()
		--[[ debug rendering
			for i, belt in ipairs(belt_specification) do
				local belt_y = belt.y
				local target_y = ty + i - count

				local gx, gy = converter(belt.x_start-1, belt.y)
				rendering.draw_circle{
					surface = state.surface,
					target = {gx+.5, gy+.5},
					radius = 0.45,
					width = 3,
					color = {1, 0.7, 0},
				}
				rendering.draw_text{
					surface = state.surface,
					target = {gx+.5, gy},
					color = {1, 0.7, 0},
					text = i,
					alignment= "center",
					scale = 2,
				}
				gx, gy = converter(tx, target_y)
				rendering.draw_circle{
					surface = state.surface,
					target = {gx+.5, gy+.5},
					radius = 0.45,
					width = 3,
					color = {.39, .58, .93},
				}
				rendering.draw_text{
					surface = state.surface,
					target = {gx+.5, gy},
					color = {.39, .58, .93},
					text = i,
					alignment= "center",
					scale = 2,
				}
			end
		end --]]
		
		local breaking_point = -count
		
		for i, belt in ipairs(belt_specification) do
			local belt_y = belt.y
			local target_y = op_y + i - count
			
			if belt_y >= target_y then
				breaking_point = i -- belt that doesn't need to accomodate spacing for other belts
				break
			end
		end
		
		if belt_specification[count].y < op_y then
			breaking_point = count + 1
		end
		
		local accomodation_value = breaking_point - 1.5
		for i, belt in ipairs(belt_specification) do
			local target_y = op_y + i - count
			if target_y == belt.y then
				accomodation_value = accomodation_value + 1
			end
			local accomodation_shift = math.ceil(math.abs(accomodation_value))
			
			-- local gx, gy = converter(belt.x_start-accomodation_shift, belt.y)
			-- rendering.draw_circle{
			-- 	surface = state.surface,
			-- 	target = {gx+.5, gy+.5},
			-- 	radius = 0.45,
			-- 	width = 3,
			-- 	color = {1, 0, 0},
			-- }
			
			if target_y ~= belt.y then
				belt_planner.build_elbow(create_entity, {
					start_direction = WEST,
					end_direction = accomodation_value >= 0 and SOUTH or NORTH,
					x1 = belt.x_start-1,
					y1 = belt.y,
					x2 = belt.x_start-accomodation_shift,
					y2 = target_y + math.sign(accomodation_value),
					belt_choice = belt_choice,
				})
				belt_planner.build_line_horizontal(create_entity, {
					direction = WEST,
					x1 = op_x,
					x2 = belt.x_start - accomodation_shift,
					y = target_y,
					belt_choice = belt_choice,
				})
				output_positions:push{
					x = op_x,
					y = target_y,
					direction = belt_choice,
					index = i,
				}
			else
				belt_planner.build_line_horizontal(create_entity, {
					direction = WEST,
					x1 = op_x,
					x2 = belt.x_start - 1,
					y = target_y,
					belt_choice = belt_choice,
				})
				output_positions:push{
					x = op_x,
					y = target_y,
					direction = belt_choice,
					index = i,
				}
			end
			
			
			accomodation_value = accomodation_value - 1
		end
		
		return output_positions
	end
	
	---@param op_x number
	---@param op_y number
	---@param op_direction defines.direction
	---@return List<BeltOutputPosition>
	function plan_vertical(op_x, op_y, op_direction)
		local output_positions = List() --[[@as List<BeltOutputPosition>]]
		local x_direction = op_direction == NORTH and 1 or -1
		local belt_spec = belt_specification
		
		-- To the right of the patch
		if (
			(op_direction == NORTH and op_x > (belt_start_x - count))
			or (op_direction == SOUTH and op_x > (belt_start_x - 1))
		)
		then
			local y = op_direction == NORTH and belt_specification[1].y or belt_specification[count].y
			for _, belt in ipairs(belt_specification) do
				local i = belt.index
				local x2_step = op_direction == NORTH and -1-count+i or -i
				belt_planner.build_elbow(create_entity, {
					start_direction = WEST,
					end_direction = op_direction,
					type = "elbow",
					x1 = belt.x_start - 1,
					y1 = belt.y,
					x2 = belt_start_x + x2_step,
					y2 = y,
					belt_choice = belt_choice,
				})
				local y2_step = op_direction == NORTH and i-1 or i-count
				local x2_step2 = op_direction == NORTH and i - 1 or 1-i
				belt_planner.build_elbow(create_entity, {
					start_direction = op_direction,
					end_direction = EAST,
					type = "elbow",
					x1 = belt_start_x + x2_step,
					y1 = belt.y,
					x2 = op_x + x2_step2 - 1,
					y2 = op_y + y2_step,
					belt_choice = belt_choice,
				})
				-- belt_planner.build_elbow(create_entity, {
				-- 	start_direction = EAST,
				-- 	end_direction = op_direction,
				-- 	type = "elbow",
				-- 	belt_choice = belt_choice,
				-- 	x1 = belt_start_x+1,
				-- 	y1 = op_y + y2_step,
				-- 	x2 = op_x + x2_step2,
				-- 	y2 = op_y,
				-- })
				belt_planner.build_line_vertical(create_entity, {
					belt_choice = belt_choice,
					direction = op_direction,
					x = op_x + x2_step2,
					y1 = op_y + y2_step,
					y2 = op_y,
				})
				output_positions:push{
					direction = op_direction, index = i,
					x = op_x + x_direction * (i-1),
					y = op_y,
				}
			end
		elseif op_direction == NORTH and op_y > belt_specification[1].y then
			local intermediate_positions = plan_west(op_x+count, op_y-1+count)
			
			for _, pos in ipairs(intermediate_positions) do
				belt_planner.build_elbow(create_entity, {
					belt_choice = belt_choice,
					type = "elbow",
					start_direction = WEST,
					end_direction = op_direction,
					x1 = op_x+count,
					y1 = pos.y,
					x2 = op_x+count-pos.index,
					y2 = op_y,
				})
			end
		elseif op_direction == SOUTH and op_y < belt_specification[count].y then
			local intermediate_positions = plan_west(op_x+1, op_y)
			
			for _, pos in ipairs(intermediate_positions) do
				belt_planner.build_elbow(create_entity, {
					belt_choice = belt_choice,
					type = "elbow",
					start_direction = WEST,
					end_direction = op_direction,
					x1 = op_x,
					y1 = pos.y,
					x2 = op_x-count+pos.index,
					y2 = op_y,
				})
			end
		else
			for i, belt in ipairs(belt_spec) do
				belt_planner.build_elbow(create_entity, {
					-- table.insert(segment_specification, {
					start_direction = WEST,
					end_direction = op_direction,
					type = "elbow",
					x1 = belt.x_start - 1,
					y1 = belt.y,
					x2 = op_x + (count - i) * x_direction,
					y2 = op_y,
					belt_choice = belt_choice,
				})
				output_positions:push{
					x = op_x + (count - i) * x_direction,
					y = op_y,
					direction = op_direction,
					index = belt.index,
				}
			end
		end
		
		return output_positions
	end
	
	---@param op_x number
	---@param op_y number
	---@return List<BeltOutputPosition>
	function plan_east(op_x, op_y)
		local op_y1, op_y2 = belt_specification[1].y, belt_specification[belt_specification.count].y
		local op_direction = op_y < op_y1 and NORTH or SOUTH
		local intermediate_y = op_direction == NORTH and op_y1 or op_y2
		local direction_accomodation = op_direction == NORTH and -belt_specification.count or -1
		
		local actual_x = min(belt_start_x, op_x+1)
		
		local step_positions = plan_vertical(actual_x+direction_accomodation, intermediate_y, op_direction)
		local output_positions = List()
		
		for _, position in ipairs(step_positions) do
			---@cast position BeltOutputPosition
			belt_planner.build_elbow(create_entity, {
				belt_choice = belt_choice,
				start_direction = op_direction,
				end_direction = EAST,
				x1 = position.x,
				y1 = position.y,
				x2 = op_x,
				y2 = op_y+position.index-1,
			})
			output_positions:push{
				x = op_x,
				y = op_y+position.index-1,
				direction = op_direction,
				index = position.index,
			}
		end
		
		return output_positions
	end
	
	local output_positions
	if belt_direction == EAST then
		output_positions = plan_east(tx, ty)
	elseif belt_direction == WEST then
		output_positions = plan_west(tx, ty)
	else
		output_positions = plan_vertical(tx, ty, belt_direction)
	end
	
	--[[ debug rendering
	local C = state.coords
	for _, pos in ipairs(output_positions) do
		local gx, gy = conv(C.gx+pos.x, C.gy+pos.y)
		rendering.draw_circle{
			surface = state.surface,
			target = {gx, gy},
			radius = 0.45,
			width = 3,
			color = {1, 0, 0},
		}
	end
	--]]
end


---@param builder_func EntityBuilderFunction
---@param t BeltinatorSegmentSpecification
function belt_planner.build_elbow(builder_func, t)
	local belt_choice = t.belt_choice
	local end_direction = t.end_direction
	local start_direction = t.start_direction
	
	local w2l, l2w = coord_transformer(t.start_direction)
	
	local lx1, ly1 = w2l(t.x1, t.y1)
	local lx2, ly2 = w2l(t.x2, t.y2)
	
	local loop_incrementer = lx2 < lx1 and -1 or 1
	for ix = lx1, lx2, loop_incrementer do
		if ix == lx2 then goto cont end
		local wx, wy = l2w(ix, ly1)
		builder_func{
			name = belt_choice,
			grid_x = wx,
			grid_y = wy,
			direction = start_direction,
		}
		::cont::
	end
	
	loop_incrementer = ly2 < ly1 and -1 or 1
	for iy = ly1, ly2, loop_incrementer do
		local wx, wy = l2w(lx2, iy)
		builder_func{
			name = belt_choice,
			grid_x = wx,
			grid_y = wy,
			direction = end_direction,
		}
	end
end

---@param builder_func EntityBuilderFunction
---@param t BeltinatorHorizontalSegmentSpecification
function belt_planner.build_line_horizontal(builder_func, t)
	local belt_choice = t.belt_choice
	local start_direction = t.direction
	local ty = t.y
	for ix = min(t.x1, t.x2), max(t.x1, t.x2) do
		builder_func{
			name = belt_choice,
			grid_x = ix,
			grid_y = ty,
			direction = start_direction,
		}
	end
end

---@param builder_func EntityBuilderFunction
---@param t BeltinatorVerticalSegmentSpecification
function belt_planner.build_line_vertical(builder_func, t)
	local belt_choice = t.belt_choice
	local start_direction = t.direction
	local tx = t.x
	for iy = min(t.y1, t.y2), max(t.y1, t.y2) do
		builder_func{
			name = belt_choice,
			grid_x = tx,
			grid_y = iy,
			direction = start_direction,
		}
	end
end

return belt_planner
