local enums = require("mpp.enums")
local blacklist = require("mpp.blacklist")
local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max
local abs = math.abs

local EAST = defines.direction.east
local NORTH = defines.direction.north
local SOUTH = defines.direction.south
local WEST = defines.direction.west
local ROTATION = table_size(defines.direction)

---@alias DirectionString
---| "west"
---| "east"
---| "south"
---| "north"

local mpp_util = {}

---@alias CoordinateConverterFunction fun(number, number, number, number): number, number

---@type table<DirectionString, CoordinateConverterFunction>
local coord_convert = {
	west = function(x, y, w, h) return x, y end,
	east = function(x, y, w, h) return w-x, h-y end,
	south = function(x, y, w, h) return h-y, x end,
	north = function(x, y, w, h) return y, w-x end,
}
mpp_util.coord_convert = coord_convert

---Rotates a direction and clamps it
---@param direction defines.direction
---@param rotation defines.direction?
---@return defines.direction
local function clamped_rotation(direction, rotation)
	return (direction + (rotation or NORTH)) % ROTATION
end

mpp_util.clamped_rotation = clamped_rotation

---@type table<DirectionString, CoordinateConverterFunction>
local coord_revert = {
	west = coord_convert.west,
	east = coord_convert.east,
	north = coord_convert.south,
	south = coord_convert.north,
}
mpp_util.coord_revert = coord_revert

mpp_util.miner_direction = {west="south",east="north",north="west",south="east"}
mpp_util.belt_direction = {west="north", east="south", north="east", south="west"}
mpp_util.opposite = {west="east",east="west",north="south",south="north"}

do
	-- switch to (direction + EAST) % ROTATION
	local d = defines.direction
	mpp_util.bp_direction = {
		west = {
			[d.north] = d.north,
			[d.east] = d.east,
			[d.south] = d.south,
			[d.west] = d.west,
		},
		north = {
			[d.north] = d.east,
			[d.east] = d.south,
			[d.south] = d.west,
			[d.west] = d.north,
		},
		east = {
			[d.north] = d.south,
			[d.east] = d.west,
			[d.south] = d.north,
			[d.west] = d.east,
		},
		south = {
			[d.north] = d.west,
			[d.east] = d.north,
			[d.south] = d.east,
			[d.west] = d.south,
		},
	}
end

---@type table<defines.direction, MapPosition.0>
local direction_coord = {
	[NORTH] = {x=0, y=-1},
	[WEST] = {x=-1, y=0},
	[SOUTH] = {x=0, y=1},
	[EAST] = {x=1, y=0},
}
mpp_util.direction_coord = direction_coord

---@param x number
---@param y number
---@param dir defines.direction
---@return number, number
local function rotate(x, y, dir)
	dir = dir % ROTATION
	if dir == EAST then
		return -x, -y
	elseif dir == SOUTH then
		return y, -x
	elseif dir == WEST then
		return x, y
	end
	return -y, x
end
mpp_util.rotate = rotate

---@class EntityStruct
---@field filtered boolean Should the struct never appear as a valid choice
---@field name string
---@field type string
---@field w number Collision width
---@field h number Collision height
---@field x number x origin 
---@field y number y origin
---@field size number?
---@field extent_w number Half of width
---@field extent_h number Half of height

---@type table<string, table<string, EntityStruct>>
local entity_cache = {}

---@param entity_name string
---@param quality_name? string
---@return EntityStruct
function mpp_util.entity_struct(entity_name, quality_name)
	quality_name = script.feature_flags.quality and quality_name or "normal"
	local quality_table = entity_cache[quality_name]
	if quality_table then
		local cached_struct = quality_table[entity_name]
		if cached_struct then return cached_struct end
	else
		entity_cache[quality_name] = {}
	end
	
	---@diagnostic disable-next-line: missing-fields
	local struct = {} --[[@as EntityStruct]]
	local proto = prototypes.entity[entity_name]
	local flags = proto.flags or {}

	local cbox = proto.collision_box
	local cbox_tl, cbox_br = cbox.left_top, cbox.right_bottom
	local cw, ch = cbox_br.x - cbox_tl.x, cbox_br.y - cbox_tl.y
	struct.name = entity_name
	struct.type = proto.type
	struct.w, struct.h = ceil(cw), ceil(ch)
	struct.size = max(struct.w, struct.h)
	struct.x = struct.w / 2 - 0.5
	struct.y = struct.h / 2 - 0.5
	struct.extent_w, struct.extent_h = struct.w / 2, struct.h / 2
	struct.filtered = flags and logic_any(
		not flags["player-creation"],
		flags["hidden"],
		flags["not-blueprintable"],
		flags["not-deconstructable"],
		struct.w == 0,
		struct.h == 0
	)

	entity_cache[quality_name][entity_name] = struct
	return struct
end

---@param struct EntityStruct
---@param direction defines.direction
---@return number, number, number, number
function mpp_util.transpose_struct(struct, direction)
	if direction == NORTH or direction == SOUTH then
		return struct.x, struct.y, struct.w, struct.h
	end
	return struct.y, struct.x, struct.h, struct.w
end

---A mining drill's origin (0, 0) is the top left corner
---The spawn location is (x, y), rotations need to rotate around
---@class MinerStruct : EntityStruct
---@field size number Physical miner size
---@field size_sq number Size squared
---@field symmetric boolean
---@field parity (-1|0) Parity offset for even sized drills, -1 when even
---@field resource_categories table<string, boolean>
---@field radius float Mining area reach
---@field area number Full coverage span of the miner
---@field real_area number Tooltip display area
---@field area_sq number Squared area
---@field outer_span number Lenght between physical size and end of radius
---@field module_inventory_size number?
---@field middle number "Center" x position
---@field drop_pos MapPosition Raw drop position
---@field rotation_bump defines.direction How much to pre-rotate mining drill to have a north facing drill
---@field out_x integer Resource drop position x
---@field out_y integer Resource drop position y
---@field extent_negative number
---@field extent_positive number
---@field supports_fluids boolean
---@field oversized boolean Is mining drill oversized
---@field pipe_left table<defines.direction, number> Y height on left side
---@field pipe_right table<defines.direction, number> Y height on right side
---@field pipe_back table<defines.direction, number[]>
---@field output_rotated table<defines.direction, MapPosition> Rotated output positions in reference to (0, 0) origin
---@field power_source_tooltip (string|table)?
---@field wrong_parity number Does miner have a wrong parity between size and area
---@field mining_speed number
---@field uses_force_mining_productivity_bonus boolean

---@type table<string, MinerStruct>
local miner_struct_cache = {}
local miner_struct_bp_cache = {}

---Calculates values for drill sizes and extents
---@param mining_drill_name string
---@param for_blueprint? boolean Don't do rotation fixing
---@return MinerStruct
function mpp_util.miner_struct(mining_drill_name, for_blueprint)
	if for_blueprint then
		local cached = miner_struct_bp_cache[mining_drill_name]
		if cached then return cached end
	else
		local cached = miner_struct_cache[mining_drill_name]
		if cached then return cached end
	end

	local miner_proto = prototypes.entity[mining_drill_name]

	local miner = table.deepcopy(mpp_util.entity_struct(mining_drill_name)) --[[@as MinerStruct]]
	miner.mining_speed = miner_proto.mining_speed
	miner.uses_force_mining_productivity_bonus = miner_proto.uses_force_mining_productivity_bonus
	
	if miner.w ~= miner.h then
		-- we have a problem ?
	end
	miner.size_sq = miner.size ^ 2
	miner.symmetric = miner.size % 2 == 1
	miner.parity = miner.size % 2 - 1
	miner.wrong_parity = 0
	miner.radius = miner_proto.mining_drill_radius
	miner.area = ceil(miner.radius * 2)
	miner.real_area = miner.area
	if miner.parity == 0 and miner.area % 2 == 0 then
		miner.radius = miner.radius - 0.5
		miner.area = ceil(miner.radius * 2)
		-- miner.wrong_parity = 1
		-- miner.outer_span = floor((miner.area - miner.size) / 2)
	end
	miner.area_sq = miner.area ^ 2
	miner.outer_span = floor((miner.area - miner.size) / 2)
	miner.resource_categories = miner_proto.resource_categories
	miner.name = miner_proto.name
	miner.module_inventory_size = miner_proto.module_inventory_size or 0
	miner.extent_negative = -miner.outer_span
	miner.extent_positive = miner.extent_negative + miner.area - 1
	miner.middle = floor(miner.size / 2) + miner.parity

	miner.filtered = miner.filtered
		or miner.area < miner.size
		or mpp_util.protype_has_script_create_effect(miner_proto)

	local vector = miner_proto.vector_to_place_result --[[@as Vector]]

	local rotation_bump = NORTH --[[@as defines.direction]]
	if not for_blueprint and vector then
		local span = miner.size / 2
		local mx, my = vector[1], vector[2]
		
		if mx < -span then
			miner.rotation_bump = WEST
		elseif mx > span then
			miner.rotation_bump = EAST
		elseif my > span then
			miner.rotation_bump = SOUTH
		else
			miner.rotation_bump = NORTH
		end
	end
	rotation_bump = miner.rotation_bump or rotation_bump
	
	if vector then
		miner.drop_pos = {x=vector[1], y=vector[2], vector[1], vector[2]}
		miner.out_x = floor(vector[1]+miner.w/2)
		miner.out_y = floor(vector[2]+miner.h/2)
	else
		miner.filtered = true
		miner.drop_pos = {x=0, y=0}
		miner.out_x, miner.out_y = 0, 0
	end
	
	-- terrifying redefine to fix misbehaving drills
	---@diagnostic disable-next-line: redefined-local
	local NORTH = clamped_rotation(NORTH, rotation_bump)
	---@diagnostic disable-next-line: redefined-local
	local EAST = clamped_rotation(EAST, rotation_bump)
	---@diagnostic disable-next-line: redefined-local
	local SOUTH = clamped_rotation(SOUTH, rotation_bump)
	---@diagnostic disable-next-line: redefined-local
	local WEST = clamped_rotation(WEST, rotation_bump)
	
	local output_rotated = {}
	do
		local function rot(x, y, dir)
			local out_x, out_y = rotate(x, y, dir)
			return floor(miner.w / 2 + out_x), floor(miner.h / 2 + out_y)
		end
		output_rotated[NORTH] = {rot(vector[1], vector[2], NORTH-EAST)}
		output_rotated[EAST] = {rot(vector[1], vector[2], EAST-EAST)}
		output_rotated[SOUTH] = {rot(vector[1], vector[2], SOUTH-EAST)}
		output_rotated[WEST] = {rot(vector[1], vector[2], WEST-EAST)}
		
		output_rotated[NORTH].x, output_rotated[NORTH].y = output_rotated[NORTH][1], output_rotated[NORTH][2]
		output_rotated[SOUTH].x, output_rotated[SOUTH].y = output_rotated[SOUTH][1], output_rotated[SOUTH][2]
		output_rotated[WEST].x, output_rotated[WEST].y = output_rotated[WEST][1], output_rotated[WEST][2]
		output_rotated[EAST].x, output_rotated[EAST].y = output_rotated[EAST][1], output_rotated[EAST][2]
		miner.output_rotated = output_rotated
	end
	
	--pipe height stuff
	if miner_proto.fluidbox_prototypes and #miner_proto.fluidbox_prototypes > 0 then
		local connections = miner_proto.fluidbox_prototypes[1].pipe_connections

		for _, conn in pairs(connections) do
			---@cast conn PipeConnectionDefinition
			if conn.direction == WEST and miner.pipe_left == nil then
				local pos = floor(conn.positions[1].y) + floor(miner.size/2)
				miner.pipe_left = {
					[NORTH] = pos,
					[EAST] = pos,
					[SOUTH] = miner.size - pos-1,
					[WEST] = miner.size - pos-1,
				}
			elseif conn.direction == EAST and miner.pipe_right == nil then
				local pos = floor(conn.positions[1].y) + floor(miner.size/2)
				miner.pipe_right = {
					[NORTH] = pos,
					[EAST] = pos,
					[SOUTH] = miner.size - pos-1,
					[WEST] = miner.size - pos-1,
				}
			elseif conn.direction == SOUTH and miner.pipe_back == nil then
				local pos = floor(conn.positions[1].x) + floor(miner.size/2)
				miner.pipe_back = {
					[NORTH] = {pos},
					[EAST] = {pos},
					[SOUTH] = {miner.size - pos-1},
					[WEST] = {miner.size - pos-1},
				}
			elseif conn.direction == SOUTH then
				local pos = conn.positions[1].x + floor(miner.size/2)
				table.insert(miner.pipe_back[NORTH], pos)
				table.insert(miner.pipe_back[EAST], pos)
				table.insert(miner.pipe_back[SOUTH], miner.size - pos-1)
				table.insert(miner.pipe_back[WEST], miner.size - pos-1)
			end
		end

		-- miner.pipe_left = floor(miner.size / 2) + miner.parity
		-- miner.pipe_right = floor(miner.size / 2) + miner.parity
		
		miner.supports_fluids = miner.pipe_left ~= nil and miner.pipe_right ~= nil
	else
		miner.supports_fluids = false
	end

	-- If larger than a large mining drill
	miner.oversized = miner.size > 7 or miner.area > 13

	if miner_proto.electric_energy_source_prototype then
		miner.power_source_tooltip = {
			"", " [img=tooltip-category-electricity] ",
			{"tooltip-category.consumes"}, " ", {"tooltip-category.electricity"},
		}
	elseif miner_proto.burner_prototype then
		local burner = miner_proto.burner_prototype --[[@as LuaBurnerPrototype]]
		if burner.fuel_categories["nuclear"] then
			miner.power_source_tooltip = {
				"", "[img=tooltip-category-nuclear]",
				{"tooltip-category.consumes"}, " ", {"fuel-category-name.nuclear"},
			}
		else
			miner.power_source_tooltip = {
				"", "[img=tooltip-category-chemical]",
				{"tooltip-category.consumes"}, " ", {"fuel-category-name.chemical"},
			}
		end
	elseif miner_proto.fluid_energy_source_prototype then
		miner.power_source_tooltip = {
			"", "[img=tooltip-category-water]",
			{"tooltip-category.consumes"}, " ", {"tooltip-category.fluid"},
		}
	end

	if for_blueprint then
		miner_struct_bp_cache[mining_drill_name] = miner
	else
		miner_struct_cache[mining_drill_name] = miner
	end
	return miner
end

---@class PoleStruct : EntityStruct
---@field name string
---@field place boolean Flag if poles are to be actually placed
---@field size number
---@field radius number Power supply reach
---@field supply_width number Full width of supply reach
---@field wire number Max wire distance
---@field supply_area_distance number
---@field extent_negative number Negative extent of the supply reach

---@type table<string, table<string, PoleStruct>>
local pole_struct_cache = {}

---@param pole_name string
---@param quality_name? string
---@return PoleStruct
function mpp_util.pole_struct(pole_name, quality_name)
	quality_name = script.feature_flags.quality and quality_name or "normal"
	
	local quality_table = pole_struct_cache[quality_name]
	if quality_table then
		local cached_struct = quality_table[pole_name]
		if cached_struct then return cached_struct end
	else
		pole_struct_cache[quality_name] = {}
	end

	local pole_proto = prototypes.entity[pole_name]
	if not pole_proto then
		return {
			place = false, -- nonexistent pole, use fallbacks and don't place
			size = 1,
			supply_width = 7,
			radius = 3.5,
			wire = 9,
			supply_area_distance = 3.5,
		}
	end
	local pole = mpp_util.entity_struct(pole_name, quality_name) --[[@as PoleStruct]]

	local radius = pole_proto.get_supply_area_distance(quality_name)
	pole.supply_area_distance = radius
	pole.supply_width = floor(radius * 2)
	pole.radius = pole.supply_width / 2
	pole.wire = pole_proto.get_max_wire_distance(quality_name)

	pole.filtered = logic_any(
		pole.filtered,
		radius < 0.5,
		pole.wire < 1
	)

	-- local distance = beacon_proto.supply_area_distance
	-- beacon.area = beacon.size + distance * 2
	-- beacon.extent_negative = -distance

	local extent = (pole.supply_width - pole.size) / 2

	pole.extent_negative = -extent

	pole_struct_cache[quality_name][pole_name] = pole
	return pole
end

---@class BeaconStruct : EntityStruct
---@field extent_negative number
---@field area number

local beacon_cache = {}

---@param beacon_name string
---@return BeaconStruct
function mpp_util.beacon_struct(beacon_name)
	local cached_struct = beacon_cache[beacon_name]
	if cached_struct then return cached_struct end

	local beacon_proto = prototypes.entity[beacon_name]
	local beacon = mpp_util.entity_struct(beacon_name) --[[@as BeaconStruct]]

	local distance = beacon_proto.get_supply_area_distance();
	beacon.area = beacon.size + distance * 2
	beacon.extent_negative = -distance

	beacon_cache[beacon_name] = beacon
	return beacon
end


local hardcoded_pipes = {}

---@param pipe_name string Name of the normal pipe
---@return string|nil, LuaEntityPrototype|nil
function mpp_util.find_underground_pipe(pipe_name)
	if hardcoded_pipes[pipe_name] then
		return hardcoded_pipes[pipe_name], prototypes.entity[hardcoded_pipes[pipe_name]]
	end
	local ground_name = pipe_name.."-to-ground"
	local ground_proto = prototypes.entity[ground_name]
	if ground_proto then
		return ground_name, ground_proto
	end
	return nil, nil
end

function mpp_util.revert(gx, gy, direction, x, y, w, h)
	local tx, ty = coord_revert[direction](x-.5, y-.5, w, h)
	return {gx + tx+.5, gy + ty + .5}
end

---@param gx any
---@param gy any
---@param direction any
---@param x any
---@param y any
---@param w any
---@param h any
---@return unknown
---@return unknown
function mpp_util.revert_ex(gx, gy, direction, x, y, w, h)
	local tx, ty = coord_revert[direction](x-.5, y-.5, w, h)
	return gx + tx+.5, gy + ty + .5
end

function mpp_util.revert_world(gx, gy, direction, x, y, w, h)
	local tx, ty = coord_revert[direction](x-.5, y-.5, w, h)
	return {gx + tx, gy + ty}
end

---Creates a local to world coord coverter delegate
---@param C Coords
---@param direction DirectionString
---@return fun(x: number, y: number, sx?: number, sy?: number): number, number
function mpp_util.reverter_delegate(C, direction)
	local gx, gy, w, h = C.gx, C.gy, C.tw, C.th
	local converter = coord_revert[direction]
	return function(x, y, sx, sy)
		local tx, ty = converter(x-.5, y-.5, w, h)
		return gx + tx + (sx or 0), gy + ty + (sy or 0)
	end
end

---@class BeltStruct
---@field name string
---@field related_underground_belt string?
---@field underground_reach number?
---@field speed number

---@type table<string, BeltStruct>
local belt_struct_cache = {}

function mpp_util.belt_struct(belt_name)
	local cached = belt_struct_cache[belt_name]
	if cached then return cached end

	---@diagnostic disable-next-line: missing-fields
	local belt = {} --[[@as BeltStruct]]
	local belt_proto = prototypes.entity[belt_name]

	belt.name = belt_name

	local related = belt_proto.related_underground_belt
	if related then
		belt.related_underground_belt = related.name
		belt.underground_reach = related.max_underground_distance
	else
		local match_attempts = {
			["transport"]	= "underground",
			["belt"]		= "underground-belt",
		}
		for pattern, replacement in pairs(match_attempts) do
			local new_name = string.gsub(belt_name, pattern, replacement)
			if new_name == belt_name then goto continue end
			related = prototypes.entity[new_name]
			if related then
				belt.related_underground_belt = new_name
				belt.underground_reach = related.max_underground_distance
				break
			end
			::continue::
		end
	end
	belt.speed = belt_proto.belt_speed * 60 * 4

	belt_struct_cache[belt_name] = belt
	return belt
end

---@class InserterStruct : EntityStruct
---@field pickup_rotated table<defines.direction, Vector>
---@field drop_rotated table<defines.direction, Vector>

---@type table<string, InserterStruct>
local inserter_struct_cache = {}

function mpp_util.inserter_struct(inserter_name)
	local cached = inserter_struct_cache[inserter_name]
	if cached then return cached end

	local inserter_proto = prototypes.entity[inserter_name]
	local inserter = mpp_util.entity_struct(inserter_name) --[[@as InserterStruct]]

	---@return table<defines.direction, Vector>
	local function rotations(_x, _y)
		_x, _y = floor(_x), floor(_y)
		return {
			[NORTH]	= { x =  _x, y =  _y},
			[EAST]	= { x = -_y, y = -_x},
			[SOUTH]	= { x = -_x, y = -_y},
			[WEST]	= { x =  _y, y =  _x},
		}
	end

	local pickup_position = inserter_proto.inserter_pickup_position --[[@as Vector]]
	local drop_position = inserter_proto.inserter_drop_position --[[@as Vector]]
	inserter.pickup_rotated = rotations(pickup_position[1], pickup_position[2])
	inserter.drop_rotated = rotations(drop_position[1], drop_position[2])

	inserter_struct_cache[inserter_name] = inserter
	return inserter
end

---@param ent BlueprintEntityEx
---@return Vector.0, Vector.0
function mpp_util.inserter_hand_locations(ent)
	local inserter = mpp_util.inserter_struct(ent.name);
	local pickup, drop = ent.pickup_position, ent.drop_position
	if pickup then
		pickup = {x = floor((pickup.x or pickup[1])+.5), y = floor((pickup.y or pickup[2])+.5)}
	else
		pickup = inserter.pickup_rotated[ent.direction or NORTH]
	end
	if drop then
		drop = {x = floor((drop.x or drop[1])+.5), y = floor((drop.y or drop[2])+.5)}
	else
		drop = inserter.drop_rotated[ent.direction or NORTH]
	end

	return pickup, drop
end

---@class PoleSpacingStruct
---@field capable_span boolean
---@field pole_start number
---@field pole_step number
---@field lane_start number
---@field lane_step number
---@field lamp_alter boolean
---@field full_miner_width number Drill count times drill width
---@field pattern List<number> Stepping when layout is incapable
---@field drill_output_positions table<number, true>

---Calculates needed power pole count
---@param state SimpleState
---@param miner_count number
---@param lane_count number
---@return PoleSpacingStruct
function mpp_util.calculate_pole_coverage_interleaved(state, miner_count, lane_count, x_shift)
	local m = mpp_util.miner_struct(state.miner_choice)
	local p = mpp_util.pole_struct(state.pole_choice, state.pole_quality_choice)
	x_shift = x_shift or 0
	
	---@type PoleSpacingStruct
	local cov = {
		capable_span = false,
		lane_start = 1,
		lane_step = 1,
		pole_start = 1,
		pole_step = 1,
		lamp_alter = false,
		full_miner_width = miner_count * m.size,
		pattern = {},
		drill_output_positions = {},
	}

	-- Shift subtract
	local covered_miners = ceil(p.supply_width / m.size)
	local stride = covered_miners * m.size

	local capable_span = false
	if floor(p.wire) >= stride and m.size ~= p.supply_width then
		capable_span = true
	else
		stride = floor(p.wire)
	end
	cov.capable_span = capable_span

	local pole_start = m.size-1
	
	if capable_span then
		local initial_span = 1+ceil((p.radius-.5) / m.size)
		local unused_span = ceil((p.radius - (m.size-.5)) / m.size)
		local clipping = math.ceil(m.size / (p.radius-.5))
		local divisor, remainder = math.divmod(max(0, miner_count-initial_span), covered_miners)
		
		if remainder > 0 and remainder <= unused_span then
			pole_start = pole_start + m.size * min(abs(remainder), abs(unused_span))
		-- elseif remainder > 0 then
		-- 	pole_start = m.size * min(remainder, unused_span) - 1
		-- elseif covered_miners % 2 == 0 then
		-- 	pole_start = m.size * 2 - 1
		end
		
		local output_north = m.output_rotated[NORTH]
		local output_south = m.output_rotated[SOUTH]
		local drill_output_positions = {}
		for i = 1, miner_count do
			local pos1 = x_shift + (i-1) * m.size+output_north[1]
			local pos2 = x_shift + (i-1) * m.size+output_south[1]
			drill_output_positions[pos1] = true
			drill_output_positions[pos2] = true
			if pos1 + 2 == pos2 then
				drill_output_positions[pos1+1] = true
			elseif pos2 + 2 == pos1 then
				drill_output_positions[pos2+1] = true
			end
		end
		cov.drill_output_positions = drill_output_positions
	else
		local pattern = List()
		
		local output_north = m.output_rotated[NORTH]
		local output_south = m.output_rotated[SOUTH]
		
		local current_x = pole_start
		-- if miner_count > 1 then
		-- 	current_x = current_x + 1
		-- end
		local start_x = current_x
		local max_step = min(floor(p.radius * 2) + m.size - 1, floor(p.wire))
		local drill_output_positions = {}
		for i = 1, miner_count do
			local pos1 = x_shift + (i-1) * m.size+output_north[1]
			local pos2 = x_shift + (i-1) * m.size+output_south[1]
			drill_output_positions[pos1] = true
			drill_output_positions[pos2] = true
			if pos1 + 2 == pos2 then
				drill_output_positions[pos1+1] = true
			elseif pos2 + 2 == pos1 then
				drill_output_positions[pos2+1] = true
			end
		end
		
		local total_span = miner_count * m.size
		local previous_x = current_x
		pattern:push(current_x)
		while current_x < total_span do
			previous_x = current_x
			local found_position = false
			for ix = min(total_span, current_x + max_step), min(current_x + 1, total_span), -1 do
				if drill_output_positions[x_shift + ix] == nil and ix < miner_count* m.size then
					found_position, current_x = true, ix
					break
				end
			end
			-- TODO: there might be redundant power poles on last mining drill
			if not found_position then
				break
			else
				pattern:push(current_x)
			end
			if current_x + p.radius * 2 >= total_span then
				break
			end
		end
		cov.pattern = pattern
		cov.drill_output_positions = drill_output_positions
		
		--[[ debug visualisation
			local converter = mpp_util.reverter_delegate(state.coords, state.direction_choice)
			for x, _ in pairs(drill_output_positions) do
				for _, belt in pairs(state.belts) do
					rendering.draw_circle{
						surface = state.surface,
						target = {converter(x+.5, belt.y+.5)},
						filled = false,
						color = {1, 1, 1},
						radius = 0.4, width = 6,
					}
				end
			end
		-- ]]
	end

	cov.pole_start = pole_start
	cov.pole_step = stride
	cov.full_miner_width = miner_count * m.size

	cov.lane_start = 0
	cov.lane_step = m.size * 2 + 2
	local lane_pairs = floor(lane_count / 2)
	local lane_coverage = ceil((p.radius-1) / (m.size + 0.5))
	if lane_coverage > 1 then
		cov.lane_start = (ceil(lane_pairs / 2) % 2 == 0 and 1 or 0) * (m.size * 2 + 2)
		cov.lane_step = lane_coverage * (m.size * 2 + 2)
	end

	cov.lamp_alter = stride < 9 and true or false

	return cov
end

---Calculates the spacing for belt interleaved power poles
---@param state State
---@param miner_count number
---@param lane_count number
---@return PoleSpacingStruct
function mpp_util.calculate_pole_coverage_simple(state, miner_count, lane_count)
	local m = mpp_util.miner_struct(state.miner_choice)
	local p = mpp_util.pole_struct(state.pole_choice, state.pole_quality_choice)
	
	---@type PoleSpacingStruct
	local cov = {
		capable_span = false,
		lane_start = 1,
		lane_step = 1,
		pole_start = 1,
		pole_step = 1,
		lamp_alter = false,
		full_miner_width = miner_count * m.size,
		pattern = {},
		bad_positions = {},
	}

	-- Shift subtract
	local covered_miners = ceil(p.supply_width / m.size)
	local miner_step = covered_miners * m.size

	-- Special handling to shift back small radius power poles so they don't poke out
	local capable_span = false

	if floor(p.wire) >= miner_step then
		capable_span = true
	else
		miner_step = floor(p.wire)
	end
	cov.capable_span = capable_span

	local pole_start = m.middle
	if capable_span then
		if covered_miners % 2 == 0 then
			pole_start = m.size-1
		elseif miner_count % covered_miners == 0 and miner_step ~= m.size then
			pole_start = pole_start + m.size
		end
	end

	cov.pole_start = pole_start
	cov.pole_step = miner_step

	cov.lane_start = 0
	cov.lane_step = m.size * 2 + 2
	local lane_pairs = floor(lane_count / 2)
	local lane_coverage = ceil((p.radius-1) / (m.size + 0.5))
	if lane_coverage > 1 then
		cov.lane_start = (ceil(lane_pairs / 2) % 2 == 0 and 1 or 0) * (m.size * 2 + 2)
		cov.lane_step = lane_coverage * (m.size * 2 + 2)
	end

	return cov
end

---@param t table
---@param func function
---@return true | nil
function mpp_util.table_find(t, func)
	for k, v in pairs(t) do
		if func(v) then return true end
	end
end

---@param t table
---@param m LuaObject 
function mpp_util.table_mapping(t, m)
	for k, v in pairs(t) do
		if k == m then return v end
	end
end

---@param player LuaPlayer
---@param blueprint LuaItemStack
function mpp_util.validate_blueprint(player, blueprint)
	if not blueprint.blueprint_snap_to_grid then
		player.print({"", "[color=red]", {"mpp.msg_blueprint_undefined_grid"}, "[/color]"}, {sound_path="utility/cannot_build"})
		return false
	end

	local miners, _ = enums.get_available_miners()
	
	local cost = blueprint.cost_to_build
	local drills = {}
	-- for name, drill in pairs(miners) do
	-- 	if cost[name] then
	-- 		drills[#drills+1] = drill.localised_name
	-- 	end
	-- end

	for _, price in ipairs(cost) do
		---@cast price ItemCountWithQuality
		if miners[price.name] then
			drills[#drills+1] = miners[price.name].localised_name
		end
	end

	if #drills > 1 then
		local msg = {"", "[color=red]", {"mpp.msg_blueprint_different_miners"}, "[/color]" }
		for _, name in pairs(drills) do
			msg[#msg+1] = "\n"
			msg[#msg+1] = name
		end
		player.print(msg, {sound_path="utility/cannot_build"})
		return false
	elseif #drills == 0 then
		player.print({"", "[color=red]", {"mpp.msg_blueprint_no_miner"}, "[/color]"}, {sound_path="utility/cannot_build"})
		return false
	end
	
	return true
end

function mpp_util.keys_to_set(...)
	local set, temp = {}, {}
	for _, t in pairs{...} do
		for k, _ in pairs(t) do
			temp[k] = true
		end
	end
	for k, _  in pairs(temp) do
		set[#set+1] = k
	end
	table.sort(set)
	return set
end

function mpp_util.list_to_keys(t)
	local temp = {}
	for _, k in ipairs(t) do
		temp[k] = true
	end
	return temp
end

---@param bp LuaItemStack
function mpp_util.blueprint_label(bp)
	local label = bp.label
	if label then
		if #label > 30 then
			return string.sub(label, 0, 28) .. "...", label
		end
		return label
	else
		return {"", {"gui-blueprint.unnamed-blueprint"}, " ", bp.item_number}
	end
end

---@class CollisionBoxProperties
---@field w number
---@field h number
---@field near number
---@field [1] boolean
---@field [2] boolean

-- LuaEntityPrototype#tile_height was added in 1.1.64, I'm developing on 1.1.61
local even_width_memoize = {}
---Gets properties of entity collision box
---@param name string
---@return CollisionBoxProperties
function mpp_util.entity_even_width(name)
	local check = even_width_memoize[name]
	if check then return check end
	local proto = prototypes.entity[name]
	local cbox = proto.collision_box
	local cbox_tl, cbox_br = cbox.left_top, cbox.right_bottom
	local cw, ch = cbox_br.x - cbox_tl.x, cbox_br.y - cbox_tl.y
	local w, h = ceil(cw), ceil(ch)
	local res = {w % 2 ~= 1, h % 2 ~= 1, w=w, h=h, near=floor(w/2)}
	even_width_memoize[name] = res
	return res
end

--- local EAST, NORTH, SOUTH, WEST, ROTATION = mpp_util.directions()
function mpp_util.directions()
	return
		defines.direction.east,
		defines.direction.north,
		defines.direction.south,
		defines.direction.west,
		table_size(defines.direction)
end

mpp_util.direction_to_string = {
	[NORTH] = "north",
	[EAST] = "east",
	[SOUTH] = "south",
	[WEST] = "west",
}

---@param player_index uint
---@return uint
function mpp_util.get_display_duration(player_index)
	return settings.get_player_settings(player_index)["mpp-lane-filling-info-duration"].value * 60 --[[@as uint]]
end

--[[
/c game.player.mod_settings["mpp-dump-heuristics-data"] = {value=true}
]]

---@param player_index uint
---@return boolean
function mpp_util.get_dump_state(player_index)
	return settings.get_player_settings(player_index)["mpp-dump-heuristics-data"].value --[[@as boolean]]
end

---Pads tooltip contents to not overlap with cursor icon
---@param ... unknown
---@return table
function mpp_util.wrap_tooltip(...)
	return select(1, ...) and {"", "     ", ...} or nil
end

function mpp_util.tooltip_entity_not_available(check, arg)
	if check then
		return mpp_util.wrap_tooltip(arg, "\n[color=red]", {"mpp.label_not_available"}, "[/color]")
	end
	return mpp_util.wrap_tooltip(arg)
end

---@param c1 Coords
---@param c2 Coords
function mpp_util.coords_overlap(c1, c2)
	local x = (c1.ix1 <= c2.ix1 and c2.ix1 <= c1.ix2) or (c1.ix1 <= c2.ix2 and c2.ix2 <= c1.ix2) or
		(c2.ix1 <= c1.ix1 and c1.ix1 <= c2.ix2) or (c2.ix1 <= c1.ix2 and c1.ix2 <= c2.ix2)
	local y = (c1.iy1 <= c2.iy1 and c2.iy1 <= c1.iy2) or (c1.iy1 <= c2.iy2 and c2.iy2 <= c1.iy2) or
		(c2.iy1 <= c1.iy1 and c1.iy1 <= c2.iy2) or (c2.iy1 <= c1.iy2 and c1.iy2 <= c2.iy2)
	return x and y
end

---Checks if thing (entity) should never appear as a choice
---@param thing LuaEntityPrototype|MinerStruct
---@return boolean|nil
function mpp_util.check_filtered(thing)
	return
		blacklist[thing.name]
		or not thing.items_to_place_this
		or thing.hidden
end

---@param player_data any
---@param category MppSettingSections
---@param name string
function mpp_util.set_entity_hidden(player_data, category, name, value)
	player_data.filtered_entities[category..":"..name] = value
end

function mpp_util.get_entity_hidden(player_data, category, name)
	return player_data.filtered_entities[category..":"..name]
end

---Checks if a player has hidden the entity choice
---@param player_data any
---@param category MppSettingSections
---@param thing MinerStruct|LuaEntityPrototype|LuaQualityPrototype
---@return false
function mpp_util.check_entity_hidden(player_data, category, thing)
	return (not player_data.entity_filtering_mode and player_data.filtered_entities[category..":"..thing.name])
end

---@param player_data PlayerData
function mpp_util.update_undo_button(player_data)
	
	local enabled = false
	local undo_button = player_data.gui.undo_button
	
	if not undo_button or undo_button.valid ~= true then return end
	
	local last_state = player_data.last_state
	
	if last_state then
		--local duration = mpp_util.get_display_duration(last_state.player.index)
		enabled = enabled or (last_state and last_state._collected_ghosts and #last_state._collected_ghosts > 0 and game.tick < player_data.tick_expires)
	end

	undo_button.enabled = enabled
	undo_button.sprite = enabled and "mpp_undo_enabled" or "mpp_undo_disabled"
	undo_button.tooltip = mpp_util.wrap_tooltip(enabled and {"controls.undo"} or {"", {"controls.undo"}," (", {"gui.not-available"}, ")"})
end

---@param prototype LuaEntityPrototype
function mpp_util.protype_has_script_create_effect(prototype)
	local create_effect = prototype.created_effect
	if create_effect == nil then return false end

	for _, effect in pairs(create_effect) do
		if effect.action_delivery == nil then return false end

		for _, delivery in pairs(effect.action_delivery) do
			if delivery.type == "instant" then
				if delivery.source_effects then
					for _, source_effect in pairs(delivery.source_effects) do
						if source_effect.type == "script" then
							return true
						end
					end
				end
				if delivery.target_effects then
					for _, source_effect in pairs(delivery.target_effects) do
						if source_effect.type == "script" then
							return true
						end
					end
				end
			end
		end

	end
	return false
end

---@type SettingValueEntry[]
local quality_listing_cache

---@return SettingValueEntry[]
function mpp_util.quality_list()
	if quality_listing_cache then return quality_listing_cache end
	
	quality_listing_cache = {}
	for name, quality in pairs(prototypes.quality) do
		if quality.hidden then goto skip_quality end
		quality_listing_cache[#quality_listing_cache+1] = {
			value = name,
			icon = "quality/"..name,
			filterable = true,
			tooltip = {"quality-name."..name},
		}
		::skip_quality::
	end
	
	return quality_listing_cache
end

---@class QualityStruct
---@field name string
---@field color Color
---@field text_color string
---@field localised_name LocalisedString

---@type table<string, QualityStruct>
local quality_cache = {}
do
	for name, quality in pairs(prototypes.quality) do
		local color = quality.color
		local a, r, g, b = color.a, color.r, color.g, color.b
		a = max(r,g,b)
		a, r, g, b = floor(a*255), floor(r*255), floor(g*255), floor(b*255)
		quality_cache[name] = {
			name = name,
			localised_name = quality.localised_name,
			color = color,
			text_color = ("#%02x%02x%02x%02x"):format(a,r,g,b),
		}
	end
end

if script.feature_flags.quality and #prototypes.quality > 2 then
	---@param name LocalisedString
	---@param quality_name string
	---@return LocalisedString
	function mpp_util.entity_name_with_quality(name, quality_name)
		local quality = quality_cache[quality_name]
		return {"", "[font=default-bold]", name, " [color="..quality.text_color.."](", quality.localised_name, ")[/color][/font]"}
	end
else
	---@param name LocalisedString
	---@param quality_name string
	---@return LocalisedString
	function mpp_util.entity_name_with_quality(name, quality_name)
		return name
	end
end

return mpp_util
